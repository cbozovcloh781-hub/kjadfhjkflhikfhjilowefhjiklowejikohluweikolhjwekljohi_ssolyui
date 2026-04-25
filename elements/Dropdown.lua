-- Ssoly UI Library - Dropdown Element
-- Single and multi-select dropdown with search

local TweenService = game:GetService("TweenService")

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(tab, config)
    local self = setmetatable({}, Dropdown)
    
    self.Tab = tab
    self.Title = config.Title or "Dropdown"
    self.Description = config.Description
    self.Values = config.Values or {}
    self.Multi = config.Multi or false
    self.Default = config.Default or (self.Multi and {} or nil)
    self.Callback = config.Callback or function() end
    self.Value = self.Multi and {} or nil
    self.Opened = false
    self.OptionButtons = {}
    
    self:CreateElement()
    
    -- Set default value
    if self.Default then
        if self.Multi then
            for _, v in pairs(self.Default) do
                self.Value[v] = true
            end
        else
            self.Value = self.Default
        end
        self:UpdateDisplay()
    end
    
    return self
end

function Dropdown:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Dropdown"
    self.Container.Size = UDim2.new(1, -20, 0, self.Description and 70 or 55)
    self.Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = false
    self.Container.ZIndex = 1
    self.Container.Parent = self.Tab.Window.ContentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(12, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Container
    
    -- Description (optional)
    local dropdownY = 32
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -20, 0, 15)
        self.DescLabel.Position = UDim2.fromOffset(12, 32)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 11
        self.DescLabel.Font = Enum.Font.SourceSans
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
        dropdownY = 50
    end
    
    -- Dropdown button
    self.DropdownButton = Instance.new("TextButton")
    self.DropdownButton.Name = "Button"
    self.DropdownButton.Size = UDim2.new(1, -24, 0, 30)
    self.DropdownButton.Position = UDim2.fromOffset(12, dropdownY)
    self.DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.DropdownButton.BackgroundTransparency = 0.3
    self.DropdownButton.BorderSizePixel = 0
    self.DropdownButton.Text = ""
    self.DropdownButton.AutoButtonColor = false
    self.DropdownButton.Parent = self.Container
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = self.DropdownButton
    
    -- Display text
    self.DisplayLabel = Instance.new("TextLabel")
    self.DisplayLabel.Name = "Display"
    self.DisplayLabel.Size = UDim2.new(1, -35, 1, 0)
    self.DisplayLabel.Position = UDim2.fromOffset(10, 0)
    self.DisplayLabel.BackgroundTransparency = 1
    self.DisplayLabel.Text = self.Multi and "None" or "Select..."
    self.DisplayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.DisplayLabel.TextSize = 13
    self.DisplayLabel.Font = Enum.Font.SourceSans
    self.DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.DisplayLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.DisplayLabel.Parent = self.DropdownButton
    
    -- Arrow icon
    self.ArrowIcon = Instance.new("TextLabel")
    self.ArrowIcon.Name = "Arrow"
    self.ArrowIcon.Size = UDim2.fromOffset(20, 20)
    self.ArrowIcon.Position = UDim2.new(1, -25, 0.5, -10)
    self.ArrowIcon.BackgroundTransparency = 1
    self.ArrowIcon.Text = "▼"
    self.ArrowIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.ArrowIcon.TextSize = 12
    self.ArrowIcon.Font = Enum.Font.SourceSansBold
    self.ArrowIcon.Parent = self.DropdownButton
    
    -- Options container (hidden by default)
    self.OptionsContainer = Instance.new("Frame")
    self.OptionsContainer.Name = "Options"
    self.OptionsContainer.Size = UDim2.new(1, -24, 0, 0)
    self.OptionsContainer.Position = UDim2.fromOffset(12, dropdownY + 35)
    self.OptionsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.OptionsContainer.BorderSizePixel = 0
    self.OptionsContainer.ClipsDescendants = true
    self.OptionsContainer.Visible = false
    self.OptionsContainer.ZIndex = 10
    self.OptionsContainer.Parent = self.Container
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = self.OptionsContainer
    
    local OptionsStroke = Instance.new("UIStroke")
    OptionsStroke.Color = Color3.fromRGB(74, 158, 255)
    OptionsStroke.Thickness = 1
    OptionsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    OptionsStroke.Parent = self.OptionsContainer
    
    -- Scrolling frame for options
    self.OptionsScroll = Instance.new("ScrollingFrame")
    self.OptionsScroll.Size = UDim2.new(1, 0, 1, 0)
    self.OptionsScroll.BackgroundTransparency = 1
    self.OptionsScroll.BorderSizePixel = 0
    self.OptionsScroll.ScrollBarThickness = 4
    self.OptionsScroll.ScrollBarImageColor3 = Color3.fromRGB(74, 158, 255)
    self.OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.OptionsScroll.Parent = self.OptionsContainer
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Padding = UDim.new(0, 2)
    OptionsLayout.Parent = self.OptionsScroll
    
    local OptionsPadding = Instance.new("UIPadding")
    OptionsPadding.PaddingTop = UDim.new(0, 5)
    OptionsPadding.PaddingBottom = UDim.new(0, 5)
    OptionsPadding.PaddingLeft = UDim.new(0, 5)
    OptionsPadding.PaddingRight = UDim.new(0, 5)
    OptionsPadding.Parent = self.OptionsScroll
    
    -- Create option buttons
    self:CreateOptions()
    
    -- Update canvas size
    OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Toggle dropdown
    self.DropdownButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover effects
    self.DropdownButton.MouseEnter:Connect(function()
        TweenService:Create(self.DropdownButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    self.DropdownButton.MouseLeave:Connect(function()
        TweenService:Create(self.DropdownButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
end

function Dropdown:CreateOptions()
    for _, value in ipairs(self.Values) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = value
        optionButton.Size = UDim2.new(1, -10, 0, 28)
        optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        optionButton.BackgroundTransparency = 0.5
        optionButton.BorderSizePixel = 0
        optionButton.Text = ""
        optionButton.AutoButtonColor = false
        optionButton.Parent = self.OptionsScroll
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 5)
        optionCorner.Parent = optionButton
        
        -- Checkmark (for multi-select)
        local checkmark = Instance.new("TextLabel")
        checkmark.Name = "Check"
        checkmark.Size = UDim2.fromOffset(20, 20)
        checkmark.Position = UDim2.fromOffset(5, 4)
        checkmark.BackgroundTransparency = 1
        checkmark.Text = self.Multi and "☐" or ""
        checkmark.TextColor3 = Color3.fromRGB(150, 150, 150)
        checkmark.TextSize = 16
        checkmark.Font = Enum.Font.SourceSansBold
        checkmark.Parent = optionButton
        
        -- Option text
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Name = "Label"
        optionLabel.Size = UDim2.new(1, self.Multi and -35 or -10, 1, 0)
        optionLabel.Position = UDim2.fromOffset(self.Multi and 30 or 8, 0)
        optionLabel.BackgroundTransparency = 1
        optionLabel.Text = value
        optionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        optionLabel.TextSize = 12
        optionLabel.Font = Enum.Font.SourceSans
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
        optionLabel.Parent = optionButton
        
        -- Click handler
        optionButton.MouseButton1Click:Connect(function()
            if self.Multi then
                self:ToggleValue(value)
            else
                self:SetValue(value)
                self:Close()
            end
        end)
        
        -- Hover effects
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.5
            }):Play()
        end)
        
        self.OptionButtons[value] = {Button = optionButton, Check = checkmark, Label = optionLabel}
    end
