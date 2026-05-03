---@diagnostic disable: undefined-global
-- Ssoly UI Library - Section Class
-- Handles sections within tabs (left/right columns)

local Section = {}
Section.__index = Section

function Section.new(tab, side)
    local self = setmetatable({}, Section)
    
    self.Tab = tab
    self.Side = side or "Left"
    self.Elements = {}
    
    self:CreateContainer()
    
    return self
end

function Section:CreateContainer()
    -- Section container
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Name = self.Side .. "Section"
    self.Container.Size = UDim2.new(0.5, -7.5, 1, 0)
    self.Container.Position = self.Side == "Left" and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 7.5, 0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.ScrollBarThickness = 4
    self.Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Container.Visible = false
    self.Container.Parent = tab.ContentContainer
    
    -- Layout
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = self.Container
    
    -- Auto-update canvas size based on content
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end)
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.Parent = self.Container
end

-- Element creation methods
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

function Section:AddToggle(config)
    local Toggle = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
    local toggle = Toggle.new(self, config)
    toggle.Container.Visible = false
    table.insert(self.Elements, toggle.Container)
    table.insert(self.Tab.Elements, toggle.Container)
    return toggle
end

function Section:AddSlider(config)
    local Slider = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
    local slider = Slider.new(self, config)
    slider.Container.Visible = false
    table.insert(self.Elements, slider.Container)
    table.insert(self.Tab.Elements, slider.Container)
    return slider
end

function Section:AddDropdown(config)
    local Dropdown = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
    local dropdown = Dropdown.new(self, config)
    dropdown.Container.Visible = false
    table.insert(self.Elements, dropdown.Container)
    table.insert(self.Tab.Elements, dropdown.Container)
    return dropdown
end

function Section:AddButton(config)
    local Button = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
    local button = Button.new(self, config)
    button.Container.Visible = false
    table.insert(self.Elements, button.Container)
    table.insert(self.Tab.Elements, button.Container)
    return button
end

function Section:AddInput(config)
    local Input = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
    local input = Input.new(self, config)
    input.Container.Visible = false
    table.insert(self.Elements, input.Container)
    table.insert(self.Tab.Elements, input.Container)
    return input
end

function Section:AddColorpicker(config)
    local Colorpicker = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
    local colorpicker = Colorpicker.new(self, config)
    colorpicker.Container.Visible = false
    table.insert(self.Elements, colorpicker.Container)
    table.insert(self.Tab.Elements, colorpicker.Container)
    return colorpicker
end

function Section:AddKeybind(config)
    local Keybind = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()
    local keybind = Keybind.new(self, config)
    keybind.Container.Visible = false
    table.insert(self.Elements, keybind.Container)
    table.insert(self.Tab.Elements, keybind.Container)
    return keybind
end

return Section
