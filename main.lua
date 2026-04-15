local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local JSON_URL = "https://raw.githubusercontent.com/sskintbgs/xeno-script/refs/heads/main/xenoscripts_scripts_only.json"

local ScriptsData = {}
local success, response = pcall(function() return game:HttpGet(JSON_URL) end)

if success then
    ScriptsData = game:GetService("HttpService"):JSONDecode(response)
end

local CurrentPlaceId = game.PlaceId
local CurrentScripts = {}

for _, s in ipairs(ScriptsData) do
    if s.placeId == CurrentPlaceId then
        table.insert(CurrentScripts, s)
    end
end

local RedBlack = {
    TextColor = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(10, 10, 10),
    Topbar = Color3.fromRGB(20, 20, 20),
    Shadow = Color3.fromRGB(0, 0, 0),
    NotificationBackground = Color3.fromRGB(15, 15, 15),
    NotificationActionsBackground = Color3.fromRGB(25, 25, 25),
    TabBackground = Color3.fromRGB(20, 20, 20),
    TabStroke = Color3.fromRGB(100, 0, 0),
    TabBackgroundSelected = Color3.fromRGB(180, 0, 0),
    TabTextColor = Color3.fromRGB(255, 255, 255),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
    ElementBackground = Color3.fromRGB(25, 25, 25),
    ElementBackgroundHover = Color3.fromRGB(40, 0, 0),
    SecondaryElementBackground = Color3.fromRGB(18, 18, 18),
    ElementStroke = Color3.fromRGB(80, 0, 0),
    SecondaryElementStroke = Color3.fromRGB(50, 0, 0),
    SliderBackground = Color3.fromRGB(40, 0, 0),
    SliderProgress = Color3.fromRGB(220, 20, 60),
    SliderStroke = Color3.fromRGB(255, 40, 80),
    ToggleBackground = Color3.fromRGB(30, 30, 30),
    ToggleEnabled = Color3.fromRGB(220, 20, 60),
    ToggleDisabled = Color3.fromRGB(60, 60, 60),
    ToggleEnabledStroke = Color3.fromRGB(255, 40, 80),
    ToggleDisabledStroke = Color3.fromRGB(80, 80, 80),
    DropdownSelected = Color3.fromRGB(40, 0, 0),
    DropdownUnselected = Color3.fromRGB(25, 25, 25),
    InputBackground = Color3.fromRGB(25, 25, 25),
    InputStroke = Color3.fromRGB(80, 0, 0),
    PlaceholderColor = Color3.fromRGB(170, 170, 170)
}

local Window = Rayfield:CreateWindow({
    Name = "XenoHub by sskint",
    LoadingTitle = "XenoHub",
    LoadingSubtitle = "by sskint",
    Theme = RedBlack
})

local Tab = Window:CreateTab("Scripts", 4483362458)

Tab:CreateParagraph({
    Title = "Current Game",
    Content = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
})

if #CurrentScripts > 0 then
    Tab:CreateSection("Scripts (" .. #CurrentScripts .. ")")

    for _, script in ipairs(CurrentScripts) do
        Tab:CreateButton({
            Name = (script.gameName or "Script") .. " by " .. (script.uploader or "Unknown"),
            Callback = function()
                if script.rawLoadstring and script.rawLoadstring ~= "" then
                    Rayfield:Notify({Title = "Injecting", Content = script.gameName, Duration = 3})
                    loadstring(script.rawLoadstring)()
                end
            end,
        })
    end
else
    Tab:CreateSection("No Scripts Found")
    Tab:CreateParagraph({
        Title = "PlaceId: " .. CurrentPlaceId,
        Content = "No scripts available for this game yet."
    })
end

local Credits = Window:CreateTab("Credits", 4483362458)
Credits:CreateSection("XenoHub by sskint")
Credits:CreateParagraph({Title = "Credits", Content = "Made by sskint\nScripts from xenoscripts.com"})
