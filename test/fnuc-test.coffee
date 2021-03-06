if browsertest?
    `sinon = window.sinon`
    `chai = window.chai`
    `expect = window.chai.expect`
    `F = window.F`
    `Q = window.Q`
else
    chai   = require 'chai'
    chai.use(require 'sinon-chai')
    sinon = require 'sinon'
    F = require('../src/fnuc')
    Q = require 'q'
    delete global.__fnuc
    F.expose(global)

assert = chai.assert
eql = assert.deepEqual

later = (f) -> (Q.Promise (rs) -> setTimeout rs, 1).then f
fuze  = (v) -> Q.Promise (rs, rj) -> setTimeout (->rj v), 1

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
        it 'overwrites undefined values', -> eql merge({a:1},{a:undefined}), a:undefined
        it 'leaves undefined in first be', ->
            eql merge({a:undefined},{b:2}), {a:undefined,b:2}

describe 'mixin', ->

    describe 'returns a new object with all arguments merged and', ->

        it 'handles one object with curry', ->
            f = mixin a:1
            r = f b:2
            eql r, {a:1,b:2}
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
        it 'overwrites undefined values', ->
            eql mixin(a = {a:1},{a:undefined}), a:undefined
            eql a, a:1
        it 'leaves undefined in first be', ->
            eql mixin(a = {a:undefined},{b:2}), {a:undefined, b:2}
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
        eql arityof(->), 0
        eql arityof((a)->), 1
        eql arityof((a,b)->), 2

    it 'chops the arity to the given number if (f,n)', ->
        eql arityof(arity(((a,b,c)->),n)), n for n in [0..10]

    it 'has a curried variant for (n)', ->
        eql arityof(arity(n)((a,b,c)->)), n for n in [0..10]

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

        it 'function for arity(0)', ->
            f = partial (->42)
            eql f(), 42

        it 'function for arity(0) with arguments', ->
            f = partial (s = spy ->42), 1, 2, 3
            eql f(4,5), 42
            eql s.args[0], [1,2,3,4,5]

        it 'handles arity(1)', ->
            r = partial ((a) -> a + 42)
            assert.isFunction r
            eql r(1,2,3), 43

        it 'function for arity(1) with arguments', ->
            fn = partial ((a) -> a + 42), 1, 2
            eql fn(), 43

        it 'works for arity(2)', ->
            r = partial ((a,b) -> a / b), 42
            assert.isFunction r
            eql arityof(r), 1
            eql r(2,3,4), 21

        it 'function for arity(2) with arguments', ->
            fn = partial ((a,b) -> a / b), 42, 2
            eql fn(), 21

        describe 'for arity(3)', ->

            it 'works with one arg', ->
                r = partial ((a,b,c) -> a / (b / c)), 12
                assert.isFunction r
                eql arityof(r), 2
                eql r(3,2,5), 8

            it 'produces a curried function', ->
                r = partial ((a,b,c) -> a / (b / c)), 12
                eql r(2)(3), 8

            it 'works with two arg', ->
                r = partial ((a,b,c) -> a / (b / c)), 12, 3
                assert.isFunction r
                eql arityof(r), 1
                eql r(2,5), 8

            it 'function with arguments', ->
                f = partial (s = spy (a,b,c) -> a / (b / c)), 12, 3, 2, 5
                eql f(4,5), 8
                eql s.args[0], [12,3,2,5,4,5]

