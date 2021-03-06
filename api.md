API
===

[`I`](api.md#i)
[`add`](api.md#add)
[`all`](api.md#all)
[`always`](api.md#always)
[`and`](api.md#and)
[`any`](api.md#any)
[`apply`](api.md#apply)
[`arity`](api.md#arity)
[`arityof`](api.md#arityof)
[`at`](api.md#at)
[`both`](api.md#both)
[`call`](api.md#call)
[`clone`](api.md#clone)
[`comp`](api.md#comp)
[`compose`](api.md#compose)
[`concat`](api.md#concat)
[`cond`](api.md#cond)
[`contains`](api.md#contains)
[`converge`](api.md#converge)
[`curry`](api.md#curry)
[`div`](api.md#div)
[`drop`](api.md#drop)
[`each`](api.md#each)
[`either`](api.md#either)
[`eq`](api.md#eq)
[`eql`](api.md#eql)
[`evolve`](api.md#evolve)
[`filter`](api.md#filter)
[`firstfn`](api.md#firstfn)
[`flip`](api.md#flip)
[`fold1`](api.md#fold1)
[`fold`](api.md#fold)
[`foldr1`](api.md#foldr1)
[`foldr`](api.md#foldr)
[`get`](api.md#get)
[`gt`](api.md#gt)
[`gte`](api.md#gte)
[`has`](api.md#has)
[`head`](api.md#head)
[`iif`](api.md#iif)
[`index`](api.md#index)
[`indexfn`](api.md#indexfn)
[`isdef`](api.md#isdef)
[`isplain`](api.md#isplain)
[`join`](api.md#join)
[`keys`](api.md#keys)
[`keyval`](api.md#keyval)
[`last`](api.md#last)
[`lastfn`](api.md#lastfn)
[`lcase`](api.md#lcase)
[`len`](api.md#len)
[`lt`](api.md#lt)
[`lte`](api.md#lte)
[`map`](api.md#map)
[`match`](api.md#match)
[`max`](api.md#max)
[`maybe`](api.md#maybe)
[`merge`](api.md#merge)
[`min`](api.md#min)
[`mixin`](api.md#mixin)
[`mod`](api.md#mod)
[`mul`](api.md#mul)
[`not`](api.md#not)
[`nth`](api.md#nth)
[`ofilter`](api.md#ofilter)
[`omap`](api.md#omap)
[`once`](api.md#once)
[`or`](api.md#or)
[`pall`](api.md#pall)
[`partial`](api.md#partial)
[`partialr`](api.md#partialr)
[`pfail`](api.md#pfail)
[`pick`](api.md#pick)
[`pipe`](api.md#pipe)
[`plift`](api.md#plift)
[`replace`](api.md#replace)
[`reverse`](api.md#reverse)
[`search`](api.md#search)
[`set`](api.md#set)
[`shallow`](api.md#shallow)
[`slice`](api.md#slice)
[`sort`](api.md#sort)
[`split`](api.md#split)
[`sub`](api.md#sub)
[`tail`](api.md#tail)
[`take`](api.md#take)
[`tap`](api.md#tap)
[`trim`](api.md#trim)
[`type`](api.md#type)
[`typeis`](api.md#typeis)
[`ucase`](api.md#ucase)
[`unapply`](api.md#unapply)
[`uniq`](api.md#uniq)
[`uniqfn`](api.md#uniqfn)
[`values`](api.md#values)
[`zip`](api.md#zip)
[`zipobj`](api.md#zipobj)
[`zipwith`](api.md#zipwith)


### Type functions

Functions operating on types.

#### I

The identity function `(x) -> x`.

`:: (a) -> a`

#### isdef

Checks whether argument is defined, i.e. not `null` and not `undefined`.

`isdef(a)` `:: a -> Boolean`

args | desc
:--- | :---
`a`  | Anything to check for `null`/`undefined`.

##### isdef example

    isdef null          # false
    isdef undefined     # false
    isdef ''            # true
    isdef 0             # true

#### isplain

Checks whether an object `o` is plain (created using `{}` or `new Object`).

`isplain(o)` `:: {*} -> Boolean`

args | desc
:--- | :---
`o`  | Anything to test for plain.

##### isplain example

    isplain null          # false
    isplain new Date      # false
    isplain {}            # true
    isplain a:42          # true

#### type

Tells what type an object is. Returns one of `'array'`, `'boolean'`,
`'date'`, `'null'`, `'number'`, `'object'`, `'string'`  or
`'undefined'`.

`type(a)`   `:: a -> String`

args | desc
:--- | :---
`a`  | Object to find type for.

##### type example

```coffee
type 'abc'     # 'string'
type 42        # 'number'
type null      # 'null'
type {}        # 'object'
type undefined # 'undefined'
```

#### typeis

Checks that the first argument is of the type specified in the second.

`typeis(a,s)`  `:: String, a -> Boolean`  
`typeis(s)(a)` `:: String -> a -> Boolean`

args | desc
:--- | :---
`a`  | Object to check type of.
`s`  | Type to check for. One of the returned types in [`type`](#type).

##### typeis example

```coffee
typeis 'abc', 'string'     # true
typeis null, 'string'      # false
typeis a, type(a)          # true
typeis 42, 'number'        # true
isnum = typeis('number')
isnum 42                   # true
```

### Function functions

Functions operating on functions.

#### always

Creates a function that always returns the initial parameter.

`always(a)`  `:: a -> * -> a`  

*The resulting function is [plifted](#plift).*

args | desc
:--- | :---
`a`  | value to always return

##### always example

```coffee
fn = always 42
fn()               # 42
fn(12345)          # 42
```

#### apply

Applies the function with the given arguments array. This is
equivalent to `fn.apply(this,args)` and is here due to being
curried. The inverse of [apply](#apply)

`apply(fn)(as)` `:: (a, ..., z -> r1) -> [a] -> r1`  

args | desc
:--- | :---
`fn` | Function to apply
`as` | Arguments array

##### apply example

```coffee
fn = apply Math.max
fn [2,4,3]           # 4
```

#### arity

Forces function arity.

To make a function `f1` of `f` that reports a certain arity we use the
form `f1 = arity(f,n)` where `n` is the number of arguments we want
`f` to report (`f1.length` will equal `n`). Note that this doesn't
stop `f1` from receiving more arguments.

`arity(f,n)` `:: (a... -> a), n -> (a... -> a)`  
`arity(n)(f)` `:: n -> (a... -> a) -> (a... -> a)`

args | desc
:--- | :---
`f`  | Function to make a new function with fixed arity of.
`n`  | The arity of the new function.

##### unary

Same as `arity(1)`.

##### binary

Same as `arity(2)`.

##### ternary

Same as `arity(3)`.

##### arity example

```coffee
myconcat = (as....) -> [].concat as...
arityof myconcat   # 0 for variadic functions.

myconcat2 = arity(2) myconcat   # could have used 'binary myconcat'
arityof myconcat2 # 2
myconcat2 1, 2    # [1,2]
myconcat2 1, 2, 3 # [1,2,3] SURPRISE! (or not)
```

#### arityof

Checks the arity of a function `arityof(f)` returns the number of
arguments `f` takes (same as `f.length`).

`arityof(f)`   `:: (a... -> a) -> Number`  

args | desc
:--- | :---
`f`  | Function to check arity of.

##### arityof example

```coffee
arityof (->)        # 0
arityof I           # 1
arityof ((a,b)->)   # 2
arityof type        # 1
arityof typeis      # 2
arityof arity       # 2
```

#### call

Calls the first argument with the consequent.

`call(fn, a,b,c)`  `:: (* -> a), * -> a`

args | desc
:--- | :---
`fn` | Function to call
`a`  | variadic number of arguments to call function with.

##### call example

```coffee
call add, 1, 2        # 3
```

#### compose

Makes a composition function out of a variable number of functions
`compose(f3,f2,f1)` becomes `f3(f2(f1)))` with the rightmost function
being invoked first (the opposite is [pipe](#pipe)).

The result is curried if the rightmost function is of arity > 1.

```coffee
h = compose(f,g)
z = h(1,2)
z = h(2)(1)
```

is equivalent to:

```coffee
y = g(1,2)
z = f(y)
```

`compose(as...)` `:: ((y -> z), (x -> y), ..., (b -> c), (a... -> b)) -> (a... -> z)`

*All arguments are [plifted](#plift).*

args | desc
:--- | :---
`as...` | Variable number of functions to compose.

##### compose example

```coffee
div10 = div(10)
add50 = add(50)
pow   = (a,b) -> Math.pow(a,b)
calc  = compose div10, add50, pow
calc(10,2)  # 15 or (10 ^ 2 + 50) / 10
calc(2)(10) # 15
```

#### cond

Conditional function invokation. Sort of like a switch-case.

```
[ [condition1, when1],
  [condition2, when2],
  ...
]
```

The produced function will attempt `condition` 1, 2, etc until one is truthy
in which case the corresponding `when` is invoked with the same arguments.

`cond(cs)` `:: [[(* -> Boolean), (* -> a)],[(* -> Boolean), (* -> a)],...] -> a `  

args | desc
:--- | :---
`cs` | Array of arrays with conditions/when.

##### cond example

```coffee
fn = cond [
  [lt(10), always("less than 10")]
  [lt(50), always("less than 50")]
  [always(true), always("something else")]
]

fn 5     # "less than 10"
fn 49    # "less than 49"
fn 110   # "something else"
```

#### curry

Takes a function `f` with multiple arguments and turns that into `f1`
that can be partially applied by providing less arguments than the
original (see [currying][curry]).

*Curry argument order is reversed* (sort of the whole point of fnuc),
i.e. `(a,b,c)` becomes `(c)(b)(a)` however the curried function can
still be invoked with multiple arguments in the original order.

1. Multiple arguments are provided left-to-right.
2. Partial arguments are filled in right-to-left.

Note that currying only makes sense for functions of arity > 1. This
means variadic functions can't be curried without "forcing" an arity.

`curry(f)` `:: (a... -> a) -> (a... -> a)`

args | desc
:--- | :---
`f`  | Function to make a curried version of.

##### curry example

```coffee
f  = curry (a, b, c) -> a + b/c
f(5, 20, 10)   # 7
f(10)(20)(5)   # 7 YAY!

Multiple arguments that are still less than the total arity of `f` are
provided in the original order but filled in right-to-left.

f(10)(5, 20)   # 7 i.e. (c)(a, b)
f(20, 10)(5)   # 7 i.e. (b, c)(a)

A variadic function must have a forced arity to be curryable.

f = curry ternary concat
f(1,2,3,4)       # [1,2,3,4] SURPRISE! (or not)
f(3)(2)(1)       # [1,2,3]
f(4)(3)(2)(1)    # TypeError: object is not a function
```

#### converge

`converge(fn1, fn2, ..., fnn, after)(a1, a2, ..., an)`

Creates a function that passes its arguments (a1-an) to fn1-fnn whose
result are in arguments to the first function (after).

`:: (((a1, ... an) -> x1), ... ((a1, ... an) -> xn), (x1, ..., xn) -> r)) -> (a1, ... an) -> r`  

*All arguments are [plifted](#plift).*

args     | desc
:---     | :---
`fn1`    | Function for first argument to after.
`fn2`    | Function for second argument to after.
`after`  | Function that willl be invoked with results of fn1-fnn.
*Variadic*|
`ret`    | A function accepting arguments to fn1-fnn


##### converge example

```coffee
mul2 = (c) -> c * 2
mul3 = (c) -> c * 3
add  = (a, b) -> a + b
fn = converge mul2, mul3, add
fn(4)                          # add (4*2), (4*3) == 20
```

#### flip

Makes a function that reverses the argument order of the given
function. Flipping is commutative so that flipping a flipped function
returns the orginal, i.e. `f == flip(flip(f))`.

Flipping works for curried functions and reverses the order of the
curry.

Flipping also works for partially applied curried functions.

`flip(f)` `:: (a, b, ..., x, y -> z) -> (y, x, ..., b, a -> z)`  
`flip(f)` `:: (y -> x -> ... -> b -> a -> z) -> (a -> b -> ... -> x -> y -> z)`  

args | desc
:--- | :---
`f`  | Function to reverse arguments of.

##### flip example

```coffee
f = flip curry ternary concat
f(1, 2, 3)    # [3,2,1]
f(3)(2)(1)    # [3,2,1] the curry was flipped
f3 = f(3)
g3 = flip f3  # flipping partially applied
f3(2)(1)      # [3,2,1]
g3(2)(1)      # [3,1,2]
```

#### iif

[Inline if](https://en.wikipedia.org/wiki/IIf) accepts three
functions, a test function, one for true and one for false.

The returned function will pass any arguments to the test function and
then either to true/false depending on the test.

`iif(c,t,f) :: (a -> bool), (a -> b), (a -> c) -> a -> b|c`

*The resulting function is [plifted](#plift).*

args | desc
:--- | :---
`c`  | Condition function that evaluates to truthy/falsey.
`t`  | Function to invoke if `fc` is truthy.
`f`  | Function to invoke if `fc` is falsey.

##### iif example

```coffee
iseven = (a) -> a % 2 == 0
evens  = (a) -> a / 2
odds   = (a) -> a * 2
fn = iif iseven, evens, odds
fn(3)                          # 6  (3 is odd, 3*2)
fn(4)                          # 2  (4 is even, 4/2)
```

#### maybe

Wraps a function and maybe invokes it, if the applied parameter(s) are
non-`null`/non-`undefined`.

Can be thought of as a "guard" against `null`/`undefined`.

`maybe(fn)`  `:: (a -> b) -> a|null -> b|null`

*The resulting function is [plifted](#plift).*

args | desc
:--- | :---
`fn` | Function to wrap.

##### maybe example

```coffee
just42 = -> 42
fn = maybe just42
fn 0                 # 42
fn 1                 # 42
fn null              # undefined, and just42 was not invoked
```

#### nth

Produces a function that returns the nth argument to that function
(counting from 0).

`nth(n)`  `:: (n) -> (a1, a2, ... az) -> an`

args | desc
:--- | :---
`n`  | the argument number

##### nth example

```coffee
fn = nth(1)
fn('a', 'b')         # 'b'
fn(5,4,3,2,1)        # 4
```

#### once

Wraps a function and guarantees it is invoked only once. The result is
cached and subsequent invokations the result is returned without
invoking the original function.

`once(fn)`  `:: (a -> b) -> (a -> b)`

args | desc
:--- | :---
`fn` | the function to wrap

##### once example

```coffee
fn = once add(10)
fn(2)             # 12
fn(4)             # 12
```

#### pall

Given an array of promises, produces a promise that will resolve
with the values when all promises in the array resolves. If no
promises in array the function synchronously returns an array
with the same content.

`pall(as)` `:: [a | Promise a] -> [a] | Promise [a]`

args | desc
:--- | :---
`as` | Array of values/promises.

##### pall example

```coffee
# helper function that resolves a promise to a value after 1 second.
later = (a) -> (new Promise (rs) -> setTimeout rs, 1000).then -> a

pall [1,2,3]                          # [1,2,3] - synchronously
pall([1,later(2),3]).then console.log # [1,2,3] - after one second
```


#### partial

Creates a function that has the original function partially applied
from the left (see also [partialr](#partialr)).

`partial ((a,b) -> a/b), 10` makes a function that will receive one
additional argument `x` to divide 10 by `x`.

`partial(f,as...)` `:: ((a... -> a), a, b, ...) -> (a... -> a)`

args | desc
:--- | :---
`f`  | Function to apply arguments for.
`as...` | Variable number of arguments to apply from the left.

##### partial example

```coffee
l     = [1,2,3,...]
even  = (a) -> a % 2 == 0    # even number filter
fl    = partial filter l    # fl always filters mylist
le    = fl even              # keep only even
```

#### partialr

Creates a function that has the original function partially applied
from the right (see also [partial](#partial)).

`partialr ((a,b) -> a/b), 10` makes a function that will receive one
additional argument `x` to divide `x` by 10.

`partialr(f,as...)` `:: ((a... -> a), a, b, ...) -> (a... -> a)`

args | desc
:--- | :---
`f`  | Function to apply arguments for.
`as...` | Variable number of arguments to apply from the right.

##### partialr example

```coffee
l     = [1,2,3,...]
even  = (a) -> a % 2 == 0         # even number filter
fr    = partial filter even       # applies even filter to any list
le    = fr l                      # keeps only even
```

#### pfail

Same as [`plift`](#plift) only, the function is only invoked if any
promise arguments are rejected. Furthermore the plift is shortcut, so
the first rejection (if multiple) is the only one invoking the
function.

`pfail(f)`  `:: ((a, b, ..., z) -> a0) -> (a, b, ..., z) -> a0)`

args | desc
:--- | :---
`f`  | Function to plift and only invoke if any promise arguments fail.

##### pfail example

```coffee
fn = pfail (err) -> "failed with #{err}"
fn(42)                  # 42, wrapped function not invoked
fn(Promise.resolve(42)) # 42, wrapped function not invoked
fn(Promise.reject(43))  # "failed with 43"
```


#### pipe

Makes a sequence of function out of a variable number of functions
`pipe(f1,f2,f3)` becomes `f3(f2(f1)))` with the leftmost function
invoked first (the opposite is [compose](#compose)).

The result is curried if the leftmost function is of arity > 1.

    h = pipe(f,g)
    z = h(1,2)
    z = h(2)(1)

is equivalent to:

    y = f(1,2)
    z = g(y)

`pipe(as...)` `:: ((y -> z), (x -> y), ..., (b -> c), (a... -> b)) -> (a... -> z)`

*All arguments are [plifted](#plift).*

args | desc
:--- | :---
`as...` | Variable number of functions to pipe.

##### pipe example

```coffee
div10 = div(10)
add50 = add(50)
pow   = (a,b) -> Math.pow(a,b)
calc  = pipe pow, add50, div10
calc(10,2)  # 15 or (10 ^ 2 + 50) / 10
calc(2)(10) # 15
```

#### plift

Lifts a function to be promise (.then-able) aware. When any argument
to the function is a promise, the function returns a promise for the
function evaluation that resolves when the arguments are resolved.

In case all arguments are non-promises, the function evaluates without
returning a promise.

`plift(f)`  `:: ((a, b, ..., z) -> a0) -> (a, b, ..., z) -> a0)`

args | desc
:--- | :---
`f`  | Function to lift

##### plift example

```coffee
# helper function that resolves a promise to a value after 1 second.
later = (a) -> (new Promise (rs) -> setTimeout rs, 1000).then -> a

f = plift (a, b) -> a + b
f(1,2)                       # 3
f(later(1), 2)               # promise that resolves to 3 after 1 second

# to see it in action
f(1, later(2)).then console.log
```

#### tap

Runs a value through a function, ignores the result of the function
and returns the original value. The mother of all side effects.

`tap(4,div(10))` divides 4 by 10 and ignores that result, returns 4.

`tap(a,f)`  `:: a, (a -> a) -> a`  
`tap(f)(a)` `:: (a -> a) -> a -> a`  

args | desc
:--- | :---
`a` | The value to pass as argument to the function.
`f` | The function to pass the argument to (and then ignore).

##### tap example

```coffee
log   = (as...) -> console.log as...      # console.log returns undefined
dolog = tap(log)                          # dolog returns same value
calc  = pipe add(3), dolog, div(10)   # log the value between the operations
calc [1,2,3]                              # logs 4...5...6
```


#### unapply

Produces a function that takes positional arguments and applies them
as an array. The inverse of [apply](#apply)

`unapply(f)(a1,a2,...)` `:: ([a] -> *) -> (a1, a2, ...) -> *`

args | desc
:--- | :---
`f` | The function to invoke
*produced function*
`as...` | Arguments to turn into array.

##### unapply example

```coffee
unapply(JSON.stringify)(1,2,3)        # '[1,2,3]'
```


### Object functions

Functions operating on objects.

#### clone

Deep clones a value. The value can be an `object`, `array`, `date`,
`string`, `number`, `boolean`, `symbol`, `null` or `undefined`. The
only thing that can't be cloned is a non-plain object (other than
date).

`clone(o)` `:: * -> *`  

args | desc
:--- | :---
`o` | Value to deep clone.

##### clone example

```coffee
clone 42            # 42
clone {a:1}         # {a:1}
clone {a:[1,2,3]}   # {a:[1,2,3]} the nested array is cloned
clone {d:new Date}  # {d:<date>}  the nested date is cloned
```

#### evolve

Creates a new object by evolving a shallow copy of object, by applying
transformation functions in a second object. Values not transformed
are copied by reference.

`evolve(o,t)`  `:: {k:v}, {k:(v -> v)} -> {k:v}`  
`evolve(t)(o)` `:: {k:(v -> v)} -> {k:v} -> {k:v}`

args | desc
:--- | :---
`o` | Object to evolve.
`t` | Object with transformation functions to apply to `o`.

##### evolve example

```coffee
o = {a:1,b:2,c:3}
t = {b:(v) -> v + 40}
o1 = evolve o, t             # {a:1,b:42,c:3}
o1 == o                      # false
badd40 = evolve t            # partial
badd40 o                     # {a:1,b:42,c:3}
```

#### eql

Deep equals. `a` equal to `b` which will recursively traverse nested
arrays and objects. See also [eq](#eq).

`eql(a,b)`   `:: a, a -> Boolean`  
`eql(b)(a)`  `:: a -> a -> Boolean`  

args | desc
:--- | :---
`a`  | Argument 1.
`b`  | Argument 2.

#### get

Gets the property value from an object, `get o, 'bar'` gives the value
of `o.bar`

`get(o,k)`  `:: {k,v}, k -> v`  
`get(k)(o)` `:: k -> {k,v} -> v`  

args | desc
:--- | :---
`o` | Object to get property from.
`k` | The property key.

##### get example

```coffee
get {a:1,b:2}, 'b'     # 2
getb = get 'b'         # partial
getb {b:3}             # 3
```

#### has

Tells whether an object has a property. `has o, 'bar'` is the same as
`o.hasOwnProperty('bar')`.

`has(o,k)`  `:: {k,v}, k -> Boolean`  
`has(k)(o)` `:: k -> {k,v} -> Boolean`  

args | desc
:--- | :---
`o` | Object to check property on.
`k` | The property key.

##### has example

```coffee
has {a:1,b:2}, 'b'     # true
hasb = has 'b'         # partial
hasb {b:3}             # true
```

#### keys

Makes an array of the keys of an object. `keys o` is the same as `Object.keys(o)`.

`keys(o)` `:: {k:v} -> [k]`  

args | desc
:--- | :---
`o` | Object to get keys from.

##### keys example

```coffee
keys {a:1,b:2}          # ['a','b']
keys {}                 # []
```

#### keyval

Produces a key-value pair as an object.

`keyval(k,v)` `:: (k,v) -> {k:v}`  

args | desc
:--- | :---
`k`  | Key value. Preferably a string.
`v`  | Value.

##### keyval example

```coffee
keyval 'a', 42     # {a:42}
```

#### merge

Alters the first object with the key/values from consecutive
objects and returns it. Rightmost object takes precedence. Omits values that are
undefined.

`merge(o, os...)` `:: {*}, {*}... -> {*}`

args | desc
:--- | :---
`o` | Target object that will be altered.
`os...` | Variable number of objects to apply left to right.

##### merge example

```coffee
merge (t={c:4}), {a:1}, {a:2,b:3}    # t is {a:2,b:3,c:4}
merge {c:4}, {a:1, b:undefined}      # {a:1,c:4}
```

#### mixin

Returns a new object with the key/values from consecutive objects
set. Rightmost object takes precende. Omits values that are
undefined. `mixin {a:1}, {b:2}` is equivalent to `merge {}, {a:1},
{b:2}`.

`mixin(os...)` `:: {*}... -> {*}`  
`mixin(o)(o)`  `:: {*} -> {*} -> {*}`

args | desc
:--- | :---
`os...` | Variable number of objects to apply left to right.

##### mixin example

```coffee
mixin (t={c:4}), {a:1}, {a:2,b:3}    # {a:2,b:3,c:4} t is {c:4}
mixin {c:4}, {a:1, b:undefined}      # {a:1,c:4}
fn = mixin {a:1}                     # partial
fn {b:2}                             # {a:1, b:2}
```

#### ofilter

Like `filter` but for objects. The filter function is invoked with
key, value `(k,v)`.

`ofilter(o,f)`  `:: {k:v}, ((k, v) -> Boolean) -> {k:v}`  
`ofilter(f)(o)` `:: ((k, v) -> Boolean) -> {k:v} -> {k:v}`

args | desc
:--- | :---
`o` | The object to invoke filter function on.
`f` | Filter function with signature `(k, v) -> Boolean`. Truthy/falsey return.

##### ofilter example

```coffee
f = (k, v) -> k == 'a' or v % 2
o = {a:0, b:1, c:2}
ofilter o, f                # {a:0, b:1}
aOrOdd = ofilter f          # partial
aOrOdd o                    # {a:0, b:1}
```

#### omap

Like `map` but for objects. The mapping function is invoked with key,
value `(k,v)`.

`omap(o,f)`  `:: {k:v}, ((k, v) -> v) -> {k:v}`  
`omap(f)(o)` `:: ((k, v) -> v) -> {k:v} -> {k:v}`

args | desc
:--- | :---
`o` | The object to invoke mapping function on.
`f` | Mapping function with signature `(k, v) -> v`.

#### omap example

```coffee
    f = (k, v) -> if k == 'b' then v + 40 else v
    omap {a:1,b:2,c:3}, f                         # {a:1,b:42,c:3}
    bAdd40 = omap(f)                              # partial
    bAdd40 {d:3,b:2}                              # {d:3,b:42}
```

#### pick

Picks a number of properties of an object into a new object. The
properties to pick can either be supplied as an array of strings or
variadic strings.

`pick(o,as)`    `:: {k:v}, [k] -> {k:v}`  
`pick(as)(o)`   `:: [k] -> {k:v} -> {k:v}`  
`pick(o,as...)` `:: {k:v}, k1, k2, k3, ... -> {k:v}`  
`pick(s)(o)`    `:: k -> {k:v} -> {k:v}`

args | desc
:--- | :---
*Array variant*|
`o`  | Object to pick properties from.
`as` | Array of string property names to pick.
*Vararg variant*|
`o`  | Object to pick properties from.
`as` | Property names to pick as variable number of string arguments.

##### pick example

```coffee
o = {a:1, b:2, c:3}
# as array
pick o,['a','b']            # {a:1, b:2}
p1 = pick ['a',b']          # partial
p1(o)                       # {a:1, b:2}
# as vararg
pick o, 'a', 'b'            # {a:1, b:2}
p3 = pick 'a'               # partial
p3(o)                       # {a:1}
```

#### set

Sets a property of an object and returns the same object.

`set(o,k,v)`   `:: {k:v}, k, v -> {k:v}`  
`set(v)(k)(o)` `:: v -> k -> {k:v} -> {k:v}`  

args | desc
:--- | :---
`o`  | Object to set a property on.
`k`  | Key for the property to set.
`v`  | The value to set.

##### set example

```coffee
o = {a:1,b:3}
set(o,'a',2)          # {a:2,b:3}
seta3 = set(3)('a')   # partial
setb4 = set(4)('b')   # partial
f = pipe seta3, setb4
f(o)                  # {a:3,b:4}
```

#### shallow

Makes a shallow copy of the given argument. The argument can be an
`object`, `array`, `date`, `string`, `number`, `boolean`, `symbol`,
`null` or `undefined`. However shallowness is only defined for `array`
and `object`.

`shallow(o)` `:: * -> *`  

args | desc
:--- | :---
`o` | Value to shallow copy.

##### shallow example

```coffee
shallow 42            # 42
shallow {a:1}         # {a:1}
shallow {a:[1,2,3]}   # {a:[1,2,3]} the nested array is copy-by-reference
shallow {d:new Date}  # {d:<date>}  the nested date is copy-by-reference
```

#### values

Makes an array of the values of an object.

`values(o)` `:: {k:v} -> [v]`  

args | desc
:--- | :---
`o` | Object to get values from.

##### values example

```coffee
values {a:1,b:2}, 'b'     # ['1','2']
values {}                 # []
```

### Array functions

Functions operating on arrays.

#### all

Tests if a condition is fulfilled for all elements of an array. Same
as `[...].every`.

`all(as,f)`  `:: [a], (a -> Boolean) -> Boolean`  
`all(f)(as)` `:: (a -> Boolean) -> [a] -> Boolean`  

args | desc
:--- | :---
`as` | Array to operate on.
`f`  | Test function that is truthy/falsy for a single element.

##### all example

```coffee
as = [1,0,2]
all as, (a) -> a > 0      # false
all as, (a) -> a >= 0     # true
gt0 = all (a) -> a > 0    # partial
gt0 as                    # false
```

#### any

Tests if a condition is fulfilled for any element of an array. Same as
`[...].some`.

`any(as,f)`  `:: [a], (a -> Boolean) -> Boolean`  
`any(f)(as)` `:: (a -> Boolean) -> [a] -> Boolean`  

args | desc
:--- | :---
`as` | Array to operate on.
`f`  | Test function that is truthy/falsy for a single element.

##### any example

```coffee
as = [1,0,2]
any as, (a) -> a > 0      # true
any as, (a) -> a > 2      # false
gt0 = any (a) -> a > 0    # partial
gt0 as                    # false
```

#### at

Returns the element at index n.

Also works for strings.

`at(as,n)`  `:: [a], n -> a`  
`at(n)(as)` `:: n -> [a] -> a`  

args | desc
:--- | :---
`as` | Array to operate on.
`n`  | Element index

##### at example

```coffee
at(1) ['apple', 'pear', 'banana']    # 'pear'
```

#### concat

Concatenates (joins) two or more lists or values. To not be surprising
has the same quirks as `Array::concat`:

1. Joins multiple arrays to one array.
2. Joins a mix of array and values to one array.
3. Joins plain values to one array.

`concat(as...)` `:: [a], a, ... -> [a]`  

args | desc
:--- | :---
`as` | Variable amount of values or arrays to concatenate.

##### concat example

```coffee
concat [1,2], [3,4]   # [1,2,3,4]
concat [1,2], 3, 4    # [1,2,3,4]
concat 1, 2, 3, 4     # [1,2,3,4]
```

#### contains

Tells if an array contains a value. Same as `index(a,v) >= 0`.

`contains(as,a)`  `:: [a], a -> Boolean`  
`contains(a)(as)` `:: a -> [a] -> Boolean`  

args | desc
:--- | :---
`as` | Array to check.
`a`  | Element to look for.

##### contains example

```coffee
contains [1,2,3], 2    # true
contains [1,2,3], 5    # false
cont5 = contains(5)    # partial
cont5 [3,4,5]          # true
```

#### drop (array)

See [`drop`](api.md#drop)

#### each

Performs side effects for each element of an array without altering
the array or returning anything useful. Same as `[...].forEach`

`each(as,f)`  `:: [a], (a -> *) -> undefined`  
`each(f)(as)` `:: (a -> *) -> [a] -> undefined`  

args | desc
:--- | :---
`as` | Array to loop over.
`f`  | Function to invoke for each element.

##### each example

```coffee
log = (a) -> console.log a
each [1,2,3], log            # prints 1...2...3
listlogger = each log        # partial
listlogger [1,2,3]           # prints 1...2...3
```

#### filter

Creates a new list containing only elements for which a test function
is true. Same as `[...].filter`.

`filter(as,f)`  `:: [a], (a -> Boolean) -> [a]`  
`filter(f)(as)` `:: (a -> Boolean) -> [a] -> [a]`  

args | desc
:--- | :---
`as` | Array to filter.
`f`  | Function used to filter array. Truthy to keep element.

##### filter example

```coffee
odd = (a) -> a % 2
filter [1,2,3], odd     # [1,3]
fo = filter odd         # partial
fo [1,2,3]              # [1,3]
```

#### firstfn

Returns the first element in a list that returns truthy for a test
function.

`firstfn(as,f)`  `:: [a], (a -> Boolean) -> a`  
`firstfn(f)(as)` `:: (a -> Boolean) -> [a] -> a`  

args | desc
:--- | :---
`as` | List to work over.
`f`  | Test function that is truthy for first element to return.

```coffee
firstfn [1,2,3,4,5], (a) -> a % 2 == 0      # 2
```

#### fold

Performs a [fold][fold] operation from the left with a seed
value. Same as `[...].reduce(f, s)` but without the additional index
or array arguments.

`fold(as,f,s)`   `[b], ((a, b) -> a), a -> a`  
`fold(s)(f)(as)` `a -> ((a, b) -> a) -> [b] -> a`  

args | desc
:--- | :---
`as` | Array to fold.
`f`  | Folding function. Signature is `(a,b)`, no index or array.
`s`  | Seed value.
*folding function* |
`a` | Value of previous fold operation or `s` for first element.
`b` | Current value from `as`.

##### fold example

```coffee
f = (p,c) -> if c % 2 then c + p else p   # sum odd numbers
fold [1,2,3], f, 5                        # 9
```

#### fold1

Same as [fold](#fold) but no seed value. Same as `[...].reduce(f)` but
without the additional index and array arguments.

`fold1(as,f)`  `[b], ((a, b) -> a) -> a`  
`fold1(f)(as)` `((a, b) -> a) -> [b] -> a`  

args | desc
:--- | :---
`as` | Array to fold.
`f`  | Folding function. Signature is `(a,b)`, no index or array.
*folding function* |
`a` | Value of previous fold operation or first element for first iteration.
`b` | Current value from `as` or second element for first iteration.

##### fold1 example

```coffee
f = (p,c) -> if c % 2 then c + p else p   # sum odd numbers
fold1 [2,3,4], f                          # 5 (in first iteration p=2 and c=3)
```

#### foldr

Same as [fold](#fold) but goes right to left with a seed value. Same
as `[...].reduceRight(f,s)` without the additional index or array.

`foldr(as,f,s)`   `[b], ((a, b) -> a), a -> a`  
`foldr(s)(f)(as)` `a -> ((a, b) -> a) -> [b] -> a`  

args | desc
:--- | :---
*See [fold](#fold)* |

#### foldr1

Same as [foldr](#foldr) but no seed value. Same as
`[...].reduceRight(f)` without the additional index or array.

`fold1(as,f)`  `[b], ((a, b) -> a) -> a`  
`fold1(f)(as)` `((a, b) -> a) -> [b] -> a`  

args | desc
:--- | :---
*See [fold1](#fold1)* |

#### head

Gets the head value of an array.

Also applicable for string.

`head(as)` `:: [a] -> a|undefined`  

args | desc
:--- | :---
`as` | The array to get the head from.

##### head example

```coffee
head [1,2,3]   # 1
head []        # undefined
```

#### index

Tells the index of a value in an array or -1 if not found. Same as
`[...].indexOf(a)`. `undefined` for empty list.

`index(as,a)`  `:: [a], a -> Number`  
`index(a)(as)` `:: a -> [a] -> Number`  

args | desc
:--- | :---
`as` | The array to look for `a` in.
`a`  | Value to look for.

##### index example

```coffee
index [1,2,3], 3       # 2
index [1,2,3], 4       # -1
```

#### indexfn

Finds the index of first value for which a function is true in an
array or -1 if not found. `undefined` for empty list.

`indexfn(as,fn)`  `:: [a], (a -> Boolean) -> Number`  
`indexfn(fn)(as)` `:: (a -> Boolean) -> [a] -> Number`  

args | desc
:--- | :---
`as` | The array to evaluate `fn` on each element in.
`fn` | Function to run on each element. Truthy will give index.

##### indexfn example

```coffee
indexfn [1,2,3], (a) -> a % 2 == 0       # 2
indexfn [1,2,3], (a) -> a > 4            # -1
```

#### join

Creates a string from a list by inserting a given string in between
each element. Same as `[...].join(s)`

`join(as,s)`  `:: [a], s -> String`  
`join(s)(as)` `:: s -> [a] -> String`  

args | desc
:--- | :---
`as` | Array to join.
`s`  | String to insert in between each element.

##### join example

```coffee
join [1,2,3], ''     # '123'
join [1,2,3], '-'    # '1-2-3'
```

#### last

Gets the last value of an array. `undefined` for empty list.

Also applicable for string.

`last(as)`  `:: [a] -> a|undefined`  

args | desc
:--- | :---
`as` | The array get the last value of.

##### last example

```coffee
last [1,2,3]     # 3
last []          # undefined
```

#### lastfn

Returns the last element in a list that returns truthy for a test
function.

`lastfn(as,f)`  `:: [a], (a -> Boolean) -> a`  
`lastfn(f)(as)` `:: (a -> Boolean) -> [a] -> a`  

args | desc
:--- | :---
`as` | List to work over.
`f`  | Test function that is truthy for last element to return.

```coffee
lastfn [1,2,3,4,5], (a) -> a % 2 == 0   # 4
```

#### map

Creates a new array of transformed values by applying a transformation
function to each element. Same as `[...].map(f)` but does not pass the
additional index and array arguments to the transformation function.

`map(as,f)`  `:: [a], (a -> b) -> [b]`  
`map(f)(as)` `:: ((a -> b) -> [a] -> [b]`  

args | desc
:--- | :---
`as` | Array to transform.
`f`  | Transformation function. Signature is `(a)` (no index or array).
*transformation function* |
`a` | Current value from `as`.

##### map example

```coffee
add1 = (a) -> a + 1
map [1,2,3], add1     # [2,3,4]
ladd1 = map add1      # partial
ladd1 [2,3,4]         # [3,4,5]
```

#### reverse

Reverses the array. Same as `[...].reverse()`

`reverse(as)` `:: [a] -> [a]`  

args | desc
:--- | :---
`as` | Array to reverse.

##### reverse example

```coffee
reverse [1,2,3]    # [3,2,1]
```

#### slice (array)

See [`slice`](api.md#slice)

#### sort

Sorts an array according to a comparator function. Same as
`[...].sort(f)`.

The comparator function `(a,b)` returns:

1. A number `< 0`  if `a < b`
2. `0` if `a == b`
3. A number `> 0` if `a > b`

Specifically if `(a1,a2)` returns something `< 0`, `(a2,a1)` must
returns something `> 0`.

`sort(as,f)`  `:: [a], (a, a -> Number) -> [a]`  
`sort(f)(as)` `:: (a, a -> Number) -> [a] -> [a]`  

args | desc
:--- | :---
`as` | Array to sort.
`f`  | Comparator function with signature `(a,b)`.
*Comparator function* |
`a`  | An element of `as` to compare to `b`.
`b`  | An element of `as` to compare to `a`.

##### sort example

```coffee
sort [2,1,3]            # [1,2,3]
comp = (a,b) -> b - a
sort [2,1,3], comp      # [3,2,1]
s = sort(comp)          # partial
s [4,1,5,2]             # [5,4,2,1]
```

#### tail

The tail of a list, that is, every element apart from the first. The
tail of `[]` is `[]`.

Also applicable for string.

`tail(as)`  `:: [a] -> [a]`  

args | desc
:--- | :---
`as` | Array to get tail of.

##### example

```coffee
tail [1,2,3]    # [2,3]
tail []         # []
```

#### take (array)

See [`take`](api.md#take)

#### uniq

Creates an array where every element occurs only once (given `==`
equality).

Same as `uniqfn I`.

`uniq(as)` `:: [a] -> [a]`  

args | desc
:--- | :---
`as` | Array to dedupe.

##### uniq example

```coffee
uniq [3,1,3,2,1,3,2,1]   # [3,1,2]
```

#### uniqfn

Creates an array where every element occurs only once given a function
applied for each element.

`uniqfn(as)` `:: [a], (a -> v) -> [a]`  

args | desc
:--- | :---
`as` | Array to dedupe.
`fn` | Function to apply to every value in the array to dedupe.

##### uniqfn example

```coffee
uniqfn [6,1,3,4,1,3,2,1], (a) -> a % 3   # [6,1,2]
```

#### zip

Takes two (or more) arrays and combines each position into a single
array of arrays.

Returned array is the minimum length argument arrays.

`zip(as,bs)`   `:: [a], [b] -> [[a,b]]`  
`zip(bs)(as)`  `:: [b] -> [a] -> [[a,b]]`  
`zip(cs...)`   `:: [a], ..., [z] -> [[a,...,z]]`

args | desc
:--- | :---
`as` | Array/string of values for first value
`bs` | Array/string of values for second value
*Variadic*|
`cs` | Variable number of arrays/strings to use

##### zip example

```coffee
zip [1,2,3], ['a','b','c']   # [(1,a),(2,b),(3,c)]
```

#### zipobj

Takes two arrays, one with keys and one with values, to
make an object with those keys/values.

`zipobj(as,bs)`   `:: [a], [b] -> {a0:k0, a1:k2, ..., az:kz}`

args | desc
:--- | :---
`ks` | Array of keys
`vs` | Array of values. Must be same length as `ks`.

##### zipobj example

```coffee
zipobj ['a','b','c'], [1,2,3]   # {a:1, b:2, c:3}
```


#### zipwith

Takes two (or more) arrays and combines each position by invoking a
function for each position.

`zipwith(as,bs,f)`   `:: [a], [b], ((a,b) -> c) -> [c]`  
`zipwith(f)(bs)(as)` `:: ((a,b) -> c) -> [b] -> [a] -> [c]`  
`zipwith(cs...,f)`   `:: [a], ... [z], ((a,...,z) -> c) -> [c]`

args | desc
:--- | :---
`as` | Array/string of values for first value to function.
`bs` | Array/string of values for second value to function.
`f`  | Function to invoke for each position.
*Variadic*|
`cs` | Variable number of arrays/strings to provide to function.

##### zipwith example

```coffee
zipwith(add) [1,2,3], [3,4,5]    # [4,6,8]
```

### String functions

Functions operating on strings.

#### lcase

Turns the given string to lowercase. Same as `s.toLowerCase()`

`lcase(s)`  `:: s -> s`  

args | desc
:--- | :---
`s`  | String to lowercase.

##### lcase example

```coffee
lcase 'aBcD'   # 'abcd'
```

#### match

Matches a regexp in a string. Same as `s1.match(s2)`. The value
returned is a special regexp match object.

`match(s,m)`  `:: s, RegExp -> [a]|null`  
`match(m)(s)` `:: RegExp -> s -> [a]|null`  

args | desc
:--- | :---
`s`  | String to match in.
`m`  | The match object which is interpreted as a RegExp.

##### match example

```coffee
match 'a bar frog', '.'     # [ 'a', index: 0, input: 'a bar frog' ]
match 'a bar frog', 'fo'    # null
match 'a bar frog', /ar?/g  # ['a', 'ar']
```

#### replace

Returns a new string with occurences of a matching string/regexp with
another string. Same as `s1.replace(s2,s3)`

`replace(s,m,r)`   `:: s, s|RegExp, s -> s`  
`replace(r)(m)(s)` `:: s -> s|RegExp -> s -> s`  

args | desc
:--- | :---
`s`  | String to replace in.
`m`  | The match object which can either be a string or a RegExp.
`r`  | The replacement string where `m` matches.

##### replace example

```coffee
replace 'abcab', 'b', 'c'    # 'accac'
replace 'abcab', 'd', 'c'    # 'abcab'
replace 'abcab', /a./g, 'f'  # 'fcf'
```

#### search

Searches the string for a given regexp and returns the index of the
match. Same as `s.search(m)`.

`search(s,m)`  `:: s, RegExp -> Number`  
`search(m)(s)` `:: RegExp -> s -> Number`  

args | desc
:--- | :---
`s`  | String to search in
`m`  | The match RegExp.

##### search example

```coffee
search 'abc',  '.'    # 0
search 'abc',  /./    # 0
search 'abc',  /d/    # -1
search 'abc',  '.c'   # 1
findC = search('c')   # partial
findC 'aqdc'          # 3
```

#### split

Splits a string into an array divided on a separator. Same as
`s1.split(s2)`

`split(s,e)`  `:: s, s|RegExp -> [s]`  
`split(e)(s)` `:: s|RegExp -> s -> [s]`  

args | desc
:--- | :---
`s`  | String to split
`e`  | Separator to split on which can be a string or RegExp.

##### split example

```coffee
split 'abc', ''          # ['a','b','c']
split 'abc', 'b'         # ['a', 'c']
split 'cadabcab', /[ab]/ # ['c', 'd', '', 'c', '', '']
```

#### slice

Slice of a string `s` from `m` to `n`, same as `s.slice(m,n)`.

Also applicable for array objects.

`slice(s,m,n)`   `:: s, n, n, -> s`  
`slice(n)(m)(s)` `:: n -> n -> n -> s`  

args | desc
:--- | :---
`s`  | String/array to slice
`m`  | Slice from
`n`  | Slice to. Optional.

##### slice example

```coffee
slice 'abcdef',  1, 3    # bc
slice [0,1,2,3], 1, 3    # [1,2]
```

#### drop

Slice the end of a string `s` from `m`, same as `s.slice(m)`.

Also applicable for array.

`drop(s,m)`  `:: s, n, -> s`  
`drop(m)(s)` `:: n -> n -> s`  

args | desc
:--- | :---
`s`  | String/array to slice end of
`m`  | Slice from

##### drop example

```coffee
drop 'abcdef',  2   # cdef
drop [0,2,3,4], 2   # [3,4]
```

#### take

Slice the beginning of a string `s` up to `n`, same as `s.slice(0, n)`.

Also applicable for array.

`take(s,n)`  `:: s, n, -> s`  
`take(n)(s)` `:: n -> n -> s`  

args | desc
:--- | :---
`s`  | String/array to slice beginning of
`n`  | Slice up to

##### take example

```coffee
take 'abcdef',  2    # ab
take [0,1,2,3], 2    # [0,1]
```

#### len

Length of string (or array)

Same as `s.length`.

`len(s)`  `:: s -> n`  

args | desc
:--- | :---
`s`  | String/array to get length of

##### len example

```coffee
len 'abcd'   # 4
len [2,1]    # 2
```

#### trim

Trims whitespace off start and end of a string. Same as `s.trim()`

`trim(s)`  `:: s -> s`  

args | desc
:--- | :---
`s`  | String to trim.

##### trim example

```coffee
trim '  ab  \n'    # 'ab'
```

#### ucase

Turns the given string to uppercase. Same as `s.toUpperCase()`

`ucase(s)` `:: s -> s`  

args | desc
:--- | :---
`s`  | String to uppercase.

##### ucase example

```coffee
ucase 'aBcD'  # 'ABCD'
```

### Math functions

Functions for math.

#### and

Returns a function that performs *logical and* on the result. For
coffeescript this function is aliased as `aand`.

`aand(a1,a2)`   `:: (*, *) -> Boolean`  
`aand(a2)(a1)`  `:: * -> * -> Boolean`  
`aand(as...)`   `:: (*, *, ...) ->  Boolean`  

args | desc
:--- | :---
`a1`  | First argument to and.
`a2`  | Second argument to and.
*Variadic*|
`as` | Variable number of arguments to and.

##### and example

```coffee
aand(true, true)      # true
aand(1,4)             # true
aand(1)(null)         # false
```

#### add

Adds two (or more) numbers or strings together.

`add(a,b)`   `:: a, a -> a`  
`add(b)(a)`  `:: a -> a -> a`  
`add(as...)` `:: a... -> a`  

args | desc
:--- | :---
`a`  | First argument to add, number or string.
`b`  | Second argument to add, number or string.
*Variadic*|
`as` | Variable number of number/strings to add together.

#### both

Returns a function that wraps two (or more) functions and performs
*logical and* on the result.

`both(f1,f2)`   `:: (a... -> Boolean), (a... -> Boolean) -> Boolean`  
`both(f2)(f1)`  `:: (a... -> Boolean) -> (a... -> Boolean) -> Boolean`  
`both(fs...)`   `:: (a... -> Boolean)... -> Boolean`  

args | desc
:--- | :---
`f1`  | First function to wrap.
`f2`  | Second function to wrap.
*Variadic*|
`fs` | Variable number of functions to wrap.

##### both example

```coffee
gt10  = gt(10)
even  = (a) -> a % 2 == 0
lt100 = lt(100)
f     = both(gt10, even)
f(102)                        # true
g     = both(gt10, even, lt100)
g(102)                        # false
```

#### comp

Returns a function does a logical not on the result of the initial
function.

`comp(f)`   `:: (a... -> Boolean) -> Boolean`  

args | desc
:--- | :---
`f`  | The function to not.

##### comp example

```coffee
even  = (a) -> a % 2 == 0
odd   = comp(even)
odd(11)            # true
```

#### div

Division. `a` divided by `b`.

`div(a,b)`   `:: a, a -> a`  
`div(b)(a)`  `:: a -> a -> a`  
`div(as...)` `:: a... -> a`  

args | desc
:--- | :---
`a`  | Dividend.
`b`  | Divisor.
*Variadic*|
`as` | Variable number of arguments. I.e. `div(a,b,c)` is `a / b / c`.

#### either

Returns a function that wraps two (or more) functions and performs
*logical or* on the result. For coffeescript this function is aliased
as `either`.

`either(f1,f2)`   `:: (a... -> Boolean), (a... -> Boolean) -> Boolean`  
`either(f2)(f1)`  `:: (a... -> Boolean) -> (a... -> Boolean) -> Boolean`  
`either(fs...)`   `:: (a... -> Boolean)... -> Boolean`  

args | desc
:--- | :---
`f1`  | First function to wrap.
`f2`  | Second function to wrap.
*Variadic*|
`fs` | Variable number of functions to wrap.

##### either example

```coffee
gt10  = gt(10)
even  = (a) -> a % 2 == 0
lt100 = lt(100)
f     = either(gt10, even)
f(102)                        # true
g     = either(gt10, even, lt100)
g(102)                        # true
```

#### eq

Equality test. `a` equal to `b`, strict (as in `===` in
javascript-terms). See also [eql](#eql).

`eq(a,b)`   `:: a, a -> a`  
`eq(b)(a)`  `:: a -> a -> a`  
`eq(as...)` `:: a... -> a`  

args | desc
:--- | :---
`a`  | Argument 1.
`b`  | Argument 2.
*Variadic*|
`as` | Variable number of arguments. I.e. eq(a,b,c)` is `a == b == c`.

#### gt

Greater than. `a` greater than `b`.

`gt(a,b)`  `:: a, a -> Boolean`  
`gt(b)(a)` `:: a -> a -> Boolean`  

args | desc
:--- | :---
`a`  | First argument in `a > b`.
`b`  | Second argument in `a > b`.

#### gte

Greater than or equals. `a` greater than or equals `b`.

`gte(a,b)`  `:: a, a -> Boolean`  
`gte(b)(a)` `:: a -> a -> Boolean`  

args | desc
:--- | :---
`a`  | First argument in `a >= b`.
`b`  | Second argument in `a >= b`.

#### lt

Less than. `a` less than `b`.

`lt(a,b)`  `:: a, a -> Boolean`  
`lt(b)(a)` `:: a -> a -> Boolean`  

args | desc
:--- | :---
`a`  | First argument in `a < b`.
`b`  | Second argument in `a < b`.

#### lte

Less than or equals. `a` less than or equals `b`.

`lte(a,b)`  `:: a, a -> Boolean`  
`lte(b)(a)` `:: a -> a -> Boolean`  

args | desc
:--- | :---
`a`  | First argument in `a <= b`.
`b`  | Second argument in `a <= b`.

#### max

The max of two (or more) arguments. Same as `Math.max(a,b)`.

`max(a,b)`   `:: a, a -> Boolean`  
`max(b)(a)`  `:: a -> a -> Boolean`  
`max(as...)` `:: a... -> Boolean`  

args | desc
:--- | :---
`a`  | First argument in `Math.max(a,b)`
`b`  | Second argument in `Math.max(a,b)`
*Variadic*|
`as` | Variable number of arguments. I.e `Math.max(a,b,c)`

#### min

The min of two (or more) arguments. Same as `Math.min(a,b)`.

`min(a,b)`   `:: a, a -> Boolean`  
`min(b)(a)`  `:: a -> a -> Boolean`  
`min(as...)` `:: a... -> Boolean`  

args | desc
:--- | :---
`a`  | First argument in `Math.min(a,b)`
`b`  | Second argument in `Math.min(a,b)`
*Variadic*|
`as` | Variable number of arguments. I.e `Math.min(a,b,c)`

#### mod

Modulus (javascript style). `a` modulus `b`.

`mod(a,b)`   `:: a, a -> a`  
`mod(b)(a)`  `:: a -> a -> a`  
`mod(as...)` `:: a... -> a`  

args | desc
:--- | :---
`a`  | Dividend.
`b`  | Divisor.
*Variadic*|
`as` | Variable number of arguments. I.e. `mod(a,b,c)` is `a % b % c`.

#### mul

Multiplication. `a` multiplied by `b`.

`mul(a,b)`   `:: a, a -> a`  
`mul(b)(a)`  `:: a -> a -> a`  
`mul(as...)` `:: a... -> a`  

args | desc
:--- | :---
`a`  | First factor in `a * b`.
`b`  | Second factor in `a * b`.
*Variadic*|
`as` | Variable number of arguments. I.e. `mul(a,b,c)` is `a * b * c`.

#### not

Function that does a logical not argument. For coffeescript this
function is aliased as `nnot`.

`nnot(a)`   `:: * -> Boolean`  

args | desc
:--- | :---
`a`  | The argument to not.

##### not example

```coffee
not(1)       # false
not(null)    # true
```

#### or

Function that performs *logical or* on the arguments. For coffeescript
this function is aliased as `oor`.

`oor(a1,a2)`   `:: (*, *) -> Boolean`  
`oor(a2)(a1)`  `:: * -> * -> Boolean`  
`oor(as...)`   `:: (*, *, ...) -> Boolean`  

args | desc
:--- | :---
`a1`  | First argument to or.
`a2`  | Second argument to or.
*Variadic*|
`as` | Variable number of arguments to or.

##### or example

```coffee
oor(1,0)         # true
oor(0,0)         # false
oor(0, null)     # false
oor(null)(1)     # true
```

#### sub

Subtraction. `a` subtracted by `b`.

`sub(a,b)`   `:: a, a -> a`  
`sub(b)(a)`  `:: a -> a -> a`  
`sub(as...)` `:: a... -> a`  

args | desc
:--- | :---
`a`  | Minuend.
`b`  | Subtrahend.
*Variadic*|
`as` | Variable number of arguments. I.e. `sub(a,b,c)` is `a - b - c`.


[curry]: https://en.wikipedia.org/wiki/Currying
[fold]:  https://en.wikipedia.org/wiki/Fold_%28higher-order_function%29
