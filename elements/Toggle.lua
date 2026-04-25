-- Ssoly UI Library - Toggle Element
-- On/Off switch with smooth animations

local TweenService = game:GetService("TweenService")

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(tab, config)
    local self = setmetatable({}, Toggle)
    
    self.Tab = tab
    self.Title = config.Title or "Toggle"
    self.Description = config.Description
    self.Default = config.Default or false
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    
    self:CreateElement()
    
    -- Set initial state
    if self.Default then
        self:SetValue(true, true)
    end
    
    return self
end

function Toggle:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Toggle"
    self.Container.Size = UDim2.new(1, -20, 0, self.Description and 60 or 45)
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
    self.TitleLabel.Size = UDim2.new(1, -70, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(12, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Container
    
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
    
    -- Toggle switch background
    self.SwitchBg = Instance.new("Frame")
    self.SwitchBg.Name = "SwitchBg"
    self.SwitchBg.Size = UDim2.fromOffset(45, 22)
    self.SwitchBg.Position = UDim2.new(1, -55, 0.5, -11)
    self.SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    self.SwitchBg.BorderSizePixel = 0
    self.SwitchBg.Parent = self.Container
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = self.SwitchBg
    
    -- Toggle switch circle
    self.SwitchCircle = Instance.new("Frame")
    self.SwitchCircle.Name = "Circle"
    self.SwitchCircle.Size = UDim2.fromOffset(18, 18)
    self.SwitchCircle.Position = UDim2.fromOffset(2, 2)
    self.SwitchCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    self.SwitchCircle.BorderSizePixel = 0
    self.SwitchCircle.Parent = self.SwitchBg
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = self.SwitchCircle
    
    -- Click button (invisible)
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, 0, 1, 0)
    self.Button.BackgroundTransparency = 1
    self.Button.Text = ""
    self.Button.Parent = self.Container
    
    -- Click handler
    self.Button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover effects
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(self.Container, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    self.Button.MouseLeave:Connect(function()
        TweenService:Create(self.Container, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.5
        }):Play()
    end)
end

function Toggle:Toggle()
    self:SetValue(not self.Value)
end

function Toggle:SetValue(value, silent)
    self.Value = value
    
    if value then
        -- ON state
        TweenService:Create(self.SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(74, 158, 255)
        }):Play()
        
        TweenService:Create(self.SwitchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(25, 2),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    else
        -- OFF state
        TweenService:Create(self.SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
        
        TweenService:Create(self.SwitchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(2, 2),
            BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end
    
    -- Call callback
    if not silent then
        task.spawn(function()
            self.Callback(value)
        end)
    end
end

return Toggle
