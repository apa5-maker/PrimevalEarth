-- PRIMEVAL EARTH | ALL IN ONE
-- MINI PE BUTTON + PLAYER ESP + FOOD ESP + SELF HP
-- AUTO DRINK + AUTO EAT + AUTO ZONE + ANTI AFK

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Matikan versi sebelumnya
if _G.PrimevalAllCleanup then
    pcall(_G.PrimevalAllCleanup)
end

if _G.PrimevalESPCleanup then
    pcall(_G.PrimevalESPCleanup)
    _G.PrimevalESPCleanup = nil
end

if _G.PrimevalSelfHPCleanup then
    pcall(_G.PrimevalSelfHPCleanup)
    _G.PrimevalSelfHPCleanup = nil
end

_G.PEFeatureInstance = (_G.PEFeatureInstance or 0) + 1
local instance = _G.PEFeatureInstance

local Running = true

local Settings = {
    ESP = false,
    Food = false,
    SelfHP = true,
    Drink = false,
    Eat = false,
    Zone = false,
    AntiAFK = true
}

local SkipZone = false
local Connections = {}

local PlayerESP = {}
local FoodESP = {}
local OwnHP = nil

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function GetRoot(model)
    if not model then return nil end

    return model:FindFirstChild("HumanoidRootPart", true)
        or model.PrimaryPart
        or model:FindFirstChild("Main", true)
        or model:FindFirstChild("Hitbox", true)
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function GetMyRoot()
    return GetRoot(LocalPlayer.Character)
end

local function GetHumanoid(model)
    if not model then return nil end

    return model:FindFirstChildOfClass("Humanoid")
        or model:FindFirstChildWhichIsA("Humanoid", true)
end

local function GetHealthColor(percent)
    if percent > 0.6 then
        return Color3.fromRGB(0, 255, 80)
    elseif percent > 0.3 then
        return Color3.fromRGB(255, 220, 0)
    else
        return Color3.fromRGB(255, 60, 60)
    end
end

--------------------------------------------------
-- GUI MINI
--------------------------------------------------

local parent

if gethui then
    local success, result = pcall(gethui)
    if success then
        parent = result
    end
end

parent = parent or LocalPlayer:WaitForChild("PlayerGui")

local oldGui = parent:FindFirstChild("PEFourFeatures")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "PEFourFeatures"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = parent

-- Bubble PE 28px
local bubble = Instance.new("TextButton")
bubble.Name = "PEBubble"
bubble.Size = UDim2.fromOffset(28, 28)
bubble.Position = UDim2.fromOffset(8, 250)
bubble.BackgroundColor3 = Color3.fromRGB(35, 105, 180)
bubble.Text = "PE"
bubble.TextColor3 = Color3.new(1, 1, 1)
bubble.TextSize = 10
bubble.Font = Enum.Font.GothamBold
bubble.Active = true
bubble.Parent = gui

Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color = Color3.fromRGB(110, 180, 255)
bubbleStroke.Thickness = 1
bubbleStroke.Parent = bubble

-- Menu
local panel = Instance.new("Frame")
panel.Name = "FeaturePanel"
panel.Size = UDim2.fromOffset(136, 239)
panel.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
panel.Visible = false
panel.Active = true
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1, 0, 0, 23)
heading.BackgroundColor3 = Color3.fromRGB(54, 34, 85)
heading.Text = "sanyoo"
heading.TextColor3 = Color3.fromRGB(210, 165, 255)
heading.Font = Enum.Font.GothamBold
heading.TextSize = 14
heading.Parent = panel

Instance.new("UICorner", heading).CornerRadius = UDim.new(0, 10)

local function UpdatePanelPosition()
    local camera = Workspace.CurrentCamera
    if not camera then return end

    local screen = camera.ViewportSize
    local pos = bubble.AbsolutePosition

    local x = pos.X + 35
    local y = pos.Y

    if x + 136 > screen.X then
        x = pos.X - 141
    end

    panel.Position = UDim2.fromOffset(
        math.clamp(x, 0, math.max(0, screen.X - 136)),
        math.clamp(y, 0, math.max(0, screen.Y - 239))
    )
