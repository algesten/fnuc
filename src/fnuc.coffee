# core
I = (a) -> a
builtin   = I.bind.bind I.call
_toString = builtin Object::toString

# generic -------------------------
shallow = (a) ->
    return a unless a # null, undefined, false, '', 0
    r = null
    if (t = type(a)) in ['string', 'number', 'boolean', 'symbol']
        r = a
    else if t == 'array'
        r = []
        r[i] = a[i] for i in [0...a.length] by 1
    else if t == 'date'
        r = new Date(a.getTime())
    else if isplain(a)
        r = merge {}, a
    else
        throw new TypeError "Can't shallow " + a
    return r

clone = (a) ->
    return a unless a # null, undefined, false, '', 0
    s = shallow(a)
    if type(a) == 'array'
        s[i] = clone(s[i]) for i in [0...a.length] by 1
    else if isplain(s)
        s[k] = clone(v) for k, v of s
    return s

# type -----------------------------
isplain = (o) -> !!o && typeof o == 'object' && o.constructor == Object
isdef   = (o) -> `o != null`
type    = (a) -> _toString(a)[8...-1].toLowerCase()

# object ----------------------------
merge   = (t, os...) -> t[k] = v for k,v of o for o in os; t
mixin   = (os...)    -> merge {}, os...

# array/string 1
head    = (a) -> a[0]
tail    = (a) -> a[1..]
last    = (a) -> a[a.length-1]

# fn --------------------------------
arity = do ->
    nary = (n, fn) ->
        switch n
            when 0  then () -> fn arguments...
            when 1  then (a) -> fn arguments...
            when 2  then (a,b) -> fn arguments...
            when 3  then (a,b,c) -> fn arguments...
            when 4  then (a,b,c,d) -> fn arguments...
            when 5  then (a,b,c,d,e) -> fn arguments...
            when 6  then (a,b,c,d,e,f) -> fn arguments...
            when 7  then (a,b,c,d,e,f,g) -> fn arguments...
            when 8  then (a,b,c,d,e,f,g,h) -> fn arguments...
            when 9  then (a,b,c,d,e,f,g,h,i) -> fn arguments...
            when 10 then (a,b,c,d,e,f,g,h,i,j) -> fn arguments...
    (fn, n) ->
        if arguments.length == 1
            n = fn
            (fn) -> nary n, fn
        else
            nary n, fn

arityof = (f) -> return f.length if typeof f == 'function'
unary   = arity 1
binary  = arity 2
ternary = arity 3

_defprop = (t, n, v) -> Object.defineProperty t, n, value: v; t

# n  - arity
# v  - true if we allow varargs. false to chop.
# f  - function to curry
# as - arguments so far
ncurry = (n, v, f, as=[]) ->
    l = n - as.length
    nf = arity(l) (bs...) ->
        cs = (if bs.length <= l then bs else (if v then bs else bs[0...l])).concat as
        if cs.length < n then ncurry n, v, f, cs else f cs...
    _defprop nf, '__fnuc_curry', -> partialr f, as...

curry = (f) ->
    n = arityof(f)
    return f if (n < 2)
    nf = arity(n) (as...) -> if as.length < n then ncurry n, false, f, as else f as...
    _defprop nf, '__fnuc_curry', -> f

# not a mathematical uncurry, it just unwraps our own curry
uncurry = (f) -> if f.__fnuc_curry then f.__fnuc_curry() else f

partial = (f, as...) ->
    return f as... if (n = (arityof(f) - as.length)) <= 0
    arity(n) (bs...) -> f as.concat(bs)...
partialr = (f, as...) ->
    return f as... if (n = (arityof(f) - as.length)) <= 0
    arity(n) (bs...) -> f bs[0...n].concat(as)...

flip = (f) ->
    return f.__fnuc_flip if f.__fnuc_flip
    rewrap = if f.__fnuc_curry then curry else I
    g = (rewrap arity(arityof(f)) (as...) -> uncurry(f) as.reverse()...)
    _defprop g, '__fnuc_flip', f

