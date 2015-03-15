if browsertest?
    `sinon = window.sinon`
    `chai = window.chai`
    `expect = window.chai.expect`
    `F = window.F`
else
    chai   = require 'chai'
    chai.use(require 'sinon-chai')
    sinon = require 'sinon'
    F = require('../src/fnuc')
    delete global.__fnuc
    F.expose(global)

assert = chai.assert
eql = assert.deepEqual

{ spy, mock, stub, sandbox } = sinon

# String
# Number
# Boolean
# Symbol
# Array
# Date
# Object

date = new Date(1421584085148)

class Foo

TYPES = [
    {v:undefined, t:'undefined', d:'',        truthy:false, func:false}
    {v:null,      t:'null',      d:'',        truthy:false, func:false}
    {v:false,     t:'boolean',   d:'',        truthy:false, func:false}
    {v:true,      t:'boolean',   d:'',        truthy:true,  func:false}
    {v:'',        t:'string',    d:'[empty]', truthy:false, func:String}
    {v:'str',     t:'string',    d:'',        truthy:true,  func:String}
    {v:0,         t:'number',    d:'[0]',     truthy:false, func:Number}
    {v:42,        t:'number',    d:'',        truthy:true,  func:Number}
    {v:[],        t:'array',     d:'[empty]', truthy:true,  func:Array}
    {v:[0,1,{}],  t:'array',     d:'',        truthy:true,  func:Array}
    {v:date,      t:'date',      d:'',        truthy:true,  func:Date}
    {v:{},        t:'object',    d:'[empty]', truthy:true,  func:Object, plain:true}
    {v:{a:1,b:{}},t:'object',    d:'',        truthy:true,  func:Object, plain:true}
    {v:new Foo,   t:'object',    d:'[proto]', truthy:true,  func:Object}
    {v:{a:[{b:1}]}, t:'object',  d:'',        truthy:true,  func:Object, plain:true}
    {v:{a:[{}]},  t:'object',    d:'',        truthy:true,  func:Object, plain:true}
    {v:tuple({a:1},[1]),t:'tuple',d:'',       truthy:true,  func:Object}
    {v:tuple(2,3),t:'tuple',     d:'',        truthy:true,  func:Object}
]
TYPE_PROTO    = TYPES.filter (spec) -> spec.t == 'object' and not spec.plain
TYPE_NO_PROTO = TYPES.filter (spec) -> spec.t != 'object' or spec.plain
TYPE_ARR      = TYPES.filter (spec) -> spec.t == 'array'
TYPE_PLAIN    = TYPES.filter (spec) -> spec.t == 'object' and spec.plain


describe 'type', ->

    describe 'for 1 arg', ->
        TYPES.forEach (spec) ->
            it "works for #{spec.t}#{spec.d}", -> eql type(spec.v), spec.t

describe 'typeis', ->

    describe 'works on the form (a,s)', ->
        TYPES.forEach (spec) ->
            it "for type #{spec.t}#{spec.d}", -> eql typeis(spec.v,spec.t), true

    describe 'works curried (s)(a)', ->
        TYPES.forEach (spec) ->
            it "for type #{spec.t}#{spec.d}", -> eql typeis(spec.t)(spec.v), true

describe 'isplain', ->

    describe 'tells whether something is a plain object', ->
        TYPES.forEach (spec) ->
            it "for type #{spec.t}#{spec.d}", -> eql isplain(spec.v), !!spec.plain

describe 'merge', ->

    describe 'alters first argument with consecutive and', ->

        it 'handles no object', -> eql merge(), undefined
        it 'handles one object', -> eql merge(a:1), a:1
        it 'handles two objects', -> eql merge({a:1},{b:2}), {a:1,b:2}
        it 'handles three objects', -> eql merge({a:1},{b:2},{c:3}), {a:1,b:2,c:3}
        it 'overwrites existing keys', -> eql merge({a:1},{a:2}), a:2
        it 'overwrites with precedence', -> eql merge({a:1},{a:2},{a:3}), a:3
        it 'ignores undefined values', -> eql merge({a:1},{a:undefined}), a:1
        it 'leaves undefined in first be', ->
            eql merge({a:undefined},{b:2}), {a:undefined,b:2}

describe 'mixin', ->

    describe 'returns a new object with all arguments merged and', ->

        it 'handles no object', -> eql mixin(), {}
        it 'handles one object', ->
            eql (r = mixin(a = a:1)), a:1
            assert.ok a != r
        it 'handles two objects', ->
            eql mixin(a = {a:1},{b:2}), {a:1,b:2}
            eql a, a:1
        it 'handles three objects', ->
            eql mixin(a = {a:1},{b:2},{c:3}), {a:1,b:2,c:3}
            eql a, a:1
        it 'overwrites existing keys', ->
            eql mixin(a = {a:1},{a:2}), a:2
            eql a, a:1
        it 'overwrites with precedence', ->
            eql mixin(a = {a:1},{a:2},{a:3}), a:3
            eql a, a:1
        it 'ignores undefined values', ->
            eql mixin(a = {a:1},{a:undefined}), a:1
            eql a, a:1
        it 'leaves undefined in first be', ->
            eql mixin(a = {a:undefined},{b:2}), b:2
            eql a, a:undefined

