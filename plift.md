plifting
========

Plifting is a strategy for using *simple functions* (perhaps even
[pure functions][puref]) when dealing with [promises][proms].

It's rather straightforward:

```javascript
var add = (a, b) => a + b;      // a simple function
var padd = F.plift(add);        // same function, but plifted

// makes a promise that resolves to v after 1000 ms.
var later = (v) => new Promise((rs) => setTimeout((()=>rs(v)), 1000));

var r1 = padd(2, 3);            //=> 5. immediate evaluation. no promise.
var r2 = padd(later(2), 3);     //=> promise for 5. after 1 second.

r2.then((r) => console.log(r)); // prints 5 after 1 second.
```


### plift

When a [plifted](api.md#plift) function receives any promise arguments
(then-able), the actual application of the function is delayed and a
promise for the evaluation is returned instead.

This enables us to focus on writing simple functions that can be
tested/run without the complication of future values, and still be
certain they work as intended for promised arguments.

Plifted functions:

* Evaluate syncronously for "normal" (non-promise) arguments.
* Returns a promise for a future evaluation when any argument is a
  promise.


### plifted composition (pipe)

Plifting individual functions is nice, but even more useful is
functional composition with automatic plifting.

##### pipe example

```javascript
// expects an object such as {userid:"abc123"}
var getIdParameter = get('userid');

// db lookup an id and returns promise for record
var dblookup = require('./db').lookup;

// from a record make a greeting
var recordToGreeting = (rec) => return "Hello " + rec.firstName + " " + rec.lastName;

// from an object with an id, lookup and make a greeting.
var idToGreeting = pipe(getIdParameter, dblookup, recordToGreeting);
```

Notice that nowhere in this functional composition (`pipe`) do we see
any promises. We know they are introduced by the `dblookup`, but the
rest of the pipe (`recordToGreeting`) will only receive the resolved
value.

The result of the entire pipe will be a promise, that needs resolving
before we see the greeting.

// in action.
idToGreeting({userid:"abc123"}).then((greet) => console.log(greet));
```

#### Motivation

##### Avoiding .then.then.then

The same result as `pipe` gave above, we could achieve using a chain
of `.then`. Although the following example can be written better, this
is often how `.then`-chains look.

```javascript
function idToGreeting(params) {
    return Q().then(function() {
        id = getIdParameter(params);
        return dblookup(id);
    }).then(function(rec) {
        return recordToGreeting(rec);
    });
}
```

Going from imperative style programming to functional, and reaping the
benefits thereof, is a lot about (re-)learning to think functionally;
instead of breaking down a problem into imperative steps, we break
down a problem into simple (preferably pure and no side effects),
interlinked (composed) functions.

Whilst a .then-chain could be interlinked simple functions, typically
they grow into monsters of nested closures with lots of imperative
code.

##### Simpler testing

In the above [`pipe` example](#pipe-example), we have one part of the
chain introducing a promised value. In an automated test we could
easily mock that away and end up with a synchronous function chain.

```javascript
var proxyquire = require('proxyquire');
var mymodule = proxyquire('mymodule', {
    './db': {
        lookup: (id) => {firstName:"Martin", lastName:"Doe"}
    }
});
assert.equal(idToGreeting({userid:"abc123"}), "Hello Martin Doe");
```


### Automatic plifting

In fnuc the following functions are automatically plifted.

* [always](api.md#always)
* [compose](api.md#compose)
* [converge](api.md#converge)
* [iif](api.md#iif)
* [maybe](api.md#maybe)
* [pipe](api.md#pipe)


### Elaborate example

A gym logging application allows getting workouts and programs using a
simple HTTP get API. Requests look like this

```
GET /pbu    # get program with id `bu`
GET /wFG    # get workout with id `FG`
```

The programs are stored in a database. The database calls have been
isolated to a separate module and are accessed using a function that
have signature:

`db.programs.get(type, id) //=> promise for program/workout`

Where `type` is one of `"program"` or `"workout"` and the promise will
be `null` if the program/workout was not found.

The following use express to serve content.

```coffee

# 404 not found   :: * -> deliver
notfound = always {code:404, body:"Not found"}

# 500 internal error :: (err) -> deliver
err500 = (err) -> {code:500, body:err.message ? String(err)}

# generic deliver function
dodeliver = ({code, mime, body}, res) ->
    res.status(code) if code
    res.set('Content-Type', mime) if mime
    res.send(body + "\n") if body

# dump the error to console
logerror = tap (err) -> console.log 'failed', err.stack ? err

# rejected promise -> deliver (and console.log)
errpipe = pfail pipe logerror, err500

# :: (req, res) -> do delivery
# unhandled rejected promises maps to 500
handle = (todeliver) -> converge pipe(todeliver, errpipe), nth(1), dodeliver

# deliver something as json :: json -> deliver
asjson   = (json) -> {code: 200, mime: 'application/json', body: JSON.stringify json}

# pick out nth request regexp match
param    = (n) -> (req) -> req.params[n]

# match request pattern
app.get /^\/([pw])([a-zA-Z0-9]+)$/, do ->

    # get prefix 'p' or 'w'
    getpfx  = param(0)                                     # :: req -> pfx

    # get id part
    getid   = param(1)                                     # :: req -> id

    # prefix determines 'program' or 'workout'
    gettype = pipe getpfx, iif eq('p'),                    # :: req -> type
        always('program'), always('workout')

    # from request get the type/id and get from db.
    dbprogram  = converge gettype, getid, db.programs.get  # :: req -> json

    # filter out `_meta` from object
    nometa   = ofilter nnot eq('_meta')                    # :: json -> json (without _meta)

    # turn filtered object into json delivery
    nometajson = pipe nometa, asjson                       # :: json -> deliver

    # from request to delivery object
    todeliver  = pipe dbprogram, iif isdef, nometajson, notfound # :: req -> deliver

    # produce function that goes from (req, res) to doing delivery
    handle todeliver
```

Link collection

[puref]: https://en.wikipedia.org/wiki/Pure_function
[proms]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
