---@diagnostic disable: undefined-global
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
    self.Container.Size = UDim2.new(1, -30, 0, 85)
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
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Container
    
    -- Description (optional)
    local dropdownY = 50
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -24, 0, 14)
        self.DescLabel.Position = UDim2.fromOffset(12, 28)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 11
        self.DescLabel.Font = Enum.Font.Gotham
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
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
    self.DropdownButton.SelectionImageObject = nil
    self.DropdownButton.Parent = self.Container
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = self.DropdownButton
    
    -- Display text
    self.DisplayLabel = Instance.new("TextLabel")
    self.DisplayLabel.Name = "Display"
    self.DisplayLabel.Size = UDim2.new(1, -30, 1, 0)
    self.DisplayLabel.Position = UDim2.fromOffset(10, 0)
    self.DisplayLabel.BackgroundTransparency = 1
    self.DisplayLabel.Text = "--"
    self.DisplayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.DisplayLabel.TextSize = 11
    self.DisplayLabel.Font = Enum.Font.Gotham
    self.DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.DisplayLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.DisplayLabel.Parent = self.DropdownButton
    
    -- Arrow icon with animation
    self.ArrowIcon = Instance.new("TextLabel")
    self.ArrowIcon.Name = "Arrow"
    self.ArrowIcon.Size = UDim2.fromOffset(16, 16)
    self.ArrowIcon.Position = UDim2.new(1, -20, 0.5, -8)
    self.ArrowIcon.BackgroundTransparency = 1
    self.ArrowIcon.Text = "▼"
    self.ArrowIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.ArrowIcon.TextSize = 10
    self.ArrowIcon.Font = Enum.Font.GothamBold
    self.ArrowIcon.Parent = self.DropdownButton
    
    -- Hover animation for arrow
    self.DropdownButton.MouseEnter:Connect(function()
        TweenService:Create(self.ArrowIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    self.DropdownButton.MouseLeave:Connect(function()
        TweenService:Create(self.ArrowIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(150, 150, 150)
        }):Play()
    end)
    
    -- Options container (hidden by default) - positioned below button with ZIndex
    self.OptionsContainer = Instance.new("Frame")
    self.OptionsContainer.Name = "Options"
    self.OptionsContainer.Size = UDim2.new(1, -24, 0, 0)
    self.OptionsContainer.Position = UDim2.fromOffset(12, dropdownY + 35)
    self.OptionsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.OptionsContainer.BorderSizePixel = 0
    self.OptionsContainer.ClipsDescendants = true
    self.OptionsContainer.Visible = false
    self.OptionsContainer.ZIndex = 100
    self.OptionsContainer.Parent = self.Tab.Window.ScreenGui
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = self.OptionsContainer
    
    local OptionsStroke = Instance.new("UIStroke")
    OptionsStroke.Color = self.Tab.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    OptionsStroke.Thickness = 1
    OptionsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    OptionsStroke.Parent = self.OptionsContainer
    
    if self.Tab.Window.AccentElements then
        table.insert(self.Tab.Window.AccentElements, OptionsStroke)
    end
    
    -- Scrolling frame for options
    self.OptionsScroll = Instance.new("ScrollingFrame")
    self.OptionsScroll.Size = UDim2.new(1, 0, 1, 0)
    self.OptionsScroll.BackgroundTransparency = 1
    self.OptionsScroll.BorderSizePixel = 0
    self.OptionsScroll.ScrollBarThickness = 4
    self.OptionsScroll.ScrollBarImageColor3 = self.Tab.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    self.OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.OptionsScroll.Parent = self.OptionsContainer
    
    if self.Tab.Window.AccentElements then
        table.insert(self.Tab.Window.AccentElements, self.OptionsScroll)
    end
    
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
    
    -- Close on click outside
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Opened then
            local mousePos = input.Position
            local buttonPos = self.DropdownButton.AbsolutePosition
            local buttonSize = self.DropdownButton.AbsoluteSize
            local optionsPos = self.OptionsContainer.AbsolutePosition
            local optionsSize = self.OptionsContainer.AbsoluteSize
            
            -- Check if click is outside both button and options
            local inButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                           mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
            local inOptions = mousePos.X >= optionsPos.X and mousePos.X <= optionsPos.X + optionsSize.X and
                            mousePos.Y >= optionsPos.Y and mousePos.Y <= optionsPos.Y + optionsSize.Y
            
            if not inButton and not inOptions then
                self:Close()
            end
        end
    end)
    
    -- Hover effects
    self.DropdownButton.MouseEnter:Connect(function()
        TweenService:Create(self.DropdownButton, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    self.DropdownButton.MouseLeave:Connect(function()
        TweenService:Create(self.DropdownButton, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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
        optionButton.SelectionImageObject = nil
        optionButton.Parent = self.OptionsScroll
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 5)
        optionCorner.Parent = optionButton
        
        -- Checkmark (for multi-select)
        local checkmark = Instance.new("Frame")
        checkmark.Name = "Check"
        checkmark.Size = UDim2.fromOffset(18, 18)
        checkmark.Position = UDim2.fromOffset(7, 5)
        checkmark.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        checkmark.BackgroundTransparency = 0
        checkmark.BorderSizePixel = 0
        checkmark.Parent = optionButton
        
        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 4)
        checkCorner.Parent = checkmark
        
        local checkStroke = Instance.new("UIStroke")
        checkStroke.Color = Color3.fromRGB(70, 70, 70)
        checkStroke.Thickness = 1.5
        checkStroke.Parent = checkmark
        
        -- Checkmark icon
        local checkIcon = Instance.new("TextLabel")
        checkIcon.Name = "Icon"
        checkIcon.Size = UDim2.new(1, 0, 1, 0)
        checkIcon.BackgroundTransparency = 1
        checkIcon.Text = ""
        checkIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkIcon.TextSize = 14
        checkIcon.Font = Enum.Font.GothamBold
        checkIcon.Parent = checkmark
        
        if not self.Multi then
            checkmark.Visible = false
        end
        
        -- Option text
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Name = "Label"
        optionLabel.Size = UDim2.new(1, self.Multi and -36 or -16, 1, 0)
        optionLabel.Position = UDim2.fromOffset(self.Multi and 32 or 8, 0)
        optionLabel.BackgroundTransparency = 1
        optionLabel.Text = value
        optionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        optionLabel.TextSize = 11
        optionLabel.Font = Enum.Font.Gotham
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
            TweenService:Create(optionButton, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.5
            }):Play()
        end)
        
        self.OptionButtons[value] = {Button = optionButton, Check = checkmark, CheckIcon = checkIcon, Label = optionLabel}
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
    
    local optionCount = math.min(#self.Values, 6)
    local targetHeight = (optionCount * 30) + 10
    
    -- Update position on every frame while open
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end
    
    local openUpwards = false
    
    local function updatePosition()
        if not self.Opened then return end
        local buttonPos = self.DropdownButton.AbsolutePosition
        local buttonSize = self.DropdownButton.AbsoluteSize
        
        -- Проверяем, чтобы дропдаун не вылезал за границы контейнера
        local containerPos = self.Tab.Window.ContentContainer.AbsolutePosition
        local containerSize = self.Tab.Window.ContentContainer.AbsoluteSize
        local containerBottom = containerPos.Y + containerSize.Y
        local containerTop = containerPos.Y
        
        local dropdownBottom = buttonPos.Y + buttonSize.Y + 5 + targetHeight
        local dropdownTop = buttonPos.Y - 5 - targetHeight
        local maxHeight = targetHeight
        
        -- Определяем, открывать вверх или вниз
        local spaceBelow = containerBottom - (buttonPos.Y + buttonSize.Y + 5)
        local spaceAbove = buttonPos.Y - containerTop - 5
        
        if spaceBelow < targetHeight and spaceAbove > spaceBelow then
            -- Открываем вверх
            openUpwards = true
            if spaceAbove < targetHeight then
                maxHeight = math.max(60, spaceAbove - 10)
            end
            self.OptionsContainer.AnchorPoint = Vector2.new(0, 1)
            self.OptionsContainer.Position = UDim2.fromOffset(
                buttonPos.X,
                buttonPos.Y - 5
            )
        else
            -- Открываем вниз
            openUpwards = false
            if dropdownBottom > containerBottom then
                maxHeight = math.max(60, spaceBelow - 10)
            end
            self.OptionsContainer.AnchorPoint = Vector2.new(0, 0)
            self.OptionsContainer.Position = UDim2.fromOffset(
                buttonPos.X,
                buttonPos.Y + buttonSize.Y + 5
            )
        end
        
        self.OptionsContainer.Size = UDim2.new(0, buttonSize.X, 0, self.OptionsContainer.AbsoluteSize.Y)
        
        -- Обновляем максимальную высоту
        if self.OptionsContainer.AbsoluteSize.Y > maxHeight then
            self.OptionsContainer.Size = UDim2.new(0, buttonSize.X, 0, maxHeight)
        end
    end
    
    self.UpdateConnection = game:GetService("RunService").RenderStepped:Connect(updatePosition)
    
    -- Initial position
    local buttonPos = self.DropdownButton.AbsolutePosition
    local buttonSize = self.DropdownButton.AbsoluteSize
    
    -- Проверяем максимальную высоту
    local containerPos = self.Tab.Window.ContentContainer.AbsolutePosition
    local containerSize = self.Tab.Window.ContentContainer.AbsoluteSize
    local containerBottom = containerPos.Y + containerSize.Y
    local containerTop = containerPos.Y
    
    local spaceBelow = containerBottom - (buttonPos.Y + buttonSize.Y + 5)
    local spaceAbove = buttonPos.Y - containerTop - 5
    
    if spaceBelow < targetHeight and spaceAbove > spaceBelow then
        openUpwards = true
        if spaceAbove < targetHeight then
            targetHeight = math.max(60, spaceAbove - 10)
        end
        self.OptionsContainer.Position = UDim2.fromOffset(
            buttonPos.X,
            buttonPos.Y - 5
        )
    else
        openUpwards = false
        if spaceBelow < targetHeight then
            targetHeight = math.max(60, spaceBelow - 10)
        end
        self.OptionsContainer.Position = UDim2.fromOffset(
            buttonPos.X,
            buttonPos.Y + buttonSize.Y + 5
        )
    end
    
    self.OptionsContainer.Size = UDim2.new(0, buttonSize.X, 0, 0)
    self.OptionsContainer.Visible = true
    
    -- Expand options with smooth animation
    if openUpwards then
        -- Начинаем снизу кнопки (на уровне верха кнопки) и растем вверх
        self.OptionsContainer.Position = UDim2.fromOffset(buttonPos.X, buttonPos.Y)
        self.OptionsContainer.AnchorPoint = Vector2.new(0, 1)
        TweenService:Create(self.OptionsContainer, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, buttonSize.X, 0, targetHeight),
            Position = UDim2.fromOffset(buttonPos.X, buttonPos.Y - 5)
        }):Play()
    else
        -- Обычное открытие вниз
        self.OptionsContainer.AnchorPoint = Vector2.new(0, 0)
        TweenService:Create(self.OptionsContainer, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, buttonSize.X, 0, targetHeight)
        }):Play()
    end
    
    -- Rotate arrow with bounce effect
    TweenService:Create(self.ArrowIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Rotation = openUpwards and -180 or 180,
        TextColor3 = self.Tab.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    }):Play()