describe 'shallow', ->

    describe 'does a shallow copy', ->
        TYPE_NO_PROTO.forEach (spec) ->
            it "for built in type #{spec.t}#{spec.d}", ->
                r = shallow(spec.v)
                eql r, spec.v

    describe 'wont handle proto', ->
        TYPE_PROTO.forEach (spec) ->
            it 'throws an exception', ->
                assert.throws (->shallow(spec.v)), 'Can\'t shallow [object Object]'

    describe 'specifically', ->

        describe 'for arrays', ->

            TYPE_ARR.forEach (spec) ->
                it "copies nested by reference for #{spec.t}#{spec.d}", ->
                    r = shallow(spec.v)
                    assert.ok r != spec.v
                    (assert.ok r[i] == spec.v[i]) for a, i in r
                    eql r.length, spec.v.length

        describe 'for objects', ->
            TYPE_PLAIN.forEach (spec) ->
                it "copies nested by reference for #{spec.t}#{spec.d}", ->
                    r = shallow(spec.v)
                    assert.ok r != spec.v
                    (assert.ok v == spec.v[k]) for k, v of r
                    eql Object.keys(r).length, Object.keys(spec.v).length

describe 'clone', ->

    describe 'does a deep copy', ->
        TYPE_NO_PROTO.forEach (spec) ->
            it "for built in type #{spec.t}#{spec.d}", ->
                r = clone(spec.v)
                eql r, spec.v

    describe 'wont handle proto', ->
        TYPE_PROTO.forEach (spec) ->
            it 'throws an exception', ->
                assert.throws (->clone(spec.v)), 'Can\'t shallow [object Object]'

    describe 'specifically', ->

        describe 'for arrays', ->
            TYPE_ARR.forEach (spec) ->
                it "clones nested for #{spec.t}#{spec.d}", ->
                    r = clone(spec.v)
                    assert.ok r != spec.v
                    for a, i in r
                        if typeis a, 'number'
                            assert.ok r[i] == spec.v[i]
                        else
                            assert.ok r[i] != spec.v[i]
                    eql r.length, spec.v.length

        describe 'for objects', ->
            TYPE_PLAIN.forEach (spec) ->
                it "clones nested for #{spec.t}#{spec.d}", ->
                    r = clone(spec.v)
                    assert.ok r != spec.v
                    for k, v of r
                        if typeis v, 'number'
                            assert.ok v == spec.v[k]
                        else
                            assert.ok v != spec.v[k]
                    eql Object.keys(r).length,  Object.keys(spec.v).length

describe 'arity', ->

    it 'returns the arity of (f)', ->
        eql arity(->), 0
        eql arity((a)->), 1
        eql arity((a,b)->), 2

    it 'chops the arity to the given number if (f,n)', ->
        eql arity(arity(((a,b,c)->),n)), n for n in [0..10]

    it 'has a curried variant for (n)', ->
        eql arity(arity(n)((a,b,c)->)), n for n in [0..10]

    describe 'unary', ->

        it 'is arity(1)', ->
            f = unary ((a,b,c,d,e) ->)
            eql f.length, 1

    describe 'binary', ->

        it 'is arity(2)', ->
            f = binary (a,b,c,d,e) ->
            eql f.length, 2

    describe 'ternary', ->

        it 'is arity(3)', ->
            f = ternary (a,b,c,d,e) ->
            eql f.length, 3

describe 'partial', ->

    describe 'partially fills in arguments from the left', ->

        it 'executes arity(0)', ->
            r = partial (->42)
            eql r, 42

        it 'executes arity(0) with arguments', ->
            r = partial (->42), 1, 2, 3
            eql r, 42

        it 'handles arity(1)', ->
            r = partial ((a) -> a + 42)
            assert.isFunction r
            eql r(1,2,3), 43

        it 'executes arity(1) with arguments', ->
            r = partial ((a) -> a + 42), 1, 2
            assert.isNotFunction r
            eql r, 43

        it 'works for arity(2)', ->
            r = partial ((a,b) -> a / b), 42
            assert.isFunction r
            eql arity(r), 1
            eql r(2,3,4), 21

        it 'executes arity(2) with arguments', ->
            r = partial ((a,b) -> a / b), 42, 2
            assert.isNotFunction r
            eql r, 21

        it 'works for arity(3) with one arg', ->
            r = partial ((a,b,c) -> a / (b / c)), 12
            assert.isFunction r
            eql arity(r), 2
            eql r(3,2,5), 8

        it 'works for arity(3) with two arg', ->
            r = partial ((a,b,c) -> a / (b / c)), 12, 3
            assert.isFunction r
            eql arity(r), 1
            eql r(2,5), 8

        it 'executes arity(3) with arguments', ->
            r = partial ((a,b,c) -> a / (b / c)), 12, 3, 2, 5
            assert.isNotFunction r
            eql r, 8

