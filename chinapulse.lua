--// Carrega Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// Limpa instância anterior ao reexecutar
if getgenv().SailorHubCleanup then
	pcall(getgenv().SailorHubCleanup)
end

local ActiveConnections = {}
local ActiveRunning = true

getgenv().SailorHubCleanup = function()
	ActiveRunning = false
	for _, conn in ipairs(ActiveConnections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(ActiveConnections)
	local oldFloor = Workspace:FindFirstChild("HubSafeFloor")
	if oldFloor then oldFloor:Destroy() end
end

local function GetCharParts()
	local char = LocalPlayer.Character
	if not char then return nil, nil, nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
	return char, hum, hrp
end

--// Pontos de ilhas/áreas para carregar mobs de outras ilhas via TP Bypass
local FallbackIslandSpots = {
	CFrame.new(0, 50, 0),
	CFrame.new(900, 50, 700),
	CFrame.new(-900, 50, 700),
	CFrame.new(1200, 50, -900),
	CFrame.new(-1200, 50, -900),
	CFrame.new(1800, 50, 300),
	CFrame.new(-1800, 50, -300),
	CFrame.new(300, 50, 1800),
	CFrame.new(-300, 50, -1800)
}

--// Configurações Globais
getgenv().HubConfig = {
	SelectedMobs = {}, -- Até 2 mobs selecionados
	AutoMobs = false,
	AutoSeaEvent = false, -- Só vai/ataca quando spawnar Sea Beast / evento de mar (não leva pro mar sozinho)
	TpBypass = true,
	SideOffset = 3.5,
	GroupRadius = 180,
	SeaEventOffset = 14
}

local LabelToMobName = {}
local KnownMobs = {}
local KnownMobLevels = {}
local KnownMobPositions = {}
local CachedMobsAlive = {}
local CachedAttackRemotes = {}
local CachedToolRemotes = {}
local CachedToolRef = nil
local LastScanTime = 0
local LastRemoteRefresh = 0
local LastStreamTime = 0
local LastAttackTime = 0
local LastEquipTime = 0
local LastSpotHopTime = 0
local SlotTurn = 1
local FallbackIndex = 1
local CurrentTarget = nil
local CurrentSlotName = nil
local CurrentSeaTarget = nil

local IgnoredKeywords = {
	"dummy", "damage", "dmg", "test", "testing", "training", "train",
	"dps", "target", "bag", "punching", "shop", "quest", "vendor"
}

local function NormalizeName(str)
	return tostring(str or "")
		:lower()
		:gsub("[áàâãä]", "a")
		:gsub("[éèêë]", "e")
		:gsub("[íìîï]", "i")
		:gsub("[óòôõö]", "o")
		:gsub("[úùûü]", "u")
		:gsub("[ç]", "c")
		:gsub("[^%a%d]", "")
end

local function IsIgnoredModel(obj)
	if not obj then return true end
	local n = obj.Name:lower()
	for _, word in ipairs(IgnoredKeywords) do
		if n:find(word, 1, true) then
			return true
		end
	end
	return false
end

local function ExtractLevel(model, hum)
	for _, attrName in ipairs({"Level", "Lvl", "MobLevel", "NpcLevel", "Lv"}) do
		local val = model:GetAttribute(attrName) or (hum and hum:GetAttribute(attrName))
		if type(val) == "number" and val > 0 then
			return tostring(math.floor(val))
		elseif type(val) == "string" then
			local num = val:match("%d+")
			if num then return num end
		end
	end

	if hum and hum.DisplayName and hum.DisplayName ~= "" then
		local lvDisp = hum.DisplayName:match("[Ll][Vv]%a*%.?%s*(%d+)") or hum.DisplayName:match("%[(%d+)%]")
		if lvDisp then return lvDisp end
	end

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
			local lvTxt = desc.Text:match("[Ll][Vv]%a*%.?%s*(%d+)") or desc.Text:match("%[(%d+)%]") or desc.Text:match("^%d+$")
			if lvTxt then return lvTxt end
		end
	end

	return nil
end

local function FindBestPart(model)
	if not model then return nil end
	local hrp = model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Torso")
		or model:FindFirstChild("UpperTorso")
		or model:FindFirstChild("Head")
		or model.PrimaryPart
	if hrp and hrp:IsA("BasePart") then
		return hrp
	end
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			return desc
		end
	end
	return nil
end

local function IsTargetStillAlive(entry)
	if not entry then return false end
	local model = entry.model
	local hum = entry.hum
	local hrp = entry.hrp
	if not model or not model.Parent or not model:IsDescendantOf(Workspace) then
		return false
	end
	if not hrp or not hrp.Parent then
		return false
	end
	if not hum or not hum.Parent then
		return false
	end
	if hum.Health <= 0 then
		return false
	end
	return true
end

local function IsSeaTargetAlive(entry)
	if not entry then return false end
	local model = entry.model
	local part = entry.hrp
	if not model or not model.Parent or not model:IsDescendantOf(Workspace) then
		return false
	end
	if not part or not part.Parent then
		return false
	end
	local hum = entry.hum
	if hum and hum.Parent and hum.Health <= 0 then
		return false
	end
	local hpAttr = model:GetAttribute("Health") or model:GetAttribute("HP")
	if type(hpAttr) == "number" and hpAttr <= 0 then
		return false
	end
	return true
end

local function IsSeaEventEntityName(nameStr)
	local n = NormalizeName(nameStr)
	return n:find("seabeast", 1, true)
		or n:find("seabest", 1, true)
		or n:find("seaevent", 1, true)
		or n:find("beastsea", 1, true)
		or (n:find("sea", 1, true) and (n:find("beast", 1, true) or n:find("event", 1, true) or n:find("ship", 1, true) or n:find("ghost", 1, true)))
		or n:find("leviathan", 1, true)
		or n:find("kraken", 1, true)
end

local function FindSpawnedSeaEvent()
	local char, _, hrp = GetCharParts()
	local best = nil
	local bestDist = math.huge

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) and IsSeaEventEntityName(obj.Name) then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local part = FindBestPart(obj)
			if part then
				local hpOk = true
				if hum and hum.Health <= 0 then
					hpOk = false
				end
				local hpAttr = obj:GetAttribute("Health") or obj:GetAttribute("HP")
				if type(hpAttr) == "number" and hpAttr <= 0 then
					hpOk = false
				end

				if hpOk then
					local dist = hrp and (hrp.Position - part.Position).Magnitude or 0
					if dist < bestDist then
						bestDist = dist
						best = {
							name = obj.Name,
							model = obj,
							hum = hum,
							hrp = part
						}
					end
				end
			end
		end
	end

	return best