compose  = (fs...) ->
    fs = _pliftall(fs)
    ncurry arityof(last fs), false, fold1 fs, (f, g) -> (as...) -> f g as...
pipe     = (fs...) ->
    fs = _pliftall(fs)
    ncurry arityof(head fs), false, foldr1 fs, (f, g) -> (as...) -> f g as...

converge = ncurry 3, true, (fs..., after) ->
    fs = _pliftall fs
    after = plift after
    ncurry apply(Math.max)(map fs, arityof), true, (args...) ->
        context = this
        after.apply context, map fs, (fn) -> fn.apply context, args

typeis   = curry (a,s) -> type(a) == s
tap      = curry (a, f) -> f(a); a                  # a, fn -> a
apply    = curry (args, fn) -> fn.apply this, args  # [a], fn -> fn(a0, a1, ..., az)
iif      = curry (c, t, f) ->
    arity(arityof(c)) plift (as...) -> if c(as...) then t?(as...) else f?(as...)
maybe    = (fn) ->
    unary plift (as...) -> fn as... if as.every isdef # (a -> b) -> a|null -> b|null
always   = (v) -> plift -> v
nth      = (n) -> (as...) -> as[n]
once = (fn) -> ran = ret = null; (as...) -> if ran then ret else (ran = true; ret = fn as...)


# array ----------------------------
all      = curry binary  builtin Array::every       # [a], fn -> Boolean
any      = curry binary  builtin Array::some        # [a], fn -> Boolean
contains = curry (as, a) -> index(as, a) >= 0       # [a], a -> b
concat   = (as...) -> [].concat as...
each     = curry binary  builtin Array::forEach     # [a], fn    -> undef
# 2015-09-05. Array.prototype.filter is significantly slower than this.
filter   = curry binary  (as, f) ->                 # [a], fn -> [a]
    r = []
    ri = -1
    (r[++ri] = v if f(v)) for v in as
    r
_filter = (as, f) -> # internal filter with v, i
    r = []
    ri = -1
    (r[++ri] = v if f(v, i)) for v, i in as
    r
_fold = (as, f, acc, arrInit) ->
    i = 0; len = as.length;
    acc = as[i++] if arrInit
    `for (;i < len; ++i) { acc = f(acc,as[i]) }`
    acc
_foldr = (as, f, acc, arrInit) ->
    i = as.length;
    acc = as[--i] if arrInit
    `while (i--) { acc = f(acc,as[i]) }`
    acc
# 2015-09-05. Array.prototype.reduce/reduceRight is significantly slower than this.
fold     = curry (as, f, v) -> _fold  as, f, v,    false # [a], fn, v -> *
fold1    = curry (as, f)    -> _fold  as, f, null, true  # [a], fn -> *
foldr    = curry (as, f, v) -> _foldr as, f, v,    false # [a], fn, v -> *
foldr1   = curry (as, f)    -> _foldr as, f, null, true  # [a], fn -> *
# 2015-09-05. Array.prototype.indexOf is slightly faster than this.
index    = curry binary (as, v, fr) ->                   # [a], a -> n
    len = as.length
    i = if fr then fr - 1 else -1
    `while (++i < len) { if (as[i] === v) return i }`
    -1
indexfn  = curry binary (as, fn, fr) ->                      # [a], (a->bool) -> n
    len = as.length
    i = if fr then fr - 1 else -1
    `while (++i < len) { if (fn(as[i])) return i }`
    -1
firstfn = curry binary (as, fn, fr) ->                       # [a], (a -> b) -> b
    r = null
    len = as?.length || 0
    return null unless len
    i = fr || 0
    `for (;i < len; ++i) { if (fn(r = as[i])) return r }`
    null
lastfn = curry binary (as, fn, fr) ->                        # [a], (a -> b) -> b
    r = null
    i = fr || (as?.length - 1)
    return null unless i < as?.length
    `for (;i >= 0; --i) { if (fn(r = as[i])) return r }`
    null