describe 'partialr', ->

    describe 'partially fills in arguments from the right', ->

        it 'executes arity(0)', ->
            r = partialr (->42)
            eql r, 42

        it 'executes arity(0) with arguments', ->
            r = partialr (->42), 1, 2, 3
            eql r, 42

        it 'handles arity(1)', ->
            r = partialr ((a) -> a + 42)
            assert.isFunction r
            eql r(1,2,3), 43

        it 'executes arity(1) with arguments', ->
            r = partialr ((a) -> a + 42), 1, 2
            assert.isNotFunction r
            eql r, 43

        it 'works for arity(2)', ->
            r = partialr ((a,b) -> a / b), 2
            assert.isFunction r
            eql arity(r), 1
            eql r(42,3,4), 21

        it 'executes arity(2) with arguments', ->
            r = partialr ((a,b) -> a / b), 42, 2
            assert.isNotFunction r
            eql r, 21

        it 'works for arity(3) with one arg', ->
            r = partialr ((a,b,c) -> a / (b / c)), 2
            assert.isFunction r
            eql arity(r), 2
            eql r(12,3,5), 8

        it 'works for arity(3) with two arg', ->
            r = partialr ((a,b,c) -> a / (b / c)), 3, 2
            assert.isFunction r
            eql arity(r), 1
            eql r(12,5), 8

        it 'executes arity(3) with arguments', ->
            r = partialr ((a,b,c) -> a / (b / c)), 12, 3, 2, 5
            assert.isNotFunction r
            eql r, 8

describe 'curry', ->

    it 'does nothing for arity(f) == 0', ->
        f = ->
        g = curry f
        assert.ok g == f

    it 'does nothing for arity(f) == 1', ->
        f = (n) ->
        g = curry f
        assert.ok g == f

    describe '(a,b) ->', ->

        div = curry (a,b) -> a / b

        it 'turns to (b) -> (a) ->', ->
            div2 = div(2)
            eql div2(10), 5

        it 'maintains arity for curried func', ->
            eql arity(div), 2

        it 'returns a smaller arity func after partial apply', ->
            div2 = div(2)
            eql arity(div2), 1

        it 'can still apply (a,b) to curried (a,b) ->', ->
            eql div(10, 2), 5

    describe '(a,b,c) ->', ->

        divt = curry (a,b,c) -> a / (b / c)

        it 'turns to (c) -> (b) -> (a) ->', ->
            div2 = divt(2)
            div4 = div2(8)
            eql div4(80), 20

        it 'maintains arity for curried func', ->
            eql arity(divt), 3

        it 'returns a small arity func after partial apply', ->
            div2 = divt(2)
            div4 = div2(8)
            eql arity(div2), 2
            eql arity(div4), 1

        it 'can be partially applied with (b,c)', ->
            div4 = divt(8, 2)
            eql div4(80), 20

        it 'does correct arity for partial applied', ->
            div4 = divt(8, 2)
            eql arity(div4), 1

        it 'can still apply (a,b,c) to curried (a,b,c) ->', ->
            eql divt(80, 8, 2), 20

        it 'can apply (b,c) to partial applied curried (a,b,c) ->', ->
            div2 = divt(2)
            eql div2(80,8), 20

        it 'doesnt splice in more arguments for a partially applied', ->
            div2 = divt(2)
            eql div2(100,25,4), 8

