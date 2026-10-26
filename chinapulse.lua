--[[\
    China Pulse - MM2 Halloween Edition (Full UI)
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
main.Size = UDim2.new(0, 420, 0, 310)
main.Position = UDim2.new(0.5, -210, 0.5, -155)
main.BackgroundColor3 = Color3.fromRGB(12, 10, 15)
main.BorderSizePixel = 0
main.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 120, 0)
stroke.Thickness = 3
stroke.Parent = main

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 300, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎃 MM2 HALLOWEEN AUTOFARM"
titleLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = main

-- Botões Minimizar e Fechar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -65, 0, 15)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 35)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = main
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -35, 0, 15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local minimizado = false
minBtn.MouseButton1Click:Connect(function()
	minimizado = not minimizado
	for _, child in pairs(main:GetChildren()) do
		if child ~= titleLabel and child ~= minBtn and child ~= closeBtn and child ~= stroke and child ~= corner then
			child.Visible = not minimizado
		end
	end
	main.Size = minimizado and UDim2.new(0, 420, 0, 50) or UDim2.new(0, 420, 0, 310)
end)

-- Construtor de Opções
local function createOption(posY, titleText, isToggle, defaultVal)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 390, 0, 55)
	container.Position = UDim2.new(0, 15, 0, posY)
	container.BackgroundTransparency = 1
	container.Parent = main
	
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, 250, 0, 25)
	lbl.Position = UDim2.new(0, 0, 0, 5)
	lbl.BackgroundTransparency = 1
	lbl.Text = titleText
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextSize = 14
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = container
	
	if isToggle then
		local state = defaultVal
		local btnTgl = Instance.new("TextButton")
		btnTgl.Size = UDim2.new(0, 50, 0, 26)
		btnTgl.Position = UDim2.new(1, -55, 0, 12)
		btnTgl.BackgroundColor3 = state and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(40, 35, 45)
		btnTgl.Text = ""
		btnTgl.Parent = container
		Instance.new("UICorner", btnTgl).CornerRadius = UDim.new(1, 0)
		
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0, 20, 0, 20)
		circle.Position = state and UDim2.new(1, -23, 0, 3) or UDim2.new(0, 3, 0, 3)
		circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		circle.Parent = btnTgl
		Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
		
		local subLbl = Instance.new("TextLabel")
		subLbl.Size = UDim2.new(0, 250, 0, 18)
		subLbl.Position = UDim2.new(0, 0, 0, 30)
		subLbl.BackgroundTransparency = 1
		subLbl.Text = state and "ON" or "OFF"
		subLbl.TextColor3 = state and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(150, 150, 150)
		subLbl.TextSize = 12
		subLbl.Font = Enum.Font.GothamBold
		subLbl.TextXAlignment = Enum.TextXAlignment.Left
		subLbl.Parent = container
		
		btnTgl.MouseButton1Click:Connect(function()
			state = not state
			btnTgl.BackgroundColor3 = state and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(40, 35, 45)
			circle.Position = state and UDim2.new(1, -23, 0, 3) or UDim2.new(0, 3, 0, 3)
			subLbl.Text = state and "ON" or "OFF"
			subLbl.TextColor3 = state and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(150, 150, 150)
			
			if titleText == "Auto Farm" then
				_G.AutoFarmActive = state
			elseif titleText == "Auto Respawn" then
				_G.AutoRespawnActive = state
			elseif titleText == "Anti Fling / Void" then
				_G.AntiFlingActive = state
			end
		end)
	else
		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 100, 0, 25)
		valLbl.Position = UDim2.new(0, 0, 0, 22)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = tostring(defaultVal)
		valLbl.TextColor3 = Color3.fromRGB(255, 140, 0)
		valLbl.TextSize = 18
		valLbl.Font = Enum.Font.GothamBold
		valLbl.TextXAlignment = Enum.TextXAlignment.Left
		valLbl.Parent = container
		
		local sliderBg = Instance.new("Frame")
		sliderBg.Size = UDim2.new(0, 390, 0, 6)
		sliderBg.Position = UDim2.new(0, 0, 0, 48)
		sliderBg.BackgroundColor3 = Color3.fromRGB(40, 35, 45)
		sliderBg.BorderSizePixel = 0
		sliderBg.Parent = container
		Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
		
		local sliderFill = Instance.new("Frame")
		sliderFill.Size = UDim2.new((defaultVal - 20) / 10, 0, 1, 0)
		sliderFill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
		sliderFill.BorderSizePixel = 0
		sliderFill.Parent = sliderBg
		Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
		
		local knob = Instance.new("TextButton")
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.Position = UDim2.new(sliderFill.Size.X.Scale, -8, 0.5, -8)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Text = ""
		knob.Parent = sliderBg
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
		
		local dragging = false
		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
				sliderFill.Size = UDim2.new(pos, 0, 1, 0)
				knob.Position = UDim2.new(pos, -8, 0.5, -8)
				local calcVal = math.floor(20 + (pos * 10))
				valLbl.Text = tostring(calcVal)
				_G.FarmSpeedValue = calcVal
			end
		end)
	end
end

createOption(55, "Auto Farm", true, false)
createOption(115, "Auto Respawn", true, true)
createOption(175, "Farm Speed", false, 25)
createOption(235, "Anti Fling / Void", true, true)

_G.AutoFarmActive = false
_G.AutoRespawnActive = true
_G.FarmSpeedValue = 25
_G.AntiFlingActive = true

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
							local nome = obj.Name:lower()
							if nome == "doce" or nome == "candy" then
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

-- Auto Respawn
task.spawn(function()
	while true do
		task.wait(1)
		if _G.AutoRespawnActive then
			pcall(function()
				if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health <= 0 then
					p.CharacterAdded:Wait()
					task.wait(1)
				end
			end)
		end
	end
end)

-- Anti Fling / Void
RunService.Stepped:Connect(function()
	if _G.AntiFlingActive then
		pcall(function()
			local char = p.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				if hrp.Position.Y < -50 then
					hrp.CFrame = CFrame.new(0, 50, 0)
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
			end
		end)
	end
end)
