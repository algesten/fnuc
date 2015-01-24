(fnuc) ->
=========

[![Build Status](https://travis-ci.org/algesten/fnuc.svg)](https://travis-ci.org/algesten/fnuc) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/algesten/fnuc)

> cause i want it my way.

### Installing with NPM

```bash`
npm install -S fnuc
```

Inject into global

    require('fnuc').installTo(global)

Or use it library style with a prefix:

    f = require `fnuc` # all functions under f

### Compatibility

Tested on IE10+, Chrome 38+, Firefox 34+, Safari 7+. IE9 did not pass
all tests since chai should style is unsupported on IE9.

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

License
-------

The MIT License (MIT)

Copyright (c) 2015 Martin Algesten

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


[princ]: http://en.wikipedia.org/wiki/Principle_of_least_astonishment
[stack]: http://stackoverflow.com/questions/25674596/#25720884
[curry]: https://en.wikipedia.org/wiki/Currying
[compo]: https://en.wikipedia.org/wiki/Function_composition_%28computer_science%29