describe 'flip', ->

    describe '(a,b) ->', ->

        f = flip (f1 = (a,b) -> a / b)

        it 'flips the arguments to (b,a) ->', ->
            eql f(2, 10), 5

        it 'keeps arity', ->
            eql arity(f), 2

        it 'is commutative', ->
            assert.ok flip(f) == f1

        it 'flips curried functions', ->
            f = flip curry (a,b) -> a / b
            eql f(2,10), 5
            eql f(10)(2), 5

        it 'is commutative for curried functions', ->
            f = flip (f1 = curry (a,b) -> a / b)
            assert.ok flip(f) == f1

        it 'flips partially applied curried functions', ->
            f = flip (curry (a,b) -> a / b)(2)
            eql f(8), 4

        it 'is commutative for partially applied curried functions', ->
            f = flip (f1 = (curry (a,b) -> a / b)(2))
            assert.ok flip(f), f1

    describe '(a,b,c) ->', ->

        f = flip (f1 = (a,b,c) -> a / (b / c))

        it 'flips the arguments to (c,b,a) ->', ->
            eql f(2, 3, 12), 8

        it 'keeps arity', ->
            eql arity(f), 3

        it 'is commutative', ->
            eql flip(f), f1

        it 'flips curried functions', ->
            f = flip curry (a,b,c) -> a / (b / c)
            eql f(2,3,12), 8
            eql f(12)(3)(2), 8

        it 'is commutative for curried functions', ->
            f = flip (f1 = curry (a,b,c) -> a / (b / c))
            assert.ok flip(f) == f1

        it 'flips partially applied curried functions', ->
            f = flip (curry (a,b,c) -> a / (b / c))(2)
            eql f(3,12), 8
            eql f(12)(3), 8

        it 'is commutative partially applied curried functions', ->
            f = flip (f1 = (curry (a,b,c) -> a / (b / c))(2))
            assert.ok flip(f) == f1

describe 'compose', ->

    describe '(f2,f1)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f = compose f2, f1

        it 'is turned to f2(f1)', ->
            eql f(6,4), 5

        it 'maintains arity for f1', ->
            eql arity(f), 2

    describe '(f3,f2,f1)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = compose f3, f2, f1

        it 'is turned to f3(f2(f1))', ->
            eql f(7,5), 2

        it 'maintains arity for f1', ->
            eql arity(f), 2

describe 'sequence', ->

    describe '(f1,f2)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f = sequence f1, f2

        it 'is turned to f2(f1)', ->
            eql f(6,4), 5

        it 'maintains arity for f1', ->
            eql arity(f), 2

    describe '(f1,f2,f3)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = sequence f1, f2, f3

        it 'is turned to f3(f2(f1))', ->
            eql f(7,5), 2

        it 'maintains arity for f1', ->
            eql arity(f), 2

describe 'I/ident', ->

    it 'returns the arg in', ->
        eql I(42), 42

    it 'is of arity 1', ->
        eql arity(I), 1

    it 'ignores additional args', ->
        eql I(42,2), 42

describe 'tap', ->

    f = spy I

    it 'is the mother of all side effect funcs', ->
        eql tap(42,f), 42
        eql f.args[0], [42]

    it 'is curried', ->
        eql tap(f)(42), 42

    it 'has arity 2', ->
        eql tap.length, 2

