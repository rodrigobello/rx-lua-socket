# rx-lua-socket

A LuaSocket driver for RxLua.

## Installation

1. Clone the repository:

    ```sh
    git clone https://github.com/yourusername/rx-lua-socket.git
    cd rx-lua-socket
    ```

2. Install the dependencies using LuaRocks:

    ```sh
    luarocks install --only-deps rx-lua-socket-0.1-1.rockspec
    ```

## Usage

```lua
local RxSocket = require("rx-lua-socket")

-- Example for single connection
RxSocket.fromConnection("localhost", 8080)
    :map(function(data) return data .. "!" end)
    :subscribe(print)

-- Example for multiple connections
RxSocket.fromConnections({"localhost", 8080}, {"localhost", 8081})
    :filter(function(data) return tonumber(data) % 2 == 0 end)
    :map(function(data) return data .. "!" end)
    :subscribe(print)