describe 'partialr', ->

    describe 'partially fills in arguments from the right', ->

        it 'function for arity(0)', ->
            f = partialr (->42)
            eql f(), 42

        it 'function for arity(0) with arguments', ->
            f = partialr (s = spy ->42), 1, 2, 3
            eql f(4,5), 42
            eql s.args[0], [1,2,3]

        it 'handles arity(1)', ->
            r = partialr ((a) -> a + 42)
            assert.isFunction r
            eql r(1,2,3), 43

        it 'function for arity(1) with arguments', ->
            f = partialr ((a) -> a + 42), 1, 2
            eql f(), 43

        it 'works for arity(2)', ->
            r = partialr ((a,b) -> a / b), 2
            assert.isFunction r
            eql arityof(r), 1
            eql r(42,3,4), 21

        it 'function for arity(2) with arguments', ->
            f = partialr (s = spy (a,b) -> a / b), 42, 2
            eql f(10,5), 21
            eql s.args[0], [42, 2]

        describe 'for arity(3)', ->

            it 'works with one arg', ->
                r = partialr ((a,b,c) -> a / (b / c)), 2
                assert.isFunction r
                eql arityof(r), 2
                eql r(12,3,5), 8

            it 'produces a curried function', ->
                r = partialr ((a,b,c) -> a / (b / c)), 2
                eql r(3)(12), 8

            it 'works with two arg', ->
                r = partialr ((a,b,c) -> a / (b / c)), 3, 2
                assert.isFunction r
                eql arityof(r), 1
                eql r(12,5), 8

            it 'function with arguments', ->
                f = partialr ((a,b,c) -> a / (b / c)), 12, 3, 2, 5
                eql f(), 8

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
            eql arityof(div), 2

        it 'returns a smaller arity func after partial apply', ->
            div2 = div(2)
            eql arityof(div2), 1

        it 'can still apply (a,b) to curried (a,b) ->', ->
            eql div(10, 2), 5

    describe '(a,b,c) ->', ->

        divt = curry (a,b,c) -> a / (b / c)

        it 'turns to (c) -> (b) -> (a) ->', ->
            div2 = divt(2)
            div4 = div2(8)
            eql div4(80), 20

        it 'maintains arity for curried func', ->
            eql arityof(divt), 3

        it 'returns a small arity func after partial apply', ->
            div2 = divt(2)
            div4 = div2(8)
            eql arityof(div2), 2
            eql arityof(div4), 1

        it 'can be partially applied with (b,c)', ->
            div4 = divt(8, 2)
            eql div4(80), 20

        it 'does correct arity for partial applied', ->
            div4 = divt(8, 2)
            eql arityof(div4), 1

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
            eql arityof(f), 2

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
            eql arityof(f), 3

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
            eql arityof(f), 2

    describe '(f3,f2,f1)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = compose f3, f2, f1

        it 'is turned to f3(f2(f1))', ->
            eql f(7,5), 2

        it 'maintains arity for f1', ->
            eql arityof(f), 2

        it 'composes vararg funs', (done) ->
            fn = compose (as...) ->
                eql as, [1,2,3]
                done()
            fn 1, 2, 3

describe 'pipe', ->

    describe '(f1,f2)', ->

        f1 = (a,b) -> a + b
        f2 = div(10)
        calc = pipe f1, f2

        it 'is turned to f2(f1)', ->
            eql calc(6,4), 1

        it 'maintains arity for f1', ->
            eql arityof(calc), 2
            eql arityof(pipe (->), I), 0
            eql arityof(pipe ((a)->), I), 1
            eql arityof(pipe ((a,b)->), I), 2
            eql arityof(pipe ((a,b,c)->), I), 3

        it 'allows promises as arg', ->
            calc(later(->10),20).then (v) -> eql v, 3

        it 'can take promises as result of pipe steps', ->
            addl = (a, b) -> later -> a + b # return promise
            calcl = pipe addl, f2
            calcl(10,20).then (v) -> eql v, 3

        it 'pipes vararg funs', (done) ->
            fn = pipe (as...) ->
                eql as, [1,2,3]
                done()
            fn 1, 2, 3

        it 'is curried', ->
            eql calc(4)(6), 1

        it 'can pipe curried functions', ->
            fn = pipe split(' '), pick
            dopick = fn 'abc'
            eql dopick({abc:42,def:43}), abc:42

    describe '(f1,f2,f3)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = pipe f1, f2, f3

        it 'is turned to f3(f2(f1))', ->
            eql f(7,5), 2

        it 'maintains arity for f1', ->
            eql arityof(f), 2

        it 'is curried', ->
            eql f(5)(7), 2

        it 'maintains arity 0 for f1, even though it hurts', ->
            f0 = ->
            eql arityof(f0), 0
            eql arityof(pipe(f0)), 0

    describe '(f1,f2,pfail,f3)', ->

        f1 = (a,b) -> a + b
        f2 = (a) -> a / 2
        f3 = (a) -> "f3 " + a
        pf = pfail (err) -> "did #{err}"
        f = pipe f1, f2, pf, f3

        it 'ignores pfail when no rejected promise', ->
            f(Q(7),3).then (r) -> eql r, 'f3 5'

        it 'invokes pfail if invoked with rejected promise', ->
            f(fuze('reject'),3).then (r) -> eql r, 'f3 did reject'

        it 'invokes pfail if any function introduces a rejected promise', ->
            f2e = (a) -> fuze 'reject'
            fe = pipe f1, f2e, pf, f3
            fe(7,3).then (r) -> eql r, 'f3 did reject'