join     = curry binary  builtin Array::join        # [a], s -> s
# 2015-09-05. Array.prototype.map is significantly slower than this.
map      = curry (as, f) ->                         # [a], fn -> [a]
    r = Array(as.length); len = as.length; i = 0
    `for (;i < len; ++i) { r[i] = f(as[i]) }`
    r
reverse  = unary builtin Array::reverse             # [a] -> [a]
sort     = curry binary  builtin Array::sort        # [a] -> [a]
uniqfn   = curry (as, fn) ->                        # [a] -> [a]
    return as unless as
    fned = map as, fn
    _filter as, (v, i) -> fned.indexOf(fned[i]) == i
uniq     = (as) -> return as unless as; _filter as, (v, i) -> as.indexOf(v) == i # [a] -> [a]

# promise ---------------------------

plift = do ->

    # tests if p has .then
    isthenable = (p) ->
        return false unless p
        return false unless typeof p in ['object', 'function']
        return typeof p.then == 'function'

    # first thenable (if any), bound to its promise
    thenbind = (p) -> p.then.bind(p)
    firstthen = (as) ->
        t = firstfn(isthenable) as
        if t then thenbind(t) else null

    # :: (onrej) -> Promise (a -> b), (a or Promise a) -> Promise b
    promapply = (errfn) -> (pfn, parg) ->
        fn = null
        onacc = (arg) -> if errfn then arg else fn(arg)
        onrej = (err) -> if errfn then errfn(err) else throw err
        pfn.then (_fn) -> fn = _fn; parg
        .then onacc, onrej

    (f) ->
        return f if f.__fnuc_plift # already lifted?
        nf = arity(arityof(f)) (as...) ->
            t0 = firstthen as # false or a bound then-function
            if t0
                # curry function so we can do promapply per argument.
                currfn = ncurry(as.length, false, f)
                # always return curried function
                alws = -> currfn
                # rejected promises shortcuts the evaluation to
                # invoke fail handler with first failure
                failfn = if _ispfail(f) then once(f) else null
                foldr as, promapply(failfn), t0(alws, alws)
            else
                if _ispfail(f) then as?[0] else f as...
        _defprop nf, '__fnuc_plift', true

_pliftall = map(plift)

pfail = (f) -> plift _defprop(f, '__fnuc_fail', true)
_ispfail   = (fn) -> !!fn?.__fnuc_fail

# moar object
has     = curry (o, k) -> o.hasOwnProperty(k)
get     = curry (o, k) -> o[k]
set     = curry (o, k, v) -> o[k] = v; o
keys    = (o) -> Object.keys(o)
values  = (o) -> map (keys o), (k) -> o[k]
ofilter = curry (o, f) -> r = {}; r[k] = v for k, v of o when f(k,v); return r
evolve  = do ->
    omap    = curry (o, f) -> r = {}; r[k] = f(k,v) for k, v of o; return r
    curry (o, t) -> omap o, (k, v) -> if has(t,k) then t[k](v) else v
pick    = curry binary (o, as...) ->
    as = as[0] if typeis(as[0],'array'); r = {}; r[k] = o[k] for k in as; return r
keyval  = curry (k, v) -> set o={}, k, v; o


# string -----------------------------
split    = curry binary  builtin String::split    # s, s -> s
match    = curry binary  builtin String::match    # s, re -> [s]|null
replace  = curry ternary builtin String::replace  # s, s, s -> s
search   = curry binary  builtin String::search   # s, s -> Boolean
trim     = unary builtin String::trim             # s -> s
ucase    = unary builtin String::toUpperCase      # s -> s
lcase    = unary builtin String::toLowerCase      # s -> s


# string or array
slice    = curry (s, m, n) -> s.slice m, n  # s, n, n -> s
drop     = curry (s, n)    -> s.slice n     # s, n -> s
take     = curry (s, n)    -> s.slice 0, n  # s, n -> s
len      = (t) -> t.length


