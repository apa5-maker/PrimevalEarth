--==================================================
-- SANYOO SC V2 | PRIMEVAL EARTH
-- ALL IN ONE + SUPER LOW GRAPHICS
-- SINGLE FILE VERSION
--==================================================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer

--==================================================
-- CLEAN OLD VERSION
--==================================================

if _G.PrimevalAllCleanup then
    pcall(_G.PrimevalAllCleanup)
end

if _G.SanyooCombinedCleanup then
    pcall(_G.SanyooCombinedCleanup)
    _G.SanyooCombinedCleanup = nil
end

_G.SanyooVersion = (_G.SanyooVersion or 0) + 1

local VERSION = _G.SanyooVersion
local Running = true
local Connections = {}

local Settings = {
    ESP = false,
    Food = false,
    SelfHP = true,
    Drink = false,
    Eat = false,
    Zone = false,
    AntiAFK = true,

    AntiLag = false,
    RemoveTrees = false,
    Fullbright = false,
    NoFog = false,
    WaterESP = false
}

local SkipZone = false

local PlayerESP = {}
local FoodESP = {}
local WaterESP = {}

local OwnHP = nil
local Saved = {}

local ScanID = 0
local WaterID = 0

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function Alive()
    return Running and _G.SanyooVersion == VERSION
end

--==================================================
-- UTILITIES
--==================================================

local function GetRoot(model)
    if not model then return nil end

    return model:FindFirstChild("HumanoidRootPart", true)
        or model.PrimaryPart
        or model:FindFirstChild("Main", true)
        or model:FindFirstChild("Hitbox", true)
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function GetMyRoot()
    return GetRoot(LP.Character)
end

local function GetHumanoid(model)
    if not model then return nil end

    return model:FindFirstChildOfClass("Humanoid")
        or model:FindFirstChildWhichIsA("Humanoid", true)
end

local function HPColor(percent)
    if percent > 0.6 then
        return Color3.fromRGB(0,255,80)
    elseif percent > 0.3 then
        return Color3.fromRGB(255,220,0)
    end

    return Color3.fromRGB(255,60,60)
end

local function Contains(name, words)
    name = string.lower(name)

    for _, word in ipairs(words) do
        if string.find(name, word, 1, true) then
            return true
        end
    end

    return false
end

local function IsCharacter(obj)
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character

        if char and (
            obj == char
            or obj:IsDescendantOf(char)
        ) then
            return true
        end
    end

    return false
end

--==================================================
-- GUI SANYOO MINI
--==================================================

local parent = LP:WaitForChild("PlayerGui")

if type(gethui) == "function" then
    local success, result = pcall(gethui)

    if success and result then
        parent = result
    end
end

local old = parent:FindFirstChild("PEFourFeatures")

if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "PEFourFeatures"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = parent

-- MINI BUTTON

local bubble = Instance.new("TextButton")
bubble.Name = "PEBubble"
bubble.Size = UDim2.fromOffset(28,28)
bubble.Position = UDim2.fromOffset(8,250)
bubble.BackgroundColor3 = Color3.fromRGB(75,45,130)
bubble.Text = "PE"
bubble.TextColor3 = Color3.new(1,1,1)
bubble.TextSize = 10
bubble.Font = Enum.Font.GothamBold
bubble.Active = true
bubble.Parent = gui

Instance.new("UICorner",bubble).CornerRadius =
    UDim.new(1,0)

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color = Color3.fromRGB(190,130,255)
bubbleStroke.Thickness = 1
bubbleStroke.Parent = bubble

-- PANEL

local panel = Instance.new("Frame")
panel.Name = "FeaturePanel"
panel.Size = UDim2.fromOffset(136,258)
panel.BackgroundColor3 = Color3.fromRGB(25,30,40)
panel.Visible = false
panel.Active = true
panel.Parent = gui

