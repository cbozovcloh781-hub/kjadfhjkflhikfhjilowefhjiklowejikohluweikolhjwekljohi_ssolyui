---@diagnostic disable: undefined-global
-- Ssoly UI Library - Collapsible Section Element
-- Expandable section for grouping elements

local TweenService = game:GetService("TweenService")

local CollapsibleSection = {}
CollapsibleSection.__index = CollapsibleSection

function CollapsibleSection.new(tab, config)
    local self = setmetatable({}, CollapsibleSection)
    
    if tab.Tab then
        self.Tab = tab.Tab
        self.Window = tab.Window
        self.ParentContainer = tab.Container
    else
        self.Tab = tab
        self.Window = tab.Window
        self.ParentContainer = tab.Window.ContentContainer
    end
    
    self.Title = config.Title or "Section"
    self.Expanded = config.Expanded ~= false
    self.Elements = {}
    
    self:CreateElement()
    
    return self
end

function CollapsibleSection:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "CollapsibleSection"
    self.Container.Size = UDim2.new(1, -30, 0, 40)
    self.Container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = false
    self.Container.Parent = self.ParentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = self.Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Transparency = 0.5
    Stroke.Parent = self.Container
    
    -- Header button
    self.HeaderButton = Instance.new("TextButton")
    self.HeaderButton.Name = "Header"
    self.HeaderButton.Size = UDim2.new(1, 0, 0, 40)
    self.HeaderButton.BackgroundTransparency = 1
    self.HeaderButton.Text = ""
    self.HeaderButton.AutoButtonColor = false
    self.HeaderButton.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(15, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.HeaderButton
    
    -- Arrow icon
    self.ArrowIcon = Instance.new("TextLabel")
    self.ArrowIcon.Name = "Arrow"
    self.ArrowIcon.Size = UDim2.fromOffset(14, 14)
    self.ArrowIcon.Position = UDim2.new(1, -25, 0.5, -7)
    self.ArrowIcon.BackgroundTransparency = 1
    self.ArrowIcon.Text = "▼"
    self.ArrowIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.ArrowIcon.TextSize = 10
    self.ArrowIcon.Font = Enum.Font.GothamBold
    self.ArrowIcon.Rotation = self.Expanded and 0 or -90
    self.ArrowIcon.Parent = self.HeaderButton
    
    -- Content container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "Content"
    self.ContentContainer.Size = UDim2.new(1, 0, 0, 0)
    self.ContentContainer.Position = UDim2.fromOffset(0, 40)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.ClipsDescendants = true
    self.ContentContainer.Visible = self.Expanded
    self.ContentContainer.Parent = self.Container
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = self.ContentContainer
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 8)
    ContentPadding.PaddingBottom = UDim.new(0, 8)
    ContentPadding.Parent = self.ContentContainer
    
    -- Update container size when content changes
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if self.Expanded then
            local contentHeight = ContentLayout.AbsoluteContentSize.Y + 16
            self.ContentContainer.Size = UDim2.new(1, 0, 0, contentHeight)
            self.Container.Size = UDim2.new(1, -30, 0, 40 + contentHeight)
        end
    end)
    
    -- Toggle on click
    self.HeaderButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover effects
    self.HeaderButton.MouseEnter:Connect(function()
        TweenService:Create(self.ArrowIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextColor3 = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
        }):Play()
    end)
    
    self.HeaderButton.MouseLeave:Connect(function()
        TweenService:Create(self.ArrowIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextColor3 = Color3.fromRGB(150, 150, 150)
        }):Play()
    end)
end

function CollapsibleSection:Toggle()
    self.Expanded = not self.Expanded
    
    if self.Expanded then
        self.ContentContainer.Visible = true
        local contentHeight = self.ContentContainer:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 16
        
        TweenService:Create(self.ContentContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 0, contentHeight)
        }):Play()
        
        TweenService:Create(self.Container, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, -30, 0, 40 + contentHeight)
        }):Play()
        
        TweenService:Create(self.ArrowIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Rotation = 0
        }):Play()
    else
        TweenService:Create(self.ContentContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        
        TweenService:Create(self.Container, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, -30, 0, 40)
        }):Play()
        
        TweenService:Create(self.ArrowIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Rotation = -90
        }):Play()
        
        task.delay(0.4, function()
            if not self.Expanded then
                self.ContentContainer.Visible = false
            end
        end)
    end
end

function CollapsibleSection:AddToggle(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Toggle = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
    local toggle = Toggle.new({Tab = self.Tab, Window = self.Window, Container = self.ContentContainer}, config)
    table.insert(self.Elements, toggle)
    return toggle
end

function CollapsibleSection:AddDropdown(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Dropdown = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
    local dropdown = Dropdown.new({Tab = self.Tab, Window = self.Window, Container = self.ContentContainer}, config)
    table.insert(self.Elements, dropdown)
    return dropdown
end

function CollapsibleSection:AddButton(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Button = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
    local button = Button.new({Tab = self.Tab, Window = self.Window, Container = self.ContentContainer}, config)
    table.insert(self.Elements, button)
    return button
end

function CollapsibleSection:AddSlider(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Slider = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
    local slider = Slider.new({Tab = self.Tab, Window = self.Window, Container = self.ContentContainer}, config)
    table.insert(self.Elements, slider)
    return slider
end

function CollapsibleSection:AddInput(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Input = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
    local input = Input.new({Tab = self.Tab, Window = self.Window, Container = self.ContentContainer}, config)
    table.insert(self.Elements, input)
    return input
end

function CollapsibleSection:AddKeybind(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Keybind = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()
    local keybind = Keybind.new({Tab = self.Tab, Window = self.Window, Container = self.ContentContainer}, config)
    table.insert(self.Elements, keybind)
    return keybind
end

function CollapsibleSection:AddColorpicker(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Colorpicker = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
    local colorpicker = Colorpicker.new({Tab = self.Tab, Window = self.Window, Container = self.ContentContainer}, config)
    table.insert(self.Elements, colorpicker)
    return colorpicker
end

return CollapsibleSection
