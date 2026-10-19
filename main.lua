

--==================================================
-- SANYOO SC V3 | PRIMEVAL EARTH
-- CATEGORY MENU + ALL IN ONE
-- WATER ESP REMOVED
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
    Rest = false,
    Zone = false,

    AntiLag = false,
    RemoveTrees = false,
    Fullbright = false,
    NoFog = false,

    AntiAFK = true
}

local SkipZone = false

local PlayerESP = {}
local FoodESP = {}

local OwnHP = nil
local Saved = {}

local ScanID = 0

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
        return Color3.fromRGB(0, 255, 80)
    elseif percent > 0.3 then
        return Color3.fromRGB(255, 220, 0)
    end

    return Color3.fromRGB(255, 60, 60)
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
-- GUI PARENT
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

--==================================================
-- MINI PE BUTTON
--==================================================

local bubble = Instance.new("TextButton")
bubble.Name = "PEBubble"
bubble.Size = UDim2.fromOffset(30, 30)
bubble.Position = UDim2.fromOffset(8, 250)
bubble.BackgroundColor3 = Color3.fromRGB(18, 8, 12)
bubble.Text = "SANYOO"
bubble.TextColor3 = Color3.new(1, 1, 1)
bubble.TextSize = 11
bubble.Font = Enum.Font.GothamBold
bubble.Active = true
bubble.Parent = gui

Instance.new("UICorner", bubble).CornerRadius =
    UDim.new(1, 0)

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color = Color3.fromRGB(255, 20, 55)
bubbleStroke.Thickness = 1
bubbleStroke.Parent = bubble

--==================================================
-- MAIN PANEL | DARK HACKER EDITION
--==================================================

local PANEL_W = 350
local PANEL_H = 270

local panel = Instance.new("Frame")
panel.Name = "FeaturePanel"
panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
panel.BackgroundColor3 = Color3.fromRGB(7, 8, 12)
panel.Visible = false
panel.Active = true
panel.ClipsDescendants = true
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 24, 55)
panelStroke.Thickness = 1.5
panelStroke.Transparency = 0.08
panelStroke.Parent = panel

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 12, 18)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(8, 8, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 5, 10))
})
panelGradient.Rotation = 25
panelGradient.Parent = panel

local heading = Instance.new("Frame")
heading.Name = "Header"
heading.Size = UDim2.new(1, 0, 0, 46)
heading.BackgroundColor3 = Color3.fromRGB(20, 7, 13)
heading.BorderSizePixel = 0
heading.Parent = panel

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 5, 22)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(22, 7, 14)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12))
})
headerGradient.Rotation = 0
headerGradient.Parent = heading

local logoMark = Instance.new("Frame")
logoMark.Name = "LogoMark"
logoMark.Position = UDim2.fromOffset(10, 8)
logoMark.Size = UDim2.fromOffset(29, 29)
logoMark.BackgroundColor3 = Color3.fromRGB(255, 20, 55)
logoMark.BorderSizePixel = 0
logoMark.Parent = heading
Instance.new("UICorner", logoMark).CornerRadius = UDim.new(0, 8)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.fromScale(1, 1)
logoText.BackgroundTransparency = 1
logoText.Text = "S"
logoText.TextColor3 = Color3.new(1, 1, 1)
logoText.Font = Enum.Font.GothamBlack
logoText.TextSize = 20
logoText.Parent = logoMark

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(47, 5)
title.Size = UDim2.new(1, -125, 0, 22)
title.BackgroundTransparency = 1
title.Text = "SANYOO.exe"
title.TextColor3 = Color3.fromRGB(255, 245, 247)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.Parent = heading

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(48, 26)
subtitle.Size = UDim2.new(1, -125, 0, 13)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PRIMEVAL EARTH  /  DARK SYSTEM"
subtitle.TextColor3 = Color3.fromRGB(255, 65, 90)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Font = Enum.Font.Code
subtitle.TextSize = 8
subtitle.Parent = heading

