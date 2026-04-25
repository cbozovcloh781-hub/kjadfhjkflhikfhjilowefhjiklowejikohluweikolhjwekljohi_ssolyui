-- Ssoly UI Library v1.0
-- Modern minimalist UI library for Roblox exploits
-- Created for YBA Enhanced Script

local Ssoly = {}
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

-- Load core modules
Ssoly.Window = loadstring(game:HttpGet(baseUrl .. "core/Window.lua"))()
Ssoly.Tab = loadstring(game:HttpGet(baseUrl .. "core/Tab.lua"))()

-- Load elements
Ssoly.Elements = {
    Toggle = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))(),
    Slider = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))(),
    Dropdown = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))(),
    Button = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))(),
    Input = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))(),
    Colorpicker = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))(),
    Keybind = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))(),
}

-- Create window
function Ssoly:CreateWindow(config)
    return self.Window.new(config)
end

-- Version info
Ssoly.Version = "1.0.0"
Ssoly.Author = "Sosalkin hub"

return Ssoly
