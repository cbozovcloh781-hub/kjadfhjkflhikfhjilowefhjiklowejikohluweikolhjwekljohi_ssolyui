---@diagnostic disable: undefined-global
-- Ssoly UI Library - Input Element
-- Text input field with validation

local TweenService = game:GetService("TweenService")

local Input = {}
Input.__index = Input

function Input.new(tab, config)
    local self = setmetatable({}, Input)
    
    self.Tab = tab
    self.Title = config.Title or "Input"
    self.Description = config.Description
    self.Placeholder = config.Placeholder or "Enter text..."
    self.Default = config.Default or ""
    self.Numeric = config.Numeric or false
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    
    self:CreateElement()
    
    return self
end

function Input:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Input"
    self.Container.Size = UDim2.new(1, -20, 0, self.Description and 75 or 60)
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
    self.TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(12, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Container
    
    -- Description (optional)
    local inputY = 32
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
        inputY = 50
    end
    
    -- Input box
    self.InputBox = Instance.new("TextBox")
    self.InputBox.Name = "InputBox"
    self.InputBox.Size = UDim2.new(1, -24, 0, 30)
    self.InputBox.Position = UDim2.fromOffset(12, inputY)
    self.InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.InputBox.BackgroundTransparency = 0.3
    self.InputBox.BorderSizePixel = 0
    self.InputBox.Text = self.Default
    self.InputBox.PlaceholderText = self.Placeholder
    self.InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    self.InputBox.TextSize = 13
    self.InputBox.Font = Enum.Font.SourceSans
    self.InputBox.TextXAlignment = Enum.TextXAlignment.Left
    self.InputBox.ClearTextOnFocus = false
    self.InputBox.TextStrokeTransparency = 0.9
    self.InputBox.Parent = self.Container
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = self.InputBox
    
    local InputPadding = Instance.new("UIPadding")
    InputPadding.PaddingLeft = UDim.new(0, 10)
    InputPadding.PaddingRight = UDim.new(0, 10)
    InputPadding.Parent = self.InputBox
    
    -- Border (focus indicator) - subtle gray instead of blue
    self.Border = Instance.new("UIStroke")
    self.Border.Color = Color3.fromRGB(80, 80, 80)
    self.Border.Thickness = 0
    self.Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Border.Parent = self.InputBox
    
    -- Focus events
    self.InputBox.Focused:Connect(function()
        TweenService:Create(self.Border, TweenInfo.new(0.2), {
            Thickness = 1,
            Color = Color3.fromRGB(100, 100, 100)
        }):Play()
        TweenService:Create(self.InputBox, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    self.InputBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(self.Border, TweenInfo.new(0.2), {
            Thickness = 0
        }):Play()
        TweenService:Create(self.InputBox, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3
        }):Play()
        
        if enterPressed then
            self:SetValue(self.InputBox.Text)
        end
    end)
    
    -- Numeric validation
    if self.Numeric then
        self.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = self.InputBox.Text
            local filtered = text:gsub("[^%d%.%-]", "")
            
            if filtered ~= text then
                self.InputBox.Text = filtered
            end
        end)
    end
end

function Input:SetValue(value, silent)
    self.Value = value
    self.InputBox.Text = value
    
    if not silent then
        task.spawn(function()
            self.Callback(value)
        end)
    end
end

return Input
