---@diagnostic disable: undefined-global
-- Ssoly UI Library - Button Element
-- Clickable button with animations

local TweenService = game:GetService("TweenService")

local Button = {}
Button.__index = Button

function Button.new(tab, config)
    local self = setmetatable({}, Button)
    
    -- Extract Tab, Window, and Container from passed object
    if tab.Tab then
        self.Tab = tab.Tab
        self.Window = tab.Window
        self.ParentContainer = tab.Container
    else
        self.Tab = tab
        self.Window = tab.Window
        self.ParentContainer = tab.Window.ContentContainer
    end
    
    self.Title = config.Title or "Button"
    self.Description = config.Description
    self.Callback = config.Callback or function() end
    
    self:CreateElement()
    
    return self
end

function Button:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Button"
    self.Container.Size = UDim2.new(1, -30, 0, self.Description and 60 or 45)
    self.Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.ParentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    -- Button
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, -24, 0, 30)
    self.Button.Position = UDim2.fromOffset(12, 8)
    self.Button.BackgroundColor3 = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    self.Button.BackgroundTransparency = 0.2
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.SelectionImageObject = nil
    self.Button.Parent = self.Container
    
    if self.Window.AccentElements then
        table.insert(self.Window.AccentElements, self.Button)
    end
    
    -- Store reference for color updates
    self.AccentElement = self.Button
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = self.Button
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Button
    
    -- Description (optional)
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -24, 0, 15)
        self.DescLabel.Position = UDim2.fromOffset(12, 42)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 11
        self.DescLabel.Font = Enum.Font.SourceSans
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    -- Click handler
    self.Button.MouseButton1Click:Connect(function()
        self:Click()
    end)
    
    -- Hover effects
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.new(1, -20, 0, 32)
        }):Play()
    end)
    
    self.Button.MouseLeave:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, -24, 0, 30)
        }):Play()
    end)
    
    -- Click animation
    self.Button.MouseButton1Down:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -28, 0, 28)
        }):Play()
    end)
    
    self.Button.MouseButton1Up:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -20, 0, 32)
        }):Play()
    end)
end

function Button:Click()
    -- Ripple effect
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.fromOffset(0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 2
    ripple.Parent = self.Button
    
    local rippleCorner = Instance.new("UICorner")
    rippleCorner.CornerRadius = UDim.new(1, 0)
    rippleCorner.Parent = ripple
    
    local tween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(self.Button.AbsoluteSize.X * 2, self.Button.AbsoluteSize.X * 2),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
    
    -- Call callback
    task.spawn(function()
        self.Callback()
    end)
end

return Button
