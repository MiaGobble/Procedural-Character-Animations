local AddType = {}

function AddType.number(Value0, Value1)
	return Value0 + Value1
end

function AddType.Vector2(Value0, Value1)
	return Value0 + Value1
end

function AddType.Vector2int16(Value0, Value1)
	return Value0 + Value1
end

function AddType.Vector3(Value0, Value1)
	return Value0 + Value1
end

function AddType.Vector3int16(Value0, Value1)
	return Value0 + Value1
end

function AddType.CFrame(Value0, Value1)
	return Value0 * Value1
end

function AddType.UDim(Value0 : UDim, Value1 : UDim)
	return Value0 + Value1
end

function AddType.UDim2(Value0 : UDim2, Value1: UDim2)
	return Value0 + Value1
end

function AddType.Color3(Value0 : Color3, Value1 : Color3)
	local r0, g0, b0 = Value0.R, Value0.G, Value0.B
	local r1, g1, b1 = Value1.R, Value1.G, Value1.B
	
	local r = r0 + r1 --math.clamp(r0 + r1, 0, 1)
	local g = g0 + g1 --math.clamp(g0 + g1, 0, 1)
	local b = b0 + b1 --math.clamp(b0 + b1, 0, 1)
	
	return Color3.new(r, g, b)
end

return AddType