Instance.new("UICorner",panel).CornerRadius =
    UDim.new(0,10)

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1,0,0,24)
heading.BackgroundColor3 = Color3.fromRGB(54,34,85)
heading.Text = "SANYOO SC V2"
heading.TextColor3 = Color3.fromRGB(210,165,255)
heading.Font = Enum.Font.GothamBold
heading.TextSize = 12
heading.Parent = panel

Instance.new("UICorner",heading).CornerRadius =
    UDim.new(0,10)

-- SCROLL MENU

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "SANYOO_SCROLL"
scroll.Position = UDim2.fromOffset(0,25)
scroll.Size = UDim2.new(1,0,1,-25)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.fromOffset(0,355)
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,3)
layout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

Connect(layout:GetPropertyChangedSignal(
    "AbsoluteContentSize"
),function()
    scroll.CanvasSize = UDim2.fromOffset(
        0,
        layout.AbsoluteContentSize.Y + 8
    )
end)

--==================================================
-- POSITION MENU
--==================================================

local function UpdatePanelPosition()
    local camera = WS.CurrentCamera
    if not camera then return end

    local screen = camera.ViewportSize
    local pos = bubble.AbsolutePosition

    local x = pos.X + 35
    local y = pos.Y

    if x + 136 > screen.X then
        x = pos.X - 141
    end

    panel.Position = UDim2.fromOffset(
        math.clamp(x,0,math.max(0,screen.X-136)),
        math.clamp(y,0,math.max(0,screen.Y-258))
    )
end

--==================================================
-- DRAG BUTTON
--==================================================

local dragging = false
local moved = false
local dragStart
local startPosition
local activeInput

Connect(bubble.InputBegan,function(input)
    if input.UserInputType ==
        Enum.UserInputType.Touch
        or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        dragging = true
        moved = false
        dragStart = input.Position
        startPosition = bubble.AbsolutePosition
        activeInput = input
    end
end)

Connect(UIS.InputChanged,function(input)
    if not dragging then return end

    local valid = input == activeInput

    if activeInput
        and activeInput.UserInputType ==
        Enum.UserInputType.MouseButton1
        and input.UserInputType ==
        Enum.UserInputType.MouseMovement then

        valid = true
    end

    if not valid then return end

    local delta = input.Position - dragStart

    if delta.Magnitude > 6 then
        moved = true
    end

    if moved then
        local camera = WS.CurrentCamera
        local screen = camera and camera.ViewportSize

        local x = startPosition.X + delta.X
        local y = startPosition.Y + delta.Y

        if screen then
            x = math.clamp(
                x,0,math.max(0,screen.X-28)
            )

            y = math.clamp(
                y,0,math.max(0,screen.Y-28)
            )
        end

        bubble.Position = UDim2.fromOffset(x,y)
        UpdatePanelPosition()
    end
end)

Connect(UIS.InputEnded,function(input)
    if input == activeInput
        or (
            activeInput
            and activeInput.UserInputType ==
            Enum.UserInputType.MouseButton1
            and input.UserInputType ==
            Enum.UserInputType.MouseButton1
        ) then

        dragging = false
        activeInput = nil
    end
end)

Connect(bubble.MouseButton1Click,function()
    if moved then
        moved = false
        return
    end

    panel.Visible = not panel.Visible

    if panel.Visible then
        UpdatePanelPosition()
    end
end)

--==================================================
-- GRAPHICS FUNCTIONS
--==================================================

local TreeWords = {
    "tree",
    "pohon",
    "trunk",
    "foliage"
}

local WaterWords = {
    "water",
    "lake",
    "pond",
    "river"
}

local function IsTree(obj)
    local node = obj

    while node and node ~= WS do
        if Contains(node.Name,TreeWords) then
            return true
        end

        node = node.Parent
    end

    return false
end

local function SaveProperty(obj,prop,value)
    local success,oldValue = pcall(function()
        return obj[prop]
    end)

    if not success then return end

    if not Saved[obj] then
        Saved[obj] = {}
    end

    if Saved[obj][prop] == nil then
        Saved[obj][prop] = oldValue
    end

    pcall(function()
        obj[prop] = value
    end)
