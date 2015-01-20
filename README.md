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

[`I`](api.md#i)
[`isPlain`](api.md#isplain)
[`isType`](api.md#istype)
[`type`](api.md#type)
[`arity`](api.md#arity)
[`compose`](api.md#compose)
[`curry`](api.md#curry)
[`flip`](api.md#flip)
[`lpartial`](api.md#lpartial)
[`rpartial`](api.md#rpartial)
[`sequence`](api.md#sequence)
[`tap`](api.md#tap)
[`clone`](api.md#clone)
[`get`](api.md#get)
[`has`](api.md#has)
[`keys`](api.md#keys)
[`merge`](api.md#merge)
[`mixin`](api.md#mixin)
[`shallow`](api.md#shallow)
[`values`](api.md#values)
[`all`](api.md#all)
[`any`](api.md#any)
[`concat`](api.md#concat)
[`contains`](api.md#contains)
[`each`](api.md#each)
[`filter`](api.md#filter)
[`fold`](api.md#fold)
[`fold1`](api.md#fold1)
[`foldr`](api.md#foldr)
[`foldr1`](api.md#foldr1)
[`head`](api.md#head)
[`index`](api.md#index)
[`join`](api.md#join)
[`last`](api.md#last)
[`map`](api.md#map)
[`reverse`](api.md#reverse)
[`sort`](api.md#sort)
[`tail`](api.md#tail)
[`uniq`](api.md#uniq)
[`lcase`](api.md#lcase)
[`match`](api.md#match)
[`replace`](api.md#replace)
[`search`](api.md#search)
[`split`](api.md#split)
[`trim`](api.md#trim)
[`ucase`](api.md#ucase)

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
