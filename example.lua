local RxSocket = require("rx-lua-socket")
local RxSocket = require("rx-lua-socket")

local args = {...}
local ports = {}
for _, port in ipairs(args) do
    table.insert(ports, tonumber(port))
end

if #ports == 0 then
    print("Usage: lua example.lua <port1> <port2> ... <portN>")
elseif #ports == 1 then
    print("Running socket for a single connection...")
    RxSocket.fromConnection("localhost", ports[1])
    :map(function(value) return "Received: " .. value end)
    :subscribe(
        function(data) print(data) end,
        function(err) print("Error: " .. err) end,
        function() print("Connection closed.") end
    )
else
    print("Running socket for multiple connections...")

    connections = {}
    for _, port in ipairs(ports) do
        table.insert(connections, {"localhost", port})
    end

    RxSocket.fromConnections(connections)
        :map(function(value) return "Received: " .. value end)
        :subscribe(
            function(data) print(data) end,
            function(err) print("Error: " .. err) end,
            function() print("Connection closed.") end
        )
end
