export type Value = {
	Set : (any) -> nil,
	Get : (nil) -> any,
}

return function(CurrentValue : any) : Value
	local Value = {}

	function Value:Set(NewValue)
		CurrentValue = NewValue
	end

	function Value:Get()
		return CurrentValue
	end
	
	return Value
end
