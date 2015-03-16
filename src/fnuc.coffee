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
    else if t == 'tuple'
        r = a.unpack tuple
    else if isplain(a)
        r = merge {}, a
    else
        throw new TypeError "Can't shallow " + a
    return r


clone = (a) ->
    return a unless a # null, undefined, false, '', 0
    if (t = type a) == 'tuple'
        s = a.unpack (as...) -> tuple clone(as)...
    else
        s = shallow(a)
        if t == 'array'
            s[i] = clone(s[i]) for i in [0...a.length] by 1
        else if isplain(s)
            s[k] = clone(v) for k, v of s
    return s


# type -----------------------------
isplain = (o) -> !!o && typeof o == 'object' && o.constructor == Object
Tuple   = -> # placeholder
type    = (a) ->
    if a instanceof Tuple
        'tuple'
    else
        _toString(a)[8...-1].toLowerCase()

# object ----------------------------
merge   = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t
mixin   = (os...)    -> merge {}, os...

# array 1
head    = (a) -> a[0]
tail    = (a) -> a[1..]
last    = (a) -> a[a.length-1]

# fn --------------------------------
arity = (f, n) ->
    if arguments.length == 1
        return f.length if type(f) == 'function'
        n = f
        f = undefined
    _ar = (f) -> ARITY[n](f)
    if f then return _ar(f) else _ar
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
    n = arity(f)
    return f if (n < 2)
    nf = arity(n) (as...) -> if as.length < n then ncurry n, false, f, as else f as...
    Object.defineProperty nf, '_curry', value: -> f
    return nf

# not a mathematical uncurry, it just unwraps our own curry
uncurry = (f) -> if f._curry then f._curry() else f

partial = (f, as...) ->
    return f as... if (n = (arity(f) - as.length)) <= 0
    arity(n) (bs...) -> f as.concat(bs)...
partialr = (f, as...) ->
    return f as... if (n = (arity(f) - as.length)) <= 0
    arity(n) (bs...) -> f bs[0...n].concat(as)...

flip = (f) ->
    return f._flip if f._flip
    rewrap = if f._curry then curry else I
    g = (rewrap arity(arity(f)) (as...) -> uncurry(f) as.reverse()...)
    Object.defineProperty g, '_flip', value:f
    return g

compose  = (fs...) -> ncurry arity(last(fs)), false, fold1 fs, (f, g) -> (as...) -> f g as...
sequence = flip compose
tap      = curry (a, f) -> f(a); a                  # a, fn -> a

typeis   = curry (a,s) -> type(a) == s

# array ----------------------------
all      = curry binary  builtin Array::every       # [a], fn -> Boolean
any      = curry binary  builtin Array::some        # [a], fn -> Boolean
contains = curry (as, a) -> index(as, a) >= 0       # [a], a -> b
concat   = curry binary (as...) -> [].concat as...
each     = curry binary  builtin Array::forEach     # [a], fn    -> undef
filter   = curry binary  (as, f) ->                 # [a], fn -> [a]|undef
    r = []
    ri = -1
    (r[++ri] = v if f(v)) for v in as
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
fold     = curry (as, f, v) -> _fold  as, f, v,    false # [a], fn, v -> *
fold1    = curry (as, f)    -> _fold  as, f, null, true  # [a], fn -> *
foldr    = curry (as, f, v) -> _foldr as, f, v,    false # [a], fn, v -> *
foldr1   = curry (as, f)    -> _foldr as, f, null, true  # [a], fn -> *
index    = curry binary (as, v, fr) ->                   # [a], a -> n
    len = as?.length || 0
    return -1 unless len
    i = fr || 0
    `for (;i < len; ++i) { if (as[i] == v) return i }`
    -1
join     = curry binary  builtin Array::join        # [a], s -> s
map      = curry (as, f) ->                         # [a], fn -> [a]
    r = Array(as.length); len = as.length; i = 0
    `for (;i < len; ++i) { r[i] = f(as[i]) }`
    r
reverse  = unary builtin Array::reverse             # [a] -> [a]
sort     = curry binary  builtin Array::sort        # [a] -> [a]
uniq     = (as) -> return as unless as; as.filter (v, i) -> index(as, v) == i # [a] -> [a]


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
_ = {} # internal placeholder
eq       = curry binary (as...) -> fold1(as, (a,b) -> if a == b then a else _) != _
aand     = curry binary (as...) -> (bs...) ->
    len = as.length; i = 0
    `for (;i < len; ++i) { if (!as[i].apply(null,bs)) { return false } }`
    true