foldfn = (p, c) -> p + c / p
FN_TEST = [
    {n:'head',   s:'[] -> undef',    f:head,   ar:1, as:[[]],                eq:undefined}
    {n:'head',   s:'[a] -> a',       f:head,   ar:1, as:[[1,2,3]],           eq:1}
    {n:'tail',   s:'[] -> []',       f:tail,   ar:1, as:[[]],                eq:[]}
    {n:'tail',   s:'[a] -> [a]',     f:tail,   ar:1, as:[[1,2,3]],           eq:[2,3]}
    {n:'last',   s:'[] -> undef',    f:last,   ar:1, as:[[]],                eq:undefined}
    {n:'last',   s:'[a] -> a',       f:last,   ar:1, as:[[1,2,3]],           eq:3}
    {n:'concat', s:'a, a -> [a]',    f:concat, ar:0, as:[0,1,2,3],           eq:[0,1,2,3]}
    {n:'concat', s:'[a], a -> [a]',  f:concat, ar:0, as:[[0,1],2],           eq:[0,1,2]}
    {n:'concat', s:'a, [a] -> [a]',  f:concat, ar:0, as:[0,1,[2,3]],         eq:[0,1,2,3]}
    {n:'concat', s:'[a], [a] -> [a]',f:concat, ar:0, as:[[0,1],[2,3]],       eq:[0,1,2,3]}
    {n:'each',   s:'[a], fn -> undef',f:each,  ar:2, as:[[0,1,2],((a) -> a + 1)],  eq:undefined}
    {n:'map',    s:'[a], fn -> [a]', f:map,    ar:2, as:[[0,1,2],((a) -> a + 1)],  eq:[1,2,3]}
    {n:'filter', s:'[a], fn -> [a]', f:filter, ar:2, as:[[0,1,2],((a) -> a % 2)],  eq:[1]}
    {n:'fold',   s:'[a], fn, v -> *',f:fold,   ar:3, as:[[24,28],foldfn,12], eq:16}
    {n:'fold1',  s:'[a], fn -> *',   f:fold1,  ar:2, as:[[12,24,28],foldfn], eq:16}
    {n:'foldr',  s:'[a], fn, v -> *',f:foldr,  ar:3, as:[[28,24],foldfn,12], eq:16}
    {n:'foldr1', s:'[a], fn -> *',   f:foldr1, ar:2, as:[[28,24,12],foldfn], eq:16}
    {n:'all',    s:'[a], fn -> b',   f:all,    ar:2, as:[[0,1,2],((a) -> a >= 0)], eq:true}
    {n:'any',    s:'[a], fn -> b',   f:any,    ar:2, as:[[0,1,2],((a) -> a > 1)],  eq:true}
    {n:'join',   s:'[a], s -> s',    f:join,   ar:2, as:[[0,1,2],'-'],       eq:'0-1-2'}
    {n:'reverse',s:'[a] -> [a]',     f:reverse,ar:1, as:[[0,1,2]],           eq:[2,1,0]}
    {n:'split',  s:'s, s -> s',      f:split,  ar:2, as:['a#b','#'],         eq:['a','b']}
    {n:'match',  s:'s, re -> null',  f:match,  ar:2, as:['abc','d'],         eq:null}
    {n:'match',  s:'s, s -> [s]',    f:match,  ar:2, as:['abc','b'], eq:'abc'.match('b')}
    {n:'match',  s:'s, re -> [s]',   f:match,  ar:2, as:['abc',/b/], eq:'abc'.match(/b/)}
    {n:'replace',s:'s, s, s -> s',   f:replace,ar:3, as:['aba','a','b'],     eq:'bba'}
    {n:'replace',s:'s, re, s -> s',  f:replace,ar:3, as:['aba',/a/g,'b'],    eq:'bbb'}
    {n:'search', s:'s, s -> b',      f:search, ar:2, as:['aaaca', 'c'],      eq:3}
    {n:'search', s:'s, re -> b',     f:search, ar:2, as:['aaaca', /ac/],     eq:2}
    {n:'slice',  s:'s, n, n -> s',   f:slice,  ar:3, as:['abcdef', 1, 3],    eq:'bc'}
    {n:'drop',   s:'s, n -> s',      f:drop,   ar:2, as:['abcdef', 2],       eq:'cdef'}
    {n:'take'   ,s:'s, n -> s',      f:take,   ar:2, as:['abcdef', 2],       eq:'ab'}
    {n:'trim',   s:'s -> s',         f:trim,   ar:1, as:['  abc '],          eq:'abc'}
    {n:'ucase',  s:'s -> s',         f:ucase,  ar:1, as:['abc'],             eq:'ABC'}
    {n:'lcase',  s:'s -> s',         f:lcase,  ar:1, as:['ABC'],             eq:'abc'}
    {n:'sort',   s:'[a], f -> [a]',  f:sort,   ar:2, as:[[2,3,1],undefined], eq:[1,2,3]}
    {n:'sort',   s:'[a], f -> [a]',  f:sort,   ar:2, as:[[2,3,1],(a,b)->b-a],eq:[3,2,1]}
    {n:'uniq',   s:'null -> null',   f:uniq,   ar:1, as:[null],              eq:null}
    {n:'uniq',   s:'[a] -> [a]',     f:uniq,   ar:1, as:[[]],                eq:[]}
    {n:'uniq',   s:'[a] -> [a]',     f:uniq,   ar:1, as:[[1,2,2,1,2,3]],     eq:[1,2,3]}
    {n:'index',  s:'[a], a -> n',    f:index,  ar:2, as:[[1,2,3,4], 3],      eq:2}
    {n:'index',  s:'[a], a -> n',    f:index,  ar:2, as:[[1,2,3,4], 5],      eq:-1}
    {n:'contains',s:'[a], a -> b',   f:contains,ar:2,as:[[1,2,3,4], 3],      eq:true}
    {n:'contains',s:'[a], a -> b',   f:contains,ar:2,as:[[1,2,3,4], 5],      eq:false}
    {n:'has',    s:'{k:v}, k -> b',  f:has,    ar:2, as:[{a:1,b:2}, 'b'],    eq:true}
    {n:'get',    s:'{k:v}, k -> v',  f:get,    ar:2, as:[{a:1,b:2}, 'b'],    eq:2}
    {n:'set',    s:'{k:v}, k, v -> v',f:set,   ar:3, as:[{a:1,b:2}, 'b', 3], eq:{a:1,b:3}}
    {n:'keys',   s:'{k:v} -> [k]',   f:keys,   ar:1, as:[{a:1,b:2}],         eq:['a','b']}
    {n:'values', s:'{k:v} -> [v]',   f:values, ar:1, as:[{a:1,b:2}],         eq:[1,2]}
    {n:'add',    s:'a, a -> a',      f:add,    ar:2, as:[12,2],              eq:14}
    {n:'add',    s:'a... -> a',      f:add,    ar:2, as:[12,2,3],            eq:17}
    {n:'sub',    s:'a, a -> a',      f:sub,    ar:2, as:[12,2],              eq:10}
    {n:'sub',    s:'a... -> a',      f:sub,    ar:2, as:[12,2,3],            eq:7}
    {n:'mul',    s:'a, a -> a',      f:mul,    ar:2, as:[12,2],              eq:24}
    {n:'mul',    s:'a... -> a',      f:mul,    ar:2, as:[12,2,3],            eq:72}
    {n:'div',    s:'a, a -> a',      f:div,    ar:2, as:[12,2],              eq:6}
    {n:'div',    s:'a... -> a',      f:div,    ar:2, as:[12,2,3],            eq:2}
    {n:'mod',    s:'a, a -> a',      f:mod,    ar:2, as:[17,6],              eq:5}
    {n:'mod',    s:'a... -> a',      f:mod,    ar:2, as:[17,6,3],            eq:2}
    {n:'min',    s:'a, a -> a',      f:min,    ar:2, as:[12,2],              eq:2}
    {n:'min',    s:'a... -> a',      f:min,    ar:2, as:[12,3,2],            eq:2}
    {n:'max',    s:'a, a -> a',      f:max,    ar:2, as:[12,2],              eq:12}
    {n:'max',    s:'a... -> a',      f:max,    ar:2, as:[3,2,12],            eq:12}
    {n:'gt',     s:'a, a -> a',      f:gt,     ar:2, as:[12,11],             eq:true}
    {n:'gt',     s:'a, a -> a',      f:gt,     ar:2, as:[12,12],             eq:false}
    {n:'gte',    s:'a, a -> a',      f:gte,    ar:2, as:[12,12],             eq:true}
    {n:'gte',    s:'a, a -> a',      f:gte,    ar:2, as:[12,13],             eq:false}
    {n:'lt',     s:'a, a -> a',      f:lt,     ar:2, as:[11,12],             eq:true}
    {n:'lt',     s:'a, a -> a',      f:lt,     ar:2, as:[12,12],             eq:false}
    {n:'lte',    s:'a, a -> a',      f:lte,    ar:2, as:[12,12],             eq:true}
    {n:'lte',    s:'a, a -> a',      f:lte,    ar:2, as:[13,12],             eq:false}
    {n:'eq',     s:'a, a -> b',      f:eq,     ar:2, as:[0,0],               eq:true}
    {n:'eq',     s:'a, a -> b',      f:eq,     ar:2, as:[1,0],               eq:false}
    {n:'eq',     s:'a, a -> b',      f:eq,     ar:2, as:[{},{}],             eq:false}
    {n:'eq',     s:'a... -> b',      f:eq,     ar:2, as:[1,1,2],             eq:false}
    {n:'eq',     s:'a... -> b',      f:eq,     ar:2, as:[false,false,false], eq:true}
    {n:'eq',     s:'a... -> b',      f:eq,     ar:2, as:[0,0,1],             eq:false}
    {n:'not',    s:'a..., a -> b',   f:nnot,   ar:2, as:[false, I],            eq:true}
    {n:'not',    s:'a..., a -> b',   f:nnot,   ar:2, as:[0,1,(a,b) -> b == 1], eq:false}
    {n:'pick',s:'{k:v}, [k] -> {k:v}',f:pick,  ar:2, as:[{a:1,b:2,c:3},['b','c']], eq:{b:2,c:3}}
    {n:'pick',s:'{k:v}, k -> {k:v}',  f:pick,  ar:2, as:[{a:1,b:2,c:3},'b','c'],   eq:{b:2,c:3}}
    {n:'pick',s:'{k:v}, k -> {k:v}',  f:pick,  ar:2, as:[{a:1,b:2,c:3},'b'],       eq:{b:2}}
    {n:'evolve', s:'{k:v}, {k:(v->v)} -> {k:v}', f:evolve, ar:2,
    as:[{a:1,b:2},{}], eq:{a:1,b:2}}
    {n:'evolve', s:'{k:v}, {k:(v->v)} -> {k:v}', f:evolve, ar:2,
    as:[{a:1,b:2},{a:(v) -> v+1}], eq:{a:2,b:2}}
    {n:'omap',s:'{k:v}, ((k,v) -> v) -> {k:v}', f:omap, ar:2,
    as:[{a:1,b:2,c:3},(k,v) -> if k == 'b' then v + 40 else v], eq:{a:1,b:42,c:3}}
    {n:'ofilter',s:'{k:v}, ((k,v) -> Boolean) -> {k:v}', f:ofilter, ar:2,
    as:[{a:1,b:2,c:3},(k,v) -> k == 'b'], eq:{b:2}}

]

