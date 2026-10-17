-- SANYOO SC | ALL IN ONE + GRAPHICS
-- Simpan sebagai combined.lua di repo yang sama dengan main.lua.
-- main.lua tetap berisi fitur asli (ESP, Auto Zone, Skip Zone, dll).
local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local Lighting = game:GetService('Lighting')
local player = Players.LocalPlayer

-- Bersihkan versi gabungan sebelumnya sebelum memuat script utama.
if _G.SanyooCombinedCleanup then
    pcall(_G.SanyooCombinedCleanup)
    _G.SanyooCombinedCleanup = nil
end

local originalUrl = 'https://raw.githubusercontent.com/apa5-maker/PrimevalEarth/main/main.lua'
local ok, err = pcall(function()
    loadstring(game:HttpGet(originalUrl))()
end)
if not ok then
    warn('SANYOO: gagal memuat main.lua asli: ' .. tostring(err))
    return
end

local parent = player:WaitForChild('PlayerGui')
local gui = parent:FindFirstChild('PEFourFeatures')
if not gui and type(gethui) == 'function' then
    local success, hidden = pcall(gethui)
    if success and hidden then gui = hidden:FindFirstChild('PEFourFeatures') end
end
if not gui then warn('SANYOO: menu asli tidak ditemukan'); return end
local panel = gui:FindFirstChild('FeaturePanel')
local bubble = gui:FindFirstChild('PEBubble')
if not panel or not bubble then warn('SANYOO: panel asli tidak ditemukan'); return end

local enabled = {AntiLag=false, RemoveTrees=false, Fullbright=false, NoFog=false, WaterESP=false}
local saved = {}
local markers = {}
local connections = {}
local active = true
local scanId = 0
local waterId = 0
local wordsTree = {'tree','pohon','trunk','foliage'}
local wordsWater = {'water','lake','pond','river'}

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local function contains(name, words)
    name = name:lower()
    for _, word in ipairs(words) do
        if name:find(word,1,true) then return true end
    end
    return false