describe 'I', ->

    it 'returns the arg in', ->
        eql I(42), 42

    it 'is of arity 1', ->
        eql arityof(I), 1

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
    {n:'head',   s:'"" -> undef',    f:head,   ar:1, as:[""],                eq:undefined}
    {n:'head',   s:'s -> s',         f:head,   ar:1, as:["123"],             eq:"1"}
    {n:'tail',   s:'"" -> ""',       f:tail,   ar:1, as:[""],                eq:""}
    {n:'tail',   s:'s -> s',         f:tail,   ar:1, as:["123"],             eq:"23"}
    {n:'last',   s:'"" -> undef',    f:last,   ar:1, as:[""],                eq:undefined}
    {n:'last',   s:'s -> a',         f:last,   ar:1, as:["123"],             eq:"3"}
    {n:'lastfn', s:'[a], fn -> a',   f:lastfn, ar:2, as:[[1,2,3,4],((a)->a%2)], eq:3}
    {n:'concat', s:'a, a -> [a]',    f:concat, ar:2, as:[0,1,2,3],           eq:[0,1,2,3]}
    {n:'concat', s:'[a], a -> [a]',  f:concat, ar:2, as:[[0,1],2],           eq:[0,1,2]}
    {n:'concat', s:'a, [a] -> [a]',  f:concat, ar:2, as:[0,1,[2,3]],         eq:[0,1,2,3]}
    {n:'concat', s:'[a], [a] -> [a]',f:concat, ar:2, as:[[0,1],[2,3]],       eq:[0,1,2,3]}
    {n:'each',   s:'[a], fn -> undef',f:each,  ar:2, as:[[0,1,2],((a) -> a + 1)],  eq:undefined}
    {n:'map',    s:'[a], fn -> [a]', f:map,    ar:2, as:[[0,1,2],((a) -> a + 1)],  eq:[1,2,3]}
    {n:'filter', s:'[a], fn -> [a]', f:filter, ar:2, as:[[0,1,2],((a) -> a % 2)],  eq:[1]}
    {n:'firstfn',s:'[a], fn -> a',   f:firstfn,ar:2, as:[[0,1,2,3],((a)->a%2)], eq:1}
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
    {n:'uniqfn', s:'null -> null',   f:uniqfn, ar:2, as:[null, I],           eq:null}
    {n:'uniqfn', s:'[a] -> [a]',     f:uniqfn, ar:2, as:[[], I],             eq:[]}
    {n:'uniqfn', s:'[a] -> [a]',     f:uniqfn, ar:2, as:[[1,4,2,1,2,3],(a)->a%2],eq:[1,4]}
    {n:'index',  s:'[a], a -> n',    f:index,  ar:2, as:[[1,2,3,4], 3],      eq:2}
    {n:'index',  s:'[a], a -> n',    f:index,  ar:2, as:[[1,2,3,4], 5],      eq:-1}
    {n:'indexfn',s:'[a], fn -> n',   f:indexfn,ar:2, as:[[1,2,3,4],(a)->a%2==0], eq:1}
    {n:'indexfn',s:'[a], fn -> n',   f:indexfn,ar:2, as:[[1,2,3,4],(a)->a>4], eq:-1}
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
    {n:'and',    s:'a, a -> b',      f:aand,   ar:2, as:[12,2],              eq:true}
    {n:'and',    s:'a, a -> b',      f:aand,   ar:2, as:[12,null],           eq:false}
    {n:'and',    s:'a, a, a -> b',   f:aand,   ar:2, as:[12,1,0],            eq:false}
    {n:'or',     s:'a, a -> b',      f:oor,    ar:2, as:[12,2],              eq:true}
    {n:'or',     s:'a, a -> b',      f:oor,    ar:2, as:[12,null],           eq:true}
    {n:'or',     s:'a, a, a -> b',   f:oor,    ar:2, as:[null,null,4],       eq:true}
    {n:'not',    s:'a -> b',         f:nnot,   ar:1, as:[12],                eq:false}
    {n:'not',    s:'a -> b',         f:nnot,   ar:1, as:[null],              eq:true}
    {n:'pick',s:'{k:v}, [k] -> {k:v}',f:pick,  ar:2, as:[{a:1,b:2,c:3},['b','c']], eq:{b:2,c:3}}
    {n:'pick',s:'{k:v}, k -> {k:v}',  f:pick,  ar:2, as:[{a:1,b:2,c:3},'b','c'],   eq:{b:2,c:3}}
    {n:'pick',s:'{k:v}, k -> {k:v}',  f:pick,  ar:2, as:[{a:1,b:2,c:3},'b'],       eq:{b:2}}
    {n:'omap',s:'{k:v}, ((k,v) -> v) -> {k:v}', f:omap, ar:2,
    as:[{a:1,b:2,c:3},(k,v) -> if k == 'b' then v + 40 else v], eq:{a:1,b:42,c:3}}
    {n:'evolve', s:'{k:v}, {k:(v->v)} -> {k:v}', f:evolve, ar:2,
    as:[{a:1,b:2},{}], eq:{a:1,b:2}}
    {n:'evolve', s:'{k:v}, {k:(v->v)} -> {k:v}', f:evolve, ar:2,
    as:[{a:1,b:2},{a:(v) -> v+1}], eq:{a:2,b:2}}
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

