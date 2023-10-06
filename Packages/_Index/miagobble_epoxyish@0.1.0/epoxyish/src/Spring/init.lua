local ITERATIONS = 8

local DEFAULT_PROPERTIES = {
	Speed = 4,
	Dampening = 4,
	Force = 50,
	Mass = 5,
}

local EPSILON = 0.001

local Spring = {}
Spring.__index = Spring

local MultiplyType = require(script.MultiplyType)
local AddType = require(script.AddType)
local TypeAsNumber = require(script.TypeAsNumber)
local Signal = require(script.Signal)

export type SpringProperties = {
	Speed : number?,
	Dampening : number?,
	Force : number?,
	Mass : number?,

	Target : {
		Set : (any) -> nil,
		Get : () -> any,
	},
	
	Position  : any?,
	Velocity : any?,
	
	Completed : Signal.signal<>,
	Asleep : boolean,
}

export type Spring = typeof(setmetatable({}, Spring)) & SpringProperties

function Spring.new(Parameters : SpringProperties) : Spring
	local self = setmetatable({}, Spring) :: Spring
	
	for Index, DefaultValue in pairs(DEFAULT_PROPERTIES) do
		self[Index] = Parameters[Index] or DefaultValue
	end
	
	if not Parameters.Target then
		error("Target value required")
	elseif typeof(Parameters.Target) ~= "table" then
		error("Target must be a valid value object")
	end
	
	self.Target = Parameters.Target
	self.Position = Parameters.Position or self.Target:Get()
	self.Velocity = Parameters.Velocity or self.Target:Get()
	
	self.Tick0 = os.clock()
	self:AdjustType()
	
	self.Asleep = false
	self.Completed = Signal.new()
	
	return self
end

function Spring:AdjustType()
	self.Type = typeof(self.Target:Get())
	self.Add = AddType[self.Type]
	self.Multiply = MultiplyType[self.Type]
	self.AsNumber = TypeAsNumber[self.Type]
end

function Spring:Impulse(Force : any)
	self.Velocity += Force
end

function Spring:Get(Index) : any
	local DeltaTime = os.clock() - self.Tick0
	local ScaledDeltaTime = math.min(DeltaTime, 1) * self.Speed / ITERATIONS
	local CurrentAcceleration
	
	if not Index then
		Index = "Position"
	end
	
	if typeof(self.Target:Get()) ~= typeof(self.Position) then
		self:AdjustType()
		self.Position = self.Target:Get()
		self.Velocity = self.Multiply(self.Target:Get(), 0)
	end
	
	if not self.Asleep then
		for IterationNumber = 1, ITERATIONS do
			local IterationForce = self.Add(self.Target:Get(), self.Multiply(self.Position, -1))
			local Acceleration = self.Multiply(self.Multiply(IterationForce, self.Force), 1 / self.Mass)

			Acceleration = self.Add(Acceleration, self.Multiply(self.Multiply(self.Velocity, self.Dampening), -1))

			self.Velocity = self.Add(self.Velocity, self.Multiply(Acceleration, ScaledDeltaTime))
			self.Position = self.Add(self.Position, self.Multiply(self.Velocity, ScaledDeltaTime))

			if IterationNumber == ITERATIONS then
				CurrentAcceleration = Acceleration
			end
		end
	end

	self.Tick0 += DeltaTime
	
	if math.abs(self.AsNumber(self.Position) - self.AsNumber(self.Target:Get())) < EPSILON then
		self.Position = self.Target:Get()
		
		if not self.Asleep then
			self.Completed:Fire()
			self.Asleep = true
		end
	else
		self.Asleep = false
	end
	
	if Index == "Position" and typeof(self.Position) == "Color3" then
		local h, s, v = self.Position:ToHSV()
		h = math.clamp(h, 0, 1)
		s = math.clamp(s, 0, 1)
		v = math.clamp(v, 0, 1)
		return Color3.fromHSV(h, s, v)
	elseif Index == "Acceleration" then
		return CurrentAcceleration
	else
		return self[Index]
	end
end

function Spring:DisconnectLatch()
	self.AwaitingDisconnect = true
end

return Spring