end

local function RestoreProperty(obj,prop)
    local properties = Saved[obj]

    if properties and properties[prop] ~= nil then
        pcall(function()
            obj[prop] = properties[prop]
        end)

        properties[prop] = nil
    end
end

local function Optimize(obj)
    if not Alive() or not obj.Parent then return end
    if IsCharacter(obj) then return end

    if obj:IsA("BasePart") then

        if Settings.RemoveTrees and IsTree(obj) then
            SaveProperty(
                obj,
                "LocalTransparencyModifier",
                1
            )
        else
            RestoreProperty(
                obj,
                "LocalTransparencyModifier"
            )
        end

        if Settings.AntiLag then
            SaveProperty(obj,"CastShadow",false)
            SaveProperty(obj,"Reflectance",0)
            SaveProperty(
                obj,
                "Material",
                Enum.Material.SmoothPlastic
            )
        else
            RestoreProperty(obj,"CastShadow")
            RestoreProperty(obj,"Reflectance")
            RestoreProperty(obj,"Material")
        end

    elseif obj:IsA("Decal")
        or obj:IsA("Texture") then

        if Settings.AntiLag then
            SaveProperty(obj,"Transparency",1)
        else
            RestoreProperty(obj,"Transparency")
        end

    elseif obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles")
        or obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then

        if Settings.AntiLag then
            SaveProperty(obj,"Enabled",false)
        else
            RestoreProperty(obj,"Enabled")
        end
    end
end

local function UpdateLighting()
    local options = {
        {"Brightness",3,Settings.Fullbright},
        {"ClockTime",14,Settings.Fullbright},

        {
            "Ambient",
            Color3.fromRGB(180,180,180),
            Settings.Fullbright
        },

        {
            "OutdoorAmbient",
            Color3.fromRGB(180,180,180),
            Settings.Fullbright
        },

        {"FogStart",100000,Settings.NoFog},
        {"FogEnd",100000,Settings.NoFog},

        {
            "GlobalShadows",
            false,
            Settings.AntiLag
        }
    }

    for _,option in ipairs(options) do
        if option[3] then
            SaveProperty(
                Lighting,
                option[1],
                option[2]
            )
        else
            RestoreProperty(
                Lighting,
                option[1]
            )
        end
    end

    for _,effect in ipairs(
        Lighting:GetDescendants()
    ) do

        if effect:IsA("PostEffect") then
            if Settings.AntiLag then
                SaveProperty(effect,"Enabled",false)
            else
                RestoreProperty(effect,"Enabled")
            end
        end
    end
end

local function RefreshGraphics()
    ScanID = ScanID + 1
    local id = ScanID

    task.spawn(function()
        for i,obj in ipairs(
            WS:GetDescendants()
        ) do

            if not Alive() or id ~= ScanID then
                return
            end

            pcall(Optimize,obj)

            if i % 250 == 0 then
                task.wait()
            end
        end

        if Alive() and id == ScanID then
            UpdateLighting()
        end
    end)
end

--==================================================
-- WATER ESP
--==================================================

local function ClearWater()
    for _,marker in ipairs(WaterESP) do
        pcall(function()
            marker:Destroy()
        end)
    end

    table.clear(WaterESP)
end

