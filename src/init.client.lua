local playersService = game:GetService("Players")
local runService = game:GetService("RunService")

local characterClient = require(script.characterClient)

local characterClientInstance = characterClient.new(playersService.LocalPlayer.Name)

runService.RenderStepped:Connect(function()
    characterClientInstance:onRenderStepped()
end)