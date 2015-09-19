minifyNot = ->
ARITY = [
    (z) -> () -> z arguments...
    (z) -> (a) -> minifyNot(a); z arguments...
    (z) -> (a,b) -> minifyNot(a,b); z arguments...
    (z) -> (a,b,c) -> minifyNot(a,b,c); z arguments...
    (z) -> (a,b,c,d) -> minifyNot(a,b,c,d); z arguments...
    (z) -> (a,b,c,d,e) -> minifyNot(a,b,c,d,e); z arguments...
    (z) -> (a,b,c,d,e,f) -> minifyNot(a,b,c,d,e,f); z arguments...
    (z) -> (a,b,c,d,e,f,g) -> minifyNot(a,b,c,d,e,f,g); z arguments...
    (z) -> (a,b,c,d,e,f,g,h) -> minifyNot(a,b,c,d,e,f,g,h); z arguments...
    (z) -> (a,b,c,d,e,f,g,h,i) -> minifyNot(a,b,c,d,e,f,g,h,i); z arguments...
    (z) -> (a,b,c,d,e,f,g,h,i,j) -> minifyNot(a,b,c,d,e,f,g,h,i,j); z arguments...
]

# core
I = ident = (a) -> a
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
type    = (a) -> _toString(a)[8...-1].toLowerCase()

# object ----------------------------
merge   = (t, os...) -> t[k] = v for k,v of o for o in os; t
mixin   = (os...)    -> merge {}, os...

# array 1
head    = (a) -> a[0]
tail    = (a) -> a[1..]
last    = (a) -> a[a.length-1]

# fn --------------------------------
arity = (f, n) ->
    if arguments.length == 1
        n = f
        f = undefined
    ar = ARITY[n]
    if f then ar(f) else ar
arityof = (f) -> return f.length if type(f) == 'function'
unary   = arity 1
binary  = arity 2
ternary = arity 3

# n  - arity
# v  - true if we allow varargs. false to chop.
# f  - function to curry
# as - arguments so far
ncurry = (n, v, f, as=[]) ->
    l = n - as.length
    nf = arity(l) (bs...) ->
        cs = (if bs.length <= l then bs else (if v then bs else bs[0...l])).concat as
        if cs.length < n then ncurry n, v, f, cs else f cs...
    Object.defineProperty nf, '_curry', value: -> partialr f, as...
    return nf

curry = (f) ->
    n = arityof(f)
    return f if (n < 2)
    nf = arity(n) (as...) -> if as.length < n then ncurry n, false, f, as else f as...
    Object.defineProperty nf, '_curry', value: -> f
    return nf

# not a mathematical uncurry, it just unwraps our own curry
uncurry = (f) -> if f._curry then f._curry() else f

partial = (f, as...) ->
    return f as... if (n = (arityof(f) - as.length)) <= 0
    arity(n) (bs...) -> f as.concat(bs)...
partialr = (f, as...) ->
    return f as... if (n = (arityof(f) - as.length)) <= 0
    arity(n) (bs...) -> f bs[0...n].concat(as)...

flip = (f) ->
    return f._flip if f._flip
    rewrap = if f._curry then curry else I
    g = (rewrap arity(arityof(f)) (as...) -> uncurry(f) as.reverse()...)
    Object.defineProperty g, '_flip', value:f
    return g

compose  = (fs...) -> ncurry arityof(last(fs)), false, fold1 fs, (f, g) -> (as...) -> f g as...
pipe     = (fs...) -> ncurry arityof(head(fs)), false, foldr1 fs, (f, g) -> (as...) -> f g as...

tap      = curry (a, f) -> f(a); a                  # a, fn -> a

typeis   = curry (a,s) -> type(a) == s

apply    = curry (args, fn) -> fn.apply this, args

converge = ncurry 3, true, (after, fns...) ->
    ncurry Math.max(fns.map(arityof)...), true, (args...) ->
        context = this
        after.apply context, map fns, (fn) -> fn.apply context, args

# array ----------------------------
all      = curry binary  builtin Array::every       # [a], fn -> Boolean
any      = curry binary  builtin Array::some        # [a], fn -> Boolean
contains = curry (as, a) -> index(as, a) >= 0       # [a], a -> b
concat   = (as...) -> [].concat as...
each     = curry binary  builtin Array::forEach     # [a], fn    -> undef
# 2015-09-05. Array.prototype.filter is significantly slower than this.
filter   = curry binary  (as, f) ->                 # [a], fn -> [a]|undef
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
    _isthenable = (p) ->
        return false unless p
        return false unless typeof p in ['object', 'function']
        return typeof p.then == 'function'

    # first thenable (if any), bound to its promise
    _firstthenable = pipe firstfn(_isthenable), (p) -> p?.then.bind(p)

    # :: Promise (a -> b), (a or Promise a) -> Promise b
    _promapply = (pfn, parg) ->
        fn = null
        pfn.then (_fn) ->
            fn = _fn
            parg
        .then (arg) ->
            fn(arg)

    (f) -> arity(arityof(f)) (as...) ->
        t0 = _firstthenable as # first is false or a thenable-function
        if t0
            foldr as, _promapply, t0 -> ncurry(as.length, false, f)
        else
            f as...

# pipe of plifted functions
ppipe = (fns...) -> pipe (map fns, plift)...


# moar object
has     = curry (o, k) -> o.hasOwnProperty(k)
get     = curry (o, k) -> o[k]
set     = curry (o, k, v) -> o[k] = v; o
keys    = (o) -> Object.keys(o)
values  = (o) -> map (keys o), (k) -> o[k]
omap    = curry (o, f) -> r = {}; r[k] = f(k,v) for k, v of o; return r
ofilter = curry (o, f) -> r = {}; r[k] = v for k, v of o when f(k,v); return r
evolve  = curry (o, t) -> omap o, (k, v) -> if has(t,k) then t[k](v) else v
pick    = curry binary (o, as...) ->
    as = as[0] if typeis(as[0],'array'); r = {}; r[k] = o[k] for k in as; return r


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
aand     = curry binary (as...) -> (bs...) ->
    len = as.length; i = 0
    `for (;i < len; ++i) { if (!as[i].apply(null,bs)) { return false } }`
    true
oor      = curry binary (as...) -> (bs...) ->
    len = as.length; i = 0
    `for (;i < len; ++i) { if (as[i].apply(null,bs)) { return true } }`
    false
nnot     = curry binary (as..., f) -> !f(as...)

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

groupby = curry (as, fn) -> fold as,
    (acc, a) ->
        k = fn a
        (acc[k] || (acc[k] = [])).push a
        acc
    , {}


################################
exports = {

    # generic
    shallow, clone

    # type
    type, typeis, isplain

    # fn
    arity, arityof, unary, binary, ternary, curry, flip, compose,
    pipe, I, ident, partial, partialr, tap, converge,
    apply

    # object
    merge, mixin, has, get, set, keys, values, pick, evolve, omap,
    ofilter, eql, groupby

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
    plift, ppipe

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
    (exp) -> (obj) ->
        return if obj[guard]
        ofexp = (flip get) exp
        ks = keys exp
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
