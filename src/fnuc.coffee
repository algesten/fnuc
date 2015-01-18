
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
    else if isPlainObject(a)
        r = merge {}, a
    else
        throw new TypeError "Can't clone " + a
    return r

cloneDeep = (a) ->
    return a unless a # null, undefined, false, '', 0
    s = clone(a)
    if isType 'array', s
        s[i] = cloneDeep(s[i]) for i in [0..(a.length - 1)] by 1
    else if isPlainObject(s)
        s[k] = cloneDeep(v) for k, v of s
    return s

# object ----------------------------
merge = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t
mixin = (os...)    -> merge {}, os...


# type -----------------------------
_toString     = (a) -> Object::toString.call a
isPlainObject = (o) -> !!o && typeof o == 'object' && o.constructor == Object
typeOf        = (a) -> _toString(a)[8...-1].toLowerCase()
isType        = (t, a) ->
    t = t.toString()[9...-20].toLowerCase() if t instanceof Function
    return typeOf(a) == t

################################
exports = {
    __fnuc: true # identifier

    # generic
    clone, cloneDeep

    # object
    merge, mixin

    # type
    isType, typeOf, isPlainObject
}

exports.installTo = (obj) ->
    return obj if obj.__fnuc
    merge obj, exports

if typeof exports == 'object'
    module.exports = exports
else if typeof define == 'function' and define.amd
    define -> exports
else
    this.FN = exports