describe 'both', ->

    gt10 = even = lt102 = null

    beforeEach ->
        gt10  = spy gt(10)
        even  = spy (n) -> n % 2 == 0
        lt102 = spy lt(102)

    it 'is of arity(2)', ->
        eql arityof(both), 2

    it 'produces a function of arity(1)', ->
        eql arityof(both I,I,I), 1

    it 'wraps two functions f, g and invokes both with &&', ->
        f = both(gt10, even)
        eql f(100, 42), true
        eql gt10.callCount, 1
        eql gt10.args[0], [100, 42]
        eql even.callCount, 1
        eql even.args[0], [100, 42]
        eql f(8), false

    it 'wraps moar functions f, g, h and invokes both with &&', ->
        f = both(gt10, even, lt102)
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
        f = both f1, f2
        eql f(), false
        eql f1.callCount, 1
        eql f2.callCount, 0


describe 'either', ->

    gt10 = even = lt102 = null

    beforeEach ->
        gt10  = spy gt(10)
        even  = spy (n) -> n % 2 == 0
        lt102 = spy lt(102)

    it 'is of arity(2)', ->
        eql arityof(either), 2

    it 'produces a function of arity(1)', ->
        eql arityof(either I,I,I), 1

    it 'wraps two functions f, g and invokes both with ||', ->
        f = either(gt10, even)
        eql f(8, 42), true
        eql gt10.callCount, 1
        eql gt10.args[0], [8, 42]
        eql even.callCount, 1
        eql even.args[0], [8, 42]
        eql f(9), false

    it 'wraps moar functions f, g, h and invokes both with ||', ->
        f = either(gt10, even, lt102)
        eql f(9,42), true
        eql gt10.args, [[9,42]]
        eql even.args, [[9, 42]]
        eql lt102.args, [[9, 42]]

    it 'is lazy', ->
        f1 = spy -> true
        f2 = spy -> false
        f = either f1, f2
        eql f(), true
        eql f1.callCount, 1
        eql f2.callCount, 0

describe 'comp', ->

    gt10 = null

    beforeEach ->
        gt10  = spy gt(10)

    it 'is of arity(1)', ->
        eql arityof(comp), 1

    it 'produces a function of arity(1)', ->
        eql arityof(comp I), 1

    it 'wraps a function and nots the output', ->
        f = comp(gt10)
        eql f(12), false
        eql gt10.callCount, 1
        eql gt10.args[0], [12]

    it 'accepts variadic', ->
        f = comp (g = spy I)
        eql f(1,2), false
        eql g.args[0], [1,2]

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

