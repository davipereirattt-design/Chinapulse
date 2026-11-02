--[[ 
    CHINA HUB - Otimizador, Gráficos Massinha & Anti-Lag (Pronto para Execução)
]]--
local Success, Result = pcall(function()
   local Players = game:GetService("Players")
   local LocalPlayer = Players.LocalPlayer
   local Workspace = game:GetService("Workspace")
   local Lighting = game:GetService("Lighting")
   local CoreGui = game:GetService("CoreGui")

   if CoreGui:FindFirstChild("ChinaHubOptimizer") then
      CoreGui.ChinaHubOptimizer:Destroy()
   end

   local ScreenGui = Instance.new("ScreenGui")
   ScreenGui.Name = "ChinaHubOptimizer"
   ScreenGui.ResetOnSpawn = false
   ScreenGui.Parent = CoreGui

   -- Botão Flutuante (Abrir / Fechar)
   local OpenButton = Instance.new("TextButton")
   OpenButton.Name = "OpenButton"
   OpenButton.Size = UDim2.new(0, 50, 0, 50)
   OpenButton.Position = UDim2.new(0, 20, 0, 150)
   OpenButton.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
   OpenButton.TextColor3 = Color3.fromRGB(0, 210, 255)
   OpenButton.TextSize = 22
   OpenButton.Font = Enum.Font.GothamBold
   OpenButton.Text = "⚡"
   OpenButton.Parent = ScreenGui

   Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 12)
   local btnStroke = Instance.new("UIStroke", OpenButton)
   btnStroke.Color = Color3.fromRGB(0, 180, 255)
   btnStroke.Thickness = 2

   -- Painel Principal
   local MainFrame = Instance.new("Frame")
   MainFrame.Name = "MainFrame"
   MainFrame.Size = UDim2.new(0, 320, 0, 280)
   MainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
   MainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
   MainFrame.BorderSizePixel = 0
   MainFrame.Visible = false
   MainFrame.Parent = ScreenGui

   Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
   local mainStroke = Instance.new("UIStroke", MainFrame)
   mainStroke.Color = Color3.fromRGB(0, 180, 255)
   mainStroke.Thickness = 2

   -- TopBar
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
   Title.TextSize = 15
   Title.Font = Enum.Font.GothamBold
   Title.Text = "⚡ CHINA HUB | Otimizador"
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
   CloseButton.Parent = TopBar

   Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

   -- Container
   local Container = Instance.new("ScrollingFrame")
   Container.Size = UDim2.new(1, -20, 1, -60)
   Container.Position = UDim2.new(0, 10, 0, 50)
   Container.BackgroundTransparency = 1
   Container.BorderSizePixel = 0
   Container.CanvasSize = UDim2.new(0, 0, 0, 220)
   Container.ScrollBarThickness = 4
   Container.Parent = MainFrame

   local UIListLayout = Instance.new("UIListLayout", Container)
   UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
   UIListLayout.Padding = UDim.new(0, 12)

   local function createMenuButton(text, color)
      local btn = Instance.new("TextButton")
      btn.Size = UDim2.new(1, 0, 0, 48)
      btn.BackgroundColor3 = color or Color3.fromRGB(30, 35, 45)
      btn.TextColor3 = Color3.fromRGB(255, 255, 255)
      btn.TextSize = 13
      btn.Font = Enum.Font.GothamBold
      btn.Text = text
      btn.Parent = Container
      
      Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
      local stroke = Instance.new("UIStroke", btn)
      stroke.Color = Color3.fromRGB(60, 70, 90)
      stroke.Thickness = 1
      return btn
   end

   -- Botão 1: Gráficos Massinha & Sem Textura
   local BtnTextures = createMenuButton("🎨 Ativar Gráficos Massinha & Sem Textura", Color3.fromRGB(35, 40, 55))
   BtnTextures.MouseButton1Click:Connect(function()
      Lighting.GlobalShadows = false
      Lighting.FogEnd = 9e9
      Lighting.Brightness = 0
      Lighting.Technology = Enum.LightingTechnology.Compatibility
      pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
      
      for _, effect in ipairs(Lighting:GetChildren()) do
         if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") then
            effect:Destroy()
         end
      end
      
      for _, obj in ipairs(Workspace:GetDescendants()) do
         if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") or obj:IsA("SpecialMesh") or obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Explosion") or obj:IsA("Highlight") then
            obj:Destroy()
         elseif obj:IsA("MeshPart") then
            obj.TextureID = ""
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            obj.Color = Color3.fromRGB(150, 150, 150)
         elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
            obj.Color = Color3.fromRGB(150, 150, 150)
         end
      end
      BtnTextures.Text = "✅ Gráficos Massinha Ativados!"
   end)

   -- Botão 2: Anti-Lag Extremo
   local BtnAntiLag = createMenuButton("⚡ Anti-Lag Extremo (Otimizar FPS)", Color3.fromRGB(35, 40, 55))
   BtnAntiLag.MouseButton1Click:Connect(function()
      for _, v in ipairs(Workspace:GetDescendants()) do
         if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
         end
      end
      settings().Rendering.EagerBulkExecution = true
      BtnAntiLag.Text = "✅ Anti-Lag Aplicado com Sucesso!"
   end)

   -- Botão 3: Limpar Memória / Lixo
   local BtnClean = createMenuButton("🧹 Limpar Lixo e Cache da Memória", Color3.fromRGB(35, 40, 55))
   BtnClean.MouseButton1Click:Connect(function()
      for _, v in ipairs(CoreGui:GetDescendants()) do
         pcall(function()
            if v:IsA("ImageLabel") or v:IsA("ImageButton") then
               v.Image = ""
            end
         end)
      end
      BtnClean.Text = "✅ Memória Limpa!"
   end)

   -- Eventos de Abrir / Fechar e Arrastar
   OpenButton.MouseButton1Click:Connect(function()
      MainFrame.Visible = not MainFrame.Visible
   end)

   CloseButton.MouseButton1Click:Connect(function()
      MainFrame.Visible = false
   end)

   local dragging, dragInput, dragStart, startPos
   OpenButton.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
         dragging = true
         dragStart = input.Position
         startPos = OpenButton.Position
         input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
               dragging = false
            end
         end)
      end
   end)

   OpenButton.InputChanged:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
         dragInput = input
      end
   end)

   game:GetService("UserInputService").InputChanged:Connect(function(input)
      if input == dragInput and dragging then
         local delta = input.Position - dragStart
         OpenButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
      end
   end)
end)

if not Success then
   warn("Erro ao carregar o China Hub: " .. tostring(Result))
end
