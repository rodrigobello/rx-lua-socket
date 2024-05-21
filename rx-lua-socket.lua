package.path = package.path .. ";" .. os.getenv("LUA_PATH")
package.cpath = package.cpath .. ";" .. os.getenv("LUA_CPATH")

local socket = require("socket")
local Rx = require("rx")

local M = {}

-- Function to create an observable from a single connection
function M.fromConnection(host, port)
    return Rx.Observable.create(function(observer)
        local client = assert(socket.connect(host, port))

        -- Function to read data from the socket
        local function readData()
            while true do
                local data, err = client:receive()
                if err then
                    observer:onError(err)
                    break
                else
                    observer:onNext(data)
                end
            end
            observer:onCompleted()
        end

        -- Start reading data in a coroutine
        local co = coroutine.create(readData)
        coroutine.resume(co)

        -- Cleanup function to close the socket
        return function()
            client:close()
        end
    end)
end

return M