end

function Dropdown:Close()
    self.Opened = false
    
    -- Disconnect update
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end
    
    -- Close options with smooth animation
    TweenService:Create(self.OptionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, self.DropdownButton.AbsoluteSize.X, 0, 0)
    }):Play()
    
    -- Rotate arrow back with bounce effect
    TweenService:Create(self.ArrowIcon, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Rotation = 0,
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    task.delay(0.3, function()
        self.OptionsContainer.Visible = false
    end)
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
    
    local accentColor = self.Tab.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    
    local option = self.OptionButtons[value]
    if option then
        if self.Value[value] then
            -- Smooth color transition and scale animation
            TweenService:Create(option.Check, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = accentColor
            }):Play()
            TweenService:Create(option.Check:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Color = accentColor
            }):Play()
            
            -- Checkmark appears with scale animation
            option.CheckIcon.TextTransparency = 1
            option.CheckIcon.Text = "✓"
            TweenService:Create(option.CheckIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0
            }):Play()
        else
            -- Smooth color transition back
            TweenService:Create(option.Check, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            }):Play()
            TweenService:Create(option.Check:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Color = Color3.fromRGB(70, 70, 70)
            }):Play()
            
            -- Checkmark disappears with fade
            TweenService:Create(option.CheckIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 1
            }):Play()
            task.delay(0.25, function()
                option.CheckIcon.Text = ""
            end)
        end
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
                table.insert(selected, tostring(value))
            end
        end
        
        if #selected == 0 then
            self.DisplayLabel.Text = "--"
        elseif #selected == 1 then
            self.DisplayLabel.Text = selected[1]
        else
            self.DisplayLabel.Text = selected[1] .. " (+" .. (#selected - 1) .. ")"
        end
        
        local accentColor = self.Tab.Window.AccentColor or Color3.fromRGB(74, 158, 255)
        
        -- Update checkmarks with animations
        for value, option in pairs(self.OptionButtons) do
            if self.Value[value] then
                TweenService:Create(option.Check, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = accentColor
                }):Play()
                TweenService:Create(option.Check:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Color = accentColor
                }):Play()
                option.CheckIcon.Text = "✓"
                option.CheckIcon.TextTransparency = 0
            else
                TweenService:Create(option.Check, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                }):Play()
                TweenService:Create(option.Check:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Color = Color3.fromRGB(70, 70, 70)
                }):Play()
                option.CheckIcon.Text = ""
                option.CheckIcon.TextTransparency = 1
            end
        end
    else
        self.DisplayLabel.Text = self.Value and tostring(self.Value) or "--"
    end
end

return Dropdown
