API
===

[`I`](api.md#i)
[`add`](api.md#add)
[`all`](api.md#all)
[`any`](api.md#any)
[`arity`](api.md#arity)
[`clone`](api.md#clone)
[`compose`](api.md#compose)
[`concat`](api.md#concat)
[`contains`](api.md#contains)
[`curry`](api.md#curry)
[`div`](api.md#div)
[`each`](api.md#each)
[`filter`](api.md#filter)
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
[`index`](api.md#index)
[`isplain`](api.md#isplain)
[`join`](api.md#join)
[`keys`](api.md#keys)
[`last`](api.md#last)
[`lcase`](api.md#lcase)
[`lpartial`](api.md#lpartial)
[`lt`](api.md#lt)
[`lte`](api.md#lte)
[`map`](api.md#map)
[`match`](api.md#match)
[`max`](api.md#max)
[`merge`](api.md#merge)
[`min`](api.md#min)
[`mixin`](api.md#mixin)
[`mod`](api.md#mod)
[`mul`](api.md#mul)
[`replace`](api.md#replace)
[`reverse`](api.md#reverse)
[`rpartial`](api.md#rpartial)
[`search`](api.md#search)
[`sequence`](api.md#sequence)
[`set`](api.md#set)
[`shallow`](api.md#shallow)
[`sort`](api.md#sort)
[`split`](api.md#split)
[`sub`](api.md#sub)
[`tail`](api.md#tail)
[`tap`](api.md#tap)
[`trim`](api.md#trim)
[`type`](api.md#type)
[`ucase`](api.md#ucase)
[`uniq`](api.md#uniq)
[`values`](api.md#values)


### Type functions

Functions operating on types.

#### I

The identity function `(x) -> x`.

`:: (a) -> a`

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

Tells or checks what type an object is depending on number of
arguments.

With one argument, returns one of `'array'`, `'boolean'`, `'date'`,
`'null'`, `'number'`, `'object'` `'string'` or `'undefined'`.

With two arguments, checks whether the second argument is of the type
specified in the first.

`type(a)`   `:: a -> String`  
`type(t,a)` `:: s|fn, a -> Boolean`

args | desc
:--- | :---
*One arg variant*|
`a`  | Object to find type for.
*Two arg variant*|
`t`  | The string type to check for.
`a`  | Object to check.

type | function
:--- | :---
`'array'`   | `Array`
`'boolean'` | `Boolean`
`'date'`    | `Date`
`'null'`    | -
`'number'`  | `Number`
`'object'`  | `Object`
`'string'`  | `String`
`'symbol'`  | `Symbol` *untested*
`'undefined'` | -

##### type one arg example

    type 'abc'     # 'string'
    type 42        # 'number'
    type null      # 'null'
    type {}        # 'object'
    type undefined # 'undefined'

##### type two arg example

    type 'string', 'abc'     # true
    type 'string', null      # false
    type type(a), a          # true
    type 'number', 42        # true

### Function functions

Functions operating on functions.

#### arity

Dual purpose method to check or force function arity.

To check the arity of a function `arity(f)` returns the number of
arguments `f` takes (same as `f.length`).

To make a function `f1` of `f` that reports a certain arity we use the
form `f1 = arity(f,n)` where `n` is the number of arguments we want
`f` to report (`f1.length` will equal `n`). Note that this doesn't
stop `f1` from receiving more arguments.

`arity(f)`   `:: (a... -> a) -> Number`  
`arity(f,n)` `:: (a... -> a), n -> (a... -> a)`  
`arity(n)(f)` `:: n -> (a... -> a) -> (a... -> a)`

args | desc
:--- | :---
*One arg variant*|
`f`  | Function to check arity of.
*Two arg variant*|
`f`  | Function to make a new function with fixed arity of.
`n`  | The arity of the new function.


args | desc
:--- | :---
`f`  | Function to force arity of.
`n`  | Number of reported arguments.

##### unary

Same as `arity(1)`.

##### binary

Same as `arity(2)`.

##### ternary

Same as `arity(3)`.

##### arity example

    arity (->)        # 0
    arity I           # 1
    arity ((a,b)->)   # 2
    arity type        # 2
    arity arity       # 2

    myconcat = (as....) -> [].concat as...
    arity myconcat    # 0 for variadic functions.

    myconcat2 = arity(2) myconcat # could have used 'binary myconcat'
    arity myconcat2   # 2

    myconcat2 1, 2    # [1,2]
    myconcat2 1, 2, 3 # [1,2,3] SURPRISE! (or not)

#### compose

Makes a composition function out of a variable number of functions
`compose(f3,f2,f1)` becomes `f3(f2(f1)))` with the rightmost function
being invoked first (the opposite is [sequence](#sequence)).

The result is curried if the rightmost function is of arity > 1.

    h = compose(f,g)
    z = h(1,2)
    z = h(2)(1)

is equivalent to:

    y = g(1,2)
    z = f(y)

`compose(as...)` `:: ((y -> z), (x -> y), ..., (b -> c), (a... -> b)) -> (a... -> z)`

args | desc
:--- | :---
`as...` | Variable number of functions to compose.

##### compose example

    div10 = div(10)
    add50 = add(50)
    pow   = (a,b) -> Math.pow(a,b)
    calc  = compose div10, add50, pow
    calc(10,2)  # 15 or (10 ^ 2 + 50) / 10
    calc(2)(10) # 15

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

    f = flip curry ternary concat
    f(1, 2, 3)    # [3,2,1]
    f(3)(2)(1)    # [3,2,1] the curry was flipped
    f3 = f(3)
    g3 = flip f3  # flipping partially applied
    f3(2)(1)      # [3,2,1]
    g3(2)(1)      # [3,1,2]

#### lpartial

Creates a function that has the original function partially applied
from the left (see also [rpartial](#rpartial)).

`lpartial ((a,b) -> a/b), 10` makes a function that will receive one
additional argument `x` to divide 10 by `x`.

`lpartial(f,as...)` `:: ((a... -> a), a, b, ...) -> (a... -> a)`

args | desc
:--- | :---
`f`  | Function to apply arguments for.
`as...` | Variable number of arguments to apply from the left.

##### lpartial example

    l     = [1,2,3,...]
    even  = (a) -> a % 2 == 0    # even number filter
    fl    = lpartial filter l    # fl always filters mylist
    le    = fl even              # keep only even

#### rpartial

Creates a function that has the original function partially applied
from the right (see also [lpartial](#lpartial)).

`rpartial ((a,b) -> a/b), 10` makes a function that will receive one
additional argument `x` to divide `x` by 10.

`rpartial(f,as...)` `:: ((a... -> a), a, b, ...) -> (a... -> a)`

args | desc
:--- | :---
`f`  | Function to apply arguments for.
`as...` | Variable number of arguments to apply from the right.

##### rpartial example

    l     = [1,2,3,...]
    even  = (a) -> a % 2 == 0         # even number filter
    fr    = lpartial filter even      # applies even filter to any list
    le    = fr l                      # keeps only even

#### sequence

Makes a sequence function out of a variable number of functions
`sequence(f1,f2,f3)` becomes `f3(f2(f1)))` with the leftmost function
invoked first (the opposite is [compose](#compose)).

The result is curried if the leftmost function is of arity > 1.

    h = sequence(f,g)
    z = h(1,2)
    z = h(2)(1)

is equivalent to:

    y = f(1,2)
    z = g(y)

`sequence(as...)` `:: ((y -> z), (x -> y), ..., (b -> c), (a... -> b)) -> (a... -> z)`

args | desc
:--- | :---
`as...` | Variable number of functions to sequence.

##### sequence example

    div10 = div(10)
    add50 = add(50)
    pow   = (a,b) -> Math.pow(a,b)
    calc  = sequence pow, add50, div10
    calc(10,2)  # 15 or (10 ^ 2 + 50) / 10
    calc(2)(10) # 15

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

    log   = (as...) -> console.log as...      # console.log returns undefined
    dolog = tap(log)                          # dolog returns same value
    calc  = sequence add(3), dolog, div(10)   # log the value between the operations
    calc [1,2,3]                              # logs 4...5...6

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

    clone 42            # 42
    clone {a:1}         # {a:1}
    clone {a:[1,2,3]}   # {a:[1,2,3]} the nested array is cloned
    clone {d:new Date}  # {d:<date>}  the nested date is cloned

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

    get {a:1,b:2}, 'b'     # 2
    getb = get 'b'         # partial
    getb {b:3}             # 3

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

    has {a:1,b:2}, 'b'     # true
    hasb = has 'b'         # partial
    hasb {b:3}             # true

#### keys

Makes an array of the keys of an object. `keys o` is the same as `Object.keys(o)`.

`keys(o)` `:: {k:v} -> [k]`

args | desc
:--- | :---
`o` | Object to get keys from.

##### keys example

    keys {a:1,b:2}          # ['a','b']
    keys {}                 # []

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

    merge (t={c:4}), {a:1}, {a:2,b:3}    # t is {a:2,b:3,c:4}
    merge {c:4}, {a:1, b:undefined}      # {a:1,c:4}

#### mixin

Returns a new object with the key/values from consecutive objects
set. Rightmost object takes precende. Omits values that are
undefined. `mixin {a:1}, {b:2}` is equivalent to `merge {}, {a:1},
{b:2}`.

`mixin(os...)` `:: {*}... -> {*}`

args | desc
:--- | :---
`os...` | Variable number of objects to apply left to right.

##### mixin example

    mixin (t={c:4}), {a:1}, {a:2,b:3}    # {a:2,b:3,c:4} t is {c:4}
    mixin {c:4}, {a:1, b:undefined}      # {a:1,c:4}

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

    o = {a:1,b:3}
    set(o,'a',2)          # {a:2,b:3}
    seta3 = set(3)('a')   # partial
    setb4 = set(4)('b')   # partial
    f = sequence seta3, setb4
    f(o)                  # {a:3,b:4}

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

    shallow 42            # 42
    shallow {a:1}         # {a:1}
    shallow {a:[1,2,3]}   # {a:[1,2,3]} the nested array is copy-by-reference
    shallow {d:new Date}  # {d:<date>}  the nested date is copy-by-reference

#### values

Makes an array of the values of an object.

`values(o)` `:: {k:v} -> [v]`

args | desc
:--- | :---
`o` | Object to get values from.

##### values example

    values {a:1,b:2}, 'b'     # ['1','2']
    values {}                 # []

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

    as = [1,0,2]
    all as, (a) -> a > 0      # false
    all as, (a) -> a >= 0     # true
    gt0 = all (a) -> a > 0    # partial
    gt0 as                    # false

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

    as = [1,0,2]
    any as, (a) -> a > 0      # true
    any as, (a) -> a > 2      # false
    gt0 = any (a) -> a > 0    # partial
    gt0 as                    # false

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

    concat [1,2], [3,4]   # [1,2,3,4]
    concat [1,2], 3, 4    # [1,2,3,4]
    concat 1, 2, 3, 4     # [1,2,3,4]

#### contains

Tells if an array contains a value. Same as `index(a,v) >= 0`.

`contains(as,a)`  `:: [a], a -> Boolean`  
`contains(a)(as)` `:: a -> [a] -> Boolean`

args | desc
:--- | :---
`as` | Array to check.
`a`  | Element to look for.

##### contains example

    contains [1,2,3], 2    # true
    contains [1,2,3], 5    # false
    cont5 = contains(5)    # partial
    cont5 [3,4,5]          # true

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

    log = (a) -> console.log a
    each [1,2,3], log            # prints 1...2...3
    listlogger = each log        # partial
    listlogger [1,2,3]           # prints 1...2...3

#### filter

Creates a new list containing only elements for which a test function
is true. Same as `[...].filter`.

`filter(as,f)`  `:: [a], (a -> Boolean) -> [a]`  
`filter(f)(as)` `:: (a -> Boolean) -> [a] -> [a]`

##### filter example

    odd = (a) -> a % 2
    filter [1,2,3], odd     # [1,3]
    fo = filter odd         # partial
    fo [1,2,3]              # [1,3]

#### fold

Performs a [fold][fold] operation from the left with a seed
value. Same as `[...].reduce(f, s)`

`fold(as,f,s)`   `[b], ((a, b, i, [b]) -> a), a -> a`  
`fold(s)(f)(as)` `a -> ((a, b, i, [b]) -> a) -> [b] -> a`

args | desc
:--- | :---
`as` | Array to fold.
`f`  | Folding function. Signature is `(a,b,i,as)`.
`s`  | Seed value.
*folding function* |
`a` | Value of previous fold operation or `s` for first element.
`b` | Current value from `as`.
`i` | Index of `b` in `as`.
`as`| The entire `as`.

##### fold example

    f = (p,c) -> if c % 2 then c + p else p   # sum odd numbers
    fold [1,2,3], f, 5                        # 9

#### fold1

Same as [fold](#fold) but no seed value. Same as `[...].reduce(f)`.

`fold1(as,f)`  `[b], ((a, b, i, [b]) -> a) -> a`  
`fold1(f)(as)` `((a, b, i, [b]) -> a) -> [b] -> a`

args | desc
:--- | :---
`as` | Array to fold.
`f`  | Folding function. Signature is `(a,b,i,as)`.
*folding function* |
`a` | Value of previous fold operation or first element for first iteration.
`b` | Current value from `as` or second element for first iteration.
`i` | Index of `b` in `as`.
`as`| The entire `as`.

##### fold1 example

    f = (p,c) -> if c % 2 then c + p else p   # sum odd numbers
    fold1 [2,3,4], f                          # 5 (in first iteration p=2 and c=3)

#### foldr

Same as [fold](#fold) but goes right to left with a seed value. Same
as `[...].reduceRight(f,s)`

`foldr(as,f,s)`   `[b], ((a, b, i, [b]) -> a), a -> a`  
`foldr(s)(f)(as)` `a -> ((a, b, i, [b]) -> a) -> [b] -> a`

args | desc
:--- | :---
*See [fold](#fold)* |

#### foldr1

Same as [foldr](#foldr) but no seed value. Same as
`[...].reduceRight(f)`

`fold1(as,f)`  `[b], ((a, b, i, [b]) -> a) -> a`  
`fold1(f)(as)` `((a, b, i, [b]) -> a) -> [b] -> a`

args | desc
:--- | :---
*See [fold1](#fold1)* |

#### head

Gets the head value of an array.

`head(as)` `:: [a] -> a|undefined`

args | desc
:--- | :---
`as` | The array to get the head from.

##### head example

    head [1,2,3]   # 1
    head []        # undefined

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

    index [1,2,3], 3       # 2
    index [1,2,3], 4       # -1

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

    join [1,2,3], ''     # '123'
    join [1,2,3], '-'    # '1-2-3'

#### last

Gets the last value of an array. `undefined` for empty list.

`last(as)`  `:: [a] -> a|undefined`

args | desc
:--- | :---
`as` | The array get the last value of.

##### last example

    last [1,2,3]     # 3
    last []          # undefined

#### map

Creates a new array of transformed values by applying a transformation
function to each element. Same as `[...].map(f)`

`map(as,f)`  `:: [a], ((a, i, [a]) -> b) -> [b]`  
`map(f)(as)` `:: ((a, i, [a]) -> b) -> [a] -> [b]`

args | desc
:--- | :---
`as` | Array to transform.
`f`  | Transformation function. Signature is `(a,i,as)`.
*transformation function* |
`a` | Current value from `as`.
`i` | Index of `a` in `as`.
`as`| The entire `as`.

##### map example

    add1 = (a) -> a + 1
    map [1,2,3], add1     # [2,3,4]
    ladd1 = map add1      # partial
    ladd1 [2,3,4]         # [3,4,5]

#### reverse

Reverses the array. Same as `[...].reverse()`

`reverse(as)` `:: [a] -> [a]`

args | desc
:--- | :---
`as` | Array to reverse.

##### reverse example

    reverse [1,2,3]    # [3,2,1]

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

    sort [2,1,3]            # [1,2,3]
    comp = (a,b) -> b - a
    sort [2,1,3], comp      # [3,2,1]
    s = sort(comp)          # partial
    s [4,1,5,2]             # [5,4,2,1]

#### tail

The tail of a list, that is, every element apart from the first. The
tail of `[]` is `[]`.

`tail(as)`  `:: [a] -> [a]`

args | desc
:--- | :---
`as` | Array to get tail of.

##### example

    tail [1,2,3]    # [2,3]
    tail []         # []

#### uniq

Creates an array where every element occurs only once (given `==`
equality).

`uniq(as)` `:: [a] -> [a]`

args | desc
:--- | :---
`as` | Array to dedupe.

##### uniq example

    uniq [3,1,3,2,1,3,2,1]   # [3,1,2]

### String functions

Functions operating on strings.

#### lcase

Turns the given string to lowercase. Same as `s.toLowerCase()`

`lcase(s)`  `:: s -> s`

args | desc
:--- | :---
`s`  | String to lowercase.

##### lcase example

    lcase 'aBcD'   # 'abcd'

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

    match 'a bar frog', '.'     # [ 'a', index: 0, input: 'a bar frog' ]
    match 'a bar frog', 'fo'    # null
    match 'a bar frog', /ar?/g  # ['a', 'ar']

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

    replace 'abcab', 'b', 'c'    # 'accac'
    replace 'abcab', 'd', 'c'    # 'abcab'
    replace 'abcab', /a./g, 'f'  # 'fcf'

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

    search 'abc',  '.'    # 0
    search 'abc',  /./    # 0
    search 'abc',  /d/    # -1
    search 'abc',  '.c'   # 1
    findC = search('c')   # partial
    findC 'aqdc'          # 3

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

    split 'abc', ''          # ['a','b','c']
    split 'abc', 'b'         # ['a', 'c']
    split 'cadabcab', /[ab]/ # ['c', 'd', '', 'c', '', '']

#### trim

Trims whitespace off start and end of a string. Same as `s.trim()`

`trim(s)`  `:: s -> s`

args | desc
:--- | :---
`s`  | String to trim.

##### trim example

    trim '  ab  \n'    # 'ab'

#### ucase

Turns the given string to uppercase. Same as `s.toUpperCase()`

`ucase(s)` `:: s -> s`

args | desc
:--- | :---
`s`  | String to uppercase.

##### ucase example

    ucase 'aBcD'  # 'ABCD'


### Math functions

Functions for math.

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
