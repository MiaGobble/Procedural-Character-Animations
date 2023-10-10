local characterClient = {}
characterClient.__index = characterClient

type characterClient = typeof(setmetatable({}, characterClient)) & {
    playerName: string,
    player: Player,
    character: Model?,
    lastTick: number,
    raycastParams : RaycastParams,
    lastRootPosition : Vector3,
    direction : Vector3
}

local playersService = game:GetService("Players")

local kinematicUtility = require(script.Parent.kinematicUtility)
local config = require(script.Parent.config)

local camera = workspace.CurrentCamera

local FOURTIETH_PI = math.pi / 40
local RIGHT_HIP_CFRAME = CFrame.new(0.5, -0.4, 0) -- The self.RightRotationAngle-hip reference CFrame, relative to the RightUpperLeg position
local LEFT_HIP_CFRAME = CFrame.new(-0.5, -0.4, 0) -- The self.LeftRotationAngle-hip reference CFrame, relative to the LeftUpperLeg position
local RIGHT_HIP_CFRAME_2 = CFrame.new(0.5,-2.7,0)
local LEFT_HIP_CFRAME_2 = CFrame.new(-0.5,-2.7,0)
local RIGHT_IDLE_CFRAME = CFrame.new(0.28, -1.9, 0.03) -- Idle CFrame of Motor6D joint
local LEFT_IDLE_CFRAME = CFrame.new(-0.28, -1.9,-0.03) -- Idle CFrame of Motor6D joint
local STRIDE_CFRAME = CFrame.new(0, 0, -config.legStride / 2)
local RAYCAST_OFFSET = 0.3

function characterClient.new(playerName) : characterClient
    local self = setmetatable({}, characterClient) :: characterClient
    
    self.playerName = playerName
    self.player = playersService:FindFirstChild(playerName) :: Player
    self.character = nil
    self.lastTick = os.clock()
    self.raycastParams = RaycastParams.new()
    self.lastRootPosition = Vector3.new()
    self.direction = Vector3.xAxis + Vector3.zAxis

    self:init()
    
    return self
end

function characterClient:init() : nil
    self:updateCharacterMap()
end

function characterClient:getCharacterMovementSpeed(frameDelta : number) : typeof(unpack({0, Vector3.new()}))
    if self.humanoidRootPart then
        local frameDistance = (self.lastRootPosition - self.humanoidRootPart.Position) / frameDelta
        local frameSpeed = frameDistance.Magnitude

        self.lastRootPosition = self.humanoidRootPart.Position

        return frameSpeed, frameDistance
    else
        return 0, (Vector3.zero :: Vector3)
    end
end

function characterClient:updateCharacterMap() : boolean -- Return whether the character is successfully mapped
    local character = self.player.character

    self.character = character
    
    if character then
        self.leftRotationAngle = 0
        self.rightRotationAngle = math.pi

        self.humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        self.targetBaseBart	= character:FindFirstChild("LowerTorso")
        self.upperTorso = character:FindFirstChild("UpperTorso")

        if self.humanoidRootPart == nil or self.targetBaseBart == nil or self.upperTorso == nil then
            print("no part")
            return false
        end

        self.waistJoint = self.upperTorso:FindFirstChild("Waist")
        self.rootJoint = self.targetBaseBart:FindFirstChild("Root")

        if self.waistJoint == nil or self.rootJoint == nil then
            print("no joint")
            return false
        end

        self.rightUpperLeg = character:FindFirstChild("RightUpperLeg")
        self.rightLowerLeg = character:FindFirstChild("RightLowerLeg")
        self.leftUpperLeg = character:FindFirstChild("LeftUpperLeg")
        self.leftLowerLeg = character:FindFirstChild("LeftLowerLeg")

        if self.rightUpperLeg == nil or self.rightLowerLeg == nil or self.leftUpperLeg == nil or self.leftLowerLeg == nil then
            print("no leg")
            return false
        end

        self.rightHip = self.rightUpperLeg:FindFirstChild("RightHip")
        self.rightKnee = self.rightLowerLeg:FindFirstChild("RightKnee")
        self.leftHip = self.leftUpperLeg:FindFirstChild("LeftHip")
        self.leftKnee = self.leftLowerLeg:FindFirstChild("LeftKnee")

        if self.rightHip == nil or self.rightKnee == nil or self.leftHip == nil or self.leftKnee == nil then
            print("no hip or knee")
            return false
        end

        self.waistCFrame1 = self.waistJoint.C1
        self.rightHipCFrame0 = self.rightHip.C0
        self.rightKneeCFrame0 = self.rightKnee.C0
        self.leftHipCFrame0 = self.leftHip.C0
        self.leftKneeCFrame0 = self.leftKnee.C0
        self.direction = Vector3.new(1, 0, 1)

        self:updateRaycastParameters()

        return true
    else
        return false
    end
end

function characterClient:updateRaycastParameters() : nil
    -- Update the raycast parameters for the character
    -- It should ignore the character
    self.raycastParams.FilterDescendantsInstances = {self.character, camera}
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

function characterClient:getMovementState(delta) : string
    local movementSpeed, movementPositionOffset = self:getCharacterMovementSpeed(delta)

    if movementSpeed < 0.5 then -- Idle
        return "Idle"
    else -- Moving
        if movementPositionOffset.Y > 20 then -- Jumping
            return "Jumping"
        elseif movementPositionOffset.Y < -20 then -- Falling
            return "Falling"
        else -- Running
            return "Running"
        end
    end