local function RefreshWater()
    WaterID = WaterID + 1
    local id = WaterID

    ClearWater()

    if not Settings.WaterESP then return end

    task.spawn(function()
        local count = 0

        for i,obj in ipairs(
            WS:GetDescendants()
        ) do

            if not Alive()
                or id ~= WaterID
                or not Settings.WaterESP then
                return
            end

            if (
                obj:IsA("BasePart")
                or obj:IsA("Model")
            )
                and Contains(obj.Name,WaterWords)
                and not IsCharacter(obj) then

                local root = GetRoot(obj)

                if obj:IsA("BasePart") then
                    root = obj
                end

                if root then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "SANYOO_WATER_ESP"
                    bb.Adornee = root
                    bb.Size = UDim2.fromOffset(95,26)
                    bb.StudsOffset = Vector3.new(0,3,0)
                    bb.AlwaysOnTop = true
                    bb.Parent = gui

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.fromScale(1,1)
                    label.BackgroundTransparency = 1
                    label.Text = "WATER"
                    label.TextColor3 =
                        Color3.fromRGB(0,190,255)
                    label.TextStrokeTransparency = 0
                    label.TextSize = 12
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bb

                    table.insert(WaterESP,bb)

                    count = count + 1

                    if count >= 80 then
                        break
                    end
                end
            end

            if i % 300 == 0 then
                task.wait()
            end
        end
    end)
end

--==================================================
-- MENU TOGGLES
--==================================================

local ToggleRefresh = {}

local function AddToggle(name,key)
    local button = Instance.new("TextButton")
    button.Name = key
    button.Size = UDim2.new(1,-10,0,23)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 9
    button.TextColor3 = Color3.new(1,1,1)
    button.Parent = scroll

    Instance.new("UICorner",button).CornerRadius =
        UDim.new(0,7)

    local function Update()
        local state = Settings[key]

        button.Text = name ..
            (state and " : ON" or " : OFF")

        button.BackgroundColor3 = state
            and Color3.fromRGB(36,140,83)
            or Color3.fromRGB(145,55,60)
    end

    ToggleRefresh[key] = Update

    Connect(button.MouseButton1Click,function()
        Settings[key] = not Settings[key]

        Update()

        if key == "AntiLag"
            or key == "RemoveTrees" then

            RefreshGraphics()

        elseif key == "Fullbright"
            or key == "NoFog" then

            UpdateLighting()

        elseif key == "WaterESP" then
            RefreshWater()
        end
    end)

    Update()

    return button
end

-- ORIGINAL FEATURES

AddToggle("PLAYER ESP","ESP")
AddToggle("FOOD ESP","Food")
AddToggle("SELF HP","SelfHP")
AddToggle("AUTO DRINK","Drink")
AddToggle("AUTO EAT","Eat")
AddToggle("ANTI AFK","AntiAFK")
AddToggle("AUTO ZONE","Zone")

-- SKIP ZONE

local skip = Instance.new("TextButton")
skip.Size = UDim2.new(1,-10,0,23)
skip.Text = "SKIP ZONE"
skip.TextColor3 = Color3.new(1,1,1)
skip.BackgroundColor3 = Color3.fromRGB(65,95,160)
skip.Font = Enum.Font.GothamBold
skip.TextSize = 9
skip.Parent = scroll

Instance.new("UICorner",skip).CornerRadius =
    UDim.new(0,7)

Connect(skip.MouseButton1Click,function()
    SkipZone = true
end)

-- GRAPHICS FEATURES

AddToggle("ANTI LAG","AntiLag")
AddToggle("REMOVE TREES","RemoveTrees")
AddToggle("FULLBRIGHT","Fullbright")
AddToggle("NO FOG","NoFog")
AddToggle("WATER ESP","WaterESP")

--==================================================
-- ANTI AFK
--==================================================

Connect(LP.Idled,function()
    if not Alive()
        or not Settings.AntiAFK then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end)

--==================================================
-- PLAYER ESP
--==================================================

local function RemovePlayer(player)
    local data = PlayerESP[player]
    if not data then return end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    PlayerESP[player] = nil
end

local function SetupPlayer(player)
    if not Alive() or player == LP then
        return
    end

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
    billboard.Size = UDim2.fromOffset(200,65)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.ESP
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0,255,150)
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

local function TrackPlayer(player)
    if player == LP then return end

    Connect(player.CharacterAdded,function()
        task.delay(0.5,function()
            if Alive() then
                SetupPlayer(player)
            end
        end)
    end)

    Connect(player.CharacterRemoving,function()
        RemovePlayer(player)
    end)
