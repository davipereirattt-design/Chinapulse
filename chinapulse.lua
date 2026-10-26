--[[
    China Pulse - MM2 Halloween Edition (Auto Farm Candy - Compacto e Móvel)
]]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local p = Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")

if pg:FindFirstChild("ChinaPulseHalloween") then
    pg.ChinaPulseHalloween:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ChinaPulseHalloween"
gui.ResetOnSpawn = false
gui.Parent = pg

-- Janela Principal (Tamanho reduzido)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 220)
main.Position = UDim2.new(0.5, -160, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(2, 10, 15)
main.BorderSizePixel = 0
main.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 120, 0)
stroke.Thickness = 2
stroke.Parent = main

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

-- Sistema para Mover o Painel com o dedo no Mobile
local dragging, dragInput, dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 320, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎃 MM2 AUTO FARM (MÓVEL)"
titleLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = main

-- Função para criar botões de alternância (Compactos)
local function createOption(yPos, text, defaultVal, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 290, 0, 35)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(15, 25, 35)
    btn.BorderSizePixel = 0
    btn.Text = "   " .. text .. ": " .. (defaultVal and "LIGADO" or "DESLIGADO")
    btn.TextColor3 = defaultVal and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = main

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local state = defaultVal
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = "   " .. text .. ": " .. (state and "LIGADO" or "DESLIGADO")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
        callback(state)
    end)
end

-- Variáveis de Controlo
_G.AutoFarmActive = false
_G.AutoRespawnActive = true
_G.FarnSpeedValue = 25
_G.AntiflingActive = true

-- Opções do Menu
createOption(40, "Auto Farm", false, function(state)
    _G.AutoFarmActive = state
end)

createOption(80, "Auto Respawn", true, function(state)
    _G.AutoRespawnActive = state
end)

createOption(120, "Farm Speed", false, function(state)
    _G.FarnSpeedValue = state and 50 or 25
end)

createOption(160, "Anti Fling / Void", true, function(state)
    _G.AntiflingActive = state
end)

-- Lógica do Auto Farm (Apenas Doces)
task.spawn(function()
    while true do
        task.wait(0.15)
        if _G.AutoFarmActive then
            pcall(function()
                local char = p.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if not _G.AutoFarmActive then break end
                        if obj:IsA("BasePart") or obj:IsA("Model") then
                            local name = obj.Name:lower()
                            if name == "doce" or name == "candy" then
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if targetPart then
                                    hrp.CFrame = targetPart.CFrame + Vector3.new(0, 1.5, 0)
                                    for _, pr in pairs(obj:GetDescendants()) do
                                        if pr:IsA("ProximityPrompt") then
                                            fireproximityprompt(pr)
                                        end
                                    end
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
