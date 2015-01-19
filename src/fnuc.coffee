ARITY = [
    (z) -> () -> z(arguments...)
    (z) -> (a) -> z(arguments...)
    (z) -> (a,b) -> z(arguments...)
    (z) -> (a,b,c) -> z(arguments...)
    (z) -> (a,b,c,d) -> z(arguments...)
    (z) -> (a,b,c,d,e) -> z(arguments...)
    (z) -> (a,b,c,d,e,f) -> z(arguments...)
    (z) -> (a,b,c,d,e,f,g) -> z(arguments...)
    (z) -> (a,b,c,d,e,f,g,h) -> z(arguments...)
    (z) -> (a,b,c,d,e,f,g,h,i) -> z(arguments...)
    (z) -> (a,b,c,d,e,f,g,h,i,j) -> z(arguments...)
]

# generic -------------------------
clone = (a) ->
    return a unless a # null, undefined, false, '', 0
    r = null
    if (type = typeOf(a)) in ['string', 'number', 'boolean', 'symbol']
        r = a
    else if type == 'array'
        r = []
        r[i] = a[i] for i in [0..(a.length - 1)] by 1
    else if type == 'date'
        r = new Date(a.getTime())
    else if isPlain(a)
        r = merge {}, a
    else
        throw new TypeError "Can't clone " + a
    return r

cloneDeep = (a) ->
    return a unless a # null, undefined, false, '', 0
    s = clone(a)
    if isType 'array', s
        s[i] = cloneDeep(s[i]) for i in [0..(a.length - 1)] by 1
    else if isPlain(s)
        s[k] = cloneDeep(v) for k, v of s
    return s

# type -----------------------------
_toString     = (a) -> Object::toString.call a
isPlain       = (o) -> !!o && typeof o == 'object' && o.constructor == Object
typeOf        = (a) -> _toString(a)[8...-1].toLowerCase()
isType        = (t, a) ->
    t = t.toString()[9...-20].toLowerCase() if t instanceof Function
    return typeOf(a) == t


# object ----------------------------
merge = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t
mixin = (os...)    -> merge {}, os...


# array 1
head = (a) -> a[0]
tail = (a) -> a[1..]
last = (a) -> a[a.length-1]

# fn --------------------------------
I = ident = (a) -> a
arity = ar = (f, n) ->
    if arguments.length == 1
        return f.length if isType 'function', f
        n = f
        f = undefined
    _ar = (f) -> ARITY[n](f)
    if f then return _ar(f) else _ar
unary   = arity 1
binary  = arity 2
ternary = arity 3

ncurry = (n, f, as=[]) -> merge (ar(n - as.length) (bs...) ->
    cs = bs.concat as
    if cs.length < n then ncurry n, f, cs else f cs...), _curry:->rpartial f, as...

curry = (f) ->
    return f if (n = ar(f)) < 2
    merge (ar(n) (as...) -> if as.length < n then ncurry n, f, as else f as...), _curry:->f

uncurry = (f) -> if f._curry then f._curry() else f

lpartial = (f, as...) ->
    return f as... if (n = (ar(f) - as.length)) <= 0
    ar(n) (bs...) -> f as.concat(bs)...
rpartial = (f, as...) ->
    return f as... if (n = (ar(f) - as.length)) <= 0
    ar(n) (bs...) -> f bs[0...n].concat(as)...

flip = (f) ->
    return f._flip if f._flip
    [unwrap, rewrap] = if f._curry then [uncurry, curry] else [I, I]
    merge (rewrap ar(ar(f)) (as...) -> unwrap(f) as.reverse()...), _flip:f

compose = (fs...) -> ncurry ar(last(fs)), fs.reduce (f, g) -> (as...) -> f g as...
sequence = flip compose

# array ----------------------------
append   = curry (a, v) -> a.concat [v]
appendTo = curry (v, a) -> a.concat [v]


################################
exports = {
    __fnuc: true # identifier

    # generic
    clone, cloneDeep

    # type
    isType, typeOf, isPlain

    # fn
    arity, unary, binary, ternary, curry, ncurry, flip, compose,
    sequence, I, ident, lpartial, rpartial

    # object
    merge, mixin

    # array
    append, appendTo
}

exports.installTo = (obj, force) ->
    return obj if obj.__fnuc unless force
    merge obj, exports

if typeof exports == 'object'
    module.exports = exports
else if typeof define == 'function' and define.amd
    define -> exports
else
    this.FN = exports
