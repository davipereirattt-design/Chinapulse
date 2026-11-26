local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Anti-AFK para sessões longas
pcall(function()
	LocalPlayer.Idled:Connect(function()
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end)
end)

local Window = Rayfield:CreateWindow({
	Name = "Sailor Piece - Sea 2",
	LoadingTitle = "Sailor Piece",
	LoadingSubtitle = "Sea 2 • Câmera Lisa + Kraken & Sea Serpent",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false
})

local DadosMobsSea2 = {
	{ label = "Delinquent [Lv. 12.750]", nome = "Delinquent" },
	{ label = "Strong Fighter [Lv. 13.000]", nome = "Strong Fighter" },
	{ label = "Strong Bandit [Lv. 13.500]", nome = "Strong Bandit" },
	{ label = "Fast Ninja [Lv. 14.500]", nome = "Fast Ninja" },
	{ label = "Spirit Fighter [Lv. 16.000]", nome = "Spirit Fighter" },
	{ label = "Strong Slayer [Lv. 18.000]", nome = "Strong Slayer" },
	{ label = "Ghoul Member [Lv. 18.500]", nome = "Ghoul Member" }
}

local OpcoesMobsLabel = {}
local MapaMobPorLabel = {}
for _, item in ipairs(DadosMobsSea2) do
	table.insert(OpcoesMobsLabel, item.label)
	MapaMobPorLabel[item.label] = item
end

local Estado = {
	AutoFarm = false,
	AutoSeaBeast = false,
	AutoAttack = false,
	FastAttack = true,
	AutoAtivarPlaca = false,
	AtivandoPlacaAgora = false,
	MobsSelecionados = { DadosMobsSea2[1].label },
	IndiceFila = 1,
	PosicaoSalvaPorMob = {},
	DistanciaFarm = 14,
	AlturaFarm = 12
}

local RemotesAtaqueCache = {}
local UltimoScanRemotes = 0
local UltimoAtaque = 0
local UltimoStatusTexto = ""
local StatusParagraph
local PlacasFeitas = setmetatable({}, { __mode = "k" })

local function AtualizarStatus(texto)
	if texto == UltimoStatusTexto then return end
	UltimoStatusTexto = texto
	if StatusParagraph then
		pcall(function()
			StatusParagraph:Set({
				Title = "Status Atual",
				Content = texto
			})
		end)
	end
end

local function UsuarioEstaDigitando()
	local ok, caixaFocada = pcall(function()
		return UserInputService:GetFocusedTextBox()
	end)
	return ok and caixaFocada ~= nil
end

local function GetChar()
	return LocalPlayer.Character
end

local function GetHRP()
	local char = GetChar()
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
	local char = GetChar()
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function LimparFisica(hrp)
	if not hrp then return end
	pcall(function()
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		hrp.Velocity = Vector3.zero
		hrp.RotVelocity = Vector3.zero
	end)
end

local function EstaPausado()
	local ok, res = pcall(function()
		return RunService:IsPaused()
	end)
	return ok and res == true
end

local function CarregarRegiao(pos)
	if not pos then return end
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(pos, 1)
	end)
end

local function ObterRemotesCombate()
	if os.clock() - UltimoScanRemotes < 40 then
		return RemotesAtaqueCache
	end
	UltimoScanRemotes = os.clock()
	table.clear(RemotesAtaqueCache)

	pcall(function()
		for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
			if obj:IsA("RemoteEvent") then
				local n = obj.Name:lower()
				local ehVfx = n:find("vfx") or n:find("effect") or n:find("particle") or n:find("sound") or n:find("fx")
				local ehCombate = n:find("combat") or n:find("attack") or n:find("punch") or n:find("hit") or n:find("m1") or n:find("slash") or n:find("swing") or n:find("damage")
				if ehCombate and not ehVfx then
					table.insert(RemotesAtaqueCache, obj)
				end
			end
		end
	end)
	return RemotesAtaqueCache
end

local function AplicarPosicaoUnica(char, hrp, hum, destinoPos, olharPara)
	if hum then
		pcall(function()
			hum.Sit = false
			hum.PlatformStand = false
			local estado = hum:GetState()
			if estado == Enum.HumanoidStateType.FallingDown or estado == Enum.HumanoidStateType.Ragdoll then
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
		end)
	end

	local cf
	if olharPara then
		local alvoOlhar = Vector3.new(olharPara.X, destinoPos.Y, olharPara.Z)
		if (alvoOlhar - destinoPos).Magnitude > 0.05 then
			cf = CFrame.lookAt(destinoPos, alvoOlhar)
		else
			cf = CFrame.new(destinoPos)
		end
	else
		cf = CFrame.new(destinoPos)
	end

	pcall(function() hrp.CFrame = cf end)
	LimparFisica(hrp)
