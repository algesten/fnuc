chai   = require 'chai'
expect = chai.expect
chai.should()
chai.use(require 'sinon-chai')
{ assert, spy, match, mock, stub, sandbox } = require 'sinon'

require('../src/fnuc').installTo(global, true)

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
]
TYPE_PROTO    = TYPES.filter (spec) -> spec.t == 'object' and not spec.plain
TYPE_NO_PROTO = TYPES.filter (spec) -> spec.t != 'object' or spec.plain
TYPE_ARR      = TYPES.filter (spec) -> spec.t == 'array'
TYPE_PLAIN    = TYPES.filter (spec) -> spec.t == 'object' and spec.plain


describe 'typeOf', ->

    TYPES.forEach (spec) ->
        it "works for #{spec.t}#{spec.d}", -> typeOf(spec.v).should.eql(spec.t)

describe 'isType', ->

    describe 'can take a string argument', ->
        TYPES.forEach (spec) ->
            it "for type #{spec.t}#{spec.d}", -> isType(spec.t, spec.v).should.be.true
    describe 'can take a Function argument', ->
        TYPES.forEach (spec) ->
            if spec.func
                it "for type #{spec.t}#{spec.d}", -> isType(spec.func, spec.v).should.be.true

describe 'isPlain', ->

    describe 'tells whether something is a plain object', ->
        TYPES.forEach (spec) ->
            it "for type #{spec.t}#{spec.d}", -> isPlain(spec.v).should.eql !!spec.plain

describe 'merge', ->

    describe 'alters first argument with consecutive and', ->

        it 'handles no object', -> expect(merge()).to.be.undefined
        it 'handles one object', -> merge(a:1).should.eql a:1
        it 'handles two objects', -> merge({a:1},{b:2}).should.eql a:1,b:2
        it 'handles three objects', -> merge({a:1},{b:2},{c:3}).should.eql a:1,b:2,c:3
        it 'overwrites existing keys', -> merge({a:1},{a:2}).should.eql a:2
        it 'overwrites with precedence', -> merge({a:1},{a:2},{a:3}).should.eql a:3
        it 'ignores undefined values', -> merge({a:1},{a:undefined}).should.eql a:1
        it 'leaves undefined in first be', ->
            merge({a:undefined},{b:2}).should.eql a:undefined,b:2

describe 'mixin', ->

    describe 'returns a new object with all arguments merged and', ->

        it 'handles no object', -> expect(mixin()).to.eql {}
        it 'handles one object', ->
            (r = mixin(a = a:1)).should.eql a:1
            a.should.not.equal r
        it 'handles two objects', ->
            mixin(a = {a:1},{b:2}).should.eql a:1,b:2
            a.should.eql a:1
        it 'handles three objects', ->
            mixin(a = {a:1},{b:2},{c:3}).should.eql a:1,b:2,c:3
            a.should.eql a:1
        it 'overwrites existing keys', ->
            mixin(a = {a:1},{a:2}).should.eql a:2
            a.should.eql a:1
        it 'overwrites with precedence', ->
            mixin(a = {a:1},{a:2},{a:3}).should.eql a:3
            a.should.eql a:1
        it 'ignores undefined values', ->
            mixin(a = {a:1},{a:undefined}).should.eql a:1
            a.should.eql a:1
        it 'leaves undefined in first be', ->
            mixin(a = {a:undefined},{b:2}).should.eql b:2
            a.should.eql a:undefined

