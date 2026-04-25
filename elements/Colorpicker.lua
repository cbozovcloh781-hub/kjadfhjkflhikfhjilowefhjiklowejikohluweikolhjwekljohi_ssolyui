-- Ssoly UI Library - Colorpicker Element
-- Advanced color picker with HSV palette

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Colorpicker = {}
Colorpicker.__index = Colorpicker

function Colorpicker.new(tab, config)
    local self = setmetatable({}, Colorpicker)
    
    self.Tab = tab
    self.Title = config.Title or "Color"
    self.Description = config.Description
    self.Default = config.Default or Color3.fromRGB(255, 255, 255)
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    self.Opened = false
    
    self:CreateElement()
    self:SetValue(self.Default, true)
    
    return self
end

function Colorpicker:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Colorpicker"
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
    self.TitleLabel.Size = UDim2.new(1, -70, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(12, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Container
    
    -- Color preview button
    self.ColorButton = Instance.new("TextButton")
    self.ColorButton.Name = "ColorButton"
    self.ColorButton.Size = UDim2.fromOffset(40, 25)
    self.ColorButton.Position = UDim2.new(1, -50, 0, 8)
    self.ColorButton.BackgroundColor3 = self.Default
    self.ColorButton.BorderSizePixel = 0
    self.ColorButton.Text = ""
    self.ColorButton.AutoButtonColor = false
    self.ColorButton.Parent = self.Container
    
    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 6)
    ColorCorner.Parent = self.ColorButton
    
    local ColorStroke = Instance.new("UIStroke")
    ColorStroke.Color = Color3.fromRGB(255, 255, 255)
    ColorStroke.Thickness = 2
    ColorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ColorStroke.Parent = self.ColorButton
    
    -- Description (optional)
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -70, 0, 15)
        self.DescLabel.Position = UDim2.fromOffset(12, 32)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 11
        self.DescLabel.Font = Enum.Font.Gotham
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    -- Picker container (hidden by default)
    self.PickerContainer = Instance.new("Frame")
    self.PickerContainer.Name = "Picker"
    self.PickerContainer.Size = UDim2.new(1, -24, 0, 0)
    self.PickerContainer.Position = UDim2.fromOffset(12, self.Description and 70 or 55)
    self.PickerContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.PickerContainer.BorderSizePixel = 0
    self.PickerContainer.ClipsDescendants = true
    self.PickerContainer.Visible = false
    self.PickerContainer.ZIndex = 10
    self.PickerContainer.Parent = self.Container
    
    local PickerCorner = Instance.new("UICorner")
    PickerCorner.CornerRadius = UDim.new(0, 6)
    PickerCorner.Parent = self.PickerContainer
    
    local PickerStroke = Instance.new("UIStroke")
    PickerStroke.Color = Color3.fromRGB(74, 158, 255)
    PickerStroke.Thickness = 1
    PickerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    PickerStroke.Parent = self.PickerContainer
    
    -- HSV Palette
    self.Palette = Instance.new("ImageButton")
    self.Palette.Name = "Palette"
    self.Palette.Size = UDim2.new(1, -70, 0, 150)
    self.Palette.Position = UDim2.fromOffset(10, 10)
    self.Palette.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Palette.BorderSizePixel = 0
    self.Palette.Image = "rbxassetid://4155801252"
    self.Palette.AutoButtonColor = false
    self.Palette.Parent = self.PickerContainer
    
    local PaletteCorner = Instance.new("UICorner")
    PaletteCorner.CornerRadius = UDim.new(0, 6)
    PaletteCorner.Parent = self.Palette
    
    -- Palette cursor
    self.PaletteCursor = Instance.new("Frame")
    self.PaletteCursor.Name = "Cursor"
    self.PaletteCursor.Size = UDim2.fromOffset(12, 12)
    self.PaletteCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    self.PaletteCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.PaletteCursor.BorderSizePixel = 0
    self.PaletteCursor.Parent = self.Palette
    
    local CursorCorner = Instance.new("UICorner")
    CursorCorner.CornerRadius = UDim.new(1, 0)
    CursorCorner.Parent = self.PaletteCursor
    
    local CursorStroke = Instance.new("UIStroke")
    CursorStroke.Color = Color3.fromRGB(0, 0, 0)
    CursorStroke.Thickness = 2
    CursorStroke.Parent = self.PaletteCursor
    
    -- Hue slider
    self.HueSlider = Instance.new("ImageButton")
    self.HueSlider.Name = "HueSlider"
    self.HueSlider.Size = UDim2.fromOffset(30, 150)
    self.HueSlider.Position = UDim2.new(1, -50, 0, 10)
    self.HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.HueSlider.BorderSizePixel = 0
    self.HueSlider.Image = "rbxassetid://3641079629"
    self.HueSlider.ImageColor3 = Color3.fromRGB(255, 255, 255)
    self.HueSlider.AutoButtonColor = false
    self.HueSlider.Parent = self.PickerContainer
    
    local HueCorner = Instance.new("UICorner")
    HueCorner.CornerRadius = UDim.new(0, 6)
    HueCorner.Parent = self.HueSlider
    
    -- Hue cursor
    self.HueCursor = Instance.new("Frame")
    self.HueCursor.Name = "Cursor"
    self.HueCursor.Size = UDim2.new(1, 4, 0, 4)
    self.HueCursor.Position = UDim2.new(0, -2, 0, 0)
    self.HueCursor.AnchorPoint = Vector2.new(0, 0.5)
    self.HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.HueCursor.BorderSizePixel = 0
    self.HueCursor.Parent = self.HueSlider
    
    local HueCursorCorner = Instance.new("UICorner")
    HueCursorCorner.CornerRadius = UDim.new(1, 0)
    HueCursorCorner.Parent = self.HueCursor
    
    local HueCursorStroke = Instance.new("UIStroke")
    HueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    HueCursorStroke.Thickness = 2
    HueCursorStroke.Parent = self.HueCursor
    
    -- RGB inputs
    local inputY = 170
    local inputLabels = {"R", "G", "B"}
    self.RGBInputs = {}
    
    for i, label in ipairs(inputLabels) do
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(0.3, -8, 0, 30)
        inputFrame.Position = UDim2.new((i-1) * 0.33, 10 + ((i-1) * 5), 0, inputY)
        inputFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        inputFrame.BorderSizePixel = 0
        inputFrame.Parent = self.PickerContainer
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 5)
        inputCorner.Parent = inputFrame
        
        local inputLabel = Instance.new("TextLabel")
        inputLabel.Size = UDim2.fromOffset(20, 30)
        inputLabel.BackgroundTransparency = 1
        inputLabel.Text = label
        inputLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        inputLabel.TextSize = 12
        inputLabel.Font = Enum.Font.GothamBold
        inputLabel.Parent = inputFrame
        
        local inputBox = Instance.new("TextBox")
        inputBox.Size = UDim2.new(1, -25, 1, 0)
        inputBox.Position = UDim2.fromOffset(22, 0)
        inputBox.BackgroundTransparency = 1
        inputBox.Text = "255"
        inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        inputBox.TextSize = 12
        inputBox.Font = Enum.Font.Gotham
        inputBox.ClearTextOnFocus = false
        inputBox.Parent = inputFrame
        
        self.RGBInputs[label] = inputBox
        
        -- Numeric validation
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = inputBox.Text:gsub("[^%d]", "")
            if text ~= inputBox.Text then
                inputBox.Text = text
            end
        end)
        
        inputBox.FocusLost:Connect(function()
            local num = tonumber(inputBox.Text) or 0
            num = math.clamp(num, 0, 255)
            inputBox.Text = tostring(num)
            
            local r = tonumber(self.RGBInputs.R.Text) or 0
            local g = tonumber(self.RGBInputs.G.Text) or 0
            local b = tonumber(self.RGBInputs.B.Text) or 0
            
            self:SetValue(Color3.fromRGB(r, g, b))
        end)
    end
    
    -- Palette dragging
    local paletteDragging = false
    
    self.Palette.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            paletteDragging = true
            self:UpdatePalette(input.Position)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if paletteDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            self:UpdatePalette(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            paletteDragging = false
        end
    end)
    
    -- Hue dragging
    local hueDragging = false
    
    self.HueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            self:UpdateHue(input.Position.Y)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            self:UpdateHue(input.Position.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    -- Toggle picker
    self.ColorButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover effect
    self.ColorButton.MouseEnter:Connect(function()
        TweenService:Create(ColorStroke, TweenInfo.new(0.2), {
            Thickness = 3
        }):Play()
    end)
    
    self.ColorButton.MouseLeave:Connect(function()
        TweenService:Create(ColorStroke, TweenInfo.new(0.2), {
            Thickness = 2
        }):Play()
    end)
end

function Colorpicker:UpdatePalette(mousePos)
    local palettePos = self.Palette.AbsolutePosition
    local paletteSize = self.Palette.AbsoluteSize
    
    local relativeX = math.clamp(mousePos.X - palettePos.X, 0, paletteSize.X)
    local relativeY = math.clamp(mousePos.Y - palettePos.Y, 0, paletteSize.Y)
    
    local saturation = relativeX / paletteSize.X
    local value = 1 - (relativeY / paletteSize.Y)
    
    -- Update cursor position
    self.PaletteCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
    
    -- Calculate color from HSV
    local hue = self:GetHue()
    local color = Color3.fromHSV(hue, saturation, value)
    
    self:SetValue(color)
end

function Colorpicker:UpdateHue(mouseY)
    local sliderPos = self.HueSlider.AbsolutePosition.Y
    local sliderSize = self.HueSlider.AbsoluteSize.Y
    
    local relativeY = math.clamp(mouseY - sliderPos, 0, sliderSize)
    local hue = relativeY / sliderSize
    
    -- Update cursor position
    self.HueCursor.Position = UDim2.new(0, -2, hue, 0)
    
    -- Update palette color
    self.Palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    
    -- Recalculate current color
    local cursorPos = self.PaletteCursor.Position
    local saturation = cursorPos.X.Scale
    local value = 1 - cursorPos.Y.Scale
    
    local color = Color3.fromHSV(hue, saturation, value)
    self:SetValue(color)
end

function Colorpicker:GetHue()
    return self.HueCursor.Position.Y.Scale
end

function Colorpicker:Toggle()
    if self.Opened then
        self:Close()
    else
        self:Open()
    end
end

function Colorpicker:Open()
    self.Opened = true
    
    self.PickerContainer.Visible = true
    
    TweenService:Create(self.PickerContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, -24, 0, 215)
    }):Play()
    
    -- Expand container
    local newHeight = (self.Description and 70 or 55) + 220
    TweenService:Create(self.Container, TweenInfo.new(0.3), {
        Size = UDim2.new(1, -20, 0, newHeight)
    }):Play()
end

function Colorpicker:Close()
    self.Opened = false
    
    TweenService:Create(self.PickerContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(1, -24, 0, 0)
    }):Play()
    
    task.delay(0.3, function()
        self.PickerContainer.Visible = false
    end)
    
    -- Shrink container
    local newHeight = self.Description and 70 or 55
    TweenService:Create(self.Container, TweenInfo.new(0.3), {
        Size = UDim2.new(1, -20, 0, newHeight)
    }):Play()
end

function Colorpicker:SetValue(color, silent)
    self.Value = color
    
    -- Update preview
    self.ColorButton.BackgroundColor3 = color
    
    -- Update RGB inputs
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    
    self.RGBInputs.R.Text = tostring(r)
    self.RGBInputs.G.Text = tostring(g)
    self.RGBInputs.B.Text = tostring(b)
    
    if not silent then
        task.spawn(function()
            self.Callback(color)
        end)
    end
end

return Colorpicker
