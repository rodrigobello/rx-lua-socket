local socket = require("socket")

if #arg < 1 then
    print("Usage: lua server.lua <port>")
    os.exit(1)
end
local port = tonumber(arg[1])
local server = assert(socket.bind("*", port))
local ip, port = server:getsockname()

print("Server is running on port " .. port)

while true do
    local client = server:accept()
    client:settimeout(10)
    while true do
        local message = {
            value = math.random(1, 100),
            source = "server on port " .. port
        }
        local line = string.format('{"value": %d, "source": "%s"}\n', message.value, message.source)
        local sent, err = client:send(line)
        if not sent then
            print("Error sending data: " .. err)
            break
        end
        socket.sleep(1) -- Send data every second
    end
    client:close()
end