end

--------------------------------------------------
-- DRAG BUBBLE
--------------------------------------------------

local dragging = false
local moved = false
local dragStart
local startPosition
local activeInput

Connect(bubble.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        moved = false
        dragStart = input.Position
        startPosition = bubble.AbsolutePosition
        activeInput = input
    end
end)

Connect(UIS.InputChanged, function(input)
    if not dragging then return end

    local valid = input == activeInput

    if activeInput
        and activeInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement then
        valid = true
    end

    if not valid then return end

    local delta = input.Position - dragStart

    if delta.Magnitude > 6 then
        moved = true
    end

    if moved then
        local camera = Workspace.CurrentCamera
        local screen = camera and camera.ViewportSize

        local x = startPosition.X + delta.X
        local y = startPosition.Y + delta.Y

        if screen then
            x = math.clamp(x, 0, math.max(0, screen.X - 28))
            y = math.clamp(y, 0, math.max(0, screen.Y - 28))
        end

        bubble.Position = UDim2.fromOffset(x, y)
        UpdatePanelPosition()
    end
end)

Connect(UIS.InputEnded, function(input)
    if input == activeInput
        or (
            activeInput
            and activeInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
        ) then

        dragging = false
        activeInput = nil
    end
end)

Connect(bubble.MouseButton1Click, function()
    if moved then
        moved = false
        return
    end

    panel.Visible = not panel.Visible

    if panel.Visible then
        UpdatePanelPosition()
    end
end)

--------------------------------------------------
-- PEMBUAT TOMBOL
--------------------------------------------------

local ToggleRefresh = {}

local function AddToggle(name, key, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 23)
    button.Position = UDim2.fromOffset(5, y)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 9
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = panel

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

    local function Update()
        local state = Settings[key]

        button.Text = name .. (state and " : ON" or " : OFF")
        button.BackgroundColor3 = state
            and Color3.fromRGB(36, 140, 83)
            or Color3.fromRGB(145, 55, 60)
    end

    ToggleRefresh[key] = Update

    Connect(button.MouseButton1Click, function()
        Settings[key] = not Settings[key]
        Update()
    end)

    Update()
end

AddToggle("ESP", "ESP", 26)
AddToggle("FOOD ESP", "Food", 52)
AddToggle("SELF HP", "SelfHP", 78)
AddToggle("AUTO DRINK", "Drink", 104)
AddToggle("AUTO EAT", "Eat", 130)
AddToggle("ANTI AFK", "AntiAFK", 156)
AddToggle("AUTO ZONE", "Zone", 182)

local skip = Instance.new("TextButton")
skip.Size = UDim2.new(1, -10, 0, 23)
skip.Position = UDim2.fromOffset(5, 208)
skip.Text = "SKIP ZONE"
skip.TextColor3 = Color3.new(1, 1, 1)
skip.BackgroundColor3 = Color3.fromRGB(65, 95, 160)
skip.Font = Enum.Font.GothamBold
skip.TextSize = 9
skip.Parent = panel
Instance.new("UICorner", skip).CornerRadius = UDim.new(0, 7)
Connect(skip.MouseButton1Click, function()
    SkipZone = true
end)

