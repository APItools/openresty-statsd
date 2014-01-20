require("busted")

local statsd = require("lib.statsd")

describe("statsd", function()
            describe("count", function()
                        it("registers a count metric for the bucket", function()
                              local s = spy.on(statsd, "register")
                              statsd.count("bucket", 99)
                              assert.spy(s).was.called_with("bucket", "99|c")
                                                                      end)
                              end)

            describe("incr", function()
                        it("makes a count of one for the bucket", function()
                              local s = spy.on(statsd, "count")
                              statsd.incr("bucket")
                              assert.spy(s).was.called_with("bucket", 1)
                                                          end)
                             end)

            describe("time", function()
                        it("registers a time metric for the bucket", function()
                              local s = spy.on(statsd, "register")
                              statsd.time("bucket", 100)
                              assert.spy(s).was.called_with("bucket", "100|ms")
                                                                     end)
                             end)

            describe("register", function()
                        it("appends a metric string terminated with a newline to the buffer", function()
                              statsd.flush()
                              statsd.register("foo", "bar")
                              statsd.register("zip", "zap")
                              assert.are.equal(statsd.buffer[1], "foo:bar\n")
                              assert.are.equal(statsd.buffer[2], "zip:zap\n")
                                                                                              end)

                                 end)

            describe("flush", function()
                        it("empties the buffer", function()
                              statsd.buffer[1] = "something"
                              statsd.flush()
                              assert.are.equal(table.getn(statsd.buffer), 0)
                                                 end)

                        pending("sends the buffer to statsd via UDP to specified host and port", function()
                                                                                               end)
                              end)

                   end)