end

local function GetScanRoots()
	local roots = {}
	for _, folderName in ipairs({"Enemies", "Mobs", "Monsters", "NPCs"}) do
		local folder = Workspace:FindFirstChild(folderName)
		if folder then
			table.insert(roots, folder)
		end
	end
	if #roots == 0 then
		table.insert(roots, Workspace)
	end
	return roots
end

local function ScanMobs(force)
	if not force and (os.clock() - LastScanTime < 0.34) then
		return CachedMobsAlive
	end
	LastScanTime = os.clock()

	local alive = {}
	local seenModels = {}

	for _, root in ipairs(GetScanRoots()) do
		for _, obj in ipairs(root:GetDescendants()) do
			if obj:IsA("Model") and not seenModels[obj] and not IsIgnoredModel(obj) and not Players:GetPlayerFromCharacter(obj) then
				seenModels[obj] = true
				local hum = obj:FindFirstChildOfClass("Humanoid")
				local part = FindBestPart(obj)
				if hum and part then
					local cleanName = tostring(obj.Name):gsub("^%s+", ""):gsub("%s+$", "")
					if cleanName ~= "" then
						local lv = ExtractLevel(obj, hum)
						if lv then
							KnownMobLevels[cleanName] = lv
							KnownMobLevels[NormalizeName(cleanName)] = lv
						end

						KnownMobs[cleanName] = true
						KnownMobPositions[NormalizeName(cleanName)] = part.CFrame

						if hum.Health > 0 then
							table.insert(alive, {
								name = cleanName,
								level = lv or KnownMobLevels[cleanName] or KnownMobLevels[NormalizeName(cleanName)] or "?",
								model = obj,
								hum = hum,
								hrp = part
							})
						end
					end
				end
			end
		end
	end

	CachedMobsAlive = alive
	return alive
end

