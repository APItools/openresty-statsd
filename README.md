# openresty-statsd [![travis-ci](https://secure.travis-ci.org/lonelyplanet/openresty-statsd.png)](https://secure.travis-ci.org/lonelyplanet/openresty-statsd)

A Lua module for openresty to send metrics to StatsD

## Features

* increments!
* counts!
* timers!
* cosocket frolics
* batchin'

## Installation

1. [Install openresty](http://openresty.org) configured `--with-luajit`
2. Copy `lib/statsd.lua` somewhere that openresty nginx can find (you may need to adjust your `LUA_PATH` or use `lua_package_path` [directive](http://wiki.nginx.org/HttpLuaModule#lua_package_path)
3. Configure nginx:

```
    # an nginx conf
    http {
      # optionally set relative lua_package_path
      lua_package_path "${prefix}lua/*.lua";

      # create a shared dictionary to for statsd. The default name is STATSD
      lua_shared_dict STATSD 20k;

      location /some_location {
        content_by_lua '
          -- this is the phase where metrics are registered
          local statsd = require 'statsd'
          local s = statsd:new()
          s:incr("test.status." .. ngx.var.status)
          s:time("test.req_time", ngx.now() - ngx.req.start_time())

        ';

        log_by_lua '
          -- this is the phase where metrics are sent
          -- batch metrics into packets of 50 metrics by default
          local statsd = require 'statsd'
          local s = statsd:new()
          s:flush()
        ';
      }
    }
```

The request-response lifecycle in nginx has [eight phases](http://wiki.nginx.org/HttpLuaModule#ngx.get_phase). The data you are likely to want to report (HTTP status, request time) is available in the last phase, `log`, but the socket API is not available. That's why stats are registered in `log_by_lua` and sent via `flush` in `content_by_lua`.

## Changelog

* 0.0.1: Works. Tested.
* 0.0.2: Uses a dictionary

## Development

### Prerequisites for dev and testing

* luarocks

### Build

1. Clone the repo
2. `luarocks install md5 [--local]`
3. `luarocks install mime [--local]`
4. `luarocks install busted [--local]`

Then on the project folder console just run:

    busted

## Related projects

* [lua-statsd](https://github.com/cwarden/lua-statsd) - doesn't use openresty's cosockets
* [nginx-statsd](https://github.com/zebrafishlabs/nginx-statsd) - written in C
* [fozzie](https://github.com/lonelyplanet/fozzie) - our Ruby StatsD client

## Author

[Dave Nolan](http://kapoq.com) / [lonelyplanet.com](http://www.lonelyplanet.com)
[Enrique García](https://github.com/kikito)