end

for _,player in ipairs(Players:GetPlayers()) do
    TrackPlayer(player)
end

Connect(Players.PlayerAdded,TrackPlayer)

Connect(Players.PlayerRemoving,function(player)
    RemovePlayer(player)
end)

--==================================================
-- FOOD ESP
--==================================================

local function IsFood(obj)
    if not obj:IsA("Model") then
        return false
    end

    local name = string.lower(obj.Name)

    return name:match("^meat%d*$") ~= nil
        or Contains(name,{
            "carcass",
            "corpse",
            "meat",
            "flesh"
        })
end

local function RemoveFood(obj)
    local data = FoodESP[obj]
    if not data then return end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    FoodESP[obj] = nil
end

local function SetupFood(obj)
    if not Alive() or not IsFood(obj) then
        return
    end

    local root = GetRoot(obj)
    if not root then return end

    local existing = FoodESP[obj]

    if existing and existing.Root == root then
        return
    end

    RemoveFood(obj)

    local highlight = Instance.new("Highlight")
    highlight.Name = "PEFoodHighlight"
    highlight.Adornee = obj
    highlight.FillColor = Color3.fromRGB(255,150,0)
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillTransparency = 0.5
    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = Settings.Food
    highlight.Parent = gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PEFoodInfo"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(180,65)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.Food
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,150,0)
    label.TextStrokeTransparency = 0
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.Parent = billboard

    FoodESP[obj] = {
        Root = root,
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }
end

-- INITIAL FOOD SCAN

task.spawn(function()
    for i,obj in ipairs(WS:GetDescendants()) do
        if not Alive() then return end

        if IsFood(obj) then
            SetupFood(obj)
        end

        if i % 300 == 0 then
            task.wait()
        end
    end
end)

Connect(WS.DescendantAdded,function(obj)
    task.defer(function()
        if not Alive() or not obj.Parent then
            return
        end

        if IsFood(obj) then
            SetupFood(obj)
        end

        if Settings.AntiLag
            or Settings.RemoveTrees then
            pcall(Optimize,obj)
        end
    end)
end)

Connect(WS.DescendantRemoving,function(obj)
    if FoodESP[obj] then
        RemoveFood(obj)
    end
end)

--==================================================
-- SELF HP
--==================================================

local function RemoveOwnHP()
    if OwnHP then
        OwnHP:Destroy()
        OwnHP = nil
    end
end

local function SetupOwnHP()
    local character = LP.Character
    if not character then return end

    local head = character:FindFirstChild("Head",true)
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
    billboard.Size = UDim2.fromOffset(140,38)
    billboard.StudsOffset = Vector3.new(0,4,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = gui

    local background = Instance.new("Frame")
    background.Name = "BarBg"
    background.Size = UDim2.new(1,0,0,12)
    background.Position = UDim2.fromOffset(0,22)
    background.BackgroundColor3 =
        Color3.fromRGB(45,45,45)
    background.BorderSizePixel = 0
    background.Parent = billboard

    Instance.new("UICorner",background).CornerRadius =
        UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1,1)
    fill.BackgroundColor3 =
        Color3.fromRGB(0,255,80)
    fill.BorderSizePixel = 0
    fill.Parent = background

    Instance.new("UICorner",fill).CornerRadius =
        UDim.new(1,0)

    local label = Instance.new("TextLabel")
    label.Name = "HealthText"
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.Text = "HP: ..."
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = billboard

    OwnHP = billboard
end

