(fnuc) ->
=========

[![Build Status](https://travis-ci.org/algesten/fnuc.svg)](https://travis-ci.org/algesten/fnuc) [![Gitter](https://d378bf3rn661mp.cloudfront.net/gitter.svg)](https://gitter.im/algesten/fnuc)

> cause i want it my way.

fnuc is a library for [functional programming][funcp] in coffeescript
(and javascript). The reason for providing the "standard" javascript
methods as pure functions is to facilitate
[functional composition][compo] and [higher order functions][highf].

### Installing with NPM

```bash
npm install -S fnuc
```

Inject into global

```coffee
require('fnuc').expose(global)
```

Enable chainables (modifies `Function.prototype`)

```coffee
require('./src/fnuc').expose(global).installChainable()
```

Or use it library style with a prefix:

```coffee
F = require `fnuc`  # all functions under F
```

### Installing with Bower

```bash
bower install -S fnuc
```

### Compatibility

Tested on IE9+, Chrome 38+, Firefox 34+, Safari 7+.

About
-----

Design philosophy:

1. fnuc tries to follow the
   [principle of least astonishment][princ]. This shows in function
   argument order which is clearly spelled out in this
   [stack overflow answer][stack].
2. Less is more. fnuc provides the most used basics, not every
   conceivable utility function. Please
   [suggest](https://github.com/algesten/fnuc/issues) functions to add
   if anything important is missing.
3. I don't mind OOP. fnuc focuses on functions that are somewhat
   interesting for [function composition][compo], not a functional
   purist approach where everything must be functions.


### Argument order

We expect a function such as `div` to have the following two forms:

```coffee
div(a, b)    # a divided by b
div(b)(a)    # right section (`div` b)
```

`div` is [curried][curry] and `div10 = div(10)` can only have the meaning
*division by 10*. Hence `div10 20` should equal `2`.

Other least astonished variants that are *not in fnuc*:

```coffee
div(_, b)    # left section (a `div`)
a `div` b    # infix haskell style
a.div b      # infix coffeescript style
```

### Chainable sequencing

To install builtins on `Function.prototype` do:

```coffee
require('./src/fnuc').installChainable()
```

Most functions in fnuc are [chainable](api.md#chainable). This means
as an alternative to [`sequence`](api.md#sequence) and
[`compose`](api.md#compose), we can simply chain them together.

```coffee
f = add(10).div(4).mul(5.6)
f(20)                         # 42
```

This is equivalent to

```coffee
f = sequence add(10), div(4), mul(5.6)
```

In words: For a number, add 10 to it, divide the result by 4 and
finally multiply the *that* result with 5.6

```coffee
((x + 10) / 4) * 5.6
```

#### Arity `any -> 1 -> 1 -> 1`

The first function can take *any* number of arguments, so can the
sequenced result. However subsequent functions operate on the result
of the previous, which can only be *1*. This means there's a risk of
slipping up by not providing enough parameters when chaining.

```coffee
f = add(10).mul      # Warning! mul needs 2 arguments.
```

This chain produces a function, but I struggle to find any sane use
for it.

As a rule of thumb, try to ensure each function in a chain only
expects one more argument.

```coffee
f = split('').join('_').replace(/a/g,'b')
f('aaacc')                                  # 'b_b_b_c_c'
```

#### Making your own chainable

The API provides an easy way to define your own
[chainable](api.md#chainable) function: `chainable(name,f)`.

```coffee
even = (n) -> n % 2 == 0
chainable 'even', even

f = mul(3).even
f(10)            # true
f(11)            # false
```

API
---

[`I`](api.md#i)
[`add`](api.md#add)
[`all`](api.md#all)
[`and`](api.md#and)
[`any`](api.md#any)
[`arity`](api.md#arity)
[`chainable`](api.md#chainable)
[`clone`](api.md#clone)
[`compose`](api.md#compose)
[`concat`](api.md#concat)
[`contains`](api.md#contains)
[`curry`](api.md#curry)
[`div`](api.md#div)
[`drop`](api.md#drop)
[`each`](api.md#each)
[`eq`](api.md#eq)
[`eql`](api.md#eql)
[`evolve`](api.md#evolve)
[`filter`](api.md#filter)
[`flip`](api.md#flip)
[`fold1`](api.md#fold1)
[`fold`](api.md#fold)
[`foldr1`](api.md#foldr1)
[`foldr`](api.md#foldr)
[`fst`](api.md#fst)
[`get`](api.md#get)
[`groupby`](api.md#groupby)
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
[`len`](api.md#len)
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
[`not`](api.md#not)
[`nth`](api.md#nth)
[`ofilter`](api.md#ofilter)
[`omap`](api.md#omap)
[`or`](api.md#or)
[`partial`](api.md#partial)
[`partialr`](api.md#partialr)
[`pick`](api.md#pick)
[`replace`](api.md#replace)
[`reverse`](api.md#reverse)
[`search`](api.md#search)
[`sequence`](api.md#sequence)
[`set`](api.md#set)
[`shallow`](api.md#shallow)
[`slice`](api.md#slice)
[`snd`](api.md#snd)
[`sort`](api.md#sort)
[`split`](api.md#split)
[`sub`](api.md#sub)
[`tail`](api.md#tail)
[`take`](api.md#take)
[`tap`](api.md#tap)
[`trim`](api.md#trim)
[`tuple`](api.md#tuple)
[`type`](api.md#type)
[`typeis`](api.md#typeis)
[`ucase`](api.md#ucase)
[`unpack`](api.md#unpack)
[`uniq`](api.md#uniq)
[`unzip`](api.md#unzip)
[`values`](api.md#values)
[`zip`](api.md#zip)
[`zipwith`](api.md#zipwith)

License
-------

The MIT License (MIT)

Copyright © 2015 Martin Algesten

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[funcp]: https://en.wikipedia.org/wiki/Functional_programming
[highf]: https://en.wikipedia.org/wiki/Higher-order_function
[princ]: http://en.wikipedia.org/wiki/Principle_of_least_astonishment
[stack]: http://stackoverflow.com/questions/25674596/#25720884
[curry]: https://en.wikipedia.org/wiki/Currying
[compo]: https://en.wikipedia.org/wiki/Function_composition_%28computer_science%29