local statusDot = Instance.new("Frame")
statusDot.Position = UDim2.new(1, -66, 0, 15)
statusDot.Size = UDim2.fromOffset(7, 7)
statusDot.BackgroundColor3 = Color3.fromRGB(255, 35, 65)
statusDot.BorderSizePixel = 0
statusDot.Parent = heading
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local statusText = Instance.new("TextLabel")
statusText.Position = UDim2.new(1, -55, 0, 10)
statusText.Size = UDim2.fromOffset(32, 15)
statusText.BackgroundTransparency = 1
statusText.Text = "READY"
statusText.TextColor3 = Color3.fromRGB(255, 95, 115)
statusText.Font = Enum.Font.Code
statusText.TextSize = 9
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = heading

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Position = UDim2.new(1, -24, 0, 6)
closeButton.Size = UDim2.fromOffset(17, 17)
closeButton.BackgroundColor3 = Color3.fromRGB(65, 10, 23)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 110, 130)
closeButton.TextSize = 15
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = heading
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

local headerLine = Instance.new("Frame")
headerLine.Position = UDim2.new(0, 0, 1, -2)
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.BackgroundColor3 = Color3.fromRGB(255, 25, 55)
headerLine.BorderSizePixel = 0
headerLine.Parent = heading

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Position = UDim2.fromOffset(8, 54)
sidebar.Size = UDim2.new(1, -16, 0, 32)
sidebar.BackgroundColor3 = Color3.fromRGB(13, 12, 17)
sidebar.BorderSizePixel = 0
sidebar.Parent = panel
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 9)

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Color3.fromRGB(65, 20, 31)
sidebarStroke.Thickness = 1
sidebarStroke.Transparency = 0.2
sidebarStroke.Parent = sidebar

local sidePadding = Instance.new("UIPadding")
sidePadding.PaddingTop = UDim.new(0, 4)
sidePadding.PaddingBottom = UDim.new(0, 4)
sidePadding.PaddingLeft = UDim.new(0, 6)
sidePadding.PaddingRight = UDim.new(0, 6)
sidePadding.Parent = sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.FillDirection = Enum.FillDirection.Horizontal
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sideLayout.Padding = UDim.new(0, 3)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

-- CONTENT AREA
local contentHead = Instance.new("Frame")
contentHead.Name = "ContentHeader"
contentHead.Position = UDim2.fromOffset(8, 92)
contentHead.Size = UDim2.new(1, -16, 0, 27)
contentHead.BackgroundColor3 = Color3.fromRGB(18, 13, 19)
contentHead.BorderSizePixel = 0
contentHead.Parent = panel
Instance.new("UICorner", contentHead).CornerRadius = UDim.new(0, 7)

local contentAccent = Instance.new("Frame")
contentAccent.Size = UDim2.fromOffset(3, 15)
contentAccent.Position = UDim2.fromOffset(8, 6)
contentAccent.BackgroundColor3 = Color3.fromRGB(255, 25, 55)
contentAccent.BorderSizePixel = 0
contentAccent.Parent = contentHead

local contentTitle = Instance.new("TextLabel")
contentTitle.Name = "SectionTitle"
contentTitle.Position = UDim2.fromOffset(17, 0)
contentTitle.Size = UDim2.new(1, -28, 1, 0)
contentTitle.BackgroundTransparency = 1
contentTitle.Text = "ESP MODULES"
contentTitle.TextColor3 = Color3.fromRGB(245, 235, 239)
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 10
contentTitle.Parent = contentHead

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "SANYOO_SCROLL"
scroll.Position = UDim2.fromOffset(8, 125)
scroll.Size = UDim2.new(1, -16, 1, -155)
scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
scroll.BackgroundTransparency = 0.15
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

local scrollStroke = Instance.new("UIStroke")
scrollStroke.Color = Color3.fromRGB(45, 23, 31)
scrollStroke.Thickness = 1
scrollStroke.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 9)
padding.PaddingBottom = UDim.new(0, 9)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = scroll

local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.Position = UDim2.new(0, 10, 1, -14)
footer.Size = UDim2.new(1, -20, 0, 10)
footer.BackgroundTransparency = 1
footer.Text = "SANYOO LABS  //  BUILD 03"
footer.TextColor3 = Color3.fromRGB(110, 75, 85)
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Font = Enum.Font.Code
footer.TextSize = 8
footer.Parent = panel

Connect(closeButton.MouseButton1Click, function()
    panel.Visible = false
end)

-- PANEL DRAG: hanya melalui handle khusus di area kosong header.
-- Tombol fitur dan permukaan panel tidak pernah memulai drag.
local panelDragging = false
local panelDragStart
local panelStartPosition
local panelActiveInput

