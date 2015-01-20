(fnuc) ->
=========

> cause i want it my way.

### Installing with NPM

```bash`
npm install -S fnuc
```

Inject into global
```
require('fnuc').installTo(global)
```

Or use it library style with a prefix:

```
f = require `fnuc` # all functions under f
```
About
-----

fnuc tries to follow the
[principle of least astonishment][princ]. This shows in function
paramater order which is clearly spelled out in this
[stack overflow answer][stack]. A short summary below.

### Parameter order

We expect a function such as `div` to have the following two forms:

```
div(a, b)    # a divided by b
div(b)(a)    # right section (`div` b)
```

`div` is [curried][curry] and `div10 = div(10)` can only have the meaning
*division by 10*. Hence `div10 20` should equal `2`.

Other least astonished variants that are *not in fnuc*:

```
div(_, b)    # left section (a `div`)
a `div` b    # infix haskell style
a.div b      # infix coffeescript style
```

API
---

### type

Functions operating on types.

#### isPlain

`:: {*} -> Boolean`

Tells whether an object is a plain object, i.e. has no prototype.

##### Example

```
isPlain null          # false
isPlain new Date      # false
isPlain {}            # true
isPlain a:42          # true
```

#### isType
#### typeOf

### fn

#### I
#### arity
#### binary
#### builtin
#### compose
#### curry
#### flip
#### ident
#### lpartial
#### ncurry
#### rpartial
#### sequence
#### tap
#### ternary
#### unary

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
