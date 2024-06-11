local socket = require("socket")
local Rx = require("rx")

local function connectSocket(host, port)
    local tcp = assert(socket.tcp())
    local result, err = tcp:connect(host, port)
    if not result then
        server = host .. ":" .. port
        return nil, "Connection to " .. server .. " failed: " .. err
    end
    -- Reset timeout after connection
    return tcp, nil
end

local function connectSockets(connections)
    local handlers = {}

    for _, conn in ipairs(connections) do
        local host, port = conn[1], conn[2]
        local tcp, err = connectSocket(host, port)
        if not tcp then
            return nil, err
        end
        table.insert(handlers, tcp)
        print("Connected to " .. host .. ":" .. port)
    end

    return handlers, nil
end

local function removeSocket(handlers, tcp)
    for i, t in ipairs(handlers) do
        if t == tcp then
            table.remove(handlers, i)
            break
        end
    end
end

local function handleSocketData(tcp, observer)
    local data, err, partial = tcp:receive("*l")
    if data then
        observer:onNext(data)
    elseif partial and #partial > 0 then
        observer:onNext(partial)
    elseif err == "closed" then
        tcp:close()
        return false, "closed"
    elseif err then
        observer:onError("failed to handle socket data: " .. err)
        tcp:close()
        return false, err
    end
    return true, nil
end

local function fromConnection(host, port)
    return Rx.Observable.create(function(observer)
        local tcp, err = connectSocket(host, port)
        if not tcp then
            observer:onError(err)
            return
        end

        print("Connected to " .. host .. ":" .. port)

        while true do
            local data, err = tcp:receive("*l") -- Read one line at a time
            if data then
                observer:onNext(data)
            elseif err == "closed" then
                observer:onCompleted()
                tcp:close()
                break
            elseif err then
                observer:onError(err)
                tcp:close()
                break
            end
            socket.sleep(1)
        end
    end)
end

local function fromConnections(connections)
    return Rx.Observable.create(function(observer)
        local handlers, err = connectSockets(connections)
        if err then
            observer:onError(err)
            return
        end

        while true do
            if #handlers == 0 then
                observer:onCompleted()
                break
            end

            local readable, _, err = socket.select(handlers, nil, 1)
            if err then
                observer:onError("Failed on socket select: " .. err)
                return
            end

            for _, tcp in ipairs(readable) do
                local success, err = handleSocketData(tcp, observer)
                if not success then
                    removeSocket(handlers, tcp)
                    if err == "closed" and #handlers == 0 then
                        observer:onCompleted()
                    end
                end
            end
            socket.sleep(1)
        end
    end)
end

return {
    fromConnection = fromConnection,
    fromConnections = fromConnections
}