# maths -----------------------------------
add      = curry binary (as...) -> fold1 as, (a,b) -> a + b
sub      = curry binary (as...) -> fold1 as, (a,b) -> a - b
mul      = curry binary (as...) -> fold1 as, (a,b) -> a * b
div      = curry binary (as...) -> fold1 as, (a,b) -> a / b
mod      = curry binary (as...) -> fold1 as, (a,b) -> a % b
min      = curry binary (as...) -> Math.min as...
max      = curry binary (as...) -> Math.max as...
gt       = curry (a,b) -> a > b
gte      = curry (a,b) -> a >= b
lt       = curry (a,b) -> a < b
lte      = curry (a,b) -> a <= b
eq       = do ->
    _ = {} # placeholder obj
    curry binary (as...) -> fold1(as, (a,b) -> if a == b then a else _) != _
aand     = curry binary (fs...) -> (as...) ->
    len = fs.length; i = 0
    `for (;i < len; ++i) { if (!fs[i].apply(null,as)) { return false } }`
    true
oor      = curry binary (fs...) -> (as...) ->
    len = fs.length; i = 0
    `for (;i < len; ++i) { if (fs[i].apply(null,as)) { return true } }`
    false
nnot     = (f) -> unary (as...) -> !f(as...)

# zipping
zipwith = ncurry 3, true, (as..., f) ->
    ml = min (a.length for a in as)...
    f (as[n][i] for n in [0...as.length] by 1)... for i in [0...ml] by 1
zip    = zipwith (as...) -> as
zipobj = do ->
    fn = (obj) -> zipwith (k, v) -> set obj, k, v
    (ks, vs) -> fn(ret = {})(ks, vs); ret

# Deep equals
eql = do ->
    eqtype  = (a, b) -> type(a) == type(b)
    eqarr   = (a, b) ->
        return false unless a.length == b.length
        (for i in [0...a.length] by 1 then return false unless eql a[i], b[i]); true
    eqplain = (a, b) -> isplain(a) and isplain(b)
    sortstr = sort (s1, s2) -> s1.localeCompare s2
    eqobj   = (a, b) ->
        ka = sortstr keys a
        return false unless eqarr ka, sortstr keys b
        (for k in ka then return false unless eql a[k], b[k]); true
    curry (a, b) ->
        return true if a == b
        (aand eqtype, switch type(a)
            when 'object' then aand eqplain, eqobj
            when 'array'  then eqarr
            else -> false)(a,b)


################################
exports = {

    # generic
    shallow, clone

    # type
    type, typeis, isplain, isdef

    # fn
    arity, arityof, unary, binary, ternary, curry, flip, compose,
    pipe, I, partial, partialr, tap, converge,
    apply, iif, maybe, always, nth, once

    # object
    merge, mixin, has, get, set, keys, values, pick, evolve, ofilter,
    eql, keyval

    # array
    concat, head, tail, last, fold, fold1, foldr, foldr1, each, map,
    filter, all, any, join, reverse, sort, index, indexfn, contains,
    uniq, uniqfn, zip, zipwith, len, firstfn, lastfn, zipobj

    # string
    split, match, replace, search, trim, ucase, lcase, slice, drop,
    take

    # maths
    add, sub, mul, div, mod, min, max, gt, gte, lt, lte, eq, aand,
    oor, nnot

    # promises
    plift, pfail

}

# aliases
exports.and = exports.aand
exports.or  = exports.oor
exports.not = exports.nnot

asprop = (fn) ->
    value: fn
    enumerable: true
    configurable: false
    writable: false

expose = do ->
    guard = '__fnuc'
    (exp) -> (obj, as...) ->
        return if obj[guard]
        ofexp = partial get, exp
        valid = (as) -> map as, (a) -> if ofexp(a) then a else throw "Not found: #{a}"
        ks = if as.length then valid(as) else keys(exp)
        fns = map(ofexp) ks
        props = zipobj ks, map(asprop) fns
        Object.defineProperties obj, props
        Object.defineProperty obj, guard, asprop(I)
        exp

exports.expose = expose(exports)

if typeof module == 'object'
    module.exports = exports
else if typeof define == 'function' and define.amd
    define -> exports
else
    this.F = exports
