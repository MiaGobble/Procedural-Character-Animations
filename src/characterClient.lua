local characterClient = {}
characterClient.__index = characterClient

type characterClient = typeof(setmetatable({}, characterClient)) & {
    playerName: string,
    player: Player,
    character: Model?,
    lastTick: number,
    raycastParams : RaycastParams,
    lastRootPosition : Vector3,
}

local playersService = game:GetService("Players")

local kinematicUtility = require(script.Parent.kinematicUtility)
local config = require(script.Parent.config)

function characterClient.new(playerName) : characterClient
    local self = setmetatable({}, characterClient) :: characterClient
    
    self.playerName = playerName
    self.player = playersService:FindFirstChild(playerName) :: Player
    self.character = nil
    self.lastTick = os.clock()
    self.raycastParams = RaycastParams.new()
    self.lastRootPosition = Vector3.new()

    self:init()
    
    return self
end

function characterClient:init() : nil
    self:updateCharacterMap()
end

function characterClient:getCharacterMovementSpeed(frameDelta : number) : number
    if self.humanoidRootPart then
        local frameDistance = (self.lastRootPosition - self.humanoidRootPart.Position).Magnitude
        local frameSpeed = frameDistance * frameDelta

        self.lastRootPosition = self.humanoidRootPart.Position

        return frameSpeed
    else
        return 0
    end
end

function characterClient:updateCharacterMap() : boolean -- Return whether the character is successfully mapped
    local character = self.player.character

    self.character = character
    
    if character then
        self.humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        self.targetBaseBart	= character:FindFirstChild("LowerTorso")
        self.upperTorso = character:FindFirstChild("UpperTorso")

        if self.HumanoidRootPart == nil or self.TargetBaseBart == nil or self.upperTorso == nil then
            return false
        end

        self.waistJoint = self.upperTorso:FindFirstChild("Waist")
        self.rootJoint = self.TargetBaseBart:FindFirstChild("Root")

        if self.waistJoint == nil or self.rootJoint == nil then
            return false
        end

        self.rightUpperLeg = character:FindFirstChild("RightUpperLeg")
        self.rightLowerLeg = character:FindFirstChild("RightLowerLeg")
        self.leftUpperLeg = character:FindFirstChild("LeftUpperLeg")
        self.leftLowerLeg = character:FindFirstChild("LeftLowerLeg")

        if self.rightUpperLeg == nil or self.rightLowerLeg == nil or self.leftUpperLeg == nil or self.leftLowerLeg == nil then
            return false
        end

        self.rightHip = self.rightUpperLeg:FindFirstChild("RightHip")
        self.rightKnee = self.rightLowerLeg:FindFirstChild("RightKnee")
        self.leftHip = self.leftUpperLeg:FindFirstChild("LeftHip")
        self.leftKnee = self.leftLowerLeg:FindFirstChild("LeftKnee")

        if self.rightHip == nil or self.rightKnee == nil or self.leftHip == nil or self.leftKnee == nil then
            return false
        end

        self.waistCFrame1 = self.WaistJoint.C1
        self.rightHipCFrame0 = self.rightHip.C0
        self.rightKneeCFrame0 = self.rightKnee.C0
        self.leftHipCFrame0 = self.leftHip.C0
        self.leftKneeCFrame0 = self.leftKnee.C0
        self.leftRotationAngle = 0
        self.rightRotationAngle = math.pi
        self.Direction = Vector3.xAxis + Vector3.zAxis

        return true
    else
        return false
    end
end

function characterClient:updateRaycastParameters() : nil
    -- Update the raycast parameters for the character
    -- It should ignore the character
    self.raycastParams.FilterDescendantsInstances = {self.character}
    self.raycastParams.FilterType = Enum.RaycastFilterType.Exclude
end

function characterClient:doCharacterPartsExist() : boolean
    if self.humanoidRootPart == nil or self.targetBaseBart == nil or self.upperTorso == nil then
        return false
    end

    if self.waistJoint == nil or self.rootJoint == nil then
        return false
    end

    if self.rightUpperLeg == nil or self.rightLowerLeg == nil or self.leftUpperLeg == nil or self.leftLowerLeg == nil then
        return false
    end

    if self.rightHip == nil or self.rightKnee == nil or self.leftHip == nil or self.leftKnee == nil then
        return false
    end

    return true
end

function characterClient:onRenderStepped() : nil
    local delta = os.clock() - self.lastTick
    self.lastTick = os.clock()

    if self.character and self:doCharacterPartsExist() then

    else
        self:updateCharacterMap()
    end
end

function characterClient:destroy()
    -- Redundant in nature but it mimics Roblox API

    for Index, _ in self do
        self[Index] = nil
    end
end