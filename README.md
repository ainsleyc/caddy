caddy
=====

Per-request storage for arbitrary data.

When the Caddy middleware is called (ex by Express), Caddy creates a data store that is accessable from any sub-modules used while handling the request. This can be a lot cleaner than attaching data to the res/req objects, which then have to be repeatedly passed around as parameters.

Each request has it's own instance of the Caddy data store. There is no chance for the Caddy data of seperate requests to interact with each other, and no need for the user to keep track of which data belongs to which request.

The data store is maintained across events and other async functions such as process.nextTick(). By extension, the store will still be available after higher-level async functions like http.request().

Install
===

```sh
$ npm install caddy
```

Middleware
===

```js
var Caddy = require('caddy');
var express = require('express');
var app = express();

app.use(Caddy.connect);
```

API
===

Once the Caddy middleware has been called, you can get() and set() data from anywhere in your code.

```js
var Caddy = require('caddy');

Caddy.set('key', 'data');
expect(Caddy.get('key')).to.equal('key');
```
