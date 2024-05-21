local socket = require("socket")

local server = assert(socket.bind("localhost", 8080))
server:settimeout(0) -- Set the server to non-blocking mode
print("Server listening on port 8080")

local clients = {}

while true do
    local client = server:accept()
    if client then
        client:settimeout(0) -- Set client to non-blocking mode
        table.insert(clients, client)
    end

    for i, client in ipairs(clients) do
        local line, err = client:receive()
        if line then
            print("Received: " .. line)
            client:send("Pong: " .. line .. "\n")
        elseif err == "closed" then
            table.remove(clients, i)
            client:close()
        end
    end
end