local function BuildMobOptionsWithLevel()
	table.clear(LabelToMobName)
	local alive = ScanMobs(true)

	local uniqueByNorm = {}
	for mobName in pairs(KnownMobs) do
		local norm = NormalizeName(mobName)
		if norm ~= "" and not uniqueByNorm[norm] then
			uniqueByNorm[norm] = mobName
		end
	end
	for _, m in ipairs(alive) do
		local norm = NormalizeName(m.name)
		if norm ~= "" and not uniqueByNorm[norm] then
			uniqueByNorm[norm] = m.name
		end
	end

	local sorted = {}
	for _, realName in pairs(uniqueByNorm) do
		table.insert(sorted, realName)
	end
	table.sort(sorted, function(a, b)
		return a:lower() < b:lower()
	end)

	local options = {}
	for _, realName in ipairs(sorted) do
		local lv = KnownMobLevels[realName] or KnownMobLevels[NormalizeName(realName)] or "?"
		local label = realName .. " [Lv." .. tostring(lv) .. "]"
		LabelToMobName[label] = realName
		LabelToMobName[realName] = realName
		table.insert(options, label)
	end

	return options
end

local function MatchesMobName(mobName, wantedName)
	if not mobName or not wantedName then return false end
	local mNorm = NormalizeName(mobName)
	local wNorm = NormalizeName(wantedName)
	if mNorm == "" or wNorm == "" then return false end
	if mNorm == wNorm or mNorm:find(wNorm, 1, true) or wNorm:find(mNorm, 1, true) then
		return true
	end
	local mBase = mNorm:gsub("%d+$", "")
	local wBase = wNorm:gsub("%d+$", "")
	return #wBase >= 4 and mBase == wBase
end

local function IsCombatEventName(nameLower)
	return nameLower:find("combat")
		or nameLower:find("attack")
		or nameLower:find("hit")
		or nameLower:find("m1")
		or nameLower:find("swing")
		or nameLower:find("punch")
		or nameLower:find("slash")
		or nameLower:find("sword")
		or nameLower:find("melee")
end

local function RefreshAttackRemotes()
	if os.clock() - LastRemoteRefresh < 30 and #CachedAttackRemotes > 0 then
		return
	end
	LastRemoteRefresh = os.clock()
	local list = {}

	for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
		if rem:IsA("RemoteEvent") and IsCombatEventName(rem.Name:lower()) then
			table.insert(list, rem)
		end
	end

	CachedAttackRemotes = list
end

local function GetToolEvents(tool)
	if CachedToolRef == tool and tool ~= nil then
		return CachedToolRemotes
	end
	CachedToolRef = tool
	table.clear(CachedToolRemotes)
	if tool then
		for _, desc in ipairs(tool:GetDescendants()) do
			if desc:IsA("RemoteEvent") then
				table.insert(CachedToolRemotes, desc)
			end
		end
	end
	return CachedToolRemotes
end

local function EnsureWeaponEquipped(char, hum)
	if not char then return nil end
	local equipped = char:FindFirstChildOfClass("Tool")
	if equipped then return equipped end

	if os.clock() - LastEquipTime < 0.25 then return nil end
	LastEquipTime = os.clock()

	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	if backpack and hum then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				pcall(function() hum:EquipTool(item) end)
				break
			end
		end
	end
	return char:FindFirstChildOfClass("Tool")
end

local function TpBypassMove(targetCFrame)
	local char, hum, hrp = GetCharParts()
	if not char or not hrp or not targetCFrame then return end

	if not getgenv().HubConfig.TpBypass then
		local dist = (hrp.Position - targetCFrame.Position).Magnitude
		if dist > 120 then return end
	end

	pcall(function()
		if hum then
			if hum.Sit then hum.Sit = false end
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.Running)
		end
		if LocalPlayer.RequestStreamAroundAsync and (os.clock() - LastStreamTime > 0.25) then
			LastStreamTime = os.clock()
			LocalPlayer:RequestStreamAroundAsync(targetCFrame.Position)
		end
	end)

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
			part.CanCollide = false
		end
	end

	pcall(function() char:PivotTo(targetCFrame) end)
	pcall(function() hrp.CFrame = targetCFrame end)
end

local function PerformAttack(targetEntry)
	local now = os.clock()
	if now - LastAttackTime < 0.050 then return end
	LastAttackTime = now

	local char, hum = GetCharParts()
	if not char then return end

	local tool = EnsureWeaponEquipped(char, hum)
	local tModel = targetEntry and targetEntry.model
	local tHRP = targetEntry and targetEntry.hrp
	local tPos = tHRP and tHRP.Position

	if tool then
		pcall(function() tool:Activate() end)
		local tEvents = GetToolEvents(tool)
		for i = 1, #tEvents do
			local ev = tEvents[i]
			pcall(function()
				ev:FireServer()
				if tPos then
					ev:FireServer(tPos, tModel)
				end
			end)
		end
	end

	for i = 1, #CachedAttackRemotes do
		local rem = CachedAttackRemotes[i]
		pcall(function()
			rem:FireServer()
			if tPos then
				rem:FireServer(tPos, tModel)
			end
		end)
	end
