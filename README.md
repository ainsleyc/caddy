caddy
=====

Per-request storage for arbitrary data.

When the caddy middleware is called (ex by Express), caddy creates a data store that is accessable from any sub-modules used while handling the request. This can be a lot cleaner than attaching data to the res/req objects.

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

Once the Caddy middleware has been called, you can get() and set() data from sub-modules.

```js
var Caddy = require('caddy');

Caddy.set('key', 'data');
expect(Caddy.get('key')).to.equal('key');
```
