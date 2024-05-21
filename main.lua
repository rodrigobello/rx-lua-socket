package.path = package.path .. ";" .. os.getenv("LUA_PATH")
package.cpath = package.cpath .. ";" .. os.getenv("LUA_CPATH")

local socket = require("socket")
local Rx = require("rx")

local RxLuaSocket = {}

function RxLuaSocket.fromConnection(host, port)
    return Rx.Observable.create(function(observer)
        local client = assert(socket.connect(host, port))
        client:settimeout(0)

        local function readData()
            while true do
                local data, err = client:receive("*l")
                if data then
                    observer:onNext(data)
                elseif err ~= "timeout" then
                    observer:onError(err)
                    break
                end
                socket.sleep(0.01)
            end
            observer:onCompleted()
        end

        local co = coroutine.create(readData)
        coroutine.resume(co)

        return function()
            client:close()
        end
    end)
end

print("setting up reactive extension on localhost 8080")
RxLuaSocket.fromConnection("localhost", 8080)
    :map(function(data) return data .. "!" end)
    :subscribe(print)

print("pinging localhost:8080")
local client = socket.connect("localhost", 8080)
client:send("hey I'm pinging localhost\n")

socket.sleep(1)
client:close()
