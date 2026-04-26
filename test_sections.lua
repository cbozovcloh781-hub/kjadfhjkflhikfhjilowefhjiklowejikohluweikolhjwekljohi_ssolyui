---@diagnostic disable: undefined-global
-- Ssoly UI Library - Test with Sections (MacLib style)

local Ssoly = loadstring(game:HttpGet("https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/init.lua"))()

local Window = Ssoly:CreateWindow({
    Title = "Sosalkin Hub - Sections Demo",
    Size = UDim2.fromOffset(700, 500),
    HubStatus = "dev",
})

-- Create tab with sections
local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "⚡"
})

-- LEFT SECTION
local LeftSection = MainTab:AddSection("Left")

LeftSection:AddToggle({
    Title = "Fly",
    Description = "Fly around the map",
    Default = false,
    Callback = function(Value)
        print("Fly:", Value)
    end
})

LeftSection:AddSlider({
    Title = "Fly Speed",
    Min = 1,
    Max = 200,
    Default = 50,
    Callback = function(Value)
        print("Speed:", Value)
    end
})

LeftSection:AddToggle({
    Title = "NoClip",
    Default = false,
    Callback = function(Value)
        print("NoClip:", Value)
    end
})

-- RIGHT SECTION
local RightSection = MainTab:AddSection("Right")

RightSection:AddToggle({
    Title = "ESP",
    Description = "Show player boxes",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end
})

RightSection:AddDropdown({
    Title = "ESP Style",
    Values = {"Corner", "Full", "3D"},
    Default = "Corner",
    Callback = function(Value)
        print("Style:", Value)
    end
})

RightSection:AddColorpicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        print("Color:", Color)
    end
})

-- Settings tab
local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "⚙️"
})

local SettingsLeft = SettingsTab:AddSection("Left")

SettingsLeft:AddDropdown({
    Title = "Theme",
    Values = {"Blue", "Purple", "Pink", "Red"},
    Default = "Blue",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

SettingsLeft:AddSlider({
    Title = "Blur Strength",
    Min = 0,
    Max = 30,
    Default = 10,
    Callback = function(Value)
        Window:SetBlurSize(Value)
    end
})

local SettingsRight = SettingsTab:AddSection("Right")

SettingsRight:AddToggle({
    Title = "Particles",
    Default = true,
    Callback = function(Value)
        Window:SetParticlesEnabled(Value)
    end
})

SettingsRight:AddButton({
    Title = "Test Notification",
    Callback = function()
        Window:Notify({
            Title = "Test",
            Content = "Sections работают!",
            Type = "Success"
        })
    end
})

Window:Show()

task.delay(0.5, function()
    Window:Notify({
        Title = "Sections Demo",
        Content = "Левая и правая секции как в MacLib!",
        Type = "Info",
        Duration = 5
    })
end)