describe 'clone', ->

    describe 'does a shallow copy', ->
        TYPE_NO_PROTO.forEach (spec) ->
            it "for built in type #{spec.t}#{spec.d}", ->
                r = clone(spec.v)
                expect(r).to.eql spec.v

    describe 'wont handle proto', ->
        TYPE_PROTO.forEach (spec) ->
            it 'throws an exception', ->
                expect(->clone(spec.v)).to.throw 'Can\'t clone [object Object]'

    describe 'specifically', ->

        describe 'for arrays', ->

            TYPE_ARR.forEach (spec) ->
                it "copies nested by reference for #{spec.t}#{spec.d}", ->
                    r = clone(spec.v)
                    r.should.not.equal spec.v
                    r[i].should.equal(spec.v[i]) for a, i in r
                    r.length.should.eql spec.v.length

        describe 'for objects', ->
            TYPE_PLAIN.forEach (spec) ->
                it "copies nested by reference for #{spec.t}#{spec.d}", ->
                    r = clone(spec.v)
                    r.should.not.equal spec.v
                    v.should.equal(spec.v[k]) for k, v of r
                    Object.keys(r).length.should.eql Object.keys(spec.v).length

describe 'cloneDeep', ->

    describe 'does a deep copy', ->
        TYPE_NO_PROTO.forEach (spec) ->
            it "for built in type #{spec.t}#{spec.d}", ->
                r = cloneDeep(spec.v)
                expect(r).to.eql spec.v

    describe 'wont handle proto', ->
        TYPE_PROTO.forEach (spec) ->
            it 'throws an exception', ->
                expect(->clone(spec.v)).to.throw 'Can\'t clone [object Object]'

    describe 'specifically', ->

        describe 'for arrays', ->

            TYPE_ARR.forEach (spec) ->
                it "clones nested for #{spec.t}#{spec.d}", ->
                    r = cloneDeep(spec.v)
                    r.should.not.equal spec.v
                    for a, i in r
                        if isType 'number', a
                            r[i].should.equal(spec.v[i])
                        else
                            r[i].should.not.equal(spec.v[i])
                    r.length.should.eql spec.v.length

        describe 'for objects', ->
            TYPE_PLAIN.forEach (spec) ->
                it "clones nested for #{spec.t}#{spec.d}", ->
                    r = cloneDeep(spec.v)
                    r.should.not.equal spec.v
                    for k, v of r
                        if isType 'number', v
                            v.should.equal(spec.v[k])
                        else
                            v.should.not.equal(spec.v[k])
                    Object.keys(r).length.should.eql Object.keys(spec.v).length

describe 'arity', ->

    it 'returns the arity of (f)', ->
        arity(()->).should.eql 0
        arity((a)->).should.eql 1
        arity((a,b)->).should.eql 2

    it 'chops the arity to the given number if (f,n)', ->
        arity(arity(((a,b,c)->),n)).should.eql n for n in [0..10]

    it 'has a curried variant for (n)', ->
        arity(arity(n)((a,b,c)->)).should.eql n for n in [0..10]

    describe 'unary', ->

        it 'is arity(1)', ->
            f = unary ((a,b,c,d,e) ->)
            f.length.should.eql 1

    describe 'binary', ->

        it 'is arity(2)', ->
            f = binary (a,b,c,d,e) ->
            f.length.should.eql 2

    describe 'ternary', ->

        it 'is arity(3)', ->
            f = ternary (a,b,c,d,e) ->
            f.length.should.eql 3

describe 'lpartial', ->

    describe 'partially fills in arguments from the left', ->

        it 'executes arity(0)', ->
            r = lpartial (->42)
            r.should.eql 42

        it 'executes arity(0) with arguments', ->
            r = lpartial (->42), 1, 2, 3
            r.should.eql 42

        it 'handles arity(1)', ->
            r = lpartial ((a) -> a + 42)
            r.should.be.a.function
            r(1,2,3).should.eql 43

        it 'executes arity(1) with arguments', ->
            r = lpartial ((a) -> a + 42), 1, 2
            r.should.not.be.a.function
            r.should.eql 43

        it 'works for arity(2)', ->
            r = lpartial ((a,b) -> a / b), 42
            r.should.be.a.function
            arity(r).should.eql 1
            r(2,3,4).should.eql 21

        it 'executes arity(2) with arguments', ->
            r = lpartial ((a,b) -> a / b), 42, 2
            r.should.not.be.a.function
            r.should.eql 21

        it 'works for arity(3) with one arg', ->
            r = lpartial ((a,b,c) -> a / (b / c)), 12
            r.should.be.a.function
            arity(r).should.eql 2
            r(3,2,5).should.eql 8

        it 'works for arity(3) with two arg', ->
            r = lpartial ((a,b,c) -> a / (b / c)), 12, 3
            r.should.be.a.function
            arity(r).should.eql 1
            r(2,5).should.eql 8

        it 'executes arity(3) with arguments', ->
            r = lpartial ((a,b,c) -> a / (b / c)), 12, 3, 2, 5
            r.should.not.be.a.function
            r.should.eql 8