end

--// ==========================================
--// JANELA RAYFIELD (MESMA ABA)
--// ==========================================
local Window = Rayfield:CreateWindow({
	Name = "Sailor Piece Hub | Sea 2",
	LoadingTitle = "Carregando Hub...",
	LoadingSubtitle = "Auto Mobs + Auto Sea Event",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

local MobDropdown = MainTab:CreateDropdown({
	Name = "Selecionar até 2 Mobs (Com Nível)",
	Options = BuildMobOptionsWithLevel(),
	CurrentOption = {},
	MultipleOptions = true,
	Flag = "SelectTwoMobsWithLv",
	Callback = function(SelectedOptions)
		local list = {}
		local seen = {}
		for _, item in ipairs(SelectedOptions or {}) do
			local realName = LabelToMobName[item] or tostring(item):gsub("%s*%[Lv%.[^%]]+%]$", "")
			local norm = NormalizeName(realName)
			if norm ~= "" and not seen[norm] then
				seen[norm] = true
				table.insert(list, realName)
				if #list >= 2 then
					break
				end
			end
		end
		getgenv().HubConfig.SelectedMobs = list
		CurrentTarget = nil
		CurrentSlotName = nil
		SlotTurn = 1
	end,
})

MainTab:CreateToggle({
	Name = "Auto Mobs",
	CurrentValue = false,
	Flag = "AutoMobsToggle",
	Callback = function(Value)
		getgenv().HubConfig.AutoMobs = Value
		if not Value then
			CurrentTarget = nil
			CurrentSlotName = nil
		else
			RefreshAttackRemotes()
		end
	end,
})

MainTab:CreateToggle({
	Name = "Auto Sea Event",
	CurrentValue = false,
	Flag = "AutoSeaEventToggle",
	Callback = function(Value)
		getgenv().HubConfig.AutoSeaEvent = Value
		if not Value then
			CurrentSeaTarget = nil
		else
			RefreshAttackRemotes()
		end
	end,
})

MainTab:CreateToggle({
	Name = "TP Bypass",
	CurrentValue = true,
	Flag = "TpBypassToggle",
	Callback = function(Value)
		getgenv().HubConfig.TpBypass = Value
	end,
})

MainTab:CreateButton({
	Name = "Atualizar Mobs e Níveis",
	Callback = function()
		pcall(function() MobDropdown:Refresh(BuildMobOptionsWithLevel()) end)
		RefreshAttackRemotes()
	end,
})

RefreshAttackRemotes()

--// Piso seguro leve
local FloorPart = Instance.new("Part")
FloorPart.Name = "HubSafeFloor"
FloorPart.Size = Vector3.new(20, 1, 20)
FloorPart.Transparency = 1
FloorPart.Anchored = true
FloorPart.CanCollide = true
FloorPart.Parent = Workspace

table.insert(ActiveConnections, RunService.Stepped:Connect(function()
	if not ActiveRunning then return end
	if not (getgenv().HubConfig.AutoMobs or getgenv().HubConfig.AutoSeaEvent) then
		FloorPart.CFrame = CFrame.new(0, -500, 0)
		return
	end

	local _, _, hrp = GetCharParts()
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		FloorPart.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
	end
end))

--// Loop de ataque em 0.052s
table.insert(ActiveConnections, RunService.Heartbeat:Connect(function()
	if not ActiveRunning then return end
	if not (getgenv().HubConfig.AutoMobs or getgenv().HubConfig.AutoSeaEvent) then return end
	local activeTarget = IsTargetStillAlive(CurrentTarget) and CurrentTarget or (IsSeaTargetAlive(CurrentSeaTarget) and CurrentSeaTarget or nil)
	PerformAttack(activeTarget)
end))

--// Loop principal: Auto Mobs + Auto Sea Event (só quando spawnar)
task.spawn(function()
	while ActiveRunning do
		task.wait(0.035)
		pcall(function()
			local autoMobs = getgenv().HubConfig.AutoMobs
			local autoSea = getgenv().HubConfig.AutoSeaEvent

			if not autoMobs and not autoSea then
				CurrentTarget = nil
				CurrentSlotName = nil
				CurrentSeaTarget = nil
				return
			end

			local char, _, hrp = GetCharParts()
			if not char or not hrp then
				CurrentTarget = nil
				CurrentSeaTarget = nil
				return
			end

			-- Prioridade quando Auto Sea Event está ativo e algum evento/Sea Beast spawnou
			if autoSea then
				if IsSeaTargetAlive(CurrentSeaTarget) then
					local sbPos = (CurrentSeaTarget.hrp.CFrame * CFrame.new(0, 2, getgenv().HubConfig.SeaEventOffset)).Position
					TpBypassMove(CFrame.lookAt(sbPos, CurrentSeaTarget.hrp.Position))
					PerformAttack(CurrentSeaTarget)
					return
				else
					CurrentSeaTarget = nil
					local spawnedSea = FindSpawnedSeaEvent()
					if spawnedSea then
						CurrentSeaTarget = spawnedSea
						local sbPos = (spawnedSea.hrp.CFrame * CFrame.new(0, 2, getgenv().HubConfig.SeaEventOffset)).Position
						TpBypassMove(CFrame.lookAt(sbPos, spawnedSea.hrp.Position))
						PerformAttack(spawnedSea)
						return
					end
				end

				-- Fica quieto esperando spawnar se Auto Mobs não estiver ativo
				if not autoMobs then
					return
				end
			end

			if not autoMobs then
				CurrentTarget = nil
				CurrentSlotName = nil
				return
			end

			local selected = getgenv().HubConfig.SelectedMobs
			if type(selected) ~= "table" or #selected == 0 then
				CurrentTarget = nil
				CurrentSlotName = nil
				return
			end

			local count = math.min(2, #selected)

			-- 1) Termina de matar o alvo atual até o fim
			if IsTargetStillAlive(CurrentTarget) then
				KnownMobPositions[NormalizeName(CurrentTarget.name)] = CurrentTarget.hrp.CFrame
				local sidePos = (CurrentTarget.hrp.CFrame * CFrame.new(getgenv().HubConfig.SideOffset, 0, 0)).Position
				TpBypassMove(CFrame.lookAt(sidePos, CurrentTarget.hrp.Position))
				PerformAttack(CurrentTarget)
				return
			end

			-- 2) Alvo atual morreu: vai rápido para o próximo companheiro do mesmo grupinho perto
			CurrentTarget = nil
			local alive = ScanMobs(false)
			local groupRadius = tonumber(getgenv().HubConfig.GroupRadius) or 180

			if CurrentSlotName then
				local bestSameGroup = nil
				local bestSameDist = math.huge
				for _, m in ipairs(alive) do
					if MatchesMobName(m.name, CurrentSlotName) and IsTargetStillAlive(m) then
						local d = (hrp.Position - m.hrp.Position).Magnitude
						if d <= groupRadius and d < bestSameDist then
							bestSameDist = d
							bestSameGroup = m
						end
					end
				end

				if bestSameGroup then
					CurrentTarget = bestSameGroup
					KnownMobPositions[NormalizeName(bestSameGroup.name)] = bestSameGroup.hrp.CFrame
					local sidePos = (bestSameGroup.hrp.CFrame * CFrame.new(getgenv().HubConfig.SideOffset, 0, 0)).Position
					TpBypassMove(CFrame.lookAt(sidePos, bestSameGroup.hrp.Position))
					PerformAttack(bestSameGroup)
					return
				end
			end

			-- 3) Busca o próximo mob válido entre os 2 selecionados
			local function findNearestForSlot(slotName)
				local best = nil
				local bestDist = math.huge
				for _, m in ipairs(alive) do
					if MatchesMobName(m.name, slotName) and IsTargetStillAlive(m) then
						local d = (hrp.Position - m.hrp.Position).Magnitude
						if d < bestDist then
							bestDist = d
							best = m
						end
					end
				end
				return best
			end

			local chosenMob = nil
			local chosenSlotIdx = nil

			for step = 0, count - 1 do
				local idx = ((SlotTurn + step - 1) % count) + 1
				local candidate = findNearestForSlot(selected[idx])
				if candidate then
					chosenMob = candidate
					chosenSlotIdx = idx
					break
				end
			end

			if chosenMob then
				CurrentSlotName = selected[chosenSlotIdx]
				SlotTurn = (chosenSlotIdx % count) + 1
		