local function UpdateOwnHP()
    if not Settings.SelfHP then
        if OwnHP then
            OwnHP.Enabled = false
        end

        return
    end

    SetupOwnHP()

    if not OwnHP then return end

    OwnHP.Enabled = true

    local humanoid = GetHumanoid(LP.Character)
    local label = OwnHP:FindFirstChild("HealthText")
    local bar = OwnHP:FindFirstChild("BarBg")
    local fill = bar and bar:FindFirstChild("Fill")

    if not label or not fill then return end

    if not humanoid then
        label.Text = "HP: N/A"
        fill.Size = UDim2.fromScale(0,1)
        return
    end

    local hp = math.max(0,humanoid.Health)
    local maxHP = math.max(1,humanoid.MaxHealth)
    local percent = math.clamp(hp/maxHP,0,1)

    label.Text = string.format(
        "HP: %d / %d",
        math.floor(hp),
        math.floor(maxHP)
    )

    fill.Size = UDim2.fromScale(percent,1)
    fill.BackgroundColor3 = HPColor(percent)
end

--==================================================
-- ESP UPDATE LOOP
--==================================================

task.spawn(function()
    while Alive() do
        pcall(function()
            local myRoot = GetMyRoot()

            for _,player in ipairs(
                Players:GetPlayers()
            ) do
                if player ~= LP and player.Character then
                    SetupPlayer(player)
                end
            end

            for player,data in pairs(PlayerESP) do
                if not player.Parent
                    or not data.Character.Parent
                    or not data.Root.Parent then

                    RemovePlayer(player)
                else
                    data.Billboard.Enabled = Settings.ESP

                    if myRoot and Settings.ESP then
                        local distance = (
                            myRoot.Position
                            - data.Root.Position
                        ).Magnitude

                        local humanoid =
                            GetHumanoid(data.Character)

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
                            .. " studs\n"
                            .. hp
                    end
                end
            end

            for obj,data in pairs(FoodESP) do
                if not obj.Parent
                    or not data.Root.Parent then

                    RemoveFood(obj)
                else
                    data.Highlight.Enabled = Settings.Food
                    data.Billboard.Enabled = Settings.Food

                    if myRoot and Settings.Food then
                        local distance = (
                            myRoot.Position
                            - data.Root.Position
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

--==================================================
-- AUTO ZONE
--==================================================

local function IsThisZoneGreen(targetPos)
    local isGreen = false

    pcall(function()
        local folder = WS.MapResources.Zones

        for _,zoneObj in pairs(
            folder:GetChildren()
        ) do

            local core = zoneObj:FindFirstChild(
                "LightCore"
            )

            if core
                and (
                    core.Position - targetPos
                ).Magnitude < 15 then

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
    {
        Position = Vector3.new(-144.54,-102.15,1032.19),
        Teleport = CFrame.new(-144.54,-109.15,1032.19)
    },
    {
        Position = Vector3.new(-617.92,143.39,-1130.44),
        Teleport = CFrame.new(-617.92,136.39,-1130.44)
    },
    {
        Position = Vector3.new(1449.99,77.16,-677.59),
        Teleport = CFrame.new(1449.99,70.16,-677.59)
    },
    {
        Position = Vector3.new(276.03,75.50,-1029.02),
        Teleport = CFrame.new(276.03,68.50,-1029.02)
    },
    {
        Position = Vector3.new(-513.23,75.73,-430.79),
        Teleport = CFrame.new(-513.23,68.73,-430.79)
    },
    {
        Position = Vector3.new(1090.65,66.03,467.14),
        Teleport = CFrame.new(1090.65,59.03,467.14)
    },
    {
        Position = Vector3.new(209.25,-32.79,-359.19),
        Teleport = CFrame.new(209.25,-39.79,-359.19)
    },
    {
        Position = Vector3.new(-170.20,109.98,388.42),
        Teleport = CFrame.new(-170.20,102.98,388.42)
    },
    {
        Position = Vector3.new(-69.11,-61.16,-1493.54),
        Teleport = CFrame.new(-69.11,-68.16,-1493.54)
    }
}

task.spawn(function()
    while Alive() do
        if Settings.Zone then
            local char = LP.Character
            local hrp = char and
                char:FindFirstChild("HumanoidRootPart")

            if hrp then
                for i = 1,#ZonesList do
                    if not Alive()
                        or not Settings.Zone then
                        break
                    end

                    local zone = ZonesList[i]

                    if not IsThisZoneGreen(
                        zone.Position
                    ) then

                        hrp.CFrame = zone.Teleport
                        task.wait(0.05)

                        local startTime = tick()
                        SkipZone = false

                        while Alive()
                            and Settings.Zone do

                            if IsThisZoneGreen(
                                zone.Position
                            )
                                or tick()-startTime >= 12
                                or SkipZone then

                                SkipZone = false
                                break
                            end

                            local shakeX =
                                math.sin(tick()*8)*0.35

                            local shakeZ =
                                math.cos(tick()*8)*0.35

                            if not hrp.Parent then
                                break
                            end

                            hrp.CFrame =
                                zone.Teleport
                                * CFrame.new(
                                    shakeX,0,shakeZ
                                )

                            hrp.AssemblyLinearVelocity =
                                Vector3.zero

                            task.wait(0.02)
                        end

                        task.wait(0.3)
                    end
                end

                local zone2 = ZonesList[2]

                while Alive()
                    and Settings.Zone do

                    local anyLost = false

                    for _,zone in ipairs(
                        ZonesList
                    ) do

                        if not IsThisZoneGreen(
                            zone.Position
                        ) then

                            anyLost = true
                            break
                        end
                    end

                    if anyLost then break end

                    if hrp and hrp.Parent then
                        hrp.CFrame = zone2.Teleport

                        hrp.AssemblyLinearVelocity =
                            Vector3.zero
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

--==================================================
-- AUTO EAT
--==================================================

task.spawn(function()
    local eatRemote

    pcall(function()
        eatRemote = RS
            :WaitForChild("Remotes",10)
            :WaitForChild("Character",10)
            :WaitForChild("Eat",10)
    end)

    while Alive() do
        if Settings.Eat and eatRemote then
            pcall(function()
                local hrp = GetMyRoot()
                if not hrp then return end

                local env =
                    WS:FindFirstChild("MapEnvironment")
                    or WS:FindFirstChild("MapResources")

                if not env then return end

                local closestTree
                local shortestDist = math.huge

                for _,desc in ipairs(
                    env:GetDescendants()
                ) do

                    if desc:IsA("Model")
                        and (
                            string.find(desc.Name,"Tree")
                            or string.find(desc.Name,"Bush")
                        ) then

                        local targetPart = GetRoot(desc)

                        if targetPart then
                            local dist = (
                                hrp.Position
                                - targetPart.Position
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

--==================================================
-- AUTO DRINK
--==================================================

task.spawn(function()
    while Alive() do
        if Settings.Drink then
            pcall(function()
                RS.Remotes.Character
                    .CharacterFunctions
                    :InvokeServer("Drink")
            end)

            task.wait(1)
        else
            task.wait(0.2)
        end
    end
end)

--==================================================
-- LIGHTING EFFECT TRACKING
--==================================================

Connect(Lighting.DescendantAdded,function(obj)
    task.defer(function()
        if not Alive() or not obj.Parent then
            return
        end

        if Settings.AntiLag
            and obj:IsA("PostEffect") then

            SaveProperty(obj,"Enabled",false)
        end
    end)
end)

--==================================================
-- CLEANUP
--==================================================

local function Cleanup()
    if not Running then return end

    Running = false

    ScanID = ScanID + 1
    WaterID = WaterID + 1

    for key in pairs(Settings) do
        Settings[key] = false
    end

    for _,connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    for player in pairs(PlayerESP) do
        RemovePlayer(player)
    end

    for obj in pairs(FoodESP) do
        RemoveFood(obj)
    end

    RemoveOwnHP()
    ClearWater()

    for obj,properties in pairs(Saved) do
        for prop,value in pairs(properties) do
            pcall(function()
                obj[prop] = value
            end)
        end
    end

    table.clear(Saved)

    if gui then
        gui:Destroy()
    end
end

_G.PrimevalAllCleanup = Cleanup

print("SANYOO SC V2 ALL IN ONE LOADED!")
