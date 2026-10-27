--[[
    China Pulse - MM2 Halloween Edition (Auto Farm Candy - Força Bruta)
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

-- Janela Principal
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

-- Sistema para Mover o Painel
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
titleLabel.Text = "🎃 MM2 AUTO FARM"
titleLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = main

-- Botão para Fechar / Abrir o Painel
local toggleGuiBtn = Instance.new("TextButton")
toggleGuiBtn.Size = UDim2.new(0, 40, 0, 40)
toggleGuiBtn.Position = UDim2.new(0, 20, 0, 100)
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
toggleGuiBtn.Text = "🎃"
toggleGuiBtn.TextSize = 20
toggleGuiBtn.Parent = gui

local tBtnCorner = Instance.new("UICorner")
tBtnCorner.CornerRadius = UDim.new(1, 0)
tBtnCorner.Parent = toggleGuiBtn

local menuVisible = true
toggleGuiBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    main.Visible = menuVisible
end)

-- Função para criar botões
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

-- Variáveis
_G.AutoFarmActive = false
_G.AutoRespawnActive = true
_G.FarnSpeedValue = 25
_G.AntiflingActive = true

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

-- Recolha Otimizada e Direta por Varredura Total de Partes
task.spawn(function()
    while true() do
        task.wait(0.2)
        if _G.AutoFarmActive then
            pcall(function()
                local char = p.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not _G.AutoFarmActive then break end
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            if n == "candy" or n == "doce" or n == "drop" or n == "coin" then
                                -- Move o boneco diretamente colado na peça e força simulação
                                hrp.CFrame = obj.CFrame + Vector3.new(0, 0.5, 0)
                                task.wait(0.08)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