end

local function TPNoAlvo(destinoPos, olharPara, carregarStream)
	local char = GetChar()
	local hrp = GetHRP()
	local hum = GetHum()
	if not char or not hrp or not destinoPos then return end
	if destinoPos.X ~= destinoPos.X or destinoPos.Y ~= destinoPos.Y or destinoPos.Z ~= destinoPos.Z then return end

	if EstaPausado() then
		local espera = 0
		while EstaPausado() and espera < 2 do
			espera += task.wait(0.1)
		end
	end

	local distInicial = (destinoPos - hrp.Position).Magnitude

	if distInicial <= 2.5 then
		LimparFisica(hrp)
		return
	end

	if carregarStream and distInicial > 250 then
		pcall(CarregarRegiao, destinoPos)
	end

	AplicarPosicaoUnica(char, hrp, hum, destinoPos, olharPara)

	if distInicial > 90 then
		for _ = 1, 3 do
			char = GetChar()
			hrp = GetHRP()
			hum = GetHum()
			if not char or not hrp then break end
			if (destinoPos - hrp.Position).Magnitude <= 16 then break end
			if carregarStream then
				pcall(CarregarRegiao, destinoPos)
			end
			AplicarPosicaoUnica(char, hrp, hum, destinoPos, olharPara)
			task.wait(0.05)
		end
	end
end

local function CalcularOffsetAtaque(alvoPos)
	local distAlcance = math.clamp(Estado.DistanciaFarm, 4, 60)
	local altura = Estado.AlturaFarm
	return alvoPos + Vector3.new(0, altura, -distAlcance)
end

local function MobEstaVivo(mob, mobHRP, mobHum)
	return mob ~= nil
		and mob.Parent ~= nil
		and mobHRP ~= nil
		and mobHRP.Parent ~= nil
		and mobHum ~= nil
		and mobHum.Parent ~= nil
		and mobHum.Health > 0
end

local function ObterPosicaoModelo(obj)
	if not obj or not obj.Parent then return nil end
	if obj:IsA("Model") then
		local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
		if root and root:IsA("BasePart") then
			return root.Position
		end
		local ok, cf = pcall(function() return obj:GetPivot() end)
		if ok and cf then
			return cf.Position
		end
	elseif obj:IsA("BasePart") then
		return obj.Position
	else
		local p = obj.Parent
		if p and p:IsA("BasePart") then
			return p.Position
		elseif p and p:IsA("Model") then
			local root = p:FindFirstChild("HumanoidRootPart") or p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart", true)
			if root and root:IsA("BasePart") then
				return root.Position
			end
		end
	end
	return nil
end

local function ModeloCombinaComChaves(obj, chaves, buscarLabels)
	local nomeLower = obj.Name:lower()
	for _, chave in ipairs(chaves) do
		if nomeLower:find(chave, 1, true) then
			return true
		end
	end

	local hum = obj:FindFirstChildOfClass("Humanoid")
	if hum and hum.DisplayName and hum.DisplayName ~= "" then
		local dispLower = hum.DisplayName:lower()
		for _, chave in ipairs(chaves) do
			if dispLower:find(chave, 1, true) then
				return true
			end
		end
	end

	if buscarLabels then
		for _, desc in ipairs(obj:GetDescendants()) do
			if desc:IsA("TextLabel") and desc.Text ~= "" then
				local txtLower = desc.Text:lower()
				for _, chave in ipairs(chaves) do
					if txtLower:find(chave, 1, true) then
						return true
					end
				end
			end
		end
	end

	return false
end

local function AlvoMaritimoAtivo(obj)
	if not obj or not obj.Parent or not obj:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(obj) then return false end

	local hum = obj:FindFirstChildOfClass("Humanoid")
	if hum then
		return hum.Health > 0
	end

	local hpAttr = obj:GetAttribute("Health") or obj:GetAttribute("HP")
	if typeof(hpAttr) == "number" then
		return hpAttr > 0
	end

	return ObterPosicaoModelo(obj) ~= nil
end

