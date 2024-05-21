local socket = require("socket")

-- Main logic function
local function main_logic()
    print("Starting main logic")

    -- Simulate doing some work with a loop
    for i = 1, 10 do
        print("Main logic step " .. i)

        -- Ping the server when i == 5
        if i == 5 then
            print("Pinging the server...")
            local client = socket.connect("localhost", 12345)
            if client then
                client:send("Ping\n")
                local response, err = client:receive()
                if response then
                    print("Server response: " .. response)
                else
                    print("Error receiving from server: " .. err)
                end
                client:close()
            else
                print("Failed to connect to the server.")
            end
        end

        socket.sleep(1)
        coroutine.yield()
    end

    print("Main logic completed")
end


-- Coroutine to run the main logic
local logic_co = coroutine.create(main_logic)

-- Run both coroutines concurrently
while coroutine.status(logic_co) ~= "dead" do
    if coroutine.status(logic_co) ~= "dead" then
        assert(coroutine.resume(logic_co))
    end
end
