# Ssoly UI Library

Modern minimalist UI library for Roblox exploits with smooth animations and advanced features.

## ✨ Features

- 🎨 **Minimalist Design** - Clean, rounded interface with dark theme
- 🖱️ **Draggable & Resizable** - Smooth window manipulation
- 📑 **Tab System** - Organized content with animated transitions
- 🔔 **Notifications** - Toast-style alerts with 4 types (Info, Success, Warning, Error)
- 🎯 **7 UI Elements** - Toggle, Slider, Dropdown, Button, Input, Colorpicker, Keybind
- ⚡ **Smooth Animations** - TweenService-powered transitions
- 🌫️ **Blur Effect** - Optional background blur
- ⌨️ **Hotkey Support** - Customizable keybinds

## 📦 Installation

```lua
local Ssoly = loadstring(game:HttpGet("YOUR_URL_HERE"))()
```

## 🚀 Quick Start

```lua
-- Create window
local Window = Ssoly:CreateWindow({
    Title = "My Script",
    Size = UDim2.fromOffset(700, 500),
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Create tab
local Tab = Window:AddTab({
    Title = "Main",
    Icon = "⚡"
})

-- Add toggle
Tab:AddToggle({
    Title = "Feature",
    Default = false,
    Callback = function(Value)
        print("Toggled:", Value)
    end
})

-- Show notification
Window:Notify({
    Title = "Success!",
    Content = "Script loaded",
    Type = "Success",
    Duration = 3
})
```

## 📚 Documentation

### Window

```lua
local Window = Ssoly:CreateWindow({
    Title = "Window Title",              -- Window title
    Size = UDim2.fromOffset(700, 500),   -- Window size
    MinSize = Vector2.new(500, 400),     -- Minimum size
    MaxSize = Vector2.new(1200, 800),    -- Maximum size
    Position = UDim2.new(0.5, -350, 0.5, -250), -- Position
    Transparency = 0.1,                  -- Background transparency (0-1)
    BlurEnabled = true,                  -- Enable blur effect
    Draggable = true,                    -- Allow dragging
    Resizable = true,                    -- Allow resizing
    MinimizeKey = Enum.KeyCode.RightControl -- Minimize hotkey
})
```

### Tab

```lua
local Tab = Window:AddTab({
    Title = "Tab Name",
    Icon = "🔥"  -- Emoji or text icon
})
```

### Toggle

```lua
Tab:AddToggle({
    Title = "Toggle Name",
    Description = "Optional description",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})
```

### Slider

```lua
Tab:AddSlider({
    Title = "Slider Name",
    Description = "Optional description",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 0,  -- Decimal places
    Suffix = " units",
    Callback = function(Value)
        print(Value)
    end
})
```

### Dropdown

```lua
-- Single select
Tab:AddDropdown({
    Title = "Dropdown",
    Values = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(Value)
        print(Value)
    end
})

-- Multi select
Tab:AddDropdown({
    Title = "Multi Dropdown",
    Values = {"A", "B", "C"},
    Multi = true,
    Default = {["A"] = true, ["B"] = true},
    Callback = function(Value)
        for item, selected in pairs(Value) do
            print(item, selected)
        end
    end
})
```

### Button

```lua
Tab:AddButton({
    Title = "Button",
    Description = "Optional description",
    Callback = function()
        print("Clicked!")
    end
})
```

### Input

```lua
Tab:AddInput({
    Title = "Input",
    Description = "Optional description",
    Placeholder = "Enter text...",
    Default = "",
    Numeric = false,  -- Only allow numbers
    Callback = function(Value)
        print(Value)
    end
})
```

### Colorpicker

```lua
Tab:AddColorpicker({
    Title = "Color",
    Description = "Optional description",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        print(Color)
    end
})
```

### Keybind

```lua
Tab:AddKeybind({
    Title = "Keybind",
    Description = "Optional description",
    Default = Enum.KeyCode.E,
    Callback = function(Key)
        print("Pressed:", Key.Name)
    end
})
```

### Notifications

```lua
Window:Notify({
    Title = "Title",
    Content = "Message content",
    Type = "Info",  -- Info, Success, Warning, Error
    Duration = 3    -- Seconds
})
```

## 🎨 Customization

### Colors

Default theme colors:
- Background: `#1a1a1a`
- Border: `#2d2d2d`
- Accent: `#4a9eff`
- Success: `#50ff78`
- Warning: `#ffc850`
- Error: `#ff5050`

### Animations

All animations use TweenService with:
- Easing: `Quad` or `Back`
- Duration: 0.2-0.4 seconds

## 🔧 Advanced Usage

### Destroying UI

```lua
Window:Destroy()
```

### Accessing Elements

```lua
local toggle = Tab:AddToggle({...})
toggle:SetValue(true)  -- Programmatically set value
```

## 📝 Notes

- Uses Roblox Instance API (no Drawing dependency)
- Compatible with all major executors
- Optimized for performance
- Mobile-friendly (touch support)

## 🐛 Known Issues

- ESP Preview not yet implemented
- Config system in development
- Theme customization coming soon

## 📄 License

Free to use for personal projects.

## 👤 Author

Created by Sosalkin Hub.