FN_TEST.forEach (spec) ->
    describe spec.n, ->
        it "has signature #{spec.s}", ->
            eql spec.f(spec.as...), spec.eq
        if spec.ar == spec.as.length
            if spec.ar > 1
                it "has a curried variant", ->
                    if spec.ar == 2
                        eql spec.f(spec.as[1])(spec.as[0]), spec.eq
                    else if spec.ar == 3
                        eql spec.f(spec.as[2])(spec.as[1])(spec.as[0]), spec.eq
            it "is of arity(#{spec.ar})", ->
                eql spec.f.length, spec.ar

describe 'map', ->

    as = split('abc', '')

    it 'doesnt pass multiple args to map function', ->
        map as, (v, i, as) ->
            eql i, undefined
            eql as, undefined
            v

describe 'fold/fold1/foldr/foldr1', ->

    fs = [fold, fold1, foldr, foldr1]
    as = [0,1,2,3]

    each fs, (f) ->
        it 'doesnt pass multiple args to fold function', ->
            f as, ((p, c, i, as) ->
                eql i, undefined
                eql as,  undefined
                p + c), 1

describe 'and', ->

    gt10 = even = lt102 = null

    beforeEach ->
        gt10  = spy gt(10)
        even  = spy (n) -> n % 2 == 0
        lt102 = spy lt(102)

    it 'is of arity(2)', ->
        eql arity(aand), 2

    it 'wraps two functions f, g and invokes both with &&', ->
        f = aand(gt10, even)
        eql f(100, 42), true
        eql gt10.callCount, 1
        eql gt10.args[0], [100, 42]
        eql even.callCount, 1
        eql even.args[0], [100, 42]
        eql f(8), false

    it 'wraps moar functions f, g, h and invokes both with &&', ->
        f = aand(gt10, even, lt102)
        eql f(100,42), true
        eql gt10.callCount, 1
        eql gt10.args[0], [100, 42]
        eql even.callCount, 1
        eql even.args[0], [100, 42]
        eql lt102.callCount, 1
        eql lt102.args[0], [100, 42]
        eql f(102), false

    it 'is lazy', ->
        f1 = spy -> false
        f2 = spy -> true
        f = aand f1, f2
        eql f(), false
        eql f1.callCount, 1
        eql f2.callCount, 0


    it 'is aliased', ->
        assert.ok F.and == F.aand