end

function characterClient:animateLeg(delta : number, rootCFrame : CFrame, lowerCFrame : CFrame, legId : string, isIdle : boolean)
    local hipCFrame, footCFrame, idleCFrame, kneeMultiplication, hipRotationAngle0, hipRotationAngle1

    if legId == "right" then
        hipCFrame = rootCFrame * RIGHT_HIP_CFRAME
        footCFrame = RIGHT_HIP_CFRAME_2
        idleCFrame = RIGHT_IDLE_CFRAME
    else
        hipCFrame = rootCFrame * LEFT_HIP_CFRAME
        footCFrame = LEFT_HIP_CFRAME_2
        idleCFrame = LEFT_IDLE_CFRAME
    end

    local hip = (rootCFrame * hipCFrame).Position
    local ground = (rootCFrame * footCFrame).Position
    local desiredPos

    if isIdle then
        kneeMultiplication = 1
        hipRotationAngle0 = 0
        hipRotationAngle1 = -(math.pi / 2) / 8
        desiredPos = (hipCFrame * idleCFrame).Position
    else
        kneeMultiplication = config.kneeRotationAmplitude
        hipRotationAngle0 = if legId == "right" then -FOURTIETH_PI else FOURTIETH_PI
        hipRotationAngle1 = 0
        desiredPos = (CFrame.new(ground, ground + self.direction) * CFrame.Angles(-self[`{legId}RotationAngle`], 0, 0) * STRIDE_CFRAME * CFrame.new(0.1,0,0)).Position
    end

    local offset = (desiredPos - hip)
    local raycastResult = workspace:Raycast(hip, offset.Unit * (offset.Magnitude + 1), self.raycastParams)
    local footPos = if raycastResult then raycastResult.Position else (hip + offset.Unit * (offset.Magnitude + RAYCAST_OFFSET))

    local plane, th1, th2 = kinematicUtility.solveLimbIK(lowerCFrame * self[`{legId}HipCFrame0`], footPos, 0.55, 1.15)
    -- self.LeftHip.C0 = self.LeftHip.C0:Lerp(lowercf:toObjectSpace(plane)*CFrame.Angles(th1,hpmod,0),hipAlpha)
	-- 		self.LeftKnee.C0 = self.LeftKnee.C0:Lerp(self.LeftKneeCFrame0*CFrame.Angles(th2*kneeRot,0,0),kneeAlpha)
    self[`{legId}Hip`].C0 = self[`{legId}Hip`].C0:Lerp(lowerCFrame:ToObjectSpace(plane) * CFrame.Angles(th1, hipRotationAngle0, hipRotationAngle1), delta * 10)
    self[`{legId}Knee`].C0 = self[`{legId}Knee`].C0:Lerp(self[`{legId}KneeCFrame0`] * CFrame.Angles(th2 * kneeMultiplication, 0, 0), delta * 10)
end

function characterClient:onRenderStepped() : nil
    local delta = math.clamp(os.clock() - self.lastTick,0.00001,0.5)
    local delta10 = math.min(delta * 10, 1)

    self.lastTick = os.clock()

    if self.character and self:doCharacterPartsExist() then
        local movementSpeed, movementVelocityVector = self:getCharacterMovementSpeed(delta)
        local movementState = self:getMovementState(delta)
        local cameraPosition = camera.CFrame.Position
        local lowerCFrame = self.targetBaseBart.CFrame
        local rootCFrame = self.humanoidRootPart.CFrame
        local direction = movementVelocityVector.Unit

        if movementState ~= "Running" then -- Don't animate if we are climbing, it looks weird
            direction = rootCFrame.LookVector
            self.direction = direction
        else
            movementVelocityVector *= Vector3.new(1, 0, 1)

            if movementVelocityVector.Magnitude > 0.5 then
                direction = self.direction:Lerp(self.direction, delta10)
                self.direction = direction
            end
        end

        direction = self.direction

        local movementSpeedBase = movementSpeed / config.walkspeedReference
        local cycleBase = movementSpeedBase * delta * config.cycleSpeed
        
        self.rightRotationAngle = (self.rightRotationAngle + cycleBase) % (math.pi * 2)
        self.leftRotationAngle = (self.leftRotationAngle + cycleBase) % (math.pi * 2)

        if movementSpeed > 0.5 then --// When moving
            local relativeVelocity = lowerCFrame:vectorToObjectSpace(movementVelocityVector)
            local relativeVelocityDiv = relativeVelocity * 0.2

            -- Upper Torso
            self.waistJoint.C1 = self.waistJoint.C1:Lerp(
                self.waistCFrame1 *
                CFrame.Angles(math.rad(relativeVelocityDiv.Z), 0.1 *
                math.cos(self.rightRotationAngle) - 2 *
                math.rad(relativeVelocityDiv.X),math.rad(-relativeVelocityDiv.X)):Inverse()
            , delta10)
            
            -- Legs
            self:animateLeg(delta, rootCFrame, lowerCFrame, "right", true)
            self:animateLeg(delta, rootCFrame, lowerCFrame, "left", true)
        else --// When not moving
            -- Upper Torso
            self.waistJoint.C1 = self.waistJoint.C1:Lerp(self.waistCFrame1, delta10)

            -- Legs
            self:animateLeg(delta, rootCFrame, lowerCFrame, "right", false)
            self:animateLeg(delta, rootCFrame, lowerCFrame, "left", false)
        end
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

return characterClient