oor      = curry binary (as...) -> (bs...) ->
    len = as.length; i = 0
    `for (;i < len; ++i) { if (as[i].apply(null,bs)) { return true } }`
    false
nnot     = curry binary (as..., f) -> !f(as...)


# tuples
class Tuple
    constructor: (as) ->
        Object.defineProperty @, '_as', value:as
        for i in [0...as.length] by 1
            Object.defineProperty @, String(i), {value:as[i],enumerable:true}
        Object.defineProperty @, 'length', value:as.length
    unpack: (un) -> un @_as...
    toString: -> "[tuple #{JSON.stringify(this)}]"
tuple  = ncurry 2, true, (as...) -> new Tuple as
unpack = curry (t, f) -> t.unpack f
fst    = (t) -> t.unpack I
snd    = (t) -> t.unpack (a, b) -> b
nth    = curry (t, n) -> t.unpack (as...) -> as[n]
len    = (t) -> t.length


# zipping
zipwith = ncurry 3, true, (as..., f) ->
    ml = min (a.length for a in as)...
    f (as[n][i] for n in [0...as.length] by 1)... for i in [0...ml] by 1
zip   = zipwith tuple
unzip = (z) ->
    return [] unless z.length
    l = len z[0]
    r = (new Array(z.length) for n in [0...l] by 1)
    un = (i) -> (as...) ->
        r[n][i] = as[n] for n in [0...l] by 1
        null
    z[i].unpack un(i) for i in [0...z.length] by 1
    tuple r...


# Deep equals
eql = do ->
    eqtype  = (a, b) -> type(a) == type(b)
    eqtuple = (a, b) -> a.unpack (as...) -> b.unpack (bs...) -> eql as, bs
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
            when 'tuple'  then eqtuple
            when 'object' then aand eqplain, eqobj
            when 'array'  then eqarr
            else -> false)(a,b)

groupby = curry (as, fn) -> fold as,
    (acc, a) ->
        k = fn a
        (acc[k] || (acc[k] = [])).push a
        acc
    , {}


# Make a function chainable off Function::
chainable = (name, f) ->
    n = arity(f)
    throw new Error("No chainable for arity 0") if n < 1
    g = if f._curry then f else curry(f)
    Object.defineProperty Function::, name, {configurable: true, get: ->
        p = this
        if n == 1
            sequence(p, g)
        else
            curry arity(n - 1) (as...) -> sequence(p, g(as...))
    }
    null


################################
exports = {

    # generic
    shallow, clone

    # type
    type, typeis, isplain

    # fn
    arity, unary, binary, ternary, curry, flip, compose,
    sequence, I, ident, partial, partialr, tap, chainable

    # object
    merge, mixin, has, get, set, keys, values, pick, evolve, omap,
    ofilter, eql, groupby

    # array
    concat, head, tail, last, fold, fold1, foldr, foldr1, each, map,
    filter, all, any, join, reverse, sort, index, contains, uniq

    # string
    split, match, replace, search, trim, ucase, lcase, slice, drop,
    take

    # maths
    add, sub, mul, div, mod, min, max, gt, gte, lt, lte, eq, aand,
    oor, nnot

    # tuple
    tuple, unpack, fst, snd, len, nth, zip, unzip, zipwith

}

# aliases
exports.and = exports.aand
exports.or  = exports.oor
exports.not = exports.nnot

CHAINABLE = split 'clone shallow flip tap has get set keys values
    concat head tail last fold fold1 foldr foldr1 each map filter all
    any join reverse sort index contains uniq split match replace
    search slice, drop, take, trim ucase lcase add sub mul div mod min
    max gt gte lt lte eq and or not eql groupby', ' '

# function to install all chainables on Function::
exports.installChainable = ->
    each CHAINABLE, (name) -> chainable name, exports[name]
    exports

# helper to expose selected functions
expose = (exp, guard) -> (obj, funs...) ->
    if funs?.length
        obj[k] = exp[k] for k in funs
    else unless obj[guard]
        obj[k] = v for k, v of exp when k.indexOf("_") != 0
        obj[guard] = true
    exp

exports.expose = expose(exports, '__fnuc')

if typeof module == 'object'
    module.exports = exports
else if typeof define == 'function' and define.amd
    define -> exports
else
    this.F = exports