describe 'or', ->

    gt10 = even = lt102 = null

    beforeEach ->
        gt10  = spy gt(10)
        even  = spy (n) -> n % 2 == 0
        lt102 = spy lt(102)

    it 'is of arity(2)', ->
        eql arity(oor), 2

    it 'wraps two functions f, g and invokes both with ||', ->
        f = oor(gt10, even)
        eql f(8, 42), true
        eql gt10.callCount, 1
        eql gt10.args[0], [8, 42]
        eql even.callCount, 1
        eql even.args[0], [8, 42]
        eql f(9), false

    it 'wraps moar functions f, g, h and invokes both with ||', ->
        f = oor(gt10, even, lt102)
        eql f(9,42), true
        eql gt10.args, [[9,42]]
        eql even.args, [[9, 42]]
        eql lt102.args, [[9, 42]]

    it 'is lazy', ->
        f1 = spy -> true
        f2 = spy -> false
        f = oor f1, f2
        eql f(), true
        eql f1.callCount, 1
        eql f2.callCount, 0

    it 'is aliased', ->
        assert.ok F.or == F.oor

describe 'not', ->

    gt10 = null

    beforeEach ->
        gt10  = spy gt(10)

    it 'is of arity(2)', ->
        eql arity(nnot), 2

    it 'wraps a function and nots the output', ->
        f = nnot(gt10)
        eql f(12), false
        eql gt10.callCount, 1
        eql gt10.args[0], [12]

    it 'is aliased', ->
        assert.ok F.not == F.nnot

describe 'chainable', ->

    it 'makes chainable functions for arity == 1', ->

        f = (a) -> a + 14
        chainable 'f', f
        g = div(2).f
        eql g(100), 64

    it 'makes chainable functions for arity >= 2', ->

        f = (a,b) -> if a == 42 then b else 0
        chainable 'guard42', f
        g = div(2).guard42(17)
        eql g(100), 0
        eql g(84), 17

    it 'wants arity >= 1', ->
        assert.throw (->chainable('fail',->)), 'No chainable for arity 0'

    it 'can redefine a chainable', ->
        f1 = (a) -> 0
        chainable 'f', f1
        f2 = (b) -> 1
        chainable 'f', f2
        g = add(3).f
        eql g(4), 1

describe 'eql', ->

    TYPES.forEach (v1, i1) -> TYPES.forEach (v2, i2) ->
        s1 = JSON.stringify(v1.v)
        s2 = JSON.stringify(v2.v)
        if i1 == i2
            it "equals for #{s1}, #{s2}", ->
                eql F.eql(v1.v, v2.v), true
        else
            it "not equals for #{s1}, #{s2}", ->
                eql F.eql(v1.v, v2.v), false

