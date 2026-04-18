-- CUBES AUTO MINER
-- Glowy Scythe default
-- Fast mining + auto sell + no animations

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "DemonHub by sskint",
    LoadingTitle = "loading..",
    LoadingSubtitle = "by sskint",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DemonHub",
        FileName = "Settings"
    },
    KeySystem = false,
    Theme = {
        -- Red & Black Theme
        TextColor = Color3.fromRGB(255, 255, 255),
        Background = Color3.fromRGB(10, 10, 10),
        Topbar = Color3.fromRGB(20, 20, 20),
        Shadow = Color3.fromRGB(0, 0, 0),
        
        NotificationBackground = Color3.fromRGB(15, 15, 15),
        NotificationActionsBackground = Color3.fromRGB(30, 30, 30),
        
        TabBackground = Color3.fromRGB(20, 20, 20),
        TabStroke = Color3.fromRGB(80, 0, 0),
        TabBackgroundSelected = Color3.fromRGB(139, 0, 0),
        TabTextColor = Color3.fromRGB(255, 255, 255),
        SelectedTabTextColor = Color3.fromRGB(255, 200, 200),
        
        ElementBackground = Color3.fromRGB(18, 18, 18),
        ElementBackgroundHover = Color3.fromRGB(30, 30, 30),
        SecondaryElementBackground = Color3.fromRGB(15, 15, 15),
        
        ElementStroke = Color3.fromRGB(80, 0, 0),
        SecondaryElementStroke = Color3.fromRGB(60, 0, 0),
        
        SliderBackground = Color3.fromRGB(40, 0, 0),
        SliderProgress = Color3.fromRGB(200, 0, 0),
        SliderStroke = Color3.fromRGB(255, 40, 40),
        
        ToggleBackground = Color3.fromRGB(25, 25, 25),
        ToggleEnabled = Color3.fromRGB(180, 0, 0),
        ToggleDisabled = Color3.fromRGB(60, 60, 60),
        ToggleEnabledStroke = Color3.fromRGB(255, 50, 50),
        ToggleDisabledStroke = Color3.fromRGB(80, 80, 80),
        ToggleEnabledOuterStroke = Color3.fromRGB(255, 80, 80),
        ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 50),
        
        DropdownSelected = Color3.fromRGB(100, 0, 0),
        DropdownUnselected = Color3.fromRGB(25, 25, 25),
        
        InputBackground = Color3.fromRGB(20, 20, 20),
        InputStroke = Color3.fromRGB(100, 0, 0),
        PlaceholderColor = Color3.fromRGB(180, 180, 180)
    }
})

-- Tabs
local MainTab = Window:CreateTab("Main")
local SellTab = Window:CreateTab("Sell")

-- Services
local player = game.Players.LocalPlayer
local cubes = workspace:WaitForChild("Cubes")
local mineRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MineRequest")
local RunService = game:GetService("RunService")

local Enabled = false
local CurrentRadius = 15
local CurrentTool = "Glowy Scythe"   -- Hard-coded
local MiningDelay = 0.025
local DisableAnimations = true
local AutoSellEnabled = false
local SellInterval = 15
local root = nil
local animConnection = nil

local function updateRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(updateRoot)
if player.Character then updateRoot() end

local function isEgg(block)
    return block.Name:lower():find("egg") ~= nil
end

local function getPosition(block)
    if not block then return nil end
    if block:IsA("BasePart") then return block.Position end
    if block:IsA("Model") and block.PrimaryPart then return block.PrimaryPart.Position end
    local part = block:FindFirstChildWhichIsA("BasePart")
    if part then return part.Position end
    return nil
end

-- No animations
local function toggleAnimations(enabled)
    if enabled then
        if animConnection then return end
        animConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end
            end
        end)
    else
        if animConnection then
            animConnection:Disconnect()
            animConnection = nil
        end
    end
end

toggleAnimations(DisableAnimations)

-- Auto sell
task.spawn(function()
    while true do
        task.wait(SellInterval)
        if AutoSellEnabled then
            local args = {"Inventory"}
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RequestSell"):FireServer(unpack(args))
        end
    end
end)

-- Mining loop
task.spawn(function()
    while true do
        task.wait(0.01)
        if not Enabled or not root or not root.Parent then continue end
        local rootPos = root.Position
        
        -- Eggs first
        for _, block in ipairs(cubes:GetDescendants()) do
            if block:IsA("Folder") then continue end
            if not isEgg(block) then continue end
            local pos = getPosition(block)
            if pos and (pos - rootPos).Magnitude <= CurrentRadius and block.Parent then
                mineRemote:FireServer(block, CurrentTool)
                if MiningDelay > 0 then task.wait(MiningDelay) end
            end
        end
        
        -- Normal blocks
        for _, block in ipairs(cubes:GetDescendants()) do
            if block:IsA("Folder") then continue end
            if isEgg(block) then continue end
            local pos = getPosition(block)
            if pos and (pos - rootPos).Magnitude <= CurrentRadius and block.Parent then
                mineRemote:FireServer(block, CurrentTool)
                if MiningDelay > 0 then task.wait(MiningDelay) end
            end
        end
    end
end)

-- MAIN TAB
MainTab:CreateToggle({
    Name = "Enable Auto Miner",
    CurrentValue = false,
    Callback = function(Value)
        Enabled = Value
    end,
})

MainTab:CreateSlider({
    Name = "Mining Radius",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) CurrentRadius = Value end,
})

MainTab:CreateSlider({
    Name = "Delay",
    Range = {0, 0.1},
    Increment = 0.001,
    CurrentValue = 0.025,
    Callback = function(Value) MiningDelay = Value end,
})

MainTab:CreateToggle({
    Name = "Disable Animations",
    CurrentValue = true,
    Callback = function(Value)
        DisableAnimations = Value
        toggleAnimations(Value)
    end,
})

-- SELL TAB
SellTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(Value)
        AutoSellEnabled = Value
    end,
})

SellTab:CreateSlider({
    Name = "Sell delay",
    Range = {5, 60},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) SellInterval = Value end,
})

SellTab:CreateButton({
    Name = "Sell Inventory Now",
    Callback = function()
        local args = {"Inventory"}
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RequestSell"):FireServer(unpack(args))
    end,
})
