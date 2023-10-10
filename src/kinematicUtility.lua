local kinematicUtility = {}

function kinematicUtility.solveLimbIK(origin : CFrame, target : Vector3, upperLimbLength : number, lowerLimbLength : number)
    local limbDifference = origin:PointToObjectSpace(target) --(target.Position - origin.Position)
    local limbUnitDirection = limbDifference.Unit
    local limbLength = limbDifference.Magnitude
    
    local x = Vector3.new(0, 0, -1):Cross(-limbUnitDirection)
    local g = math.acos(-limbUnitDirection.Z)
    local plane = origin * CFrame.fromAxisAngle(x, g):Inverse()
    
    if limbLength < math.max(lowerLimbLength, upperLimbLength) - math.min(lowerLimbLength, upperLimbLength) then
        --p*CFrame.new(0,0,math.max(l1,l0)-math.min(l1,l0)-m),-HalfPi,Pi
        return plane * CFrame.new(0, 0, math.max(lowerLimbLength, upperLimbLength) - math.min(lowerLimbLength, upperLimbLength) - limbLength), -math.pi / 2, math.pi
    elseif limbLength > upperLimbLength + lowerLimbLength then
        return plane, math.pi / 2, 0
    else
        local a1 = -math.acos((-(lowerLimbLength * lowerLimbLength) + (upperLimbLength * upperLimbLength) + (limbLength * limbLength)) / (2 * upperLimbLength * limbLength))
        local a2 = math.acos(((lowerLimbLength * lowerLimbLength) - (upperLimbLength * upperLimbLength) + (limbLength * limbLength)) / (2 * lowerLimbLength * limbLength))
        return plane, math.pi / 2 - a1, -(a2 - a1)
    end
end

return kinematicUtility