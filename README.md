
<p align="center">
  <img src="./assets/icon.png" alt="Greenwich" />
</p>

*Join the [Discord](https://discord.gg/vfn3NJ3TUm) for support and to chat with people.*

# GreenwichDB
Go back to the start of time, where DataStore's weren't complex.

## Installation

Start off by copying [`greenwich.lua`](/greenwich.lua) over to `ServerStorage`. Make sure it a ModuleScript named `Greenwich`.

## Concept

The concept of Greenwich is to provide 1 DataStore, and only 1, so it removes complications completely. It's faster and lighter on the server, and provides a simple API.

## How does it work?

Simple. We have a `dbFunctions` table and a `greenwich` table. What we do, is define our functions on `dbFunctions`, then when you call `GetDB` iterate through each function and return an instance of it. This means that you don't have to do `dbFunctions:Set("hello", "key", "value")` - simply `Grenwich:GetDB("hello"):Set("key", "value")`

## Usage

To require Greenwich, simple append the following code to your script:

```lua
local ServerStorage = game:GetService("ServerStorage")
local Greenwich = require(ServerStorage:WaitForChild("Greenwich"))
```
