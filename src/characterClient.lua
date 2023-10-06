local characterClient = {}
characterClient.__index = characterClient

local playersService = game:GetService("Players")

type characterClient = typeof(setmetatable({}, characterClient)) & {
    playerName: string,
    player: Player,
    character: Model,
    lastTick: number
}

function characterClient.new(playerName) : characterClient
    local self = setmetatable({}, characterClient) :: characterClient
    
    self.playerName = playerName
    self.player = playersService:FindFirstChild(playerName) :: Player
    self.character = self.player.Character
    self.lastTick = os.clock()

    self:init()
    
    return self
end

function characterClient:init() : nil
    
end

function characterClient:updateCharacter() : boolean
    self.character = self.player.Character
    return self.character ~= nil
end

function characterClient:onRenderStepped() : nil
    local delta = os.clock() - self.lastTick
    self.lastTick = os.clock()
end

function characterClient:destroy()
    -- Redundant in nature but it mimics Roblox API
    self.playerName = nil
    self.player = nil
    self.character = nil
    self.lastTick = nil
end