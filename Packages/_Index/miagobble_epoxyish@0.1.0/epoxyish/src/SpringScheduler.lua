local SpringScheduler = {}

local RunService = game:GetService("RunService")

local SpringRef = require(script.Parent.Spring)
local ValueRef = require(script.Parent.Value)

local ScheduledSprings = {}

function SpringScheduler:GetFrameStepEvent()
	if RunService:IsClient() then
		return RunService.RenderStepped
	else
		return RunService.Heartbeat
	end
end

function SpringScheduler:AddToQueue(Spring : SpringRef.Spring, Object : Instance, PropertyName : string)
	table.insert(ScheduledSprings, {Spring, Object, PropertyName})
end

function SpringScheduler:Render()
	for _, ScheduledEvent in ScheduledSprings do
		local Spring, Object, PropertyName = unpack(ScheduledEvent)
		
		if Spring.AwaitingDisconnect == true or not Object or not Object.Parent then
			Spring.AwaitingDisconnect = nil
			table.remove(ScheduledSprings, table.find(ScheduledSprings, ScheduledEvent))
		else
			Object[PropertyName] = Spring:Get()
		end
	end 
end

return SpringScheduler