describe 'zip', ->

    describe 'based on generic zipwith', ->

        it 'is arity 3', ->
            eql arityof(zipwith), 3

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

    describe 'to array', ->

        it 'is an array of arrays', ->
            r = zip [1,2], [3,4]
            eql type(r), 'array'
            eql type(r[0]), 'array'
            eql JSON.stringify(r), '[[1,3],[2,4]]'

        it 'is arity 2', ->
            eql arityof(zip), 2

        it 'is curried', ->
            z = zip [3,4]
            r = z [1,2]
            eql JSON.stringify(r), '[[1,3],[2,4]]'

        it 'is vararg curried', ->
            z = zip [5,6]
            r = z [1,2], [3,4]
            eql JSON.stringify(r), '[[1,3,5],[2,4,6]]'

        it 'handles strings', ->
            r = zip 'ab', 'de'
            eql JSON.stringify(r), '[["a","d"],["b","e"]]'

describe 'zipobj', ->

    it 'is of arity 2', ->
        eql arityof(zipobj), 2

    it 'makes an object out of keys/values', ->
        eql zipobj(['a','b'], [1,2]), {a:1, b:2}

    it 'wants equal length arrays', ->
        eql zipobj(['a','b'], [1]), {a:1}
        eql zipobj(['a'], [1,2]), {a:1}

describe 'plift', ->

    PTYPES = [
        {v:null,      t:'null' }
        {v:42,        t:'number'}
    ]

    types = (f, check) ->

        PTYPES.forEach (t) ->

            describe "plain(#{t.t})", ->

                check -> f(t.v,t.v)

            describe "promise(#{t.t})", ->

                check -> f(later(->t.v), t.v)

    describe 'with no arg', ->
        it 'calls fun', ->
            f = plift (g = spy ->)
            f()
            eql g.args[0].length, 0

    describe 'with one arg', ->

        lifted = plift (a, av) -> [a, av]

        types lifted, (f) ->
            check = (arr) ->
                eql arr[0], arr[1]
            it 'works', ->
                ret = f()
                if ret.then
                    ret.then check
                else
                    check ret

    describe 'with two args,', ->

        lifted = curry plift (a, av, b, bv) -> [a, av, b, bv]

        types lifted, (f) -> describe 'and', -> types f(), (f) ->
            check = (arr) ->
                eql arr[0], arr[1]
                eql arr[2], arr[3]
            it 'works', ->
                ret = f()
                if ret.then
                    ret.then check
                else
                    check ret

    describe 'with varags', ->

        lifted = plift (as...) -> [as[0], as[1]]
        types lifted, (f) ->
            check = (arr) ->
                eql arr[0], arr[1]
            it 'works', ->
                ret = f()
                if ret.then
                    ret.then check
                else
                    check ret

    describe 'preserves arg order', ->

        describe 'with two args', ->

            lifted = plift (a, b) -> a / b

            it 'works for two plain', ->
                eql lifted(10,5), 2

            it 'works for first promise', ->
                lifted(Q(10), 5).then (r) ->
                    eql r, 2

            it 'works for second promise', ->
                lifted(10, Q(5)).then (r) ->
                    eql r, 2

        describe 'with three args', ->

            lifted = plift (a, b, c) -> a / (b * c)

            it 'works for two plain', ->
                eql lifted(12,3,2), 2

            it 'works for first promise', ->
                lifted(Q(12),3,2).then (r) ->
                    eql r, 2

            it 'works for second promise', ->
                lifted(12,Q(3),2).then (r) ->
                    eql r, 2

            it 'works for third promise', ->
                lifted(12,3,Q(2)).then (r) ->
                    eql r, 2

            it 'works for first and third promise', ->
                lifted(Q(12),3,Q(2)).then (r) ->
                    eql r, 2

