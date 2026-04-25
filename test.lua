-- Ssoly UI Library - Test/Demo Script
-- Run this to see the UI in action

local Ssoly = loadstring(game:HttpGet("path/to/ssoly/init.lua"))()

-- Create window
local Window = Ssoly:CreateWindow({
    Title = "Ssoly UI Demo",
    Size = UDim2.fromOffset(700, 500),
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(1200, 800),
    Transparency = 0.1,
    BlurEnabled = true,
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Create tabs
local MovementTab = Window:AddTab({
    Title = "Movement",
    Icon = "⚡"
})

local ESPTab = Window:AddTab({
    Title = "ESP",
    Icon = "👁️"
})

local AutofarmTab = Window:AddTab({
    Title = "Autofarm",
    Icon = "🤖"
})

local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "⚙️"
})

-- === MOVEMENT TAB ===
MovementTab:AddToggle({
    Title = "Fly",
    Description = "Allows you to fly around the map",
    Default = false,
    Callback = function(Value)
        Window:Notify({
            Title = "Fly",
            Content = Value and "Enabled" or "Disabled",
            Type = "Success",
            Duration = 2
        })
    end
})

MovementTab:AddSlider({
    Title = "Fly Speed",
    Description = "Adjust your flying speed",
    Min = 1,
    Max = 200,
    Default = 50,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(Value)
        print("Fly Speed:", Value)
    end
})

MovementTab:AddToggle({
    Title = "NoClip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(Value)
        print("NoClip:", Value)
    end
})

MovementTab:AddToggle({
    Title = "Speed Hack",
    Description = "Increase your walk speed",
    Default = false,
    Callback = function(Value)
        print("Speed:", Value)
    end
})

MovementTab:AddSlider({
    Title = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 50,
    Rounding = 0,
    Callback = function(Value)
        print("Speed Value:", Value)
    end
})

MovementTab:AddKeybind({
    Title = "Fly Keybind",
    Description = "Press to toggle fly",
    Default = Enum.KeyCode.F,
    Callback = function(Key)
        Window:Notify({
            Title = "Fly Toggled",
            Content = "Pressed " .. Key.Name,
            Type = "Info"
        })
    end
})

-- === ESP TAB ===
ESPTab:AddToggle({
    Title = "Enable ESP",
    Description = "Show player information",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end
})

ESPTab:AddToggle({
    Title = "Box ESP",
    Description = "Draw boxes around players",
    Default = false,
    Callback = function(Value)
        print("Box ESP:", Value)
    end
})

ESPTab:AddDropdown({
    Title = "Box Style",
    Values = {"Corner", "Full", "3D"},
    Default = "Corner",
    Callback = function(Value)
        print("Box Style:", Value)
    end
})

ESPTab:AddColorpicker({
    Title = "Box Color",
    Description = "Color of ESP boxes",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        print("Box Color:", Color)
    end
})

ESPTab:AddToggle({
    Title = "Tracer ESP",
    Default = false,
    Callback = function(Value)
        print("Tracer ESP:", Value)
    end
})

ESPTab:AddColorpicker({
    Title = "Tracer Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Color)
        print("Tracer Color:", Color)
    end
})

ESPTab:AddSlider({
    Title = "Max Distance",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        print("Max Distance:", Value)
    end
})

-- === AUTOFARM TAB ===
AutofarmTab:AddToggle({
    Title = "Auto Farm Items",
    Description = "Automatically collect items",
    Default = false,
    Callback = function(Value)
        Window:Notify({
            Title = "Autofarm",
            Content = Value and "Started" or "Stopped",
            Type = Value and "Success" or "Warning",
            Duration = 3
        })
    end
})

AutofarmTab:AddDropdown({
    Title = "Farm Items",
    Description = "Select items to farm",
    Values = {"All", "Rokakaka", "Arrow", "Mask", "Diary"},
    Multi = true,
    Default = {["All"] = true},
    Callback = function(Value)
        print("Farm Items:", Value)
    end
})

AutofarmTab:AddSlider({
    Title = "Farm Delay",
    Description = "Delay between pickups",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Rounding = 1,
    Suffix = "s",
    Callback = function(Value)
        print("Farm Delay:", Value)
    end
})

AutofarmTab:AddToggle({
    Title = "Auto Sell Items",
    Description = "Automatically sell collected items",
    Default = false,
    Callback = function(Value)
        print("Autosell:", Value)
    end
})

AutofarmTab:AddDropdown({
    Title = "Sell Items",
    Values = {"All", "Rokakaka", "Arrow", "Mask"},
    Multi = true,
    Default = {},
    Callback = function(Value)
        print("Sell Items:", Value)
    end
})

AutofarmTab:AddButton({
    Title = "Show Stats",
    Description = "Display farming statistics",
    Callback = function()
        Window:Notify({
            Title = "📊 Farm Stats",
            Content = "Items: 150\nMoney: $45,000\nUptime: 2h 30m",
            Type = "Info",
            Duration = 5
        })
    end
})

-- === SETTINGS TAB ===
SettingsTab:AddInput({
    Title = "Username",
    Description = "Enter your username",
    Placeholder = "Player123",
    Default = "",
    Callback = function(Value)
        print("Username:", Value)
    end
})

SettingsTab:AddInput({
    Title = "Money Limit",
    Description = "Maximum money to farm",
    Placeholder = "1000000",
    Default = "1000000",
    Numeric = true,
    Callback = function(Value)
        print("Money Limit:", Value)
    end
})

SettingsTab:AddSlider({
    Title = "UI Transparency",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Rounding = 2,
    Callback = function(Value)
        Window.Container.BackgroundTransparency = Value
    end
})

SettingsTab:AddButton({
    Title = "Test Notifications",
    Callback = function()
        Window:Notify({Title = "Info", Content = "This is an info notification", Type = "Info"})
        task.wait(0.5)
        Window:Notify({Title = "Success", Content = "Operation completed successfully!", Type = "Success"})
        task.wait(0.5)
        Window:Notify({Title = "Warning", Content = "Be careful with this setting", Type = "Warning"})
        task.wait(0.5)
        Window:Notify({Title = "Error", Content = "Something went wrong!", Type = "Error"})
    end
})

SettingsTab:AddButton({
    Title = "Destroy UI",
    Description = "Close and remove the UI",
    Callback = function()
        Window:Notify({
            Title = "Goodbye!",
            Content = "UI will be destroyed in 2 seconds",
            Type = "Warning",
            Duration = 2
        })
        task.wait(2)
        Window:Destroy()
    end
})

print("Ssoly UI Demo loaded! Press RightControl to minimize/restore.")
Window:Notify({
    Title = "Welcome!",
    Content = "Ssoly UI v1.0 loaded successfully",
    Type = "Success",
    Duration = 5
})
