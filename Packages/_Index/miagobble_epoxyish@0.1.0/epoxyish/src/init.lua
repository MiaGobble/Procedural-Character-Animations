local Epoxyish = {}

local Value = require(script.Value)
local Spring = require(script.Spring)
local SpringScheduler = require(script.SpringScheduler)

local function Latch(Object : Instance) : ({[string] : Spring.Spring}) -> nil
	if typeof(Object) == "Instance" then
		return function(SpringProperties : {[string] : Spring.Spring})
			for PropertyName, Spring in SpringProperties do
				SpringScheduler:AddToQueue(Spring, Object, PropertyName)
			end
		end
	else
		error("Object is not an instance")
	end
end

SpringScheduler:GetFrameStepEvent():Connect(function()
	SpringScheduler:Render()
end)

return {
	Value = Value,
	Spring = Spring.new,
	Latch = Latch,
}
