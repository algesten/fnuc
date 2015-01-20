(fnuc) ->
=========

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/algesten/fnuc)

> cause i want it my way.

### Installing with NPM

```bash`
npm install -S fnuc
```

Inject into global

    require('fnuc').installTo(global)

Or use it library style with a prefix:

    f = require `fnuc` # all functions under f

About
-----

Design philosophy:

1. fnuc tries to follow the
   [principle of least astonishment][princ]. This shows in function
   argument order which is clearly spelled out in this
   [stack overflow answer][stack].
2. Less is more. fnuc provides the most used basics, not every
   conceivable utility function.
3. I don't mind OOP. fnuc focuses on functions that are somewhat
   interesting for [function composition][compo], not a functional
   purist approach where everything must be functions.


### Argument order

We expect a function such as `div` to have the following two forms:


    div(a, b)    # a divided by b
    div(b)(a)    # right section (`div` b)


`div` is [curried][curry] and `div10 = div(10)` can only have the meaning
*division by 10*. Hence `div10 20` should equal `2`.

Other least astonished variants that are *not in fnuc*:

    div(_, b)    # left section (a `div`)
    a `div` b    # infix haskell style
    a.div b      # infix coffeescript style

API
---

### Type

Functions operating on types.

#### I

The identity function `(x) -> x`.

`:: (a) -> a`

#### isPlain

`Checks whether an object `o` is plain (created using `{}` or `new Object`).

`isPlain(o)` `:: {*} -> Boolean`

args | desc
:--- | :---
`o`  | Anything to test for plain.

##### isPlain example


    isPlain null          # false
    isPlain new Date      # false
    isPlain {}            # true
    isPlain a:42          # true

#### isType

Checks is an object `a` is of the given type `t`, where `t` can be any
of `'array'`, `'boolean'`, `'date'`, `'null'`, `'number'`, `'object'`
`'string'` or `'undefined'`. The function accepts any output from
[type](#type).

`isType(t,a)` `:: s|fn, a -> Boolean`

args | desc
:--- | :---
`t`  | Type to test for. Either a string type function.
`a`  | Object to test.

type | function
:--- | :---
`'array'`   | `Array`
`'boolean'` | `Boolean`
`'date'`    | `Date`
`'number'`  | `Number`
`'null'`    | -
`'object'`  | `Object`
`'string'`  | `String`
`'symbol'`  | `Symbol` *untested*
`'undefined'` | -

##### isType example


    isType 'string', 'abc'     # true
    isType 'string', null      # false
    isType type(a), a          # true
    isType Number, 42          # true
    isType 'number', 42        # true

#### type

Tells what type an object is. Returns one of `'array'`, `'boolean'`,
`'date'`, `'null'`, `'number'`, `'object'` `'string'` or `'undefined'`.

`type(a)` `:: a -> String`

args | desc
:--- | :---
`a`  | Object to find type for.

##### type example

    type 'abc'     # 'string'
    type 42        # 'number'
    type null      # 'null'
    type {}        # 'object'
    type undefined # 'undefined'

### Function

Functions operating on functions.

#### arity

Dual purpose method to check or force function arity.

To check the arity of a function `arity(f)` returns the number of
arguments `f` takes (same as `f.length`).

To make a function `f1` of `f` that reports a certain arity we use the
form `f1 = arity(f,n)` where `n` is the number of arguments we want
`f` to report (`f1.length` will equal `n`). Note that this doesn't
stop `f1` from receiving more arguments.

###### check variant
`arity(f)`   `:: (a... -> a) -> Number`

args | desc
:--- | :---
`f`  | Function to check arity of.

###### force variant
`arity(f,n)` `:: (a... -> a), n -> (a... -> a)`  
`arity(n)(f)` `:: n -> (a... -> a) -> (a... -> a)`

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
    arity isType      # 2
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

#### ident
#### lpartial
#### ncurry
#### rpartial
#### sequence
#### tap

### object

#### clone
#### get
#### has
#### keys
#### merge
#### mixin
#### shallow
#### values

### array

#### all
#### any
#### concat
#### contains
#### each
#### filter
#### fold
#### fold1
#### foldr
#### foldr1
#### head
#### index
#### join
#### last
#### map
#### reverse
#### sort
#### tail
#### uniq

### string

#### lcase
#### match
#### replace
#### search
#### split
#### trim
#### ucase


[princ]: http://en.wikipedia.org/wiki/Principle_of_least_astonishment
[stack]: http://stackoverflow.com/questions/25674596/#25720884
[curry]: https://en.wikipedia.org/wiki/Currying
[compo]: https://en.wikipedia.org/wiki/Function_composition_%28computer_science%29