-- Anti AFK: menanggapi event idle saat toggle aktif.
Connect(LocalPlayer.Idled, function()
    if not Running or not Settings.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

--------------------------------------------------
-- PLAYER ESP
--------------------------------------------------

local function RemovePlayer(player)
    local data = PlayerESP[player]
    if not data then return end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    PlayerESP[player] = nil
end

local function SetupPlayer(player)
    if not Running or player == LocalPlayer then return end

    local character = player.Character
    if not character then return end

    local root = GetRoot(character)
    if not root then return end

    local existing = PlayerESP[player]

    if existing
        and existing.Character == character
        and existing.Root == root
        and existing.Billboard.Parent then
        return
    end

    RemovePlayer(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PEPlayerESP"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(200, 65)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.ESP
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextWrapped = true
    label.Parent = billboard

    PlayerESP[player] = {
        Character = character,
        Root = root,
        Billboard = billboard,
        Label = label
    }
end

--------------------------------------------------
-- FOOD ESP
--------------------------------------------------

local function IsFood(object)
    if not object:IsA("Model") then
        return false
    end

    local name = string.lower(object.Name)

    if name:match("^meat%d*$") then
        return true
    end

    return name:find("carcass", 1, true) ~= nil
        or name:find("corpse", 1, true) ~= nil
        or name:find("meat", 1, true) ~= nil
        or name:find("flesh", 1, true) ~= nil
end

local function RemoveFood(object)
    local data = FoodESP[object]
    if not data then return end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    FoodESP[object] = nil
end

local function SetupFood(object)
    if not Running or not IsFood(object) then return end

    local root = GetRoot(object)
    if not root then return end

    local existing = FoodESP[object]

    if existing and existing.Root == root then
        return
    end

    RemoveFood(object)

    local highlight = Instance.new("Highlight")
    highlight.Name = "PEFoodHighlight"
    highlight.Adornee = object
    highlight.FillColor = Color3.fromRGB(255, 150, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = Settings.Food
    highlight.Parent = gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PEFoodInfo"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(180, 65)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.Food
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 150, 0)
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.Parent = billboard

    FoodESP[object] = {
        Root = root,
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }
end

--------------------------------------------------
-- SELF HP BAR
--------------------------------------------------

local function RemoveOwnHP()
    if OwnHP then
        OwnHP:Destroy()
        OwnHP = nil
    end
end

local function SetupOwnHP()
    local character = LocalPlayer.Character
    if not character then return end

    local head = character:FindFirstChild("Head", true)
        or GetRoot(character)

    if not head or not head:IsA("BasePart") then
        return
    end

    if OwnHP and OwnHP.Adornee == head then
        return
    end

    RemoveOwnHP()

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PEOwnHealth"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(140, 38)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = gui

    local background = Instance.new("Frame")
    background.Name = "BarBg"
    background.Size = UDim2.new(1, 0, 0, 12)
    background.Position = UDim2.fromOffset(0, 22)
    background.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    background.BorderSizePixel = 0
    background.Parent = billboard

    Instance.new("UICorner", background).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
    fill.BorderSizePixel = 0
    fill.Parent = background

    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Name = "HealthText"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "HP: ..."
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = billboard

    OwnHP = billboard
end

local function UpdateOwnHP()
    if not Settings.SelfHP then
        if OwnHP then OwnHP.Enabled = false end
        return
    end

    SetupOwnHP()

    if not OwnHP then return end

    OwnHP.Enabled = true

    local humanoid = GetHumanoid(LocalPlayer.Character)
    local label = OwnHP:FindFirstChild("HealthText")
    local bar = OwnHP:FindFirstChild("BarBg")
    local fill = bar and bar:FindFirstChild("Fill")

    if not label or not fill then return end

    if not humanoid then
        label.Text = "HP: N/A"
        fill.Size = UDim2.fromScale(0, 1)
        return
    end

    local hp = math.max(0, humanoid.Health)
    local maxHP = math.max(1, humanoid.MaxHealth)
    local percent = math.clamp(hp / maxHP, 0, 1)

    label.Text = string.format(
        "HP: %d / %d",
        math.floor(hp),
        math.floor(maxHP)
    )

    fill.Size = UDim2.fromScale(percent, 1)
    fill.BackgroundColor3 = GetHealthColor(percent)
end

--------------------------------------------------
-- PLAYER TRACKING
--------------------------------------------------

local function TrackPlayer(player)
    if player == LocalPlayer then return end

    Connect(player.CharacterAdded, function()
        task.delay(0.5, function()
            if Running then SetupPlayer(player) end
        end)
    end)

    Connect(player.CharacterRemoving, function()
        RemovePlayer(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    TrackPlayer(player)
end

Connect(Players.PlayerAdded, TrackPlayer)

Connect(Players.PlayerRemoving, function(player)
    RemovePlayer(player)
end)

--------------------------------------------------
-- FOOD TRACKING
--------------------------------------------------

-- Scan food awal
for _, object in ipairs(Workspace:GetDescendants()) do
    if IsFood(object) then
        SetupFood(object)
    end
end

-- Food baru
Connect(Workspace.DescendantAdded, function(object)
    if IsFood(object) then
        task.delay(0.3, function()
            if Running and object.Parent then
                SetupFood(object)
            end
        end)
    end
end)

-- Food hilang
Connect(Workspace.DescendantRemoving, function(object)
    if FoodESP[object] then
        RemoveFood(object)
    end
end)

--------------------------------------------------
-- UPDATE ESP + FOOD + SELF HP
--------------------------------------------------

task.spawn(function()
    while Running and _G.PEFeatureInstance == instance do
        pcall(function()
            local myRoot = GetMyRoot()

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    SetupPlayer(player)
                end
            end

            for player, data in pairs(PlayerESP) do
                if not player.Parent
                    or not data.Character.Parent
                    or not data.Root.Parent then

                    RemovePlayer(player)
                else
                    data.Billboard.Enabled = Settings.ESP

                    if myRoot and Settings.ESP then
                        local distance = (
                            myRoot.Position - data.Root.Position
                        ).Magnitude

                        local humanoid = GetHumanoid(data.Character)
                        local hp = "HP: N/A"

                        if humanoid then
                            hp = string.format(
                                "HP: %d/%d",
                                math.floor(humanoid.Health),
                                math.floor(humanoid.MaxHealth)
                            )
                        end

                        data.Label.Text =
                            player.DisplayName
                            .. "\n"
                            .. math.floor(distance)
                            .. " studs"
                            .. "\n"
                            .. hp
                    end
                end
            end

            for object, data in pairs(FoodESP) do
                if not object.Parent or not data.Root.Parent then
                    RemoveFood(object)
                else
                    data.Highlight.Enabled = Settings.Food
                    data.Billboard.Enabled = Settings.Food

                    if myRoot and Settings.Food then
                        local distance = (
                            myRoot.Position - data.Root.Position
                        ).Magnitude

                        data.Label.Text =
                            "FOOD\n"
                            .. math.floor(distance)
                            .. " studs"
                    end
                end
            end

            UpdateOwnHP()
        end)

        task.wait(0.5)
    end
end)

--------------------------------------------------
-- AUTO ZONE
--------------------------------------------------

local function IsThisZoneGreen(targetPos)
    local isGreen = false

    pcall(function()
        local folder = Workspace.MapResources.Zones

        for _, zoneObj in pairs(folder:GetChildren()) do
            local core = zoneObj:FindFirstChild("LightCore")

            if core and (core.Position - targetPos).Magnitude < 15 then
                local color = core.Color

                if color.R == 0
                    and color.G > 0.9
                    and color.B == 0 then

                    isGreen = true
                end

                break
            end
        end
    end)

    return isGreen
end

local ZonesList = {
    {Position = Vector3.new(-144.54,-102.15,1032.19), Teleport = CFrame.new(-144.54,-109.15,1032.19)},
    {Position = Vector3.new(-617.92,143.39,-1130.44), Teleport = CFrame.new(-617.92,136.39,-1130.44)},
    {Position = Vector3.new(1449.99,77.16,-677.59), Teleport = CFrame.new(1449.99,70.16,-677.59)},
    {Position = Vector3.new(276.03,75.50,-1029.02), Teleport = CFrame.new(276.03,68.50,-1029.02)},
    {Position = Vector3.new(-513.23,75.73,-430.79), Teleport = CFrame.new(-513.23,68.73,-430.79)},
    {Position = Vector3.new(1090.65,66.03,467.14), Teleport = CFrame.new(1090.65,59.03,467.14)},
    {Position = Vector3.new(209.25,-32.79,-359.19), Teleport = CFrame.new(209.25,-39.79,-359.19)},
    {Position = Vector3.new(-170.20,109.98,388.42), Teleport = CFrame.new(-170.20,102.98,388.42)},
    {Position = Vector3.new(-69.11,-61.16,-1493.54), Teleport = CFrame.new(-69.11,-68.16,-1493.54)}
}

task.spawn(function()
    while Running and _G.PEFeatureInstance == instance do
        if Settings.Zone then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                for i = 1, #ZonesList do
                    if not Running or not Settings.Zone then break end

                    local zone = ZonesList[i]

                    if not IsThisZoneGreen(zone.Position) then
                        hrp.CFrame = zone.Teleport
                        task.wait(0.05)

                        local startTime = tick()
                        SkipZone = false

                        while Running
                            and Settings.Zone
                            and _G.PEFeatureInstance == instance do

                            if IsThisZoneGreen(zone.Position)
                                or tick() - startTime >= 12
                                or SkipZone then

                                SkipZone = false
                                break
                            end

                            local shakeX = math.sin(tick() * 8) * 0.35
                            local shakeZ = math.cos(tick() * 8) * 0.35

                            hrp.CFrame = zone.Teleport
                                * CFrame.new(shakeX, 0, shakeZ)

                            hrp.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.02)
                        end

                        task.wait(0.3)
                    end
                end

                local zone2 = ZonesList[2]

                while Running
                    and Settings.Zone
                    and _G.PEFeatureInstance == instance do

                    local anyLost = false

                    for _, zone in ipairs(ZonesList) do
                        if not IsThisZoneGreen(zone.Position) then
                            anyLost = true
                            break
                        end
                    end

                    if anyLost then break end

                    if hrp and hrp.Parent then
                        hrp.CFrame = zone2.Teleport
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end

                    task.wait(0.02)
                end
            else
                task.wait(0.5)
            end
        else
            task.wait(0.1)
        end
    end
end)

--------------------------------------------------
-- AUTO EAT
--------------------------------------------------

task.spawn(function()
    local eatRemote = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("Character")
        :WaitForChild("Eat")

    while Running and _G.PEFeatureInstance == instance do
        if Settings.Eat then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = GetRoot(char)

                if not hrp then return end

                local env = Workspace:FindFirstChild("MapEnvironment")
                    or Workspace:FindFirstChild("MapResources")

                if not env then return end

                local closestTree
                local shortestDist = math.huge

                for _, desc in ipairs(env:GetDescendants()) do
                    if desc:IsA("Model")
                        and (
                            string.find(desc.Name, "Tree")
                            or string.find(desc.Name, "Bush")
                        ) then

                        local targetPart = GetRoot(desc)

                        if targetPart then
                            local dist = (
                                hrp.Position - targetPart.Position
                            ).Magnitude

                            if dist < shortestDist then
                                shortestDist = dist
                                closestTree = desc
                            end
                        end
                    end
                end

                if closestTree then
                    eatRemote:FireServer(closestTree)
                end
            end)

            task.wait(1)
        else
            task.wait(0.2)
        end
    end
end)

--------------------------------------------------
-- AUTO DRINK
--------------------------------------------------

task.spawn(function()
    while Running and _G.PEFeatureInstance == instance do
        if Settings.Drink then
            pcall(function()
                ReplicatedStorage
                    .Remotes
                    .Character
                    .CharacterFunctions
                    :InvokeServer("Drink")
            end)

            task.wait(1)
        else
            task.wait(0.2)
        end
    end
end)

--------------------------------------------------
-- CLEANUP (untuk reload script)
--------------------------------------------------

local function Cleanup()
    if not Running then return end

    Running = false

    Settings.ESP = false
    Settings.Food = false
    Settings.SelfHP = false
    Settings.Drink = false
    Settings.Eat = false
    Settings.Zone = false
    Settings.AntiAFK = false

    _G.PEFeatureInstance = _G.PEFeatureInstance + 1

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    for player in pairs(PlayerESP) do
        RemovePlayer(player)
    end

    for object in pairs(FoodESP) do
        RemoveFood(object)
    end

    RemoveOwnHP()

    if gui then
        gui:Destroy()
    end
end

_G.PrimevalAllCleanup = Cleanup


print("Primeval Earth All-in-One Loaded!")