local function EncontrarSeaBeastOuKraken()
	local chaves = {"kraken", "sea serpent", "seaserpent"}
	local charPlayer = GetChar()
	local hrpPlayer = GetHRP()

	local melhorObj = nil
	local melhorPos = nil
	local menorDist = math.huge

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= charPlayer and not (charPlayer and obj:IsDescendantOf(charPlayer)) then
			if AlvoMaritimoAtivo(obj) and ModeloCombinaComChaves(obj, chaves, true) then
				local pos = ObterPosicaoModelo(obj)
				if pos then
					local d = hrpPlayer and (hrpPlayer.Position - pos).Magnitude or 0
					if d < menorDist then
						menorDist = d
						melhorObj = obj
						melhorPos = pos
					end
				end
			end
		end
	end

	return melhorObj, melhorPos
end

pcall(function()
	LocalPlayer.CharacterAdded:Connect(function(novoChar)
		if not Estado.AutoSeaBeast then return end
		task.spawn(function()
			local hrp = novoChar:WaitForChild("HumanoidRootPart", 10)
			if not hrp then return end
			task.wait(0.35)
			if not Estado.AutoSeaBeast then return end

			local beastObj, beastPos = EncontrarSeaBeastOuKraken()
			if beastObj and beastPos then
				AtualizarStatus("Respawnou! Indo para: " .. beastObj.Name)
				TPNoAlvo(CalcularOffsetAtaque(beastPos), beastPos, true)
			end
		end)
	end)
end)

local function EncontrarMobVivo(nomeBusca)
	if not nomeBusca or nomeBusca == "" then return nil end
	local alvo = nomeBusca:lower()
	local hrpPlayer = GetHRP()
	local charPlayer = GetChar()

	local melhorMob, melhorHRP, melhorHum = nil, nil, nil
	local menorDist = math.huge

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= charPlayer and not Players:GetPlayerFromCharacter(obj) then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
			if MobEstaVivo(obj, hrp, hum) and ModeloCombinaComChaves(obj, {alvo}, false) then
				local d = hrpPlayer and (hrpPlayer.Position - hrp.Position).Magnitude or 0
				if d < menorDist then
					menorDist = d
					melhorMob, melhorHRP, melhorHum = obj, hrp, hum
				end
			end
		end
	end

	return melhorMob, melhorHRP, melhorHum
end

local function EquiparArma()
	local char = GetChar()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not char or not backpack then return nil end

	local toolEquipada = char:FindFirstChildWhichIsA("Tool")
	if toolEquipada then return toolEquipada end

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			pcall(function() item.Parent = char end)
			return item
		end
	end
	return nil
end

local function ExecutarAtaque(usarCliqueVirtual)
	if UsuarioEstaDigitando() then return end

	local intervaloMinimo = Estado.FastAttack and 0.14 or 0.24
	if os.clock() - UltimoAtaque < intervaloMinimo then
		return
	end
	UltimoAtaque = os.clock()

	local char = GetChar()
	if not char then return end

	local tool = EquiparArma()
	if tool then
		pcall(function() tool:Activate() end)
	end

	local remotesCombate = ObterRemotesCombate()
	for _, remote in ipairs(remotesCombate) do
		if remote and remote.Parent then
			pcall(function() remote:FireServer() end)
		end
	end

	if usarCliqueVirtual and not UsuarioEstaDigitando() then
		pcall(function()
			local cam = Workspace.CurrentCamera
			local centro = cam and (cam.ViewportSize * 0.5) or Vector2.new(400, 240)
			VirtualUser:CaptureController()
			VirtualUser:Button1Down(centro)
			VirtualUser:Button1Up(centro)
		end)
	end
end

