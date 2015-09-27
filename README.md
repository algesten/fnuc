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

```javascript
require('fnuc').expose(global);
```

Or use it library style with a prefix:

```javascript
F = require('fnuc');  // all functions under F
```

Use destructuring assignment to pick things you want.

Coffeescript

```coffee
{split, map} = require 'fnuc'
```

Javascript

```javascript
let {split, map} = require('fnuc');
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

*  fnuc tries to follow the
   [principle of least astonishment][princ]. This shows in function
   argument order which is clearly spelled out in this
   [stack overflow answer][stack].

*  Less is more. fnuc provides the most used basics, not every
   conceivable utility function. Please
   [suggest](https://github.com/algesten/fnuc/issues) functions to add
   if anything important is missing.

*  Javascript is liberating. Functional programming purists may argue
   the virtues of [immutability][immut] and typing whilst I would
   argue the opposite; the lack of rigour has made programming fun
   again. fnuc embraces all of javascript and will mutate where
   appropriate.


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

API
---

[`I`](api.md#i)
[`add`](api.md#add)
[`all`](api.md#all)
[`always`](api.md#always)
[`and`](api.md#and)
[`any`](api.md#any)
[`apply`](api.md#apply)
[`arity`](api.md#arity)
[`arityof`](api.md#arityof)
[`clone`](api.md#clone)
[`compose`](api.md#compose)
[`concat`](api.md#concat)
[`contains`](api.md#contains)
[`converge`](api.md#converge)
[`curry`](api.md#curry)
[`div`](api.md#div)
[`drop`](api.md#drop)
[`each`](api.md#each)
[`eq`](api.md#eq)
[`eql`](api.md#eql)
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
[`or`](api.md#or)
[`partial`](api.md#partial)
[`partialr`](api.md#partialr)
[`pick`](api.md#pick)
[`pipe`](api.md#pipe)
[`plift`](api.md#plift)
[`ppipe`](api.md#ppipe)
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
[`uniq`](api.md#uniq)
[`uniqfn`](api.md#uniqfn)
[`values`](api.md#values)
[`zip`](api.md#zip)
[`zipobj`](api.md#zipobj)
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
[immut]: https://en.wikipedia.org/wiki/Immutable_object
