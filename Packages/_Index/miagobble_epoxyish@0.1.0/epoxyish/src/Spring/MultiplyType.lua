local MultiplyType = {}

local function MultiplyArrayByNumber(Array0, Number)
	local Array1 = {}
	
	for Index, Value in Array0 do
		Array1[Index] = Value * Number
	end
	
	return Array1
end

function MultiplyType.number(Value0, Number)
	return Value0 * Number
end

function MultiplyType.Vector2(Value0, Number)
	return Value0 * Number
end

function MultiplyType.Vector2int16(Value0, Number)
	return Value0 * Number
end

function MultiplyType.Vector3(Value0, Number)
	return Value0 * Number
end

function MultiplyType.Vector3int16(Value0, Number)
	return Value0 * Number
end

function MultiplyType.CFrame(Value0 : CFrame, Number)
	local Position = Value0.Position
	local RotationX, RotationY, RotationZ = Value0:ToEulerAnglesXYZ()
	
	return CFrame.new(Position * Number) * CFrame.fromEulerAnglesXYZ(RotationX * Number, RotationY * Number, RotationZ * Number)
end

function MultiplyType.UDim(Value0 : UDim, Number)
	local Array0 = {Value0.Scale, Value0.Offset}
	local MultipliedArray = MultiplyArrayByNumber(Array0, Number)

	return UDim.new(unpack(MultipliedArray))
end

function MultiplyType.UDim2(Value0 : UDim2, Number)
	local Array0 = {Value0.X.Scale, Value0.X.Offset, Value0.Y.Scale, Value0.Y.Offset}
	local MultipliedArray = MultiplyArrayByNumber(Array0, Number)
	
	return UDim2.new(unpack(MultipliedArray))
end

function MultiplyType.Color3(Color0 : Color3, Number)
	local Array0 = {Color0.R, Color0.G, Color0.B}
	local MultipliedArray = MultiplyArrayByNumber(Array0, Number)
	
	return Color3.new(unpack(MultipliedArray))
end

return MultiplyType