end

function Dropdown:Toggle()
    if self.Opened then
        self:Close()
    else
        self:Open()
    end
end

function Dropdown:Open()
    self.Opened = true
    
    local optionCount = math.min(#self.Values, 5)
    local targetHeight = (optionCount * 30) + 10
    
    self.OptionsContainer.Visible = true
    
    TweenService:Create(self.OptionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, -24, 0, targetHeight)
    }):Play()
    
    TweenService:Create(self.ArrowIcon, TweenInfo.new(0.3), {
        Rotation = 180
    }):Play()
    
    -- Expand container
    local newHeight = (self.Description and 70 or 55) + targetHeight + 5
    TweenService:Create(self.Container, TweenInfo.new(0.3), {
        Size = UDim2.new(1, -20, 0, newHeight)
    }):Play()
end

function Dropdown:Close()
    self.Opened = false
    
    TweenService:Create(self.OptionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(1, -24, 0, 0)
    }):Play()
    
    TweenService:Create(self.ArrowIcon, TweenInfo.new(0.3), {
        Rotation = 0
    }):Play()
    
    task.delay(0.3, function()
        self.OptionsContainer.Visible = false
    end)
    
    -- Shrink container
    local newHeight = self.Description and 70 or 55
    TweenService:Create(self.Container, TweenInfo.new(0.3), {
        Size = UDim2.new(1, -20, 0, newHeight)
    }):Play()
end

function Dropdown:SetValue(value, silent)
    if self.Multi then
        self.Value = value
    else
        self.Value = value
    end
    
    self:UpdateDisplay()
    
    if not silent then
        task.spawn(function()
            self.Callback(self.Value)
        end)
    end
end

function Dropdown:ToggleValue(value)
    if not self.Multi then return end
    
    self.Value[value] = not self.Value[value] or nil
    
    local option = self.OptionButtons[value]
    if option then
        option.Check.Text = self.Value[value] and "☑" or "☐"
        option.Check.TextColor3 = self.Value[value] and Color3.fromRGB(74, 158, 255) or Color3.fromRGB(150, 150, 150)
    end
    
    self:UpdateDisplay()
    
    task.spawn(function()
        self.Callback(self.Value)
    end)
end

function Dropdown:UpdateDisplay()
    if self.Multi then
        local selected = {}
        for value, enabled in pairs(self.Value) do
            if enabled then
                table.insert(selected, value)
            end
        end
        
        if #selected == 0 then
            self.DisplayLabel.Text = "None"
        elseif #selected == 1 then
            self.DisplayLabel.Text = selected[1]
        else
            self.DisplayLabel.Text = selected[1] .. " (+" .. (#selected - 1) .. ")"
        end
        
        -- Update checkmarks
        for value, option in pairs(self.OptionButtons) do
            option.Check.Text = self.Value[value] and "☑" or "☐"
            option.Check.TextColor3 = self.Value[value] and Color3.fromRGB(74, 158, 255) or Color3.fromRGB(150, 150, 150)
        end
    else
        self.DisplayLabel.Text = self.Value or "Select..."
    end
end

return Dropdown
