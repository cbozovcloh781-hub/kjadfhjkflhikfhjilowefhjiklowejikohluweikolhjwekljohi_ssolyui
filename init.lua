-- Ssoly UI Library v1.0
-- Modern minimalist UI library for Roblox exploits
-- Created for YBA Enhanced Script

local Ssoly = {}

-- Load core modules
Ssoly.Window = require(script.core.Window)
Ssoly.Tab = require(script.core.Tab)

-- Load elements
Ssoly.Elements = {
    Toggle = require(script.elements.Toggle),
    Slider = require(script.elements.Slider),
    Dropdown = require(script.elements.Dropdown),
    Button = require(script.elements.Button),
    Input = require(script.elements.Input),
    Colorpicker = require(script.elements.Colorpicker),
    Keybind = require(script.elements.Keybind),
}

-- Create window
function Ssoly:CreateWindow(config)
    return self.Window.new(config)
end

-- Version info
Ssoly.Version = "1.0.0"
Ssoly.Author = "Sosalkin hub"

return Ssoly
