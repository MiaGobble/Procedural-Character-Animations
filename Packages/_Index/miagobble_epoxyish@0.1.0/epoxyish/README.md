# Epoxyish
Epoxyish is a generic solution to springing values unlike before. You can animate various data types and automatically have the springs animate to your instances based on values you create and change.

Everything is fully type-checked and thus should autofill.

Supported value types include:
```
Number
Vector2 & Vector2int16
Vector3 & Vector3int16
CFrame
UDim
UDim2
Color3
```

The ideal format of expoyish is to store Spring, Value, and Latch as variables to speed up development process, and this post shows examples assuming such.

## Example Code
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Epoxyish = require(ReplicatedStorage.Epoxyish)

local Value = Epoxyish.Value
local Spring = Epoxyish.Spring
local Latch = Epoxyish.Latch

local Target = workspace.Target
local Part = workspace.Value

local PartPositionValue = Value(Target.Position)

local PartPositionSpring = Spring {
	Target = PartPositionValue,
	
	Speed = 5,
	Dampening = 3,
}

Latch(Part) {
	Position = PartPositionSpring
}

while true do
	task.wait(1)
	PartPositionValue:Set(Vector3.new(math.random(-30, 30), 10, math.random(-30, 30)))
end
```