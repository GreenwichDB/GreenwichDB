# GreenwichDB
Go back to the start of time, where DataStore's weren't complex.

## Installation

Start off by copying [`greenwich.lua`](/greenwich.lua) over to `ServerStorage`. Make sure it a ModuleScript named `Greenwich`.

## Concept

The concept of Greenwich is to provide 1 DataStore, and only 1, so it removes complications completely. It's faster and lighter on the server, and provides a simple API.

## Usage

To require Greenwich, simple append the following code to your script:

```lua
local ServerStorage = game:GetService("ServerStorage")
local Greenwich = require(ServerStorage:WaitForChild("Greenwich"))
```
