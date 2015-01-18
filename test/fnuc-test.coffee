chai   = require 'chai'
expect = chai.expect
chai.should()
chai.use(require 'sinon-chai')
{ assert, spy, match, mock, stub, sandbox } = require 'sinon'

require('../src/fnuc').installTo(global)

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

describe 'isPlainObject', ->

    describe 'tells whether something is a plain object', ->
        TYPES.forEach (spec) ->
            it "for type #{spec.t}#{spec.d}", -> isPlainObject(spec.v).should.eql !!spec.plain

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