local dragHandle = Instance.new("TextButton")
dragHandle.Name = "HeaderDragHandle"
dragHandle.Position = UDim2.fromOffset(82, 0)
dragHandle.Size = UDim2.new(1, -112, 0, 46)
dragHandle.BackgroundTransparency = 1
dragHandle.Text = ""
dragHandle.AutoButtonColor = false
dragHandle.Active = true
dragHandle.ZIndex = 20
dragHandle.Parent = heading

local function BeginPanelDrag(input)
    if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    panelDragging = true
    panelDragStart = input.Position
    panelStartPosition = panel.AbsolutePosition
    panelActiveInput = input
end

Connect(dragHandle.InputBegan, BeginPanelDrag)

Connect(UIS.InputChanged, function(input)
    if not panelDragging or not panelActiveInput then return end

    local valid = input == panelActiveInput
    if panelActiveInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement then
        valid = true
    end
    if not valid then return end

    local delta = input.Position - panelDragStart
    local camera = WS.CurrentCamera
    local screen = camera and camera.ViewportSize
    local x = panelStartPosition.X + delta.X
    local y = panelStartPosition.Y + delta.Y

    if screen then
        x = math.clamp(x, 0, math.max(0, screen.X - PANEL_W))
        y = math.clamp(y, 0, math.max(0, screen.Y - PANEL_H))
    end
    panel.Position = UDim2.fromOffset(x, y)
end)

Connect(UIS.InputEnded, function(input)
    if input == panelActiveInput
        or (panelActiveInput
            and panelActiveInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1) then
        panelDragging = false
        panelActiveInput = nil
    end
end)

-- PANEL POSITION
--==================================================

local function UpdatePanelPosition()
    local camera = WS.CurrentCamera
    if not camera then return end

    local screen = camera.ViewportSize
    local pos = bubble.AbsolutePosition

    local x = pos.X + 37
    local y = pos.Y

    if x + PANEL_W > screen.X then
        x = pos.X - PANEL_W - 7
    end

    panel.Position = UDim2.fromOffset(
        math.clamp(
            x,
            0,
            math.max(0, screen.X - PANEL_W)
        ),
        math.clamp(
            y,
            0,
            math.max(0, screen.Y - PANEL_H)
        )
    )
end

--==================================================
-- MINI BUTTON: PANEL OTOMATIS DI TENGAH SAAT DIBUKA
--==================================================

