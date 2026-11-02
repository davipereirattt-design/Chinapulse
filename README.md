--[[ 
    CHINA HUB - Anime Piece Auto Farm & Otimizador Móvel
    - Auto Missão integrada e automática ao ligar o Auto Farm
    - Posição flutuante sobre a cabeça do bandido (deitado de barriga para baixo)
    - Painel móvel e botão flutuante próprios
    - Sistema Anti-Lag e Gráficos Massinha
]]--

local Success, Result = pcall(function()
   local Players = game:GetService("Players")
   local LocalPlayer = Players.LocalPlayer
   local Workspace = game:GetService("Workspace")
   local Lighting = game:GetService("Lighting")
   local CoreGui = game:GetService("CoreGui")
   local UserInputService = game:GetService("UserInputService")
   local VirtualUser = game:GetService("VirtualUser")

   if CoreGui:FindFirstChild("ChinaHubAnimePiece") then
      CoreGui.ChinaHubAnimePiece:Destroy()
   end

   local ScreenGui = Instance.new("ScreenGui")
   ScreenGui.Name = "ChinaHubAnimePiece"
   ScreenGui.ResetOnSpawn = false
   ScreenGui.Parent = CoreGui

   -- ==================== BOTÃO FLUTUANTE MÓVEL ====================
   local OpenButton = Instance.new("TextButton")
   OpenButton.Size = UDim2.new(0, 50, 0, 50)
   OpenButton.Position = UDim2.new(0, 20, 0, 150)
   OpenButton.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
   OpenButton.TextColor3 = Color3.fromRGB(0, 210, 255)
   OpenButton.TextSize = 22
   OpenButton.Font = Enum.Font.GothamBold
   OpenButton.Text = "⚡"
   OpenButton.Parent = ScreenGui

   Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 12)
   local strokeBtn = Instance.new("UIStroke", OpenButton)
   strokeBtn.Color = Color3.fromRGB(0, 180, 255)
   strokeBtn.Thickness = 2

   -- ==================== PAINEL PRINCIPAL MÓVEL ====================
   local MainFrame = Instance.new("Frame")
   MainFrame.Size = UDim2.new(0, 320, 0, 320)
   MainFrame.Position = UDim2.new(0.5, -160, 0.5, -160)
   MainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
   MainFrame.BorderSizePixel = 0
   MainFrame.Visible = false
   MainFrame.Parent = ScreenGui

   Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
   local strokeMain = Instance.new("UIStroke", MainFrame)
   strokeMain.Color = Color3.fromRGB(0, 180, 255)
   strokeMain.Thickness = 2

   -- TopBar (Cabeçalho)
   local TopBar = Instance.new("Frame")
   TopBar.Size = UDim2.new(1, 0, 0, 45)
   TopBar.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
   TopBar.BorderSizePixel = 0
   TopBar.Parent = MainFrame

   Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

   local bottomCover = Instance.new("Frame")
   bottomCover.Size = UDim2.new(1, 0, 0, 10)
   bottomCover.Position = UDim2.new(0, 0, 1, -10)
   bottomCover.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
   bottomCover.BorderSizePixel = 0
   bottomCover.Parent = TopBar

   local Title = Instance.new("TextLabel")
   Title.Size = UDim2.new(1, -50, 1, 0)
   Title.Position = UDim2.new(0, 15, 0, 0)
   Title.BackgroundTransparency = 1
   Title.TextColor3 = Color3.fromRGB(255, 255, 255)
   Title.TextSize = 14
   Title.Font = Enum.Font.GothamBold
   Title.Text = "⚡ CHINA HUB | Anime Piece"
   Title.TextXAlignment = Enum.TextXAlignment.Left
   Title.Parent = TopBar

   local CloseButton = Instance.new("TextButton")
   CloseButton.Size = UDim2.new(0, 30, 0, 30)
   CloseButton.Position = UDim2.new(1, -38, 0.5, -15)
   CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
   CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
   CloseButton.TextSize = 14
   CloseButton.Font = Enum.Font.GothamBold
   CloseButton.Text = "X"
   CloseButton.Parent = MainFrame

   Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

   -- Container
   local Container = Instance.new("ScrollingFrame")
   Container.Size = UDim2.new(1, -20, 1, -65)
   Container.Position = UDim2.new(0, 10, 0, 55)
   Container.BackgroundTransparency = 1
   Container.BorderSizePixel = 0
   Container.CanvasSize = UDim2.new(0, 0, 0, 260)
   Container.ScrollBarThickness = 4
   Container.Parent = MainFrame

   local UIListLayout = Instance.new("UIListLayout", Container)
   UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
   UIListLayout.Padding = UDim.new(0, 10)

   local function createToggle(text, callback)
      local btn = Instance.new("TextButton")
      btn.Size = UDim2.new(1, 0, 0, 45)
      btn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
      btn.TextColor3 = Color3.fromRGB(255, 255, 255)
      btn.TextSize = 13
      btn.Font = Enum.Font.GothamBold
      btn.Text = text .. ": [DESLIGADO]"
      btn.Parent = Container
      
      Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
      local stroke = Instance.new("UIStroke", btn)
      stroke.Color = Color3.fromRGB(60, 70, 90)
      stroke.Thickness = 1
      
      local state = false
      btn.MouseButton1Click:Connect(function()
         state = not state
         if state then
            btn.Text = text .. ": [LIGADO]"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
         else
            btn.Text = text .. ": [DESLIGADO]"
            btn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
         end
         callback(state)
      end)
   end

   local function createButton(text, callback)
      local btn = Instance.new("TextButton")
      btn.Size = UDim2.new(1, 0, 0, 45)
      btn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
      btn.TextColor3 = Color3.fromRGB(255, 255, 255)
      btn.TextSize = 13
      btn.Font = Enum.Font.GothamBold
      btn.Text = text
      btn.Parent = Container
      
      Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
      local stroke = Instance.new("UIStroke", btn)
      stroke.Color = Color3.fromRGB(60, 70, 90)
      stroke.Thickness = 1
      
      btn.MouseButton1Click:Connect(callback)
   end

   -- ==================== VARIÁVEIS DE ESTADO ====================
   local autoFarmEnabled = false

   -- ==================== FUNÇÕES DE AUTOMATIZAÇÃO ====================

   local function attackTarget()
      pcall(function()
         VirtualUser:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
         task.wait(0.05)
         VirtualUser:Button1Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
      end)
   end

   -- Encontrar NPC de Missão (como o Zack ou outros da ilha)
   local function getQuestNpc()
      for _, obj in ipairs(Workspace:GetDescendants()) do
         if obj:IsA("Model") and (obj.Name:lower() == "zack" or obj.Name:lower():find("quest") or obj.Name:lower():find("npc")) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if root then
               return obj
            end
         end
      end
      return nil
   end

   -- Encontrar os inimigos (bandidos) mais próximos
   local function getNearestBandit()
      local nearest = nil
      local shortestDistance = math.huge
      local character = LocalPlayer.Character
      if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
      local hrp = character.HumanoidRootPart

      for _, obj in ipairs(Workspace:GetDescendants()) do
         if obj:IsA("Model") and obj ~= character then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local targetHrp = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and targetHrp and humanoid.Health > 0 then
               local nameLower = obj.Name:lower()
               if nameLower:find("bandit") or nameLower:find("bandido") or nameLower:find("zack") then
                  local dist = (hrp.Position - targetHrp.Position).Magnitude
                  if dist < shortestDistance then
                     shortestDistance = dist
                     nearest = obj
                  end
               end
            end
         end
      end
      return nearest
   end

   -- Loop Principal do Auto Farm + Auto Missão
   task.spawn(function()
      while true do
         if autoFarmEnabled then
            pcall(function()
               local character = LocalPlayer.Character
               if character and character:FindFirstChild("HumanoidRootPart") then
                  local hrp = character.HumanoidRootPart

                  -- 1. Verifica se tem missão ativa na tela
                  local hasActiveQuest = false
                  pcall(function()
                     local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                     if playerGui then
                        for _, gui in ipairs(playerGui:GetDescendants()) do
                           if gui:IsA("TextLabel") and (gui.Text:lower():find("derrote") or gui.Text:lower():find("quest") or gui.Text:lower():find("/")) then
                              hasActiveQuest = true
                           end
                        end
                     end
                  end)

                  -- Se não tiver missão ativa, vai automaticamente interagir com o NPC de missão
                  if not hasActiveQuest then
                     local questNpc = getQuestNpc()
                     if questNpc and questNpc:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = questNpc.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.4)
                        for _, prompt in ipairs(questNpc:GetDescendants()) do
                           if prompt:IsA("ProximityPrompt") then
                              fireproximityprompt(prompt)
                           end
                        end
                        task.wait(0.8)
                     end
                  end

                  -- 2. Localiza o bandido e teleporta flutuando sobre a cabeça (deitado de barriga para baixo)
                  local bandit = getNearestBandit()
                  if bandit and bandit:FindFirstChild("HumanoidRootPart") then
                     local bHrp = bandit.HumanoidRootPart
                     
                     hrp.CFrame = bHrp.CFrame * CFrame.new(0, 4, 0) * CFrame.Angles(math.rad(90), 0, 0)
                     hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                     
                     attackTarget()
                  end
               end
            end)
         end
         task.wait(0.1)
      end
   end)

   -- ==================== BOTÕES DO PAINEL ====================

   createToggle("⚔️ Auto Farm + Auto Missão", function(state)
      autoFarmEnabled = state
   end)

   createButton("🎨 Ativar Gráficos Massinha & Anti-Lag", function()
      task.spawn(function()
         Lighting.GlobalShadows = false
         Lighting.FogEnd = 9e9
         Lighting.Brightness = 0
         Lighting.Technology = Enum.LightingTechnology.Compatibility
         
         for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(function()
               if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") or obj:IsA("ParticleEmitter") then
                  obj:Destroy()
               elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
                  obj.Material = Enum.Material.SmoothPlastic
                  obj.Color = Color3.fromRGB(140, 140, 140)
                  obj.CastShadow = false
               end
            end)
         end
      end)
   end)

   -- Eventos de Abrir / Fechar e Arrastar
   OpenButton.MouseButton1Click:Connect(function()
      MainFrame.Visible = not MainFrame.Visible
   end)

   CloseButton.MouseButton1Click:Connect(function()
      MainFrame.Visible = false
   end)

   local function makeDraggable(item, handle)
      handle = handle or item
      local dragging, dragInput, dragStart, startPos
      
      handle.InputBegan:Connect(function(input)
         if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = item.Position
            input.Changed:Connect(function()
               if input.UserInputState == Enum.UserInputState.End then
                  dragging = false
               end
            end)
         end
      end)

      handle.InputChanged:Connect(function(input)
         if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragInput = input
         end
      end)

      UserInputService.InputChanged:Connect(function(input)
         if input == dragInput and dragging then
            local delta = input.Position - dragStart
            item.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
         end
      end)
   end

   makeDraggable(OpenButton)
   makeDraggable(MainFrame, TopBar)
end)

if not Success then
   warn("Erro ao carregar o script do Anime Piece: " .. tostring(Result))
end