describe 'rpartial', ->

    describe 'partially fills in arguments from the right', ->

        it 'executes arity(0)', ->
            r = rpartial (->42)
            r.should.eql 42

        it 'executes arity(0) with arguments', ->
            r = rpartial (->42), 1, 2, 3
            r.should.eql 42

        it 'handles arity(1)', ->
            r = rpartial ((a) -> a + 42)
            r.should.be.a.function
            r(1,2,3).should.eql 43

        it 'executes arity(1) with arguments', ->
            r = rpartial ((a) -> a + 42), 1, 2
            r.should.not.be.a.function
            r.should.eql 43

        it 'works for arity(2)', ->
            r = rpartial ((a,b) -> a / b), 2
            r.should.be.a.function
            arity(r).should.eql 1
            r(42,3,4).should.eql 21

        it 'executes arity(2) with arguments', ->
            r = rpartial ((a,b) -> a / b), 42, 2
            r.should.not.be.a.function
            r.should.eql 21

        it 'works for arity(3) with one arg', ->
            r = rpartial ((a,b,c) -> a / (b / c)), 2
            r.should.be.a.function
            arity(r).should.eql 2
            r(12,3,5).should.eql 8

        it 'works for arity(3) with two arg', ->
            r = rpartial ((a,b,c) -> a / (b / c)), 3, 2
            r.should.be.a.function
            arity(r).should.eql 1
            r(12,5).should.eql 8

        it 'executes arity(3) with arguments', ->
            r = rpartial ((a,b,c) -> a / (b / c)), 12, 3, 2, 5
            r.should.not.be.a.function
            r.should.eql 8

describe 'curry', ->

    it 'does nothing for arity 0', ->
        curry(f=(->)).should.equal f

    it 'does nothing for arity 1', ->
        curry(f=((a)->)).should.equal f

    describe '(a,b) ->', ->

        div = curry (a,b) -> a / b

        it 'turns to (b) -> (a) ->', ->
            div2 = div(2)
            div2(10).should.eql 5

        it 'maintains arity for curried func', ->
            arity(div).should.eql 2

        it 'returns a smaller arity func after partial apply', ->
            div2 = div(2)
            arity(div2).should.eql 1

        it 'can still apply (a,b) to curried (a,b) ->', ->
            div(10, 2).should.eql 5

    describe '(a,b,c) ->', ->

        divt = curry (a,b,c) -> a / (b / c)

        it 'turns to (c) -> (b) -> (a) ->', ->
            div2 = divt(2)
            div4 = div2(8)
            div4(80).should.eql 20

        it 'maintains arity for curried func', ->
            arity(divt).should.eql 3

        it 'returns a small arity func after partial apply', ->
            div2 = divt(2)
            div4 = div2(8)
            arity(div2).should.eql 2
            arity(div4).should.eql 1

        it 'can be partially applied with (b,c)', ->
            div4 = divt(8, 2)
            div4(80).should.equal 20

        it 'does correct arity for partial applied', ->
            div4 = divt(8, 2)
            arity(div4).should.eql 1

        it 'can still apply (a,b,c) to curried (a,b,c) ->', ->
            divt(80, 8, 2).should.eql 20

        it 'can apply (b,c) to partial applied curried (a,b,c) ->', ->
            div2 = divt(2)
            div2(80,8).should.eql 20