end
local function isCharacter(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p.Character
        if c and (obj == c or obj:IsDescendantOf(c)) then return true end
    end
    return false
end
local function isTree(obj)
    local node = obj
    while node and node ~= Workspace do
        if contains(node.Name, wordsTree) then return true end
        node = node.Parent
    end
    return false
end
local function set(obj, prop, value)
    local ok, old = pcall(function() return obj[prop] end)
    if not ok then return end
    if not saved[obj] then saved[obj] = {} end
    if saved[obj][prop] == nil then saved[obj][prop] = old end
    pcall(function() obj[prop] = value end)
end
local function restore(obj, prop)
    local props = saved[obj]
    if props and props[prop] ~= nil then
        pcall(function() obj[prop] = props[prop] end)
        props[prop] = nil
    end
end
local function optimize(obj)
    if not active or not obj.Parent or isCharacter(obj) then return end
    if obj:IsA('BasePart') then
        if enabled.RemoveTrees and isTree(obj) then
            set(obj,'LocalTransparencyModifier',1)
        else
            restore(obj,'LocalTransparencyModifier')
        end
        if enabled.AntiLag then
            set(obj,'CastShadow',false)
            set(obj,'Reflectance',0)
            set(obj,'Material',Enum.Material.SmoothPlastic)
        else
            restore(obj,'CastShadow')
            restore(obj,'Reflectance')
            restore(obj,'Material')
        end
    elseif obj:IsA('Decal') or obj:IsA('Texture') then
        if enabled.AntiLag then set(obj,'Transparency',1)
        else restore(obj,'Transparency') end
    elseif obj:IsA('ParticleEmitter') or obj:IsA('Trail')
        or obj:IsA('Beam') or obj:IsA('Smoke') or obj:IsA('Fire')
        or obj:IsA('Sparkles') or obj:IsA('PointLight')
        or obj:IsA('SpotLight') or obj:IsA('SurfaceLight') then
        if enabled.AntiLag then set(obj,'Enabled',false)
        else restore(obj,'Enabled') end
    end
end
local function lighting()
    for _, entry in ipairs({
        {'Brightness',3,enabled.Fullbright},
        {'ClockTime',14,enabled.Fullbright},
        {'Ambient',Color3.fromRGB(180,180,180),enabled.Fullbright},
        {'OutdoorAmbient',Color3.fromRGB(180,180,180),enabled.Fullbright},
        {'FogStart',100000,enabled.NoFog},
        {'FogEnd',100000,enabled.NoFog},
        {'GlobalShadows',false,enabled.AntiLag}
    }) do
        if entry[3] then set(Lighting,entry[1],entry[2])
        else restore(Lighting,entry[1]) end
    end
    for _, effect in ipairs(Lighting:GetDescendants()) do
        if effect:IsA('PostEffect') then
            if enabled.AntiLag then set(effect,'Enabled',false)
            else restore(effect,'Enabled') end
        end
    end
end
local function refresh()
    scanId = scanId + 1
    local id = scanId
    task.spawn(function()
        for i,obj in ipairs(Workspace:GetDescendants()) do
            if not active or id ~= scanId then return end
            pcall(optimize,obj)
            if i%250 == 0 then task.wait() end
        end
        if active and id == scanId then lighting() end
    end)
end
local function clearWater()
    for _, m in ipairs(markers) do pcall(function() m:Destroy() end) end
    table.clear(markers)
end
local function refreshWater()
    waterId = waterId + 1
    local id = waterId
    clearWater()
    if not enabled.WaterESP then return end
    task.spawn(function()
        local count = 0
        for i,obj in ipairs(Workspace:GetDescendants()) do
            if not active or id ~= waterId then return end
            if (obj:IsA('BasePart') or obj:IsA('Model'))
                and contains(obj.Name,wordsWater) and not isCharacter(obj) then
                local root = obj:IsA('BasePart') and obj
                    or obj.PrimaryPart or obj:FindFirstChildWhichIsA('BasePart',true)
                if root then
                    local bb = Instance.new('BillboardGui')
                    bb.Name='SANYOO_WATER_ESP'
                    bb.Adornee=root
                    bb.Size=UDim2.fromOffset(95,26)
                    bb.StudsOffset=Vector3.new(0,3,0)
                    bb.AlwaysOnTop=true
                    bb.Parent=gui
                    local label=Instance.new('TextLabel')
                    label.Size=UDim2.fromScale(1,1)
                    label.BackgroundTransparency=1
                    label.Text='WATER'
                    label.TextColor3=Color3.fromRGB(0,190,255)
                    label.TextStrokeTransparency=0
                    label.TextSize=12
                    label.Font=Enum.Font.GothamBold
                    label.Parent=bb
                    table.insert(markers,bb)
                    count=count+1
                    if count>=80 then break end
                end
            end
            if i%300==0 then task.wait() end
        end
    end)
end

-- Menu asli tetap satu panel, sekarang scrollable dan ringkas.
panel.Size=UDim2.fromOffset(136,258)
local scroll=Instance.new('ScrollingFrame')
scroll.Name='SANYOO_SCROLL'
scroll.Position=UDim2.fromOffset(0,24)
scroll.Size=UDim2.new(1,0,1,-24)
scroll.BackgroundTransparency=1
scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3
scroll.CanvasSize=UDim2.fromOffset(0,365)
scroll.Parent=panel
for _, child in ipairs(panel:GetChildren()) do
    if child:IsA('TextButton') then child.Parent=scroll end
end
local function reposition()
    local cam=Workspace.CurrentCamera
    if not cam then return end
    local screen=cam.ViewportSize
    local pos=bubble.AbsolutePosition
    local x=pos.X+35
    if x+136>screen.X then x=pos.X-141 end
    panel.Position=UDim2.fromOffset(
        math.clamp(x,0,math.max(0,screen.X-136)),
        math.clamp(pos.Y,0,math.max(0,screen.Y-258))
    )
end
connect(bubble.MouseButton1Click,function()
    task.defer(function() if active and panel.Visible then reposition() end end)
end)
connect(bubble:GetPropertyChangedSignal('Position'),function()
    if panel.Visible then reposition() end
end)

local options={
    {'ANTI LAG','AntiLag'},
    {'REMOVE TREES','RemoveTrees'},
    {'FULLBRIGHT','Fullbright'},
    {'NO FOG','NoFog'},
    {'WATER ESP','WaterESP'}
}
for i,item in ipairs(options) do
    local name,key=item[1],item[2]
    local button=Instance.new('TextButton')
    button.Size=UDim2.new(1,-10,0,23)
    button.Position=UDim2.fromOffset(5,234+(i-1)*26)
    button.Font=Enum.Font.GothamBold
    button.TextSize=9
    button.TextColor3=Color3.new(1,1,1)
    button.Parent=scroll
    Instance.new('UICorner',button).CornerRadius=UDim.new(0,7)
    local function paint()
        button.Text=name..(enabled[key] and ' : ON' or ' : OFF')
        button.BackgroundColor3=enabled[key]
            and Color3.fromRGB(36,140,83) or Color3.fromRGB(145,55,60)
    end
    connect(button.MouseButton1Click,function()
        enabled[key]=not enabled[key]
        paint()
        if key=='WaterESP' then refreshWater()
        elseif key=='AntiLag' or key=='RemoveTrees' then refresh()
        else lighting() end
    end)
    paint()
end
connect(Workspace.DescendantAdded,function(obj)
    task.defer(function()
        if active and obj.Parent then
            pcall(optimize,obj)
            if obj:IsDescendantOf(Lighting) then lighting() end
        end
    end)
end)

local originalCleanup=_G.PrimevalAllCleanup
local function cleanup()
    if not active then return end
    active=false
    scanId=scanId+1
    waterId=waterId+1
    for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    clearWater()
    for obj,props in pairs(saved) do
        for prop,value in pairs(props) do
            pcall(function() obj[prop]=value end)
        end
    end
    table.clear(saved)
end
_G.SanyooCombinedCleanup=cleanup
_G.PrimevalAllCleanup=function()
    cleanup()
    if originalCleanup then pcall(originalCleanup) end
end
print('SANYOO SC COMBINED LOADED!')