local function AvancarParaProximoMob()
	if #Estado.MobsSelecionados > 1 then
		Estado.IndiceFila = (Estado.IndiceFila % #Estado.MobsSelecionados) + 1
	else
		Estado.IndiceFila = 1
	end
end

local function CliqueTela()
	pcall(function()
		local cam = Workspace.CurrentCamera
		local centro = cam and (cam.ViewportSize * 0.5) or Vector2.new(400, 240)
		VirtualUser:CaptureController()
		VirtualUser:Button1Down(centro)
		task.wait(0.01)
		VirtualUser:Button1Up(centro)
	end)
end

local function RodarPlacas()
	local hrp = GetHRP()
	if not hrp then Estado.AtivandoPlacaAgora = false return end
	local agora = os.clock()
	for _, d in ipairs(Workspace:GetDescendants()) do
		if not Estado.AutoAtivarPlaca then break end
		if (d:IsA("ProximityPrompt") and d.Enabled) or d:IsA("ClickDetector") then
			local n = d.Name:lower()
			if not (n:find("shop") or n:find("vendor") or n:find("quest") or n:find("spawn")) then
				local feito = PlacasFeitas[d]
				if not feito or (agora - feito) > 3 then
					local pos = ObterPosicaoModelo(d)
					if pos and (hrp.Position - pos).Magnitude <= 900 then
						Estado.AtivandoPlacaAgora = true
						AtualizarStatus("Placa...")
						TPNoAlvo(pos, pos, false)
						task.wait(0.05)
						if d:IsA("ProximityPrompt") then
							pcall(function()
								d.HoldDuration = 0
								d.RequiresLineOfSight = false
								d.MaxActivationDistance = math.max(d.MaxActivationDistance or 15, 30)
							end)
							if typeof(fireproximityprompt) == "function" then pcall(fireproximityprompt, d, 0) end
							pcall(function() d:InputHoldBegin() task.wait(0.03) d:InputHoldEnd() end)
						elseif d:IsA("ClickDetector") then
							if typeof(fireclickdetector) == "function" then pcall(fireclickdetector, d, 0) end
							CliqueTela()
						end
						PlacasFeitas[d] = os.clock()
					end
				end
			end
		end
	end
	Estado.AtivandoPlacaAgora = false
end

task.spawn(function()
	while true do
		pcall(function()
			if Estado.AutoAtivarPlaca and not EstaPausado() then
				RodarPlacas()
			else
				Estado.AtivandoPlacaAgora = false
			end
		end)
		task.wait(0.18)
	end
end)

-- Loop Auto Attack
task.spawn(function()
	while true do
		if Estado.AutoAttack and not Estado.AtivandoPlacaAgora and not EstaPausado() and not UsuarioEstaDigitando() then
			pcall(ExecutarAtaque, false)
			task.wait(Estado.FastAttack and 0.14 or 0.24)
		else
			task.wait(0.25)
		end
	end
end)

-- Loop Auto Sea Beast: fica em repouso leve enquanto não há Kraken nem Sea Serpent
task.spawn(function()
	while true do
		if Estado.AutoSeaBeast and not Estado.AtivandoPlacaAgora and not EstaPausado() then
			local beastObj, beastPos = EncontrarSeaBeastOuKraken()
			if beastObj and beastPos then
				AtualizarStatus("Matando: " .. beastObj.Name)
				TPNoAlvo(CalcularOffsetAtaque(beastPos), beastPos, true)

				local ultimoCheckAlvo = os.clock()
				while Estado.AutoSeaBeast and not Estado.AtivandoPlacaAgora and not EstaPausado() and AlvoMaritimoAtivo(beastObj) do
					local hum = GetHum()
					if not hum or hum.Health <= 0 then
						break
					end
					local posAtual = ObterPosicaoModelo(beastObj)
					if not posAtual then break end
					local posAtaque = CalcularOffsetAtaque(posAtual)
					TPNoAlvo(posAtaque, posAtual, false)
					pcall(ExecutarAtaque, true)
					task.wait(Estado.FastAttack and 0.14 or 0.24)

					if os.clock() - ultimoCheckAlvo >= 0.75 then
						ultimoCheckAlvo = os.clock()
						if not AlvoMaritimoAtivo(beastObj) then
							break
						end
					end
				end

				if Estado.AutoSeaBeast then
					AtualizarStatus("Aguardando Kraken ou Sea Serpent...")
				end
			else
				AtualizarStatus("Aguardando Kraken ou Sea Serpent...")
				task.wait(1.0)
			end
		else
			task.wait(0.35)
		end
	end
end)

-- Loop Auto Farm
task.spawn(function()
	while true do
		if Estado.AutoFarm and not Estado.AutoSeaBeast and not Estado.AtivandoPlacaAgora and not EstaPausado() then
			local selecionados = Estado.MobsSelecionados
			if not selecionados or #selecionados == 0 then
				task.wait(0.25)
			else
				if Estado.IndiceFila > #selecionados then
					Estado.IndiceFila = 1
				end

				local labelAlvo = selecionados[Estado.IndiceFila]
				local infoMob = MapaMobPorLabel[labelAlvo]
				if not infoMob then
					Estado.IndiceFila = 1
					task.wait(0.2)
				else
					local mob, mobHRP, mobHum = EncontrarMobVivo(infoMob.nome)

					if not mob and Estado.PosicaoSalvaPorMob[infoMob.nome] then
						local posDestino = Estado.PosicaoSalvaPorMob[infoMob.nome]
						AtualizarStatus("TP -> " .. infoMob.nome)
						TPNoAlvo(posDestino, nil, true)

						for _ = 1, 6 do
							if not Estado.AutoFarm or Estado.AutoSeaBeast or Estado.AtivandoPlacaAgora then break end
							if Estado.MobsSelecionados[Estado.IndiceFila] ~= labelAlvo then break end
							mob, mobHRP, mobHum = EncontrarMobVivo(infoMob.nome)
							if mob then break end
							local hrp = GetHRP()
							if hrp and (hrp.Position - posDestino).Magnitude > 16 then
								TPNoAlvo(posDestino, nil, false)
							elseif hrp then
								LimparFisica(hrp)
							end
							task.wait(0.18)
						end
					end

					if mob and mobHRP and mobHum then
						Estado.PosicaoSalvaPorMob[infoMob.nome] = mobHRP.Position + Vector3.new(0, Estado.AlturaFarm, 0)
						AtualizarStatus("Farmando [" .. Estado.IndiceFila .. "/" .. #selecionados .. "]: " .. infoMob.nome)

						while Estado.AutoFarm and not Estado.AutoSeaBeast and not Estado.AtivandoPlacaAgora and not EstaPausado() and MobEstaVivo(mob, mobHRP, mobHum) do
							local labelAtual = Estado.MobsSelecionados[Estado.IndiceFila]
							if labelAtual ~= labelAlvo then break end

							local basePos = mobHRP.Position
							local posAtaque = CalcularOffsetAtaque(basePos)
							TPNoAlvo(posAtaque, basePos, false)
							pcall(ExecutarAtaque, true)
							task.wait(Estado.FastAttack and 0.14 or 0.24)
						end

						local proximoDoMesmo, pHRP, _ = EncontrarMobVivo(infoMob.nome)
						if proximoDoMesmo and pHRP then
							TPNoAlvo(CalcularOffsetAtaque(pHRP.Position), pHRP.Position, false)
						elseif #Estado.MobsSelecionados > 1 then
							AvancarParaProximoMob()
							local proxLabel = Estado.MobsSelecionados[Estado.IndiceFila]
							local proxInfo = proxLabel and MapaMobPorLabel[proxLabel]
							if proxInfo and Estado.PosicaoSalvaPorMob[proxInfo.nome] then
								TPNoAlvo(Estado.PosicaoSalvaPorMob[proxInfo.nome], nil, true)
							end
						end
					else
						if #Estado.MobsSelecionados > 1 then
							AvancarParaProximoMob()
						end
					end
					task.wait(0.2)
				end
			end
		else
			task.wait(0.3)
		end
	end
end)

local MainTab = Window:CreateTab("Sea 2", 4483362458)
local PlacaTab = Window:CreateTab("Auto Placa", 4483362458)

StatusParagraph = MainTab:CreateParagraph({
	Title = "Status Atual",
	Content = "Pronto. Câmera mais suave ao mexer no mar + Auto Placa em aba própria."
})

MainTab:CreateDropdown({
	Name = "Mobs (Até 2)",
	Options = OpcoesMobsLabel,
	CurrentOption = { DadosMobsSea2[1].label },
	MultipleOptions = true,
	Flag = "DropMobsMulti",
	Callback = function(Options)
		if #Options > 2 then
			Estado.MobsSelecionados = { Options[#Options - 1], Options[#Options] }
		else
			Estado.MobsSelecionados = Options
		end
		Estado.IndiceFila = 1
		AtualizarStatus("Mobs ativos: " .. (#Estado.MobsSelecionados > 0 and table.concat(Estado.MobsSelecionados, ", ") or "Nenhum"))
	end,
})

MainTab:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Flag = "ToggleAutoFarm",
	Callback = function(Value)
		Estado.AutoFarm = Value
		Estado.IndiceFila = 1
		AtualizarStatus("Auto Farm: " .. (Value and "LIGADO" or "DESLIGADO"))
	end,
})

MainTab:CreateToggle({
	Name = "Auto Sea Beast",
	CurrentValue = false,
	Flag = "ToggleAutoSeaBeast",
	Callback = function(Value)
		Estado.AutoSeaBeast = Value
		AtualizarStatus(Value and "Auto Sea Beast: LIGADO (aguardando Kraken / Sea Serpent)" or "Auto Sea Beast: DESLIGADO")
	end,
})

MainTab:CreateToggle({
	Name = "Auto Attack",
	CurrentValue = false,
	Flag = "ToggleAutoAttack",
	Callback = function(Value)
		Estado.AutoAttack = Value
		AtualizarStatus("Auto Attack: " .. (Value and "LIGADO" or "DESLIGADO"))
	end,
})

MainTab:CreateToggle({
	Name = "Fast Attack",
	CurrentValue = true,
	Flag = "ToggleFastAttack",
	Callback = function(Value
