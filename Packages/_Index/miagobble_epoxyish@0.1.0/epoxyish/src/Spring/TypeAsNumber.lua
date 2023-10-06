local TypeAsNumber = {}

function TypeAsNumber.number(Value)
	return Value
end

function TypeAsNumber.Vector2(Value : Vector2)
	return Value.Magnitude
end

function TypeAsNumber.Vector2int16(Value : Vector2int16)
	return Value.Y + Value.X
end

function TypeAsNumber.Vector3(Value : Vector3)
	return Value.Magnitude
end

function TypeAsNumber.Vector3int16(Value : Vector3int16)
	return Value.X + Value.Y + Value.Z
end

function TypeAsNumber.CFrame(Value : CFrame)
	local Position = Value.Position
	local RotationX, RotationY, RotationZ = Value:ToEulerAnglesXYZ()
	
	return Position.X + Position.Y + Position.Z + RotationX + RotationY + RotationZ
end

function TypeAsNumber.UDim(Value : UDim)
	return Value.Offset + Value.Scale
end

function TypeAsNumber.UDim2(Value : UDim2)
	return Value.Y.Offset + Value.Y.Scale + Value.X.Offset + Value.X.Scale
end

function TypeAsNumber.Color3(Value : Color3)
	return Value.R, Value.G, Value.B
end

return TypeAsNumber