describe 'converge', ->

    add = (a, b) -> a + b
    add3 = (a, b, c) -> a + b + c
    mul2 = mul 2
    mul3 = mul 3
    mul4 = mul 4
    div10 = div(10)
    calc = (add, div) -> "#{add}|#{div}"

    it 'is of arity 3', ->
        eql arityof(converge), 3

    describe 'accepts a function that is invoked with the results', ->

        it 'of two functions', ->
            fn = converge mul2, mul3, add
            eql fn(2), 10 # add (2*2), (3*2)

        it 'of three functions', ->
            fn = converge mul2, mul3, mul4, add3
            eql fn(2), 18

    it 'is a curry', ->
        fn = converge(add)(mul3)(mul2)
        eql fn(2), 10

    it 'curries the resulting function', ->
        fn = converge ((a,b) -> a + b), ((a,b,c) -> a + b + c), add
        eql arityof(fn), 3
        eql fn(2)(3)(4), 16  # add (4+3), (4+3+2)

    it 'allows promises as arg', ->
        fn = converge add, div10, calc
        fn(later(->10),2).then (v) -> eql v, "12|0.5"

    it 'can take promises as result of func step', ->
        addl = (a, b) -> later -> a + b # return promise
        fn = converge addl, div10, calc
        fn(10,2).then (v) -> eql v, "12|0.5"

    it 'can pfail as after fn', ->
        fn = converge mul2, mul3, pfail (err) -> "did #{err}"
        fn(fuze('reject')).then (r) -> eql r, 'did reject'

    it 'converges vararg funs', (done) ->
        a = (as...) -> as[1]
        b = (as...) -> as[2]
        fn = converge a, b, (a, b) ->
            eql a, 2
            eql b, 3
            done()
        fn 1, 2, 3

    it 'deals with arity 0', (done) ->
        a = (a) -> 1
        b = -> 2
        fn = converge a, b, -> done()
        fn 1

    it 'isnt crazy with pipe', ->
        norun = -> throw new Error("Nooo!")
        converge norun, pipe(norun), norun
        converge norun, pipe(norun, I), norun

describe 'apply', ->

    it 'applies a function', ->
        eql apply(Math.max)([2,4,3]), 4

describe 'unapply', ->

    it 'turns positional arguments into indexed', ->
        eql unapply(join(','))(1,2,3), '1,2,3'

describe 'iif', ->

    it 'is arity 3', ->
        eql arityof(iif), 3

    it 'produces a curried function which arity is that of c', ->
        c = (a, b) -> true
        t = (a) -> 42
        f = (a, b, c, d) ->
        fn = iif c,t,f
        eql arityof(fn), 2
        eql fn(2)(1), 42

    it 'is curried', ->
        fn1 = spy -> 42
        fn2 = spy -> 43
        eql iif(fn2)(fn1)(I)(1), 42

    it 'applies first branch if truthy', ->
        fn1 = spy -> 42
        fn2 = spy -> 43
        fn = iif I, fn1, fn2
        eql fn(1), 42
        eql fn1.args[0], [1]

    it 'applies second branch if falsey', ->
        fn1 = spy -> 42
        fn2 = spy -> 43
        fn = iif I, fn1, fn2
        eql fn(0), 43
        eql fn2.args[0], [0]

    it 'accepts null first branch', ->
        fn2 = spy -> 43
        fn = iif I, null, fn2
        eql fn(1), undefined

    it 'accepts null second branch', ->
        fn1 = spy -> 42
        fn = iif I, fn1, null
        eql fn(0), undefined

    it 'works for variadic', ->
        tst = spy I
        fn1 = spy -> 42
        fn2 = spy -> 43
        fn = iif tst, fn1, fn2
        eql fn(1,2,3), 42
        eql fn(0,2,3), 43
        eql tst.args[0], [1,2,3]
        eql fn1.args[0], [1,2,3]
        eql fn2.args[0], [0,2,3]

    it 'accepts a promise arg', ->
        fn1 = -> 42
        fn2 = -> 43
        fn = iif I, fn1, fn2
        fn(later -> 1).then (r) -> eql r, 42



describe 'maybe', ->

    it 'wraps a function and only invokes it if input is non-falsey', ->
        fn = maybe -> 42
        eql fn(null), undefined
        eql fn(undefined), undefined
        eql fn(0), 42
        eql fn(1), 42

    it 'works for variadic input', ->
        fn = maybe -> 42
        eql fn(1,null), undefined
        eql fn(1,undefined), undefined
        eql fn(1,0), 42
        eql fn(1,1), 42

    it 'accepts promises to maybe fn', ->
        fn = maybe -> 42
        fn(later -> 1).then (r) -> eql r, 42

    it 'accepts promises for null', ->
        fn = maybe -> 42
        fn(later -> null).then (r) -> eql r, undefined

