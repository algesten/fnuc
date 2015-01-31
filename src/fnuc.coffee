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
    if type(s) == 'array'
        s[i] = clone(s[i]) for i in [0...a.length] by 1
    else if isplain(s)
        s[k] = clone(v) for k, v of s
    return s


# type -----------------------------
isplain       = (o) -> !!o && typeof o == 'object' && o.constructor == Object
type          = (a) -> _toString(a)[8...-1].toLowerCase()

# object ----------------------------
merge  = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t
mixin  = (os...)    -> merge {}, os...

# array 1
head   = (a) -> a[0]
tail   = (a) -> a[1..]
last   = (a) -> a[a.length-1]

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

ncurry = (n, f, as=[]) ->
    l = n - as.length
    nf = arity(l) (bs...) ->
        cs = (if bs.length <= l then bs else bs[0...l]).concat as
        if cs.length < n then ncurry n, f, cs else f cs...
    nf._curry = -> rpartial f, as...
    return nf

curry = (f) ->
    n = arity(f)
    return f if (n < 2)
    nf = arity(n) (as...) -> if as.length < n then ncurry n, f, as else f as...
    nf._curry = -> f
    return nf

# not a mathematical uncurry, it just unwraps our own curry
uncurry = (f) -> if f._curry then f._curry() else f

lpartial = (f, as...) ->
    return f as... if (n = (arity(f) - as.length)) <= 0
    arity(n) (bs...) -> f as.concat(bs)...
rpartial = (f, as...) ->
    return f as... if (n = (arity(f) - as.length)) <= 0
    arity(n) (bs...) -> f bs[0...n].concat(as)...

flip = (f) ->
    return f._flip if f._flip
    rewrap = if f._curry then curry else I
    merge (rewrap arity(arity(f)) (as...) -> uncurry(f) as.reverse()...), _flip:f

compose = (fs...) -> ncurry arity(last(fs)), fs.reduce (f, g) -> (as...) -> f g as...
sequence = flip compose
tap      = curry (a, f) -> f(a); a                  # a, fn -> a

typeis        = curry (a,s) -> type(a) == s

# array ----------------------------
all      = curry binary  builtin Array::every       # [a], fn -> Boolean
any      = curry binary  builtin Array::some        # [a], fn -> Boolean
contains = curry (as, a) -> index(as, a) >= 0       # [a], a -> b
concat   = curry binary (as...) -> [].concat as...
each     = curry binary  builtin Array::forEach     # [a], fn    -> undef
filter   = curry binary  builtin Array::filter      # [a], fn -> [a]|undef
fold     = curry (as, f, v) -> as.reduce ((p,c) -> f(p,c)), v      # [a], fn, v -> *
fold1    = curry (as, f)    -> as.reduce ((p,c) -> f(p,c))         # [a], fn -> *
foldr    = curry (as, f, v) -> as.reduceRight ((p,c) -> f(p,c)), v # [a], fn, v -> *
foldr1   = curry (as, f)    -> as.reduceRight ((p,c) -> f(p,c))    # [a], fn -> *
index    = curry binary  builtin Array::indexOf     # [a], a -> n
join     = curry binary  builtin Array::join        # [a], s -> s
map      = curry (as, f) -> as.map (a) -> f(a)      # [a], fn -> [a]
reverse  = unary builtin Array::reverse             # [a] -> [a]
sort     = curry binary  builtin Array::sort        # [a] -> [a]
uniq     = (a) -> return a unless a; a.filter (v, i) -> a.indexOf(v) == i # [a] -> [a]


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
split    = curry binary  builtin String::split       # s, s -> s
match    = curry binary  builtin String::match       # s, re -> [s]|null
replace  = curry ternary builtin String::replace     # s, s, s -> s
search   = curry binary  builtin String::search      # s, s -> Boolean
trim     = unary builtin String::trim                # s -> s
ucase    = unary builtin String::toUpperCase         # s -> s
lcase    = unary builtin String::toLowerCase         # s -> s


# maths -----------------------------------
add      = curry binary (as...) -> as.reduce (a,b) -> a + b
sub      = curry binary (as...) -> as.reduce (a,b) -> a - b
mul      = curry binary (as...) -> as.reduce (a,b) -> a * b
div      = curry binary (as...) -> as.reduce (a,b) -> a / b
mod      = curry binary (as...) -> as.reduce (a,b) -> a % b
min      = curry binary (as...) -> Math.min as...
max      = curry binary (as...) -> Math.max as...
gt       = curry (a,b) -> a > b
gte      = curry (a,b) -> a >= b
lt       = curry (a,b) -> a < b
lte      = curry (a,b) -> a <= b
_ = {} # internal placeholder
eq       = curry binary (as...) -> as.reduce((a,b) -> if a == b then a else _) != _
and_     = curry binary (as...) -> (bs...) -> as.reduce ((a,b) -> a and b(bs...)), true
or_      = curry binary (as...) -> (bs...) -> as.reduce ((a,b) -> a or  b(bs...)), false
not_     = curry binary (as..., f) -> !f(as...)


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

    __fnuc: true # identifier

    # generic
    shallow, clone

    # type
    type, typeis, isplain

    # fn
    arity, unary, binary, ternary, curry, flip, compose,
    sequence, I, ident, lpartial, rpartial, tap, chainable

    # object
    merge, mixin, has, get, set, keys, values, pick, evolve, omap, ofilter

    # array
    concat, head, tail, last, fold, fold1, foldr, foldr1, each, map,
    filter, all, any, join, reverse, sort, index, contains, uniq

    # string
    split, match, replace, search, trim, ucase, lcase

    # maths
    add, sub, mul, div, mod, min, max, gt, gte, lt, lte, eq, and_,
    or_, not_

}

exports.and = exports.and_
exports.or = exports.or_
exports.not = exports.not_

CHAINABLE = ['clone', 'shallow', 'flip', 'tap', 'has', 'get', 'set',
    'keys', 'values', 'concat', 'head', 'tail', 'last', 'fold',
    'fold1', 'foldr', 'foldr1', 'each', 'map', 'filter', 'all', 'any',
    'join', 'reverse', 'sort', 'index', 'contains', 'uniq', 'split',
    'match', 'replace', 'search', 'trim', 'ucase', 'lcase', 'add',
    'sub', 'mul', 'div', 'mod', 'min', 'max', 'gt', 'gte', 'lt',
    'lte', 'eq', 'and', 'or', 'not']

# function to install all chainables on Function::
exports.installChainable = ->
    each CHAINABLE, (name) -> chainable name, exports[name]
    exports

exports.installTo = (obj, force) ->
    return exports if obj.__fnuc unless force
    tutti = shallow exports
    delete tutti.installTo
    delete tutti.installChainable
    merge obj, tutti
    exports

if typeof module == 'object'
    module.exports = exports
else if typeof define == 'function' and define.amd
    define -> exports
else
    this.F = exports