describe 'flip', ->

    describe '(a,b) ->', ->

        f = flip (f1 = (a,b) -> a / b)

        it 'flips the arguments to (b,a) ->', ->
            f(2, 10).should.eql 5

        it 'keeps arity', ->
            arity(f).should.eql 2

        it 'is commutative', ->
            flip(f).should.equal f1

        it 'flips curried functions', ->
            f = flip curry (a,b) -> a / b
            f(2,10).should.equal 5
            f(10)(2).should.equal 5

        it 'is commutative for curried functions', ->
            f = flip (f1 = curry (a,b) -> a / b)
            flip(f).should.equal f1

        it 'flips partially applied curried functions', ->
            f = flip (curry (a,b) -> a / b)(2)
            f(8).should.eql 4

        it 'is commutative for partially applied curried functions', ->
            f = flip (f1 = (curry (a,b) -> a / b)(2))
            flip(f).should.equal f1

    describe '(a,b,c) ->', ->

        f = flip (f1 = (a,b,c) -> a / (b / c))

        it 'flips the arguments to (c,b,a) ->', ->
            f(2, 3, 12).should.eql 8

        it 'keeps arity', ->
            arity(f).should.eql 3

        it 'is commutative', ->
            flip(f).should.equal f1

        it 'flips curried functions', ->
            f = flip curry (a,b,c) -> a / (b / c)
            f(2,3,12).should.equal 8
            f(12)(3)(2).should.equal 8

        it 'is commutative curried functions', ->
            f = flip (f1 = curry (a,b,c) -> a / (b / c))
            flip(f).should.equal f1

        it 'flips partially applied curried functions', ->
            f = flip (curry (a,b,c) -> a / (b / c))(2)
            f(3,12).should.eql 8
            f(12)(3).should.eql 8

        it 'is commutative partially applied curried functions', ->
            f = flip (f1 = (curry (a,b,c) -> a / (b / c))(2))
            flip(f).should.equal f1

describe 'compose', ->

    describe '(f2,f1)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f = compose f2, f1

        it 'is turned to f2(f1)', ->
            f(6,4).should.eql 5

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

    describe '(f3,f2,f1)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = compose f3, f2, f1

        it 'is turned to f3(f2(f1))', ->
            f(7,5).should.eql 2

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

describe 'sequence', ->

    describe '(f1,f2)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f = sequence f1, f2

        it 'is turned to f2(f1)', ->
            f(6,4).should.eql 5

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

    describe '(f1,f2,f3)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = sequence f1, f2, f3

        it 'is turned to f3(f2(f1))', ->
            f(7,5).should.eql 2

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

describe 'I/ident', ->

    it 'returns the arg in', ->
        I(42).should.eql 42

    it 'is of arity 1', ->
        arity(I).should.eql 1

    it 'ignores additional args', ->
        I(42,2).should.eql 42

describe 'append', ->

    describe '([a], v) -> [b]', ->

        it 'appends v to a in a new list', ->
            b = append(a=[0], 1)
            b.should.eql [0,1]
            a.should.eql [0]

        it 'deals with [v] correctly', ->
            b = append(a=[0], [1])
            b.should.eql [0,[1]]
            a.should.eql [0]

        it 'with correct arity', ->
            arity(append).should.eql 2

        it 'has a curried variant (v) -> ([a]) -> [b]', ->
            app4 = append(4)
            app4([3]).should.eql [3,4]

describe 'appendTo', ->

    describe '(v, [a]) -> [b]', ->

        it 'appends v to a in a new list', ->
            b = appendTo(1, a=[0])
            b.should.eql [0,1]
            a.should.eql [0]

        it 'deals with [v] correctly', ->
            b = appendTo([1], a=[0])
            b.should.eql [0,[1]]
            a.should.eql [0]

        it 'with correct arity', ->
            arity(appendTo).should.eql 2

        it 'has a curried variant ([a]) -> (v) -> [b]', ->
            appTo3 = appendTo([3])
            appTo3(4).should.eql [3,4]
