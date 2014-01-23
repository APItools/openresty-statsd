local fakengx = require 'spec.lib.fakengx'
local statsd  = require 'lib.statsd'

describe("statsd", function()
  local s, dict
  before_each(function()
    ngx  = fakengx.new()
    s    = statsd:new()
    dict = ngx.shared[s.dict]
  end)

  describe("count", function()
    it("registers a count metric for the bucket", function()
      local sp = spy.on(s, "register")
      s:count("bucket", 99)
      assert.spy(sp).was.called_with(s, "bucket", 99, "c")
    end)
  end)

  describe("incr", function()
    it("makes a count of one for the bucket", function()
      local sp = spy.on(s, "count")
      s:incr("bucket")
      assert.spy(sp).was.called_with(s, "bucket", 1)
    end)
  end)

  describe("time", function()
    it("registers a time metric for the bucket", function()
      local sp = spy.on(s, "register")
      s:time("bucket", 100)
      assert.spy(sp).was.called_with(s, "bucket", 100, 'ms')
    end)
  end)

  describe("register", function()
    it("appends a metric string terminated with a newline to the buffer", function()
      assert.is_nil(dict:get('last_id'))

      s:register("foo", "bar", "baz")
      assert.are.equal(dict:get(1), "foo:bar|baz\n")
      assert.are.equal(dict:get('last_id'), 1)

      s:register("quux", "corge", "grault")
      assert.are.equal(dict:get(2), "quux:corge|grault\n")
      assert.are.equal(dict:get('last_id'), 2)
    end)
  end)

  describe("flush", function()
    it("does nothing if the buffer is not filled up", function()
      s:register("foo", "bar", "baz")
      s:flush()
      assert.is_nil(dict:get('last_flushed_id'))
      assert.are.equal(ngx.shared.statsd:get(1), "foo:bar|baz\n")
    end)

    it("#focus sends the buffer to statsd via UDP to specified host and port", function()
      local mocksocket = {setpeername = function() end, close = function() end}
      local sent = nil
      mocksocket.send = function(_, x) sent = x end
      ngx.socket.udp = function() return mocksocket end

      local setpeername = spy.on(mocksocket, 'setpeername')
      local close       = spy.on(mocksocket, 'close')

      local s = statsd.new(nil, nil, nil, 1)

      s:register("foo", "bar", "baz")
      s:register("quux", "corge", "grault")
      s:register("garply", "waldo", "fred")
      s:flush()

      assert.spy(setpeername).was.called_with(mocksocket, s.host, s.port)
      assert.spy(close).was.called_with(mocksocket)

      assert.are.same(sent, {'foo:bar|baz\n', 'quux:corge|grault\n'})

      assert.are.equal(dict:get('last_id'), 3)
      assert.are.equal(dict:get('last_flushed_id'), 2)
    end)
  end)

end)

