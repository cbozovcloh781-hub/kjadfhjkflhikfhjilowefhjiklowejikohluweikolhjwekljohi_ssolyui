-- Ssoly UI Library - Tab Class
-- Handles individual tabs and their content

local TweenService = game:GetService("TweenService")

local Tab = {}
Tab.__index = Tab

function Tab.new(window, config)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Title = config.Title or "Tab"
    self.Icon = config.Icon or "📄"
    self.Elements = {}
    self.Selected = false
    
    self:CreateButton()
    
    return self
end

function Tab:CreateButton()
    -- Tab button
    self.Button = Instance.new("TextButton")
    self.Button.Name = self.Title
    self.Button.Size = UDim2.new(1, 0, 0, 40)
    self.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.Button.BackgroundTransparency = 0.3
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.Parent = self.Window.TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Button
    
    -- Icon
    self.IconLabel = Instance.new("TextLabel")
    self.IconLabel.Name = "Icon"
    self.IconLabel.Size = UDim2.fromOffset(30, 30)
    self.IconLabel.Position = UDim2.fromOffset(10, 5)
    self.IconLabel.BackgroundTransparency = 1
    self.IconLabel.Text = self.Icon
    self.IconLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.IconLabel.TextSize = 18
    self.IconLabel.Font = Enum.Font.GothamBold
    self.IconLabel.Parent = self.Button
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(45, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Button
    
    -- Selection indicator
    self.Indicator = Instance.new("Frame")
    self.Indicator.Name = "Indicator"
    self.Indicator.Size = UDim2.new(0, 3, 0, 0)
    self.Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    self.Indicator.AnchorPoint = Vector2.new(0, 0.5)
    self.Indicator.BackgroundColor3 = Color3.fromRGB(74, 158, 255)
    self.Indicator.BorderSizePixel = 0
    self.Indicator.Parent = self.Button
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = self.Indicator
    
    -- Click handler
    self.Button.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)
    
    -- Hover effects
    self.Button.MouseEnter:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
        end
    end)
end

function Tab:Select()
    self.Selected = true
    
    -- Animate selection
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(74, 158, 255),
        BackgroundTransparency = 0.8
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 3, 0, 30)
    }):Play()
    
    -- Show elements
    for _, element in pairs(self.Elements) do
        element.Visible = true
    end
end

function Tab:Deselect()
    self.Selected = false
    
    -- Animate deselection
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BackgroundTransparency = 0.3
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 3, 0, 0)
    }):Play()
    
    -- Hide elements
    for _, element in pairs(self.Elements) do
        element.Visible = false
    end
end

-- Element creation methods
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

function Tab:AddToggle(config)
    local Toggle = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
    local toggle = Toggle.new(self, config)
    table.insert(self.Elements, toggle.Container)
    return toggle
end

function Tab:AddSlider(config)
    local Slider = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
    local slider = Slider.new(self, config)
    table.insert(self.Elements, slider.Container)
    return slider
end

function Tab:AddDropdown(config)
    local Dropdown = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
    local dropdown = Dropdown.new(self, config)
    table.insert(self.Elements, dropdown.Container)
    return dropdown
end

function Tab:AddButton(config)
    local Button = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
    local button = Button.new(self, config)
    table.insert(self.Elements, button.Container)
    return button
end

function Tab:AddInput(config)
    local Input = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
    local input = Input.new(self, config)
    table.insert(self.Elements, input.Container)
    return input
end

function Tab:AddColorpicker(config)
    local Colorpicker = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
    local colorpicker = Colorpicker.new(self, config)
    table.insert(self.Elements, colorpicker.Container)
    return colorpicker
end

function Tab:AddKeybind(config)
    local Keybind = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()
    local keybind = Keybind.new(self, config)
    table.insert(self.Elements, keybind.Container)
    return keybind
end

return Tab