Connect(bubble.MouseButton1Click, function()
    panel.Visible = not panel.Visible

    if panel.Visible then
        local camera = WS.CurrentCamera

        if camera then
            local screen = camera.ViewportSize

            panel.Position = UDim2.fromOffset(
                math.max(0, (screen.X - PANEL_W) / 2),
                math.max(0, (screen.Y - PANEL_H) / 2)
            )
        end
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

local function IsTree(obj)
    local node = obj

    while node and node ~= WS do
        if Contains(node.Name, TreeWords) then
            return true
        end

        node = node.Parent
    end

    return false
end

local function SaveProperty(obj, prop, value)
    local success, oldValue = pcall(function()
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

local function RestoreProperty(obj, prop)
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
            SaveProperty(obj, "CastShadow", false)
            SaveProperty(obj, "Reflectance", 0)
            SaveProperty(
                obj,
                "Material",
                Enum.Material.SmoothPlastic
            )
        else
            RestoreProperty(obj, "CastShadow")
            RestoreProperty(obj, "Reflectance")
            RestoreProperty(obj, "Material")
        end

    elseif obj:IsA("Decal")
        or obj:IsA("Texture") then

        if Settings.AntiLag then
            SaveProperty(obj, "Transparency", 1)
        else
            RestoreProperty(obj, "Transparency")
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
            SaveProperty(obj, "Enabled", false)
        else
            RestoreProperty(obj, "Enabled")
        end
    end
end

local function UpdateLighting()
    local options = {
        {"Brightness", 3, Settings.Fullbright},
        {"ClockTime", 14, Settings.Fullbright},

        {
            "Ambient",
            Color3.fromRGB(180, 180, 180),
            Settings.Fullbright
        },

        {
            "OutdoorAmbient",
            Color3.fromRGB(180, 180, 180),
            Settings.Fullbright
        },

        {"FogStart", 100000, Settings.NoFog},
        {"FogEnd", 100000, Settings.NoFog},

        {
            "GlobalShadows",
            false,
            Settings.AntiLag
        }
    }

    for _, option in ipairs(options) do
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

    for _, effect in ipairs(
        Lighting:GetDescendants()
    ) do

        if effect:IsA("PostEffect") then
            if Settings.AntiLag then
                SaveProperty(effect, "Enabled", false)
            else
                RestoreProperty(effect, "Enabled")
            end
        end
    end
end

local function RefreshGraphics()
    ScanID = ScanID + 1
    local id = ScanID

    task.spawn(function()
        for i, obj in ipairs(
            WS:GetDescendants()
        ) do

            if not Alive() or id ~= ScanID then
                return
            end

            pcall(Optimize, obj)

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
-- CATEGORY SYSTEM | DARK HACKER UI
--==================================================

local Categories = {}
local CurrentCategory = "ESP"
local ToggleRefresh = {}

local CategoryInfo = {
    ESP = {Icon = "◈", Title = "ESP MODULES"},
    FARM = {Icon = "⌁", Title = "AUTOMATION"},
    GRAPHICS = {Icon = "▧", Title = "VISUAL SYSTEM"},
    SETTINGS = {Icon = "⚙", Title = "SYSTEM SETTINGS"}
}

local function ShowCategory(category)
    CurrentCategory = category
    local info = CategoryInfo[category]
    contentTitle.Text = info and info.Title or string.upper(category)

    for name, button in pairs(Categories) do
        local active = name == category
        button.BackgroundColor3 = active
            and Color3.fromRGB(75, 9, 27)
            or Color3.fromRGB(20, 16, 22)
        button.TextColor3 = active
            and Color3.fromRGB(255, 90, 115)
            or Color3.fromRGB(165, 151, 160)
        local accent = button:FindFirstChild("ActiveBar")
        if accent then accent.Visible = active end
        local stroke = button:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = active
                and Color3.fromRGB(255, 25, 60)
                or Color3.fromRGB(48, 29, 37)
        end
    end

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child.Visible = child:GetAttribute("Category") == category
        end
    end
    scroll.CanvasPosition = Vector2.zero
end

local function AddCategory(name, label, order)
    local info = CategoryInfo[name] or {Icon = "•"}
    local button = Instance.new("TextButton")
    button.Name = name
    button.LayoutOrder = order
    button.Size = UDim2.new(0, 77, 0, 24)
    button.BackgroundColor3 = Color3.fromRGB(20, 16, 22)
    button.BorderSizePixel = 0
    button.Text = info.Icon .. "  " .. label
    button.TextColor3 = Color3.fromRGB(165, 151, 160)
    button.TextSize = 8
    button.TextXAlignment = Enum.TextXAlignment.Center
    button.Font = Enum.Font.GothamBold
    button.Parent = sidebar
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(48, 29, 37)
    stroke.Thickness = 1
    stroke.Parent = button

    local activeBar = Instance.new("Frame")
    activeBar.Name = "ActiveBar"
    activeBar.Position = UDim2.new(0.12, 0, 1, -3)
    activeBar.Size = UDim2.new(0.76, 0, 0, 2)
    activeBar.BackgroundColor3 = Color3.fromRGB(255, 25, 60)
    activeBar.BorderSizePixel = 0
    activeBar.Visible = false
    activeBar.Parent = button
    Instance.new("UICorner", activeBar).CornerRadius = UDim.new(1, 0)

    Categories[name] = button
    Connect(button.MouseButton1Click, function() ShowCategory(name) end)
end

AddCategory("ESP", "ESP", 1)
AddCategory("FARM", "AUTO FARM", 2)
AddCategory("GRAPHICS", "GRAPHICS", 3)
AddCategory("SETTINGS", "SETTINGS", 4)

local function AddToggle(name, key, category, order)
    local button = Instance.new("TextButton")
    button.Name = key
    button.LayoutOrder = order
    button.Size = UDim2.new(1, -4, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(23, 18, 24)
    button.BorderSizePixel = 0
    button.Text = ""
    button:SetAttribute("Category", category)
    button.Parent = scroll
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Name = "CardStroke"
    stroke.Color = Color3.fromRGB(54, 30, 39)
    stroke.Thickness = 1
    stroke.Transparency = 0.15
    stroke.Parent = button

    local accent = Instance.new("Frame")
    accent.Name = "CardAccent"
    accent.Position = UDim2.fromOffset(0, 9)
    accent.Size = UDim2.new(0, 3, 1, -18)
    accent.BackgroundColor3 = Color3.fromRGB(90, 35, 48)
    accent.BorderSizePixel = 0
    accent.Parent = button
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "FeatureName"
    titleLabel.Position = UDim2.fromOffset(13, 5)
    titleLabel.Size = UDim2.new(1, -86, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = Color3.fromRGB(238, 226, 232)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 10
    titleLabel.Parent = button

    local detail = Instance.new("TextLabel")
    detail.Name = "FeatureDetail"
    detail.Position = UDim2.fromOffset(13, 25)
    detail.Size = UDim2.new(1, -86, 0, 14)
    detail.BackgroundTransparency = 1
    detail.Text = "MODULE / " .. string.upper(key)
    detail.TextColor3 = Color3.fromRGB(112, 92, 103)
    detail.TextXAlignment = Enum.TextXAlignment.Left
    detail.Font = Enum.Font.Code
    detail.TextSize = 8
    detail.Parent = button

    local switch = Instance.new("Frame")
    switch.Name = "Switch"
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -11, 0.5, 0)
    switch.Size = UDim2.fromOffset(36, 20)
    switch.BackgroundColor3 = Color3.fromRGB(48, 39, 46)
    switch.BorderSizePixel = 0
    switch.Parent = button
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Position = UDim2.fromOffset(3, 3)
    knob.Size = UDim2.fromOffset(14, 14)
    knob.BackgroundColor3 = Color3.fromRGB(185, 169, 178)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local stateText = Instance.new("TextLabel")
    stateText.Name = "StateText"
    stateText.AnchorPoint = Vector2.new(1, 1)
    stateText.Position = UDim2.new(1, -11, 1, -3)
    stateText.Size = UDim2.fromOffset(45, 10)
    stateText.BackgroundTransparency = 1
    stateText.Text = "DISABLED"
    stateText.TextColor3 = Color3.fromRGB(120, 96, 107)
    stateText.Font = Enum.Font.Code
    stateText.TextSize = 7
    stateText.TextXAlignment = Enum.TextXAlignment.Right
    stateText.Parent = button

    local function Update()
        local enabled = Settings[key]
        button.BackgroundColor3 = enabled
            and Color3.fromRGB(38, 13, 22)
            or Color3.fromRGB(23, 18, 24)
        stroke.Color = enabled
            and Color3.fromRGB(255, 25, 60)
            or Color3.fromRGB(54, 30, 39)
        accent.BackgroundColor3 = enabled
            and Color3.fromRGB(255, 25, 60)
            or Color3.fromRGB(90, 35, 48)
        switch.BackgroundColor3 = enabled
            and Color3.fromRGB(205, 12, 45)
            or Color3.fromRGB(48, 39, 46)
        knob.Position = enabled
            and UDim2.fromOffset(23, 3)
            or UDim2.fromOffset(3, 3)
        knob.BackgroundColor3 = enabled
            and Color3.fromRGB(255, 255, 255)
            or Color3.fromRGB(185, 169, 178)
        stateText.Text = enabled and "ENABLED" or "DISABLED"
        stateText.TextColor3 = enabled
            and Color3.fromRGB(255, 75, 100)
            or Color3.fromRGB(120, 96, 107)
    end

    ToggleRefresh[key] = Update
    Connect(button.MouseButton1Click, function()
        Settings[key] = not Settings[key]
        Update()
        if key == "AntiLag" or key == "RemoveTrees" then
            RefreshGraphics()
        elseif key == "Fullbright" or key == "NoFog" then
            UpdateLighting()
        end
    end)
    Update()
    return button
end

-- ESP CATEGORY
AddToggle("PLAYER ESP", "ESP", "ESP", 1)
AddToggle("FOOD ESP", "Food", "ESP", 2)
AddToggle("SELF HEALTH", "SelfHP", "ESP", 3)

-- AUTO FARM CATEGORY
AddToggle("AUTO DRINK", "Drink", "FARM", 1)
AddToggle("AUTO EAT", "Eat", "FARM", 2)
AddToggle("AUTO REST", "Rest", "FARM", 3)
AddToggle("AUTO ZONE", "Zone", "FARM", 4)

local skip = Instance.new("TextButton")
skip.Name = "SkipZone"
skip.LayoutOrder = 5
skip.Size = UDim2.new(1, -4, 0, 42)
skip.Text = "  »   SKIP CURRENT ZONE"
skip.TextXAlignment = Enum.TextXAlignment.Left
skip.TextColor3 = Color3.fromRGB(255, 220, 226)
skip.BackgroundColor3 = Color3.fromRGB(78, 9, 27)
skip.BorderSizePixel = 0
skip.Font = Enum.Font.GothamBold
skip.TextSize = 10
skip:SetAttribute("Category", "FARM")
skip.Parent = scroll
Instance.new("UICorner", skip).CornerRadius = UDim.new(0, 8)
local skipStroke = Instance.new("UIStroke")
skipStroke.Color = Color3.fromRGB(255, 35, 65)
skipStroke.Thickness = 1
skipStroke.Parent = skip
Connect(skip.MouseButton1Click, function() SkipZone = true end)

-- GRAPHICS CATEGORY
AddToggle("ANTI LAG", "AntiLag", "GRAPHICS", 1)
AddToggle("REMOVE TREES", "RemoveTrees", "GRAPHICS", 2)
AddToggle("FULLBRIGHT", "Fullbright", "GRAPHICS", 3)
AddToggle("NO FOG", "NoFog", "GRAPHICS", 4)

-- SETTINGS CATEGORY
AddToggle("ANTI AFK", "AntiAFK", "SETTINGS", 1)

-- PLAYER TELEPORT | choose a player, then move beside them
local SelectedTeleportPlayer = nil

local function AddActionButton(name, text, order, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.LayoutOrder = order
    button.Size = UDim2.new(1, -4, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(38, 13, 22)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 220, 226)
    button.TextWrapped = true
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button:SetAttribute("Category", "SETTINGS")
    button.Parent = scroll
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 35, 65)
    stroke.Thickness = 1
    stroke.Parent = button
    Connect(button.MouseButton1Click, function()
        if Alive() then callback(button) end
    end)
    return button
end

local function GetTeleportTargets()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            table.insert(targets, player)
        end
    end
    table.sort(targets, function(a, b)
        return string.lower(a.DisplayName .. " (" .. a.Name .. ")")
            < string.lower(b.DisplayName .. " (" .. b.Name .. ")")
    end)
    return targets
end

local targetButton
local function RefreshTeleportTarget()
    local targets = GetTeleportTargets()
    if #targets == 0 then
        SelectedTeleportPlayer = nil
        if targetButton then targetButton.Text = "PLAYER TARGET  |  No other players" end
        return
    end
    local selectedIndex = 0
    for i, player in ipairs(targets) do
        if player == SelectedTeleportPlayer then selectedIndex = i break end
    end
    selectedIndex = (selectedIndex % #targets) + 1
    SelectedTeleportPlayer = targets[selectedIndex]
    if targetButton then
        targetButton.Text = "SELECT PLAYER  |  " .. SelectedTeleportPlayer.DisplayName
            .. " (@" .. SelectedTeleportPlayer.Name .. ")  •  tap to change"
    end
end

targetButton = AddActionButton("TeleportPlayerTarget", "SELECT PLAYER  |  tap to choose", 2, function()
    RefreshTeleportTarget()
end)

AddActionButton("TeleportToPlayer", "TELEPORT TO SELECTED PLAYER", 3, function(button)
    local target = SelectedTeleportPlayer
    if not target or target.Parent ~= Players then
        button.Text = "TARGET LEFT  |  choose another player"
        task.delay(1.5, function()
            if button and button.Parent then button.Text = "TELEPORT TO SELECTED PLAYER" end
        end)
        return
    end
    local myRoot = GetMyRoot()
    local targetRoot = GetRoot(target.Character)
    if not myRoot or not targetRoot then
        button.Text = "TELEPORT FAILED  |  character not ready"
        task.delay(1.5, function()
            if button and button.Parent then button.Text = "TELEPORT TO SELECTED PLAYER" end
        end)
        return
    end
    local ok = pcall(function()
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
    end)
    button.Text = ok and ("TELEPORTED  |  " .. target.DisplayName) or "TELEPORT FAILED"
    task.delay(1.5, function()
        if button and button.Parent then button.Text = "TELEPORT TO SELECTED PLAYER" end
    end)
end)

Connect(Players.PlayerRemoving, function(player)
    if player == SelectedTeleportPlayer then
        SelectedTeleportPlayer = nil
        RefreshTeleportTarget()
    end
end)

ShowCategory("ESP")

-- ANTI AFK
--==================================================

Connect(LP.Idled, function()
    if not Alive()
        or not Settings.AntiAFK then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
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

local function TrackPlayer(player)
    if player == LP then return end

    Connect(player.CharacterAdded, function()
        task.delay(0.5, function()
            if Alive() then
                SetupPlayer(player)
            end
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

--==================================================
-- FOOD ESP
--==================================================

local function IsFood(obj)
    if not obj:IsA("Model") then
        return false
    end

    local name = string.lower(obj.Name)

    return name:match("^meat%d*$") ~= nil
        or Contains(name, {
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
    highlight.FillColor = Color3.fromRGB(255, 150, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop
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

    FoodESP[obj] = {
        Root = root,
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }
end

-- INITIAL FOOD SCAN

task.spawn(function()
    for i, obj in ipairs(WS:GetDescendants()) do
        if not Alive() then return end

        if IsFood(obj) then
            SetupFood(obj)
        end

        if i % 300 == 0 then
            task.wait()
        end
    end
end)

Connect(WS.DescendantAdded, function(obj)
    task.defer(function()
        if not Alive() or not obj.Parent then
            return
        end

        if IsFood(obj) then
            SetupFood(obj)
        end

        if Settings.AntiLag
            or Settings.RemoveTrees then

            pcall(Optimize, obj)
        end
    end)
end)

Connect(WS.DescendantRemoving, function(obj)
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
    background.BackgroundColor3 =
        Color3.fromRGB(45, 45, 45)
    background.BorderSizePixel = 0
    background.Parent = billboard

    Instance.new("UICorner", background).CornerRadius =
        UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 =
        Color3.fromRGB(0, 255, 80)
    fill.BorderSizePixel = 0
    fill.Parent = background

    Instance.new("UICorner", fill).CornerRadius =
        UDim.new(1, 0)

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
    fill.BackgroundColor3 = HPColor(percent)
end

--==================================================
-- ESP UPDATE LOOP
--==================================================

task.spawn(function()
    while Alive() do
        pcall(function()
            local myRoot = GetMyRoot()

            for _, player in ipairs(
                Players:GetPlayers()
            ) do
                if player ~= LP and player.Character then
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

            for obj, data in pairs(FoodESP) do
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

        for _, zoneObj in pairs(
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
        Position = Vector3.new(-144.54, -102.15, 1032.19),
        Teleport = CFrame.new(-144.54, -109.15, 1032.19)
    },
    {
        Position = Vector3.new(-617.92, 143.39, -1130.44),
        Teleport = CFrame.new(-617.92, 136.39, -1130.44)
    },
    {
        Position = Vector3.new(1449.99, 77.16, -677.59),
        Teleport = CFrame.new(1449.99, 70.16, -677.59)
    },
    {
        Position = Vector3.new(276.03, 75.50, -1029.02),
        Teleport = CFrame.new(276.03, 68.50, -1029.02)
    },
    {
        Position = Vector3.new(-513.23, 75.73, -430.79),
        Teleport = CFrame.new(-513.23, 68.73, -430.79)
    },
    {
        Position = Vector3.new(1090.65, 66.03, 467.14),
        Teleport = CFrame.new(1090.65, 59.03, 467.14)
    },
    {
        Position = Vector3.new(209.25, -32.79, -359.19),
        Teleport = CFrame.new(209.25, -39.79, -359.19)
    },
    {
        Position = Vector3.new(-170.20, 109.98, 388.42),
        Teleport = CFrame.new(-170.20, 102.98, 388.42)
    },
    {
        Position = Vector3.new(-69.11, -61.16, -1493.54),
        Teleport = CFrame.new(-69.11, -68.16, -1493.54)
    }
}

task.spawn(function()
    while Alive() do
        if Settings.Zone then
            local char = LP.Character
            local hrp = char and
                char:FindFirstChild("HumanoidRootPart")

            if hrp then
                for i = 1, #ZonesList do
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
                                or tick() - startTime >= 12
                                or SkipZone then

                                SkipZone = false
                                break
                            end

                            local shakeX =
                                math.sin(tick() * 8) * 0.35

                            local shakeZ =
                                math.cos(tick() * 8) * 0.35

                            if not hrp.Parent then
                                break
                            end

                            hrp.CFrame =
                                zone.Teleport
                                * CFrame.new(
                                    shakeX, 0, shakeZ
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

                    for _, zone in ipairs(
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
            :WaitForChild("Remotes", 10)
            :WaitForChild("Character", 10)
            :WaitForChild("Eat", 10)
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

                for _, desc in ipairs(
                    env:GetDescendants()
                ) do

                    if desc:IsA("Model")
                        and (
                            string.find(desc.Name, "Tree")
                            or string.find(desc.Name, "Bush")
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
-- QUEST TRACKER + AUTO REST (PAINPH10-STYLE)
-- Detects quest text under PlayerGui.GameUI.QuestsFrame.
-- Auto Rest only runs while a Rest quest is detected; toggle stays ON.
--==================================================

local CurrentQuest = "None"

local function DetectCurrentQuest()
    local playerGui = LP:FindFirstChild("PlayerGui")
    local gameUI = playerGui and playerGui:FindFirstChild("GameUI")
    local questsFrame = gameUI and gameUI:FindFirstChild("QuestsFrame")

    if not questsFrame then
        return "None"
    end

    for _, child in ipairs(questsFrame:GetChildren()) do
        local textContent = string.lower(child.Name or "")

        for _, desc in ipairs(child:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                textContent = textContent .. " " .. string.lower(desc.Text or "")
            end
        end

        if string.find(textContent, "eat something", 1, true) then
            return "Eat"
        elseif string.find(textContent, "drink water", 1, true) then
            return "Drink"
        elseif string.find(textContent, "rest", 1, true) then
            return "Rest"
        end
    end

    return "None"
end

task.spawn(function()
    while Alive() do
        local ok, detectedQuest = pcall(DetectCurrentQuest)

        if ok then
            -- Keep the AUTO REST toggle unchanged. Quest detection alone
            -- controls whether resting is requested by the worker below.
            CurrentQuest = detectedQuest
        end

        task.wait(0.2)
    end
end)

task.spawn(function()
    local function getRestRemote()
        local remotes = RS:WaitForChild("Remotes", 10)
        local characterRemotes = remotes and remotes:WaitForChild("Character", 10)
        return characterRemotes and characterRemotes:WaitForChild("Rest", 10)
    end

    local restRemote = getRestRemote()
    local lastRequestedState = nil

    while Alive() do
        -- Only request resting while Auto Rest is enabled and the Rest quest is active.
        local shouldRest = (Settings.Rest == true and CurrentQuest == "Rest")

        if not restRemote or not restRemote.Parent then
            restRemote = getRestRemote()
            lastRequestedState = nil
        end

        -- Jangan kirim perintah apa pun saat toggle baru dinyalakan.
        -- Mulai rest hanya ketika quest Rest terdeteksi; kirim false hanya
        -- kalau script sebelumnya memang sudah mengaktifkan rest.
        local shouldSendRequest = shouldRest or (lastRequestedState == true and not shouldRest)
        if restRemote and shouldSendRequest and shouldRest ~= lastRequestedState then
            local ok, err = pcall(function()
                if restRemote:IsA("RemoteFunction") then
                    restRemote:InvokeServer(shouldRest)
                elseif restRemote:IsA("RemoteEvent") then
                    restRemote:FireServer(shouldRest)
                else
                    error("Character.Rest is not a RemoteFunction or RemoteEvent")
                end
            end)

            if ok then
                lastRequestedState = shouldRest
            else
                warn("[SANYOO SC] Auto Rest failed: " .. tostring(err))
                task.wait(1)
            end
        end

        task.wait(0.3)
    end
end)

--==================================================
-- LIGHTING EFFECT TRACKING
--==================================================

Connect(Lighting.DescendantAdded, function(obj)
    task.defer(function()
        if not Alive() or not obj.Parent then
            return
        end

        if Settings.AntiLag
            and obj:IsA("PostEffect") then

            SaveProperty(obj, "Enabled", false)
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

    for key in pairs(Settings) do
        Settings[key] = false
    end

    for _, connection in ipairs(Connections) do
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

    for obj, properties in pairs(Saved) do
        for prop, value in pairs(properties) do
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

print("SANYOO SC V3 CATEGORY MENU LOADED!")

