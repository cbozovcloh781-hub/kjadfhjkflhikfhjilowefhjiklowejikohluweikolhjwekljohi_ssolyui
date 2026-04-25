---@diagnostic disable: undefined-global, undefined-field
-- Ssoly UI Library - Slider Element
-- Slider with manual input and smooth animations

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

function Slider.new(tab, config)
    local self = setmetatable({}, Slider)
    
    self.Tab = tab
    self.Title = config.Title or "Slider"
    self.Description = config.Description
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Default = config.Default or self.Min
    self.Rounding = config.Rounding or 0
    self.Suffix = config.Suffix or ""
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    
    self:CreateElement()
    self:SetValue(self.Default, true)
    
    return self
end

function Slider:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Slider"
    self.Container.Size = UDim2.new(1, -20, 0, self.Description and 85 or 70)
    self.Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Tab.Window.ContentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -120, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(12, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Container
    
    -- Value display / input
    self.ValueBox = Instance.new("TextBox")
    self.ValueBox.Name = "ValueBox"
    self.ValueBox.Size = UDim2.fromOffset(70, 25)
    self.ValueBox.Position = UDim2.new(1, -78, 0, 8)
    self.ValueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.ValueBox.BackgroundTransparency = 0.3
    self.ValueBox.BorderSizePixel = 0
    self.ValueBox.Text = tostring(self.Value) .. self.Suffix
    self.ValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ValueBox.TextSize = 12
    self.ValueBox.Font = Enum.Font.SourceSansBold
    self.ValueBox.ClearTextOnFocus = false
    self.ValueBox.TextStrokeTransparency = 0.9
    self.ValueBox.Parent = self.Container
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 6)
    ValueCorner.Parent = self.ValueBox
    
    -- Description (optional)
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
    end
    
    -- Slider track background (thicker)
    local sliderY = self.Description and 52 or 38
    self.SliderTrack = Instance.new("Frame")
    self.SliderTrack.Name = "Track"
    self.SliderTrack.Size = UDim2.new(1, -24, 0, 10)
    self.SliderTrack.Position = UDim2.fromOffset(12, sliderY)
    self.SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    self.SliderTrack.BorderSizePixel = 0
    self.SliderTrack.Active = true
    self.SliderTrack.Parent = self.Container
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = self.SliderTrack
    
    -- Slider fill (progress)
    self.SliderFill = Instance.new("Frame")
    self.SliderFill.Name = "Fill"
    self.SliderFill.Size = UDim2.new(0, 0, 1, 0)
    self.SliderFill.BackgroundColor3 = Color3.fromRGB(74, 158, 255)
    self.SliderFill.BorderSizePixel = 0
    self.SliderFill.Parent = self.SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = self.SliderFill
    
    -- Slider handle (circle) - properly centered on track with larger hitbox
    self.SliderHandle = Instance.new("TextButton")
    self.SliderHandle.Name = "Handle"
    self.SliderHandle.Size = UDim2.fromOffset(30, 30)
    self.SliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
    self.SliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    self.SliderHandle.BackgroundTransparency = 1
    self.SliderHandle.Text = ""
    self.SliderHandle.AutoButtonColor = false
    self.SliderHandle.SelectionImageObject = nil
    self.SliderHandle.ZIndex = 3
    self.SliderHandle.Parent = self.SliderTrack
    
    -- Visual circle inside button
    local handleCircle = Instance.new("Frame")
    handleCircle.Name = "Circle"
    handleCircle.Size = UDim2.fromOffset(18, 18)
    handleCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    handleCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    handleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handleCircle.BorderSizePixel = 0
    handleCircle.Parent = self.SliderHandle
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(1, 0)
    HandleCorner.Parent = handleCircle
    
    self.HandleCircle = handleCircle
    
    -- Min/Max labels
    self.MinLabel = Instance.new("TextLabel")
    self.MinLabel.Size = UDim2.fromOffset(50, 15)
    self.MinLabel.Position = UDim2.fromOffset(12, sliderY + 15)
    self.MinLabel.BackgroundTransparency = 1
    self.MinLabel.Text = tostring(self.Min)
    self.MinLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    self.MinLabel.TextSize = 10
    self.MinLabel.Font = Enum.Font.SourceSans
    self.MinLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.MinLabel.Parent = self.Container
    
    self.MaxLabel = Instance.new("TextLabel")
    self.MaxLabel.Size = UDim2.fromOffset(50, 15)
    self.MaxLabel.Position = UDim2.new(1, -62, 0, sliderY + 15)
    self.MaxLabel.BackgroundTransparency = 1
    self.MaxLabel.Text = tostring(self.Max)
    self.MaxLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    self.MaxLabel.TextSize = 10
    self.MaxLabel.Font = Enum.Font.SourceSans
    self.MaxLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.MaxLabel.Parent = self.Container
    
    -- Dragging logic
    local dragging = false
    
    self.SliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            self:UpdateSlider(input.Position.X)
        end
    end)
    
    self.SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            self:UpdateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            self:UpdateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Manual input with suffix handling
    self.ValueBox.Focused:Connect(function()
        -- Remove suffix when focused
        local text = self.ValueBox.Text:gsub(self.Suffix, ""):gsub("%s+", "")
        self.ValueBox.Text = text
    end)
    
    self.ValueBox.FocusLost:Connect(function(enterPressed)
        local text = self.ValueBox.Text:gsub("%s+", "")
        local num = tonumber(text)
        
        if num then
            self:SetValue(math.clamp(num, self.Min, self.Max))
        else
            -- Reset to current value if invalid
            self.ValueBox.Text = tostring(self.Value) .. self.Suffix
        end
    end)
    
    -- Hover effects
    self.SliderTrack.MouseEnter:Connect(function()
        TweenService:Create(self.HandleCircle, TweenInfo.new(0.2), {
            Size = UDim2.fromOffset(22, 22)
        }):Play()
    end)
    
    self.SliderTrack.MouseLeave:Connect(function()
        if not dragging then
            TweenService:Create(self.HandleCircle, TweenInfo.new(0.2), {
                Size = UDim2.fromOffset(18, 18)
            }):Play()
        end
    end)
end

function Slider:UpdateSlider(mouseX)
    local trackPos = self.SliderTrack.AbsolutePosition.X
    local trackSize = self.SliderTrack.AbsoluteSize.X
    local relativeX = math.clamp(mouseX - trackPos, 0, trackSize)
    local percentage = relativeX / trackSize
    
    local value = self.Min + (self.Max - self.Min) * percentage
    self:SetValue(value)
end

function Slider:SetValue(value, silent)
    -- Round value
    if self.Rounding == 0 then
        value = math.floor(value + 0.5)
    else
        local mult = 10 ^ self.Rounding
        value = math.floor(value * mult + 0.5) / mult
    end
    
    value = math.clamp(value, self.Min, self.Max)
    self.Value = value
    
    -- Update UI
    local percentage = (value - self.Min) / (self.Max - self.Min)
    
    TweenService:Create(self.SliderFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(percentage, 0, 1, 0)
    }):Play()
    
    -- Move handle smoothly on track (properly centered)
    local trackWidth = self.SliderTrack.AbsoluteSize.X
    local handleX = trackWidth * percentage
    TweenService:Create(self.SliderHandle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(percentage, 0, 0.5, 0)
    }):Play()
    
    self.ValueBox.Text = tostring(value) .. self.Suffix
    
    -- Call callback
    if not silent then
        task.spawn(function()
            self.Callback(value)
        end)
    end
end

return Slider