describe 'groupby', ->

    it 'is is arity 2', ->
        eql arity(groupby), 2

    it 'groups objects according to key function', ->
        as = [{n:'apa'},{n:'banan'},{n:'ananas'}]
        fn = compose take(1), get('n')
        gs = groupby as, fn
        eql gs, {
            a: [{n:'apa'},{n:'ananas'}]
            b: [{n:'banan'}]
        }

    it 'handles empty', ->
        eql groupby([], ->), {}

    it 'is curried', ->
        as = [{n:'apa'}]
        fn = compose take(1), get('n')
        gs = groupby(fn)(as)
        eql gs, a:[{n:'apa'}]

describe 'tuple', ->

    jst = JSON.stringify

    it 'creates a tuple from 2 args', ->
        t = tuple 22, 23
        eql jst(t), '{"0":22,"1":23}'

    it 'creates a tuple from 3 args', ->
        t = tuple 22, 23, 24
        eql jst(t), '{"0":22,"1":23,"2":24}'

    it 'is arity 2', ->
        eql arity(tuple), 2

    it 'is curried', ->
        f = tuple 23
        t = f 22
        eql jst(t), '{"0":22,"1":23}'

    it 'is vararg curried', ->
        f = tuple 24
        t = f 22, 23
        eql jst(t), '{"0":22,"1":23,"2":24}'

    it 'unpacks with fst', ->
        t = tuple 22, 23, 24
        eql fst(t), 22

    it 'unpacks with snd', ->
        t = tuple 22, 23, 24
        eql snd(t), 23

    it 'unpacks with nth', ->
        t = tuple 22, 23, 24
        eql nth(2)(t), 24

    it 'unpacks with length for len', ->
        t = tuple 22, 23
        eql len(t), 2
        t = tuple 22, 23, 24
        eql len(t), 3

    it 'deep equals with eql', ->
        t1 = tuple [a:1], {c:[2]}
        t2 = tuple [a:1], {c:[2]}
        assert.ok F.eql t1, t2
        t1 = tuple [a:1], tuple(2,3)
        t2 = tuple [a:1], tuple(2,3)
        assert.ok F.eql t1, t2
        t1 = tuple [a:1], tuple(2,3), 3
        t2 = tuple [a:1], tuple(2,3)
        assert.ok not F.eql t1, t2

    describe 'unpack', ->

        it 'unpacks to function', ->
            t = tuple 1, 2, 3
            eql (unpack t, (as...) -> as), [1,2,3]

        it 'is arity 2', ->
            eql arity(unpack), 2

        it 'is curried', ->
            t = tuple 1, 2, 3
            f = unpack (as...) -> as
            eql f(t), [1,2,3]

describe 'zip', ->

    describe 'based on generic zipwith', ->

        it 'is arity 3', ->
            eql arity(zipwith), 3

        it 'is curried', ->
            f = zipwith(add)
            r = f [1,2], [3,4]
            eql r, [4,6]

        it 'is vararg curried', ->
            f = zipwith(add)
            r = f [1,2], [3,4], [5,6]
            eql r, [9,12]

        it 'works for strings', ->
            r = zipwith((as...) -> join(as,'-')) 'ab', 'de'
            eql r, ['a-d', 'b-e']

    describe 'to tuples', ->

        it 'is an array of tuples', ->
            r = zip [1,2], [3,4]
            eql type(r), 'array'
            eql type(r[0]), 'tuple'
            eql r.toString(), '[tuple {"0":1,"1":3}],[tuple {"0":2,"1":4}]'

        it 'is arity 2', ->
            eql arity(zip), 2

        it 'is curried', ->
            z = zip [3,4]
            r = z [1,2]
            eql r.toString(), '[tuple {"0":1,"1":3}],[tuple {"0":2,"1":4}]'

        it 'is vararg curried', ->
            z = zip [5,6]
            r = z [1,2], [3,4]
            eql r.toString(), '[tuple {"0":1,"1":3,"2":5}],[tuple {"0":2,"1":4,"2":6}]'

        it 'handles strings', ->
            r = zip 'ab', 'de'
            eql r.toString(), '[tuple {"0":"a","1":"d"}],[tuple {"0":"b","1":"e"}]'


        describe 'unzips with unzip', ->

            it 'is arity 1', ->
                eql arity(unzip), 1

            it 'goes backwards to tuple', ->
                r = zip [1,2], [3,4]
                u = unzip r
                eql type(u), 'tuple'
                eql fst(u), [1,2]
                eql snd(u), [3,4]

            it 'is vararg number of zipped tuples', ->
                r = zip [1,2], [3,4], [5,6]
                u = unzip r
                eql type(u), 'tuple'
                eql fst(u), [1,2]
                eql snd(u), [3,4]
                eql nth(2)(u), [5,6]