describe 'always', ->

    it 'produces a function that always returns the given value', ->
        fn = always(42)
        eql fn(), 42
        eql fn(12345), 42

    it 'waits for a promise', ->
        fn = always(42)
        fn(later ->1).then (r) -> eql r, 42

describe 'keyval', ->

    it 'makes a key-value pair as an object', ->
        o = keyval 'a', 42
        eql o, a:42

    it 'handles null keys', ->
        o = keyval null, 42
        eql o, {null:42}

    it 'handles undefined keys', ->
        o = keyval undefined, 42
        eql o, {undefined:42}

    it 'is curried', ->
        eql keyval(42)('a'), {a:42}

describe 'nth', ->

    it 'produces a function that returns the nth argument', ->
        eql nth(1)(1,2,3), 2

    it 'produces an arity that of the arg + 1', ->
        arityof nth(1), 2
        arityof nth(4), 5

    it 'produces a curried function', ->
        fn = nth(2)
        eql fn(42)(1)(1), 42

describe 'at', ->

    it 'is of arity 2', ->
        eql arityof(at), 2

    it 'produces a function that extracts the nth position', ->
        eql at([1,2,3],1), 2

    it 'is curried', ->
        eql at(1)([1,2,3]), 2

    it 'works for strings', ->
        eql at(1)('123'), '2'

describe 'pfail', ->

    fn = s = null
    beforeEach ->
        fn = pfail s = spy (err) -> "failed with " + err

    describe 'with rejected promise argument', ->

        it 'is invoked', ->
            fn(fuze 'reject').then (r) -> eql r, 'failed with reject'

    describe 'with multiple rejected promise argument', ->

        it 'is invoked', ->
            fn(fuze('reject 1'), fuze('reject 2')).then (r) ->
                eql s.args.length, 1 # only invoked once
                eql r, 'failed with reject 2'

    describe 'with accepted promise argument', ->

        it 'is skipped', ->
            fn(Q('accept')).then (r) -> eql r, 'accept'

    describe 'with non-promise argument', ->

        it 'is skipped', ->
            eql fn(42), 42

        it 'is skipped with no arg', ->
            eql fn(), undefined

describe 'pall', ->

    describe 'with array of plain values', ->

        it 'returns an array', ->
            eql pall([1,2,3]), [1,2,3]

    describe 'with array of mixed values/promises', ->

        it 'resolves to array of values', ->
            pall([1,later(->2),later(->3)]).then (as) -> eql as, [1,2,3]

    describe 'with array where some value rejects', ->

        it 'is rejected with same rejection', ->
            pall([1,fuze(42),later(3)]).fail (err) -> eql err, 42


describe 'once', ->

    it 'invokes function once', ->
        fn = once s = spy -> 42
        fn(); fn()
        eql s.args.length, 1

    it 'keeps returning same value', ->
        fn = once (a) -> a + 41
        eql fn(1), 42
        eql fn(2), 42

describe 'cond', ->

    it 'is arity 1', ->
        eql arityof(cond), 1

    it 'works for one condition', ->
        fn = cond [[lt(10), always(42)]]
        eql fn(8), 42

    it 'returns undefined if no match', ->
        fn = cond [[lt(10), always(42)]]
        eql fn(11), undefined

    it 'invokes function with same args as cond', ->
        fn = cond [[lt(10), (s = spy -> 42)]]
        eql fn(8,7), 42
        eql s.args[0], [8,7]

    it 'choses first cond that matches', ->
        fn = cond [
            [lt(10), always(42)]
            [lt(12), always(43)]
        ]
        eql fn(11), 43

describe 'call', ->

    it 'calls first argument with consequent', ->
        eql call(add, 1, 2), 3

    it 'is curried', ->
        eql call(1)(I), 1

    it 'can be partialed', ->
        eql (partial(call, add) 1, 2), 3
