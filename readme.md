# Vector3 Sequence For Roblox

Create Vector3 Sequence and get linear value

## Script unfinished yet

- [x] Basic Logic
- [ ] Sequence Envlope

## Basic Usage

```lua
local v3Seq = require "Vector3Sequence"

local seq = v3Seq.new {
    0,0,0, 0,0;
    1,0,0, 0.5,0;
    1,1,0, 1,0;
}

-- or this
local seq = v3Seq.simple {
    0,0,0, 0;
    1,0,0, 0.5;
    1,1,0, 1;
}

print(seq:Value(0.7)) --> 1, 0.4000000059604645, 0
```

## APIs

``` lua
.new()
.simple()
```

- Build function

``` lua
.Bezier(points:{Vector3}, samplingRate)
```

- Generate a Bezier curve

Sampling rate defaults to 10

``` lua
:GetValue(t)
-- or
:Value(t)
```

- Get the linear value
