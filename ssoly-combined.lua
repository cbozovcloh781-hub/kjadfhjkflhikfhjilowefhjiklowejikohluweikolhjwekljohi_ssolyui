---@diagnostic disable: undefined-global
-- Ssoly UI Library v1.1.0 - Combined Version
-- Modern minimalist UI library for Roblox exploits
-- All modules combined in one file for fast loading
-- Created by Sosalkin Hub

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============================================================================
-- PARTICLES SYSTEM
-- ============================================================================
local Particles = {}
Particles.Enabled = true
Particles.Active = {}

function Particles.new(parent, accentColor)
    local self = setmetatable({}, {__index = Particles})
    
    self.Parent = parent
    self.AccentColor = accentColor or Color3.fromRGB(74, 158, 255)
    self.Container = Instance.new("Frame")
    self.Container.Name = "ParticlesContainer"
    self.Container.Size = UDim2.fromScale(1, 1)
    self.Container.BackgroundTransparency = 1
    self.Container.ZIndex = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = parent
    
    self.Particles = {}
    self.MaxParticles = 100
    self.SpawnRate = 0.08
    self.LastSpawn = 0
    self.Running = false
    
    return self
end

function Particles:CreateParticle()
    if not Particles.Enabled then return end
    if not self.Running then return end
    if not self.Container or not self.Container.Parent then return end
    if #self.Particles >= self.MaxParticles then return end
    
    local size = math.random(2, 5)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.fromOffset(size, size)
    
    local direction = math.random(1, 100)
    local startPos, endPos
    
    if direction <= 70 then
        startPos = UDim2.new(math.random(0, 100) / 100, 0, 0, -10)
        endPos = UDim2.new(startPos.X.Scale + math.random(-10, 10) / 100, 0, 1, 10)
    elseif direction <= 85 then
        startPos = UDim2.new(0, -10, math.random(0, 100) / 100, 0)
        endPos = UDim2.new(1, 10, startPos.Y.Scale + math.random(-10, 10) / 100, 0)
    else
        startPos = UDim2.new(1, 10, math.random(0, 100) / 100, 0)
        endPos = UDim2.new(0, -10, startPos.Y.Scale + math.random(-10, 10) / 100, 0)
    end
    
    particle.Position = startPos
    
    local function clamp(val, min, max) return math.max(min, math.min(max, val)) end
    local r = clamp(self.AccentColor.R * 255 + math.random(-15, 15), 0, 255)
    local g = clamp(self.AccentColor.G * 255 + math.random(-15, 15), 0, 255)
    local b = clamp(self.AccentColor.B * 255 + math.random(-15, 15), 0, 255)
    
    particle.BackgroundColor3 = Color3.fromRGB(r, g, b)
    particle.BackgroundTransparency = math.random(40, 80) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 1
    particle.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    table.insert(self.Particles, particle)
    
    local duration = math.random(6, 12)
    
    local tween = TweenService:Create(
        particle,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Position = endPos, BackgroundTransparency = 1}
    )
    
    tween.Completed:Connect(function()
        if particle and particle.Parent then
            particle:Destroy()
        end
        for i, p in ipairs(self.Particles) do
            if p == particle then
                table.remove(self.Particles, i)
                break
            end
        end
    end)
    
    tween:Play()
end

function Particles:Start()
    if self.Connection then return end
    
    self.Running = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Particles.Enabled or not self.Running then
            self.Container.Visible = false
            return
        end
        
        self.Container.Visible = true
        local now = tick()
        if now - self.LastSpawn >= self.SpawnRate then
            self:CreateParticle()
            self.LastSpawn = now
        end
    end)
    
    table.insert(Particles.Active, self)
end

function Particles:Stop()
    self.Running = false
    
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    for i = #self.Particles, 1, -1 do
        local particle = self.Particles[i]
        if particle and particle.Parent then
            TweenService:Create(particle, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
            
            task.delay(2, function()
                if particle and particle.Parent then
                    particle:Destroy()
                end
            end)
        end
        table.remove(self.Particles, i)
    end
    
    for i, p in ipairs(Particles.Active) do
        if p == self then
            table.remove(Particles.Active, i)
            break
        end
    end
end

function Particles:Destroy()
    self:Stop()
    self.Container:Destroy()
end

function Particles.SetEnabled(enabled)
    Particles.Enabled = enabled
    
    for _, particleSystem in ipairs(Particles.Active) do
        if not enabled then
            particleSystem.Running = false
            if particleSystem.Container then
                particleSystem.Container.Visible = false
            end
            for i = #particleSystem.Particles, 1, -1 do
                local particle = particleSystem.Particles[i]
                if particle and particle.Parent then
                    TweenService:Create(particle, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                    
                    task.delay(2, function()
                        if particle and particle.Parent then
                            particle:Destroy()
                        end
                    end)
                end
                table.remove(particleSystem.Particles, i)
            end
        else
            particleSystem.Running = true
            if particleSystem.Container then
                particleSystem.Container.Visible = true
            end
        end
    end
end

function Particles:SetAccentColor(color)
    self.AccentColor = color
end

-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================
local Notification = {}
Notification.Container = nil
Notification.Queue = {}
Notification.Active = {}

function Notification:Init(screenGui)
    if self.Container then return end
    
    self.Container = Instance.new("Frame")
    self.Container.Name = "Notifications"
    self.Container.Size = UDim2.fromOffset(320, 0)
    self.Container.Position = UDim2.new(1, -330, 1, -10)
    self.Container.AnchorPoint = Vector2.new(0, 1)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = screenGui
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    Layout.Parent = self.Container
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.Size = UDim2.fromOffset(300, Layout.AbsoluteContentSize.Y)
    end)
end

function Notification:Show(config)
    if not self.Container then return end
    
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 3
    local type = config.Type or "Info"
    
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    notif.BackgroundTransparency = 0
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = self.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = notif
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(50, 50, 50)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = notif
    
    local typeColors = {
        Info = Color3.fromRGB(74, 158, 255),
        Success = Color3.fromRGB(80, 255, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80)
    }
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.fromOffset(10, 10)
    indicator.Position = UDim2.fromOffset(10, 10)
    indicator.BackgroundColor3 = typeColors[type] or typeColors.Info
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 3
    indicator.Parent = notif
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = indicator
    
    local typeIcons = {
        Info = "ⓘ",
        Success = "✓",
        Warning = "⚠",
        Error = "✕"
    }
    
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(24, 24)
    icon.Position = UDim2.fromOffset(26, 12)
    icon.BackgroundTransparency = 1
    icon.Text = typeIcons[type] or typeIcons.Info
    icon.TextColor3 = Color3.fromRGB(200, 200, 200)
    icon.TextSize = 16
    icon.Font = Enum.Font.GothamBold
    icon.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -70, 0, 18)
    titleLabel.Position = UDim2.fromOffset(56, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = notif
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -70, 0, 0)
    contentLabel.Position = UDim2.fromOffset(56, 32)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    contentLabel.TextSize = 11
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = notif
    
    local textService = game:GetService("TextService")
    local textBounds = textService:GetTextSize(
        content,
        12,
        Enum.Font.Gotham,
        Vector2.new(232, math.huge)
    )
    
    local contentHeight = math.max(textBounds.Y, 15)
    contentLabel.Size = UDim2.new(1, -60, 0, contentHeight)
    
    local totalHeight = 50 + contentHeight
    
    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.Size = UDim2.new(1, -16, 0, 3)
    progress.Position = UDim2.new(0, 8, 1, -8)
    progress.BackgroundColor3 = typeColors[type] or typeColors.Info
    progress.BorderSizePixel = 0
    progress.ZIndex = 2
    progress.Parent = notif
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = progress
    
    notif.Size = UDim2.new(1, 0, 0, totalHeight)
    notif.Position = UDim2.new(1, 50, 0, 0)
    notif.BackgroundTransparency = 1
    
    for _, child in pairs(notif:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextTransparency = 1
        end
        if child:IsA("GuiObject") and child ~= notif and child.Name ~= "Progress" then
            child.BackgroundTransparency = 1
        end
    end
    
    local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    TweenService:Create(notif, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(notif, tweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(Stroke, tweenInfo, {Transparency = 0}):Play()
    TweenService:Create(indicator, tweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(icon, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(titleLabel, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(contentLabel, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(progress, tweenInfo, {BackgroundTransparency = 0}):Play()
    
    task.delay(1.0, function()
        TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 3)
        }):Play()
    end)
    
    task.delay(duration, function()
        self:Dismiss(notif)
    end)
    
    local dismissBtn = Instance.new("TextButton")
    dismissBtn.Size = UDim2.new(1, 0, 1, 0)
    dismissBtn.BackgroundTransparency = 1
    dismissBtn.Text = ""
    dismissBtn.Parent = notif
    
    dismissBtn.MouseButton1Click:Connect(function()
        self:Dismiss(notif)
    end)
    
    table.insert(self.Active, notif)
end

function Notification:Dismiss(notif)
    if not notif or not notif.Parent then return end
    
    local tween = TweenService:Create(notif, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 50, 0, 0)
    })
    tween:Play()
    
    TweenService:Create(notif, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    
    for _, child in pairs(notif:GetDescendants()) do
        if child:IsA("GuiObject") then
            TweenService:Create(child, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
            end
        end
    end
    
    tween.Completed:Connect(function()
        notif:Destroy()
        
        for i, n in ipairs(self.Active) do
            if n == notif then
                table.remove(self.Active, i)
                break
            end
        end
    end)
end

function Notification:DismissAll()
    for _, notif in ipairs(self.Active) do
        self:Dismiss(notif)
    end
end

-- ============================================================================
-- UI ELEMENTS
-- ============================================================================

-- Toggle Element
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(tab, config)
    local self = setmetatable({}, Toggle)
    
    self.Tab = tab.Tab or tab
    self.Window = tab.Window or (tab.Tab and tab.Tab.Window)
    self.Title = config.Title or "Toggle"
    self.Description = config.Description
    self.Default = config.Default or false
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    
    self:CreateElement(tab.Container)
    
    if self.Default then
        self:SetValue(true, true)
    end
    
    return self
end

function Toggle:CreateElement(parent)
    self.Container = Instance.new("Frame")
    self.Container.Name = "Toggle"
    self.Container.Size = UDim2.new(1, -30, 0, self.Description and 50 or 38)
    self.Container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.Parent = parent or self.Window.ContentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = self.Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Transparency = 0.5
    Stroke.Parent = self.Container
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -70, 0, 18)
    self.TitleLabel.Position = UDim2.fromOffset(10, 8)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Container
    
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -70, 0, 14)
        self.DescLabel.Position = UDim2.fromOffset(10, 26)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 10
        self.DescLabel.Font = Enum.Font.SourceSans
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    self.SwitchBg = Instance.new("Frame")
    self.SwitchBg.Name = "SwitchBg"
    self.SwitchBg.Size = UDim2.fromOffset(40, 20)
    self.SwitchBg.Position = UDim2.new(1, -48, 0.5, -10)
    self.SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    self.SwitchBg.BorderSizePixel = 0
    self.SwitchBg.Parent = self.Container
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = self.SwitchBg
    
    self.SwitchCircle = Instance.new("Frame")
    self.SwitchCircle.Name = "Circle"
    self.SwitchCircle.Size = UDim2.fromOffset(16, 16)
    self.SwitchCircle.Position = UDim2.fromOffset(2, 2)
    self.SwitchCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    self.SwitchCircle.BorderSizePixel = 0
    self.SwitchCircle.Parent = self.SwitchBg
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = self.SwitchCircle
    
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, 0, 1, 0)
    self.Button.BackgroundTransparency = 1
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.SelectionImageObject = nil
    self.Button.Parent = self.Container
    
    self.Button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(self.Container, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.4
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
    
    local accentColor = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    
    if value then
        TweenService:Create(self.SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = accentColor
        }):Play()
        
        TweenService:Create(self.SwitchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(22, 2),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    else
        TweenService:Create(self.SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
        
        TweenService:Create(self.SwitchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(2, 2),
            BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end
    
    if not silent then
        task.spawn(function()
            self.Callback(value)
        end)
    end
end

-- Slider Element
local Slider = {}
Slider.__index = Slider

function Slider.new(tab, config)
    local self = setmetatable({}, Slider)
    
    if tab.Tab then
        self.Tab = tab.Tab
        self.Window = tab.Window
        self.ParentContainer = tab.Container
    else
        self.Tab = tab
        self.Window = tab.Window
        self.ParentContainer = tab.Window.ContentContainer
    end
    
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
    self.Container = Instance.new("Frame")
    self.Container.Name = "Slider"
    self.Container.Size = UDim2.new(1, -30, 0, self.Description and 75 or 62)
    self.Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.ParentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -120, 0, 18)
    self.TitleLabel.Position = UDim2.fromOffset(10, 8)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Container
    
    self.ValueBox = Instance.new("TextBox")
    self.ValueBox.Name = "ValueBox"
    self.ValueBox.Size = UDim2.fromOffset(65, 22)
    self.ValueBox.Position = UDim2.new(1, -72, 0, 7)
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
    
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -20, 0, 14)
        self.DescLabel.Position = UDim2.fromOffset(10, 26)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 10
        self.DescLabel.Font = Enum.Font.SourceSans
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    local sliderY = self.Description and 43 or 32
    self.SliderTrack = Instance.new("Frame")
    self.SliderTrack.Name = "Track"
    self.SliderTrack.Size = UDim2.new(1, -20, 0, 8)
    self.SliderTrack.Position = UDim2.fromOffset(10, sliderY)
    self.SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    self.SliderTrack.BorderSizePixel = 0
    self.SliderTrack.Active = true
    self.SliderTrack.Parent = self.Container
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = self.SliderTrack
    
    self.SliderFill = Instance.new("Frame")
    self.SliderFill.Name = "Fill"
    self.SliderFill.Size = UDim2.new(0, 0, 1, 0)
    self.SliderFill.BackgroundColor3 = self.Tab.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    self.SliderFill.BorderSizePixel = 0
    self.SliderFill.Parent = self.SliderTrack
    
    if self.Window.AccentElements then
        table.insert(self.Window.AccentElements, self.SliderFill)
    end
    
    self.AccentElement = self.SliderFill
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = self.SliderFill
    
    self.SliderHandle = Instance.new("TextButton")
    self.SliderHandle.Name = "Handle"
    self.SliderHandle.Size = UDim2.fromOffset(26, 26)
    self.SliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
    self.SliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    self.SliderHandle.BackgroundTransparency = 1
    self.SliderHandle.Text = ""
    self.SliderHandle.AutoButtonColor = false
    self.SliderHandle.SelectionImageObject = nil
    self.SliderHandle.ZIndex = 3
    self.SliderHandle.Parent = self.SliderTrack
    
    local handleCircle = Instance.new("Frame")
    handleCircle.Name = "Circle"
    handleCircle.Size = UDim2.fromOffset(16, 16)
    handleCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    handleCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    handleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handleCircle.BorderSizePixel = 0
    handleCircle.Parent = self.SliderHandle
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(1, 0)
    HandleCorner.Parent = handleCircle
    
    self.HandleCircle = handleCircle
    
    self.MinLabel = Instance.new("TextLabel")
    self.MinLabel.Size = UDim2.fromOffset(50, 14)
    self.MinLabel.Position = UDim2.fromOffset(10, sliderY + 12)
    self.MinLabel.BackgroundTransparency = 1
    self.MinLabel.Text = tostring(self.Min)
    self.MinLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    self.MinLabel.TextSize = 10
    self.MinLabel.Font = Enum.Font.SourceSans
    self.MinLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.MinLabel.Parent = self.Container
    
    self.MaxLabel = Instance.new("TextLabel")
    self.MaxLabel.Size = UDim2.fromOffset(50, 14)
    self.MaxLabel.Position = UDim2.new(1, -60, 0, sliderY + 12)
    self.MaxLabel.BackgroundTransparency = 1
    self.MaxLabel.Text = tostring(self.Max)
    self.MaxLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    self.MaxLabel.TextSize = 10
    self.MaxLabel.Font = Enum.Font.SourceSans
    self.MaxLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.MaxLabel.Parent = self.Container
    
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
    
    self.ValueBox.Focused:Connect(function()
        local text = self.ValueBox.Text:gsub(self.Suffix, ""):gsub("%s+", "")
        self.ValueBox.Text = text
    end)
    
    self.ValueBox.FocusLost:Connect(function(enterPressed)
        local text = self.ValueBox.Text:gsub("%s+", "")
        local num = tonumber(text)
        
        if num then
            self:SetValue(math.clamp(num, self.Min, self.Max))
        else
            self.ValueBox.Text = tostring(self.Value) .. self.Suffix
        end
    end)
    
    self.SliderTrack.MouseEnter:Connect(function()
        TweenService:Create(self.HandleCircle, TweenInfo.new(0.2), {
            Size = UDim2.fromOffset(20, 20)
        }):Play()
    end)
    
    self.SliderTrack.MouseLeave:Connect(function()
        if not dragging then
            TweenService:Create(self.HandleCircle, TweenInfo.new(0.2), {
                Size = UDim2.fromOffset(16, 16)
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
    if self.Rounding == 0 then
        value = math.floor(value + 0.5)
    else
        local mult = 10 ^ self.Rounding
        value = math.floor(value * mult + 0.5) / mult
    end
    
    value = math.clamp(value, self.Min, self.Max)
    self.Value = value
    
    local percentage = (value - self.Min) / (self.Max - self.Min)
    
    TweenService:Create(self.SliderFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(percentage, 0, 1, 0)
    }):Play()
    
    local trackWidth = self.SliderTrack.AbsoluteSize.X
    local handleX = trackWidth * percentage
    TweenService:Create(self.SliderHandle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(percentage, 0, 0.5, 0)
    }):Play()
    
    self.ValueBox.Text = tostring(value) .. self.Suffix
    
    if not silent then
        task.spawn(function()
            self.Callback(value)
        end)
    end
end

-- Button Element
local Button = {}
Button.__index = Button

function Button.new(tab, config)
    local self = setmetatable({}, Button)
    
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
    self.Container = Instance.new("Frame")
    self.Container.Name = "Button"
    self.Container.Size = UDim2.new(1, -30, 0, self.Description and 50 or 38)
    self.Container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
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
    
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, -20, 0, 26)
    self.Button.Position = UDim2.fromOffset(10, 6)
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
    
    self.AccentElement = self.Button
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = self.Button
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Button
    
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -20, 0, 14)
        self.DescLabel.Position = UDim2.fromOffset(10, 34)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 10
        self.DescLabel.Font = Enum.Font.SourceSans
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    self.Button.MouseButton1Click:Connect(function()
        self:Click()
    end)
    
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.new(1, -16, 0, 28)
        }):Play()
    end)
    
    self.Button.MouseLeave:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, -20, 0, 26)
        }):Play()
    end)
    
    self.Button.MouseButton1Down:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -24, 0, 24)
        }):Play()
    end)
    
    self.Button.MouseButton1Up:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -16, 0, 28)
        }):Play()
    end)
end

function Button:Click()
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
    
    task.spawn(function()
        self.Callback()
    end)
end

-- Input Element
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
    self.Container = Instance.new("Frame")
    self.Container.Name = "Input"
    self.Container.Size = UDim2.new(1, -30, 0, self.Description and 75 or 60)
    self.Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Tab.Window.ContentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -20, 0, 18)
    self.TitleLabel.Position = UDim2.fromOffset(10, 8)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Container
    
    local inputY = 28
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -20, 0, 14)
        self.DescLabel.Position = UDim2.fromOffset(10, 26)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 10
        self.DescLabel.Font = Enum.Font.SourceSans
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
        inputY = 42
    end
    
    self.InputBox = Instance.new("TextBox")
    self.InputBox.Name = "InputBox"
    self.InputBox.Size = UDim2.new(1, -20, 0, 30)
    self.InputBox.Position = UDim2.fromOffset(10, inputY)
    self.InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.InputBox.BackgroundTransparency = 0.3
    self.InputBox.BorderSizePixel = 0
    self.InputBox.Text = self.Default
    self.InputBox.PlaceholderText = self.Placeholder
    self.InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    self.InputBox.TextSize = 12
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
    
    self.Border = Instance.new("UIStroke")
    self.Border.Color = Color3.fromRGB(80, 80, 80)
    self.Border.Thickness = 0
    self.Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Border.Parent = self.InputBox
    
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

-- Keybind Element
local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(tab, config)
    local self = setmetatable({}, Keybind)
    
    self.Tab = tab
    self.Title = config.Title or "Keybind"
    self.Description = config.Description
    self.Default = config.Default or Enum.KeyCode.E
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    self.Listening = false
    
    self:CreateElement()
    self:SetupListener()
    
    return self
end

function Keybind:CreateElement()
    self.Container = Instance.new("Frame")
    self.Container.Name = "Keybind"
    self.Container.Size = UDim2.new(1, -20, 0, self.Description and 60 or 45)
    self.Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Tab.Window.ContentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -100, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(12, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Container
    
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -100, 0, 15)
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
    
    self.KeybindButton = Instance.new("TextButton")
    self.KeybindButton.Name = "Button"
    self.KeybindButton.Size = UDim2.fromOffset(80, 25)
    self.KeybindButton.Position = UDim2.new(1, -90, 0.5, -12.5)
    self.KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.KeybindButton.BackgroundTransparency = 0.3
    self.KeybindButton.BorderSizePixel = 0
    self.KeybindButton.Text = self:GetKeyName(self.Value)
    self.KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.KeybindButton.TextSize = 12
    self.KeybindButton.Font = Enum.Font.SourceSansBold
    self.KeybindButton.AutoButtonColor = false
    self.KeybindButton.TextStrokeTransparency = 0.9
    self.KeybindButton.Parent = self.Container
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = self.KeybindButton
    
    self.Border = Instance.new("UIStroke")
    self.Border.Color = Color3.fromRGB(74, 158, 255)
    self.Border.Thickness = 0
    self.Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Border.Parent = self.KeybindButton
    
    self.KeybindButton.MouseButton1Click:Connect(function()
        self:StartListening()
    end)
    
    self.KeybindButton.MouseEnter:Connect(function()
        if not self.Listening then
            TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end
    end)
    
    self.KeybindButton.MouseLeave:Connect(function()
        if not self.Listening then
            TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
end

function Keybind:GetKeyName(keyCode)
    local keyName = keyCode.Name
    
    local shortcuts = {
        LeftShift = "LShift",
        RightShift = "RShift",
        LeftControl = "LCtrl",
        RightControl = "RCtrl",
        LeftAlt = "LAlt",
        RightAlt = "RAlt",
        CapsLock = "Caps",
        Return = "Enter",
        Backspace = "Back"
    }
    
    return shortcuts[keyName] or keyName
end

function Keybind:StartListening()
    self.Listening = true
    self.KeybindButton.Text = "..."
    
    TweenService:Create(self.Border, TweenInfo.new(0.2), {
        Thickness = 2
    }):Play()
    
    TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(74, 158, 255),
        BackgroundTransparency = 0.8
    }):Play()
end

function Keybind:StopListening()
    self.Listening = false
    self.KeybindButton.Text = self:GetKeyName(self.Value)
    
    TweenService:Create(self.Border, TweenInfo.new(0.2), {
        Thickness = 0
    }):Play()
    
    TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = 0.3
    }):Play()
end

function Keybind:SetupListener()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if self.Listening then
            if input.KeyCode == Enum.KeyCode.Escape then
                self:StopListening()
                return
            end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self:SetValue(input.KeyCode)
                self:StopListening()
            end
        else
            if not gameProcessed and input.KeyCode == self.Value then
                task.spawn(function()
                    self.Callback(self.Value)
                end)
            end
        end
    end)
end

function Keybind:SetValue(keyCode, silent)
    self.Value = keyCode
    self.KeybindButton.Text = self:GetKeyName(keyCode)
end

-- Dropdown Element
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(tab, config)
    local self = setmetatable({}, Dropdown)
    
    if tab.Tab then
        self.Tab = tab.Tab
        self.Window = tab.Window
        self.ParentContainer = tab.Container
    else
        self.Tab = tab
        self.Window = tab.Window
        self.ParentContainer = tab.Window.ContentContainer
    end
    
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
    
    if self.Default then
        if self.Multi then
            if type(self.Default) == "table" then
                for key, value in pairs(self.Default) do
                    if type(key) == "string" and value == true then
                        self.Value[key] = true
                    end
                end
            end
        else
            self.Value = self.Default
        end
        self:UpdateDisplay()
    end
    
    return self
end

function Dropdown:CreateElement()
    self.Container = Instance.new("Frame")
    self.Container.Name = "Dropdown"
    self.Container.Size = UDim2.new(1, -30, 0, 72)
    self.Container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = false
    self.Container.ZIndex = 1
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
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -20, 0, 18)
    self.TitleLabel.Position = UDim2.fromOffset(10, 8)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Container
    
    local dropdownY = 42
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -20, 0, 13)
        self.DescLabel.Position = UDim2.fromOffset(10, 24)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 10
        self.DescLabel.Font = Enum.Font.Gotham
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    self.DropdownButton = Instance.new("TextButton")
    self.DropdownButton.Name = "Button"
    self.DropdownButton.Size = UDim2.new(1, -20, 0, 26)
    self.DropdownButton.Position = UDim2.fromOffset(10, dropdownY)
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
    
    self.DisplayLabel = Instance.new("TextLabel")
    self.DisplayLabel.Name = "Display"
    self.DisplayLabel.Size = UDim2.new(1, -26, 1, 0)
    self.DisplayLabel.Position = UDim2.fromOffset(8, 0)
    self.DisplayLabel.BackgroundTransparency = 1
    self.DisplayLabel.Text = "--"
    self.DisplayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.DisplayLabel.TextSize = 10
    self.DisplayLabel.Font = Enum.Font.Gotham
    self.DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.DisplayLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.DisplayLabel.Parent = self.DropdownButton
    
    self.ArrowIcon = Instance.new("TextLabel")
    self.ArrowIcon.Name = "Arrow"
    self.ArrowIcon.Size = UDim2.fromOffset(14, 14)
    self.ArrowIcon.Position = UDim2.new(1, -18, 0.5, -7)
    self.ArrowIcon.BackgroundTransparency = 1
    self.ArrowIcon.Text = "▼"
    self.ArrowIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.ArrowIcon.TextSize = 10
    self.ArrowIcon.Font = Enum.Font.GothamBold
    self.ArrowIcon.Parent = self.DropdownButton
    
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
    
    self.OptionsContainer = Instance.new("Frame")
    self.OptionsContainer.Name = "Options"
    self.OptionsContainer.Size = UDim2.new(1, -20, 0, 0)
    self.OptionsContainer.Position = UDim2.fromOffset(10, dropdownY + 30)
    self.OptionsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.OptionsContainer.BorderSizePixel = 0
    self.OptionsContainer.ClipsDescendants = true
    self.OptionsContainer.Visible = false
    self.OptionsContainer.ZIndex = 100
    self.OptionsContainer.Parent = self.Window.ScreenGui
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = self.OptionsContainer
    
    local OptionsStroke = Instance.new("UIStroke")
    OptionsStroke.Color = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    OptionsStroke.Thickness = 1
    OptionsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    OptionsStroke.Parent = self.OptionsContainer
    
    if self.Window.AccentElements then
        table.insert(self.Window.AccentElements, OptionsStroke)
    end
    
    self.OptionsScroll = Instance.new("ScrollingFrame")
    self.OptionsScroll.Size = UDim2.new(1, 0, 1, 0)
    self.OptionsScroll.BackgroundTransparency = 1
    self.OptionsScroll.BorderSizePixel = 0
    self.OptionsScroll.ScrollBarThickness = 4
    self.OptionsScroll.ScrollBarImageColor3 = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    self.OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.OptionsScroll.Parent = self.OptionsContainer
    
    if self.Window.AccentElements then
        table.insert(self.Window.AccentElements, self.OptionsScroll)
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
    
    self:CreateOptions()
    
    OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 10)
    end)
    
    self.DropdownButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Opened then
            local mousePos = input.Position
            local buttonPos = self.DropdownButton.AbsolutePosition
            local buttonSize = self.DropdownButton.AbsoluteSize
            local optionsPos = self.OptionsContainer.AbsolutePosition
            local optionsSize = self.OptionsContainer.AbsoluteSize
            
            local inButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                           mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
            local inOptions = mousePos.X >= optionsPos.X and mousePos.X <= optionsPos.X + optionsSize.X and
                            mousePos.Y >= optionsPos.Y and mousePos.Y <= optionsPos.Y + optionsSize.Y
            
            if not inButton and not inOptions then
                self:Close()
            end
        end
    end)
    
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
        optionButton.Size = UDim2.new(1, -10, 0, 25)
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
        
        local checkmark = Instance.new("Frame")
        checkmark.Name = "Check"
        checkmark.Size = UDim2.fromOffset(16, 16)
        checkmark.Position = UDim2.fromOffset(6, 4)
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
        
        local checkIcon = Instance.new("TextLabel")
        checkIcon.Name = "Icon"
        checkIcon.Size = UDim2.new(1, 0, 1, 0)
        checkIcon.BackgroundTransparency = 1
        checkIcon.Text = ""
        checkIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkIcon.TextSize = 12
        checkIcon.Font = Enum.Font.GothamBold
        checkIcon.Parent = checkmark
        
        if not self.Multi then
            checkmark.Visible = false
        end
        
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Name = "Label"
        optionLabel.Size = UDim2.new(1, self.Multi and -32 or -14, 1, 0)
        optionLabel.Position = UDim2.fromOffset(self.Multi and 28 or 7, 0)
        optionLabel.BackgroundTransparency = 1
        optionLabel.Text = value
        optionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        optionLabel.TextSize = 10
        optionLabel.Font = Enum.Font.Gotham
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
        optionLabel.Parent = optionButton
        
        optionButton.MouseButton1Click:Connect(function()
            if self.Multi then
                self:ToggleValue(value)
            else
                self:SetValue(value)
                self:Close()
            end
        end)
        
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
    local targetHeight = (optionCount * 27) + 10
    
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end
    
    local openUpwards = false
    
    local function updatePosition()
        if not self.Opened then return end
        local buttonPos = self.DropdownButton.AbsolutePosition
        local buttonSize = self.DropdownButton.AbsoluteSize
        
        local containerPos = self.Window.ContentContainer.AbsolutePosition
        local containerSize = self.Window.ContentContainer.AbsoluteSize
        local containerBottom = containerPos.Y + containerSize.Y
        local containerTop = containerPos.Y
        
        local dropdownBottom = buttonPos.Y + buttonSize.Y + 5 + targetHeight
        local dropdownTop = buttonPos.Y - 5 - targetHeight
        local maxHeight = targetHeight
        
        local spaceBelow = containerBottom - (buttonPos.Y + buttonSize.Y + 5)
        local spaceAbove = buttonPos.Y - containerTop - 5
        
        if spaceBelow < targetHeight and spaceAbove > spaceBelow then
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
        
        if self.OptionsContainer.AbsoluteSize.Y > maxHeight then
            self.OptionsContainer.Size = UDim2.new(0, buttonSize.X, 0, maxHeight)
        end
    end
    
    self.UpdateConnection = RunService.RenderStepped:Connect(updatePosition)
    
    local buttonPos = self.DropdownButton.AbsolutePosition
    local buttonSize = self.DropdownButton.AbsoluteSize
    
    local containerPos = self.Window.ContentContainer.AbsolutePosition
    local containerSize = self.Window.ContentContainer.AbsoluteSize
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
    
    if openUpwards then
        self.OptionsContainer.Position = UDim2.fromOffset(buttonPos.X, buttonPos.Y)
        self.OptionsContainer.AnchorPoint = Vector2.new(0, 1)
        TweenService:Create(self.OptionsContainer, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, buttonSize.X, 0, targetHeight),
            Position = UDim2.fromOffset(buttonPos.X, buttonPos.Y - 5)
        }):Play()
    else
        self.OptionsContainer.AnchorPoint = Vector2.new(0, 0)
        TweenService:Create(self.OptionsContainer, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, buttonSize.X, 0, targetHeight)
        }):Play()
    end
    
    TweenService:Create(self.ArrowIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Rotation = openUpwards and -180 or 180,
        TextColor3 = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    }):Play()
end

function Dropdown:Close()
    self.Opened = false
    
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end
    
    TweenService:Create(self.OptionsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, self.DropdownButton.AbsoluteSize.X, 0, 0)
    }):Play()
    
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
    
    local accentColor = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    
    local option = self.OptionButtons[value]
    if option then
        if self.Value[value] then
            TweenService:Create(option.Check, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = accentColor
            }):Play()
            TweenService:Create(option.Check:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Color = accentColor
            }):Play()
            
            option.CheckIcon.TextTransparency = 1
            option.CheckIcon.Text = "✓"
            TweenService:Create(option.CheckIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0
            }):Play()
        else
            TweenService:Create(option.Check, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            }):Play()
            TweenService:Create(option.Check:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Color = Color3.fromRGB(70, 70, 70)
            }):Play()
            
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
        
        local accentColor = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
        
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

-- ============================================================================
-- TAB CLASS
-- ============================================================================
local Tab = {}
Tab.__index = Tab

function Tab.new(window, config)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Title = config.Title or "Tab"
    self.Icon = config.Icon or "📄"
    self.Elements = {}
    self.Sections = {}
    self.Selected = false
    
    self:CreateButton()
    self:CreateContentContainer()
    
    return self
end

function Tab:CreateContentContainer()
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "Content_" .. self.Title
    self.ContentContainer.Size = UDim2.new(1, 0, 1, 0)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Visible = false
    self.ContentContainer.Parent = self.Window.ContentContainer
end

function Tab:CreateButton()
    self.Button = Instance.new("TextButton")
    self.Button.Name = self.Title
    self.Button.Size = UDim2.new(1, 0, 0, 40)
    self.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Button.BackgroundTransparency = 0
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.SelectionImageObject = nil
    self.Button.Parent = self.Window.TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = self.Button
    
    local iconIds = {
        ["⚡"] = "rbxassetid://7733992901",
        ["movement"] = "rbxassetid://7733992901",
        ["fly"] = "rbxassetid://7733992901",
        ["👁️"] = "rbxassetid://7733955511",
        ["👁"] = "rbxassetid://7733955511",
        ["esp"] = "rbxassetid://7733955511",
        ["eye"] = "rbxassetid://7733955511",
        ["🤖"] = "rbxassetid://7733920644",
        ["🚜"] = "rbxassetid://7733920644",
        ["autofarm"] = "rbxassetid://7733920644",
        ["farm"] = "rbxassetid://7733920644",
        ["⚙️"] = "rbxassetid://7733955511",
        ["⚙"] = "rbxassetid://7733955511",
        ["settings"] = "rbxassetid://7733955511",
        ["config"] = "rbxassetid://7733955511",
    }
    
    local iconId = iconIds[self.Icon] or iconIds[self.Title:lower()] or "rbxassetid://7733964126"
    
    self.IconLabel = Instance.new("ImageLabel")
    self.IconLabel.Name = "Icon"
    self.IconLabel.Size = UDim2.fromOffset(18, 18)
    self.IconLabel.Position = UDim2.fromOffset(12, 11)
    self.IconLabel.BackgroundTransparency = 1
    self.IconLabel.Image = iconId
    self.IconLabel.ImageColor3 = Color3.fromRGB(150, 150, 150)
    self.IconLabel.Parent = self.Button
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -45, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(38, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.TitleLabel.TextSize = 12
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Button
    
    self.Indicator = Instance.new("Frame")
    self.Indicator.Name = "Indicator"
    self.Indicator.Size = UDim2.new(0, 3, 0, 0)
    self.Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    self.Indicator.AnchorPoint = Vector2.new(0, 0.5)
    self.Indicator.BackgroundColor3 = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    self.Indicator.BorderSizePixel = 0
    self.Indicator.Parent = self.Button
    
    if self.Window.AccentElements then
        table.insert(self.Window.AccentElements, self.Indicator)
    end
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = self.Indicator
    
    self.Button.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)
    
    self.Button.MouseEnter:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ImageColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
        end
    end)
end

function Tab:Select()
    self.Selected = true
    
    local accentColor = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.85
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 3, 0, 30)
    }):Play()
    
    if #self.Sections > 0 then
        self.ContentContainer.Visible = true
        
        for _, section in pairs(self.Sections) do
            if section.Container then
                section.Container.Visible = true
            end
        end
    end
    
    for i, element in pairs(self.Elements) do
        if element and element.Parent then
            element.Visible = true
            
            for _, child in pairs(element:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    child.TextTransparency = 1
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    child.ImageTransparency = 1
                elseif child:IsA("Frame") then
                    child.BackgroundTransparency = 1
                end
            end
            
            task.delay(i * 0.02, function()
                if element and element.Parent and self.Selected then
                    for _, child in pairs(element:GetDescendants()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                            local targetTransparency = 0
                            if child.Name == "Title" or child.Name == "Value" then
                                targetTransparency = 0.3
                            end
                            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                TextTransparency = targetTransparency
                            }):Play()
                        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                ImageTransparency = 0
                            }):Play()
                        elseif child:IsA("Frame") then
                            local targetTransparency = 0
                            if child.Name == "Container" or child.Parent.Name == "Container" then
                                targetTransparency = 0
                            end
                            TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundTransparency = targetTransparency
                            }):Play()
                        end
                    end
                end
            end)
        end
    end
end

function Tab:Deselect()
    self.Selected = false
    
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 3, 0, 0)
    }):Play()
    
    for i, element in pairs(self.Elements) do
        if element and element.Parent then
            for _, child in pairs(element:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextTransparency = 1
                    }):Play()
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        ImageTransparency = 1
                    }):Play()
                elseif child:IsA("Frame") then
                    TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end
        end
    end
    
    task.delay(0.25, function()
        if not self.Selected then
            self.ContentContainer.Visible = false
            
            for _, section in pairs(self.Sections) do
                if section.Container then
                    section.Container.Visible = false
                end
            end
            
            for _, element in pairs(self.Elements) do
                if element and element.Parent then
                    element.Visible = false
                end
            end
        end
    end)
end

function Tab:AddSection(side)
    side = side or "Left"
    
    local sectionContainer = self.ContentContainer:FindFirstChild(side .. "Section")
    if not sectionContainer then
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = side .. "Section"
        scrollFrame.Size = UDim2.new(0.5, -7.5, 1, 0)
        scrollFrame.Position = side == "Left" and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 7.5, 0, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Visible = false
        scrollFrame.Parent = self.ContentContainer
        
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = scrollFrame
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentHeight = Layout.AbsoluteContentSize.Y
            local containerHeight = scrollFrame.AbsoluteSize.Y
            if contentHeight > containerHeight then
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
                scrollFrame.ScrollBarThickness = 4
            else
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, containerHeight)
                scrollFrame.ScrollBarThickness = 0
            end
        end)
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 10)
        Padding.PaddingBottom = UDim.new(0, 10)
        Padding.Parent = scrollFrame
        
        sectionContainer = scrollFrame
        
        if side == "Right" and not self.ContentContainer:FindFirstChild("Divider") then
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Size = UDim2.new(0, 1, 1, 0)
            divider.Position = UDim2.new(0.5, 0, 0, 0)
            divider.AnchorPoint = Vector2.new(0.5, 0)
            divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            divider.BorderSizePixel = 0
            divider.ZIndex = 2
            divider.Parent = self.ContentContainer
        end
    end
    
    local section = {Container = sectionContainer, Tab = self, Side = side, Window = self.Window}
    
    function section:AddToggle(config)
        local t = Toggle.new(section, config)
        t.Container.Visible = false
        table.insert(self.Tab.Elements, t.Container)
        return t
    end
    
    function section:AddSlider(config)
        local s = Slider.new(section, config)
        s.Container.Visible = false
        table.insert(self.Tab.Elements, s.Container)
        return s
    end
    
    function section:AddDropdown(config)
        local d = Dropdown.new(section, config)
        d.Container.Visible = false
        table.insert(self.Tab.Elements, d.Container)
        return d
    end
    
    function section:AddButton(config)
        local b = Button.new(section, config)
        b.Container.Visible = false
        table.insert(self.Tab.Elements, b.Container)
        return b
    end
    
    function section:AddInput(config)
        local i = Input.new(section, config)
        i.Container.Visible = false
        table.insert(self.Tab.Elements, i.Container)
        return i
    end
    
    function section:AddKeybind(config)
        local k = Keybind.new(section, config)
        k.Container.Visible = false
        table.insert(self.Tab.Elements, k.Container)
        return k
    end
    
    table.insert(self.Sections, section)
    return section
end

function Tab:AddToggle(config)
    local t = Toggle.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
    t.Container.Visible = false
    table.insert(self.Elements, t.Container)
    return t
end

function Tab:AddSlider(config)
    local s = Slider.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
    s.Container.Visible = false
    table.insert(self.Elements, s.Container)
    return s
end

function Tab:AddDropdown(config)
    local d = Dropdown.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
    d.Container.Visible = false
    table.insert(self.Elements, d.Container)
    return d
end

function Tab:AddButton(config)
    local b = Button.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
    b.Container.Visible = false
    table.insert(self.Elements, b.Container)
    return b
end

function Tab:AddInput(config)
    local i = Input.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
    i.Container.Visible = false
    table.insert(self.Elements, i.Container)
    return i
end

function Tab:AddKeybind(config)
    local k = Keybind.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
    k.Container.Visible = false
    table.insert(self.Elements, k.Container)
    return k
end



-- ============================================================================
-- WINDOW CLASS
-- ============================================================================

local Window = {}
Window.__index = Window

-- Default configuration
local DEFAULT_CONFIG = {
    Title = "Sosalkin Hub",
    Size = UDim2.fromOffset(900, 650),
    MinSize = Vector2.new(700, 550),
    MaxSize = Vector2.new(1200, 800),
    Position = UDim2.new(0.5, -450, 0.5, -325),
    Transparency = 0.1,
    BlurEnabled = true,
    Draggable = true,
    Resizable = true,
    MinimizeKey = Enum.KeyCode.RightControl,
    HubStatus = "shub",
    StatusColor = Color3.fromRGB(150, 150, 150),
    PremiumExpiry = nil,
    AccentTheme = "Blue",
    ColorScheme = "Dark",
}

function Window.new(config)
    local self = setmetatable({}, Window)
    
    -- Merge config with defaults
    self.Config = {}
    for k, v in pairs(DEFAULT_CONFIG) do
        self.Config[k] = config[k] or v
    end
    
    self.Minimized = false
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.AccentColor = Color3.fromRGB(74, 158, 255)
    self.AccentElements = {}
    self._delayShow = config._delayShow or false
    
    -- Create GUI
    self:CreateGUI()
    self:SetupDragging()
    self:SetupResizing()
    self:SetupMinimize()
    
    -- Apply theme if specified
    if self.Config.AccentTheme or self.Config.ColorScheme then
        task.defer(function()
            if self.Config.AccentTheme and self.Config.AccentTheme ~= "Blue" then
                self:SetTheme(self.Config.AccentTheme)
            end
            if self.Config.ColorScheme and self.Config.ColorScheme ~= "Dark" then
                self:SetColorScheme(self.Config.ColorScheme)
            end
        end)
    end
    
    -- Initialize particles system
    self:InitParticles()
    
    -- Initialize notification system (will be loaded separately)
    self.Notification = nil
    
    return self
end

function Window:CreateGUI()
    -- Remove old UI if exists
    local coreGui = game:GetService("CoreGui")
    local oldUI = coreGui:FindFirstChild("SsolyUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Remove old blur if exists
    local lighting = game:GetService("Lighting")
    local oldBlur = lighting:FindFirstChild("SsolyBlur")
    if oldBlur then
        oldBlur:Destroy()
    end
    
    -- Main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SsolyUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = false
    self.ScreenGui.Enabled = not self._delayShow
    self.ScreenGui.Parent = coreGui
    
    -- Blur effect
    if self.Config.BlurEnabled then
        self.Blur = Instance.new("BlurEffect")
        self.Blur.Name = "SsolyBlur"
        self.Blur.Size = self._delayShow and 0 or 10
        self.Blur.Parent = lighting
    end
    
    self.BlurSize = 10
    
    -- Main container (rounded)
    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.Size = self.Config.Size
    self.Container.Position = self.Config.Position
    self.Container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.Container.BackgroundTransparency = self.Config.Transparency
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.SelectionImageObject = nil
    self.Container.Parent = self.ScreenGui
    
    -- Rounded corners (bigger radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = self.Container
    
    -- Border (stroke) - thinner and darker
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(40, 40, 40)
    UIStroke.Thickness = 1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = self.Container
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 35)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    self.TitleBar.BackgroundTransparency = 0
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Container
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = self.TitleBar
    
    -- Divider line (thinner)
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, 0)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Divider.BorderSizePixel = 0
    Divider.Parent = self.TitleBar
    
    -- Title text with time and online
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -140, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(12, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Config.Title .. " | " .. os.date("%H:%M") .. " | Online: -- | Loading..."
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.TitleLabel.Parent = self.TitleBar
    
    -- Load version from GitHub
    self.UIVersion = "..."
    task.spawn(function()
        local success, version = pcall(function()
            local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
            return game:HttpGet(baseUrl .. "version.txt?v=" .. math.random(1, 999999) .. "&t=" .. tick())
        end)
        if success and version then
            self.UIVersion = version:gsub("%s+", "")
        else
            self.UIVersion = "?.?.?"
        end
    end)
    
    -- Update time and version
    task.spawn(function()
        while self.TitleLabel and self.TitleLabel.Parent do
            self.TitleLabel.Text = self.Config.Title .. " | " .. os.date("%H:%M") .. " | Online: -- | v" .. self.UIVersion
            task.wait(1)
        end
    end)
    
    -- Close button (X)
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "Close"
    self.CloseButton.Size = UDim2.fromOffset(25, 25)
    self.CloseButton.Position = UDim2.new(1, -32, 0.5, -12.5)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.CloseButton.BackgroundTransparency = 0
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.CloseButton.TextSize = 18
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.AutoButtonColor = false
    self.CloseButton.Parent = self.TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = self.CloseButton
    
    -- Minimize button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "Minimize"
    self.MinimizeButton.Size = UDim2.fromOffset(25, 25)
    self.MinimizeButton.Position = UDim2.new(1, -62, 0.5, -12.5)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.MinimizeButton.BackgroundTransparency = 0
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.Text = "−"
    self.MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.MinimizeButton.TextSize = 16
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.AutoButtonColor = false
    self.MinimizeButton.Parent = self.TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 4)
    MinCorner.Parent = self.MinimizeButton
    
    -- Tab container (left side)
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 140, 1, -105)
    self.TabContainer.Position = UDim2.fromOffset(8, 40)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.Container
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = self.TabContainer
    
    -- Content container (right side) - darker with card style
    self.ContentContainer = Instance.new("ScrollingFrame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -160, 1, -45)
    self.ContentContainer.Position = UDim2.fromOffset(152, 40)
    self.ContentContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    self.ContentContainer.BackgroundTransparency = 0
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.ScrollBarThickness = 4
    self.ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    self.ContentContainer.ScrollBarImageTransparency = 0
    self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentContainer.Parent = self.Container
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = self.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = self.ContentContainer
    
    -- Auto-update canvas size (FIX: prevent infinite growth + hide scrollbar when not needed)
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = ContentLayout.AbsoluteContentSize.Y
        local containerHeight = self.ContentContainer.AbsoluteSize.Y
        -- Cap maximum canvas size to prevent infinite growth
        local maxCanvasSize = containerHeight * 3
        if contentHeight > containerHeight then
            self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, math.min(contentHeight + 20, maxCanvasSize))
            self.ContentContainer.ScrollBarThickness = 4
        else
            self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, containerHeight)
            self.ContentContainer.ScrollBarThickness = 0
        end
    end)
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 15)
    ContentPadding.PaddingRight = UDim.new(0, 15)
    ContentPadding.Parent = self.ContentContainer
    
    -- Bottom glow effect (subtle accent glow)
    self.BottomGlow = Instance.new("Frame")
    self.BottomGlow.Name = "BottomGlow"
    self.BottomGlow.Size = UDim2.new(1, 0, 0, 3)
    self.BottomGlow.Position = UDim2.new(0, 0, 1, -3)
    self.BottomGlow.BackgroundColor3 = self.AccentColor
    self.BottomGlow.BackgroundTransparency = 0.7
    self.BottomGlow.BorderSizePixel = 0
    self.BottomGlow.ZIndex = 10
    self.BottomGlow.Parent = self.Container
    
    -- Glow gradient for softer effect
    local glowGradient = Instance.new("UIGradient")
    glowGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    glowGradient.Rotation = 0
    glowGradient.Parent = self.BottomGlow
    
    table.insert(self.AccentElements, self.BottomGlow)
    
    -- Player profile (bottom-left corner) - card style
    self.ProfileContainer = Instance.new("Frame")
    self.ProfileContainer.Name = "Profile"
    self.ProfileContainer.Size = UDim2.new(0, 140, 0, 50)
    self.ProfileContainer.Position = UDim2.new(0, 8, 1, -58)
    self.ProfileContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.ProfileContainer.BackgroundTransparency = 0
    self.ProfileContainer.BorderSizePixel = 0
    self.ProfileContainer.Parent = self.Container
    
    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 10)
    ProfileCorner.Parent = self.ProfileContainer
    
    local ProfileStroke = Instance.new("UIStroke")
    ProfileStroke.Color = Color3.fromRGB(40, 40, 40)
    ProfileStroke.Thickness = 1
    ProfileStroke.Parent = self.ProfileContainer
    
    -- Get player info
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    -- Avatar circle
    self.AvatarFrame = Instance.new("Frame")
    self.AvatarFrame.Name = "Avatar"
    self.AvatarFrame.Size = UDim2.fromOffset(36, 36)
    self.AvatarFrame.Position = UDim2.fromOffset(7, 7)
    self.AvatarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.AvatarFrame.BorderSizePixel = 0
    self.AvatarFrame.Parent = self.ProfileContainer
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = self.AvatarFrame
    
    -- Avatar image
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatarImage.Parent = self.AvatarFrame
    
    local AvatarImgCorner = Instance.new("UICorner")
    AvatarImgCorner.CornerRadius = UDim.new(1, 0)
    AvatarImgCorner.Parent = avatarImage
    
    -- Username
    self.UsernameLabel = Instance.new("TextLabel")
    self.UsernameLabel.Name = "Username"
    self.UsernameLabel.Size = UDim2.new(1, -52, 0, 16)
    self.UsernameLabel.Position = UDim2.fromOffset(48, 10)
    self.UsernameLabel.BackgroundTransparency = 1
    self.UsernameLabel.Text = player.Name
    self.UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.UsernameLabel.TextSize = 12
    self.UsernameLabel.Font = Enum.Font.GothamBold
    self.UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.UsernameLabel.Parent = self.ProfileContainer
    
    -- Display name (if different)
    if player.DisplayName ~= player.Name then
        self.DisplayNameLabel = Instance.new("TextLabel")
        self.DisplayNameLabel.Name = "DisplayName"
        self.DisplayNameLabel.Size = UDim2.new(1, -52, 0, 14)
        self.DisplayNameLabel.Position = UDim2.fromOffset(48, 26)
        self.DisplayNameLabel.BackgroundTransparency = 1
        self.DisplayNameLabel.Text = "@" .. player.Name
        self.DisplayNameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DisplayNameLabel.TextSize = 10
        self.DisplayNameLabel.Font = Enum.Font.Gotham
        self.DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        self.DisplayNameLabel.Parent = self.ProfileContainer
        
        -- Update username to show display name
        self.UsernameLabel.Text = player.DisplayName
    end
    
    -- Hub status label
    self.StatusLabel = Instance.new("TextLabel")
    self.StatusLabel.Name = "Status"
    self.StatusLabel.Size = UDim2.new(1, -52, 0, 12)
    self.StatusLabel.Position = UDim2.fromOffset(48, player.DisplayName ~= player.Name and 38 or 28)
    self.StatusLabel.BackgroundTransparency = 1
    self.StatusLabel.Text = "shub"
    self.StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.StatusLabel.TextSize = 9
    self.StatusLabel.Font = Enum.Font.GothamBold
    self.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.StatusLabel.Parent = self.ProfileContainer
    
    -- Set initial status
    task.defer(function()
        self:SetHubStatus(self.Config.HubStatus, self.Config.PremiumExpiry)
    end)
    
    -- Resize handle (curved bar around bottom-right corner) - OUTSIDE container
    self.ResizeHandle = Instance.new("Frame")
    self.ResizeHandle.Name = "ResizeHandle"
    self.ResizeHandle.Size = UDim2.fromOffset(30, 30)
    self.ResizeHandle.Position = UDim2.new(0, 0, 0, 0)
    self.ResizeHandle.AnchorPoint = Vector2.new(0, 0)
    self.ResizeHandle.BackgroundTransparency = 1
    self.ResizeHandle.ClipsDescendants = false
    self.ResizeHandle.ZIndex = 5
    self.ResizeHandle.Visible = false
    self.ResizeHandle.Parent = self.ScreenGui
    
    self.ResizeBars = {}
    
    -- Create arc using many bars for smooth appearance
    for i = 0, 20 do
        local angle = (i / 20) * 90
        local rad = math.rad(angle)
        local radius = 12
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.fromOffset(6, 6)
        bar.Position = UDim2.fromOffset(
            15 + math.cos(rad) * radius,
            15 + math.sin(rad) * radius
        )
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.BackgroundColor3 = self.AccentColor
        bar.BackgroundTransparency = 0.3
        bar.BorderSizePixel = 0
        bar.Rotation = angle
        bar.Parent = self.ResizeHandle
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = bar
        
        table.insert(self.ResizeBars, bar)
        table.insert(self.AccentElements, bar)
    end
    
    -- Vertical resize handle (bottom center)
    self.ResizeHandleV = Instance.new("Frame")
    self.ResizeHandleV.Name = "ResizeHandleV"
    self.ResizeHandleV.Size = UDim2.fromOffset(30, 6)
    self.ResizeHandleV.Position = UDim2.new(0, 0, 0, 0)
    self.ResizeHandleV.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ResizeHandleV.BackgroundColor3 = self.AccentColor
    self.ResizeHandleV.BackgroundTransparency = 0.3
    self.ResizeHandleV.BorderSizePixel = 0
    self.ResizeHandleV.ZIndex = 5
    self.ResizeHandleV.Visible = false
    self.ResizeHandleV.Parent = self.ScreenGui
    
    table.insert(self.AccentElements, self.ResizeHandleV)
    
    local ResizeVCorner = Instance.new("UICorner")
    ResizeVCorner.CornerRadius = UDim.new(1, 0)
    ResizeVCorner.Parent = self.ResizeHandleV
    
    -- Horizontal resize handle (right center)
    self.ResizeHandleH = Instance.new("Frame")
    self.ResizeHandleH.Name = "ResizeHandleH"
    self.ResizeHandleH.Size = UDim2.fromOffset(6, 30)
    self.ResizeHandleH.Position = UDim2.new(0, 0, 0, 0)
    self.ResizeHandleH.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ResizeHandleH.BackgroundColor3 = self.AccentColor
    self.ResizeHandleH.BackgroundTransparency = 0.3
    self.ResizeHandleH.BorderSizePixel = 0
    self.ResizeHandleH.ZIndex = 5
    self.ResizeHandleH.Visible = false
    self.ResizeHandleH.Parent = self.ScreenGui
    
    table.insert(self.AccentElements, self.ResizeHandleH)
    
    local ResizeHCorner = Instance.new("UICorner")
    ResizeHCorner.CornerRadius = UDim.new(1, 0)
    ResizeHCorner.Parent = self.ResizeHandleH
end


function Window:CreateSnowEffect()
    -- Snow container
    local snowContainer = Instance.new("Frame")
    snowContainer.Name = "SnowEffect"
    snowContainer.Size = UDim2.new(1, 0, 1, 0)
    snowContainer.BackgroundTransparency = 1
    snowContainer.ClipsDescendants = true
    snowContainer.ZIndex = 0
    snowContainer.Parent = self.Container
    
    -- Create snowflakes
    local function createSnowflake()
        local snowflake = Instance.new("Frame")
        snowflake.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
        snowflake.Position = UDim2.new(math.random(0, 100) / 100, 0, 0, -10)
        snowflake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        snowflake.BackgroundTransparency = math.random(30, 70) / 100
        snowflake.BorderSizePixel = 0
        snowflake.Parent = snowContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = snowflake
        
        -- Animate falling
        local duration = math.random(8, 15)
        local endY = self.Container.AbsoluteSize.Y + 10
        
        TweenService:Create(snowflake, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.new(snowflake.Position.X.Scale + math.random(-10, 10) / 100, 0, 1, endY)
        }):Play()
        
        -- Remove after animation
        task.delay(duration, function()
            if snowflake and snowflake.Parent then
                snowflake:Destroy()
            end
        end)
    end
    
    -- Spawn snowflakes continuously
    task.spawn(function()
        while self.Container and self.Container.Parent do
            createSnowflake()
            task.wait(math.random(100, 300) / 1000)
        end
    end)
end

function Window:SetupDragging()
    if not self.Config.Draggable then return end
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    -- Main window dragging
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Container.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            
            -- Smooth animation
            TweenService:Create(self.Container, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Minimized indicator dragging
    local minDragging = false
    local minDragStart = nil
    local minStartPos = nil
    local lastClickTime = 0
end

function Window:SetupResizing()
    if not self.Config.Resizable then return end
    
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    local resizeMode = nil
    
    -- Update resize handle positions
    local function updateResizePositions()
        local containerPos = self.Container.AbsolutePosition
        local containerSize = self.Container.AbsoluteSize
        
        -- Corner handle (very close to menu corner)
        self.ResizeHandle.Position = UDim2.fromOffset(
            containerPos.X + containerSize.X - 25,
            containerPos.Y + containerSize.Y - 25
        )
        
        -- Vertical handle (bottom center)
        self.ResizeHandleV.Position = UDim2.fromOffset(
            containerPos.X + containerSize.X / 2,
            containerPos.Y + containerSize.Y + 3
        )
        
        -- Horizontal handle (right center)
        self.ResizeHandleH.Position = UDim2.fromOffset(
            containerPos.X + containerSize.X + 3,
            containerPos.Y + containerSize.Y / 2
        )
    end
    
    self.Container:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateResizePositions)
    self.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateResizePositions)
    updateResizePositions()
    
    -- Corner resize (both directions)
    self.ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeMode = "both"
            resizeStart = input.Position
            startSize = self.Container.AbsoluteSize
        end
    end)
    
    -- Vertical resize (height only)
    self.ResizeHandleV.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeMode = "vertical"
            resizeStart = input.Position
            startSize = self.Container.AbsoluteSize
        end
    end)
    
    -- Horizontal resize (width only)
    self.ResizeHandleH.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeMode = "horizontal"
            resizeStart = input.Position
            startSize = self.Container.AbsoluteSize
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = startSize.X
            local newHeight = startSize.Y
            
            if resizeMode == "both" then
                newWidth = math.clamp(startSize.X + delta.X, self.Config.MinSize.X, self.Config.MaxSize.X)
                newHeight = math.clamp(startSize.Y + delta.Y, self.Config.MinSize.Y, self.Config.MaxSize.Y)
            elseif resizeMode == "vertical" then
                newHeight = math.clamp(startSize.Y + delta.Y, self.Config.MinSize.Y, self.Config.MaxSize.Y)
            elseif resizeMode == "horizontal" then
                newWidth = math.clamp(startSize.X + delta.X, self.Config.MinSize.X, self.Config.MaxSize.X)
            end
            
            self.Container.Size = UDim2.fromOffset(newWidth, newHeight)
            self.Config.Size = UDim2.fromOffset(newWidth, newHeight)
            updateResizePositions()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            resizeMode = nil
        end
    end)
    
    -- Hover effects
    self.ResizeHandle.MouseEnter:Connect(function()
        for _, bar in ipairs(self.ResizeBars) do
            TweenService:Create(bar, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        end
    end)
    
    self.ResizeHandle.MouseLeave:Connect(function()
        if not resizing then
            for _, bar in ipairs(self.ResizeBars) do
                TweenService:Create(bar, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.3
                }):Play()
            end
        end
    end)
    
    self.ResizeHandleV.MouseEnter:Connect(function()
        TweenService:Create(self.ResizeHandleV, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)
    
    self.ResizeHandleV.MouseLeave:Connect(function()
        if not resizing then
            TweenService:Create(self.ResizeHandleV, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
    
    self.ResizeHandleH.MouseEnter:Connect(function()
        TweenService:Create(self.ResizeHandleH, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)
    
    self.ResizeHandleH.MouseLeave:Connect(function()
        if not resizing then
            TweenService:Create(self.ResizeHandleH, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
end


function Window:SetupMinimize()
    -- Close button click - FADE OUT with color preservation
    self.CloseButton.MouseButton1Click:Connect(function()
        if self._closing then return end
        self._closing = true
        
        -- Hide resize handles IMMEDIATELY
        self.ResizeHandle.Visible = false
        self.ResizeHandleV.Visible = false
        self.ResizeHandleH.Visible = false
        
        -- Stop particles IMMEDIATELY
        if self.ParticleSystem and self.ParticleSystem.Container then
            self.ParticleSystem.Container.Visible = false
            self.ParticleSystem.Running = false
        end
        
        -- Simple fade: only animate Container transparency
        local fadeDuration = 0.3
        local fadeInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        -- Fade only the main container
        TweenService:Create(self.Container, fadeInfo, {
            BackgroundTransparency = 1
        }):Play()
        
        -- Fade blur
        if self.Blur then
            TweenService:Create(self.Blur, fadeInfo, {Size = 0}):Play()
        end
        
        -- Hide after fade completes
        task.delay(fadeDuration, function()
            self.ScreenGui.Enabled = false
            self._wasClosedWithX = true
            self._closing = false
            
            -- Restore container transparency
            self.Container.BackgroundTransparency = self.Config.Transparency
        end)
    end)
    
    -- Close button hover
    self.CloseButton.MouseEnter:Connect(function()
        TweenService:Create(self.CloseButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        }):Play()
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        TweenService:Create(self.CloseButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
    end)
    
    -- Minimize button click
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Hotkey - TOGGLE MINIMIZE or RESTORE after X close
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Config.MinimizeKey then
            if self._closing then return end
            
            -- If was closed with X, restore to MINIMIZED state (title bar only)
            if self._wasClosedWithX and not self.ScreenGui.Enabled then
                self._wasClosedWithX = false
                
                -- Set to minimized state FIRST
                self.Minimized = true
                
                -- Set Container to title bar size
                self.Container.Size = UDim2.fromOffset(400, 35)
                
                -- Hide content elements
                self.ContentContainer.Visible = false
                self.TabContainer.Visible = false
                self.ProfileContainer.Visible = false
                self.BottomGlow.Visible = false
                
                -- Start with transparent container
                self.Container.BackgroundTransparency = 1
                
                -- Enable GUI (show title bar)
                self.ScreenGui.Enabled = true
                
                -- Fade in title bar
                TweenService:Create(self.Container, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = self.Config.Transparency
                }):Play()
                
                -- Don't show blur when minimized
                if self.Blur then
                    self.Blur.Size = 0
                end
                
                -- Don't show particles when minimized
                if self.ParticleSystem and self.ParticleSystem.Container then
                    self.ParticleSystem.Container.Visible = false
                    self.ParticleSystem.Running = false
                end
                
                -- Don't show resize handles when minimized
                self.ResizeHandle.Visible = false
                self.ResizeHandleV.Visible = false
                self.ResizeHandleH.Visible = false
            else
                -- Normal minimize toggle
                self:ToggleMinimize()
            end
        end
    end)
    
    -- Minimize button hover
    self.MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(self.MinimizeButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    self.MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(self.MinimizeButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
    end)
end


function Window:ToggleMinimize()
    if self._minimizing or self._closing then return end
    self._minimizing = true
    
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        -- Save current position
        self._savedPosition = self.Container.Position
        
        -- Hide blur
        if self.Blur then
            TweenService:Create(self.Blur, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = 0}):Play()
        end
        
        -- Hide particles IMMEDIATELY
        if self.ParticleSystem and self.ParticleSystem.Container then
            self.ParticleSystem.Container.Visible = false
            self.ParticleSystem.Running = false
        end
        
        -- Hide resize handles
        self.ResizeHandle.Visible = false
        self.ResizeHandleV.Visible = false
        self.ResizeHandleH.Visible = false
        
        -- HIDE ProfileContainer and TabContainer IMMEDIATELY to prevent overlap
        self.ProfileContainer.Visible = false
        self.TabContainer.Visible = false
        
        -- Fade out and shrink simultaneously
        local duration = 0.25
        local fadeInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint)
        
        -- Fade out content while shrinking
        TweenService:Create(self.ContentContainer, fadeInfo, {
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(self.BottomGlow, fadeInfo, {
            BackgroundTransparency = 1
        }):Play()
        
        -- Fade out all text and images in ContentContainer ONLY
        for _, desc in pairs(self.ContentContainer:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                TweenService:Create(desc, fadeInfo, {
                    TextTransparency = 1
                }):Play()
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                TweenService:Create(desc, fadeInfo, {
                    ImageTransparency = 1
                }):Play()
            end
        end
        
        -- Shrink to title bar - START IMMEDIATELY (no delay)
        TweenService:Create(self.Container, fadeInfo, {
            Size = UDim2.fromOffset(400, 35)
        }):Play()
        
        -- Hide elements AFTER animation completes (ProfileContainer and TabContainer already hidden)
        task.delay(duration, function()
            self.ContentContainer.Visible = false
            self.BottomGlow.Visible = false
            self._minimizing = false
        end)
    else
        -- Show elements FIRST (but keep them transparent)
        self.ContentContainer.Visible = true
        self.TabContainer.Visible = true
        self.ProfileContainer.Visible = true
        self.BottomGlow.Visible = true
        
        -- Expand and fade in simultaneously
        local duration = 0.25
        local fadeInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint)
        
        -- Expand container
        TweenService:Create(self.Container, fadeInfo, {
            Size = self.Config.Size,
            Position = self._savedPosition or self.Config.Position
        }):Play()
        
        -- Fade in content
        TweenService:Create(self.ContentContainer, fadeInfo, {
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(self.TabContainer, fadeInfo, {
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(self.ProfileContainer, fadeInfo, {
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(self.BottomGlow, fadeInfo, {
            BackgroundTransparency = 0.7
        }):Play()
        
        -- Fade in ProfileContainer stroke
        local profileStroke = self.ProfileContainer:FindFirstChildOfClass("UIStroke")
        if profileStroke then
            TweenService:Create(profileStroke, fadeInfo, {
                Transparency = 0
            }):Play()
        end
        
        -- Fade in all text and images
        for _, container in pairs({self.ContentContainer, self.TabContainer, self.ProfileContainer}) do
            for _, desc in pairs(container:GetDescendants()) do
                if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                    TweenService:Create(desc, fadeInfo, {
                        TextTransparency = 0
                    }):Play()
                elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                    TweenService:Create(desc, fadeInfo, {
                        ImageTransparency = 0
                    }):Play()
                end
            end
        end
        
        -- Show blur and particles
        if self.Blur then
            TweenService:Create(self.Blur, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = self.BlurSize}):Play()
        end
        
        if self.ParticleSystem and self.ParticleSystem.Container then
            self.ParticleSystem.Container.Visible = true
            self.ParticleSystem.Running = true
        end
        
        -- Show resize handles
        task.delay(duration, function()
            self.ResizeHandle.Visible = true
            self.ResizeHandleV.Visible = true
            self.ResizeHandleH.Visible = true
            self._minimizing = false
        end)
    end
end


function Window:AddTab(config)
    -- Use local Tab class instead of loadstring
    local tab = Tab.new(self, config)
    table.insert(self.Tabs, tab)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function Window:SelectTab(tab)
    if self.CurrentTab == tab then return end
    if self._switchingTab then return end
    
    self._switchingTab = true
    
    -- Deselect current tab with fade out
    if self.CurrentTab then
        self.CurrentTab:Deselect()
        
        -- Wait for fade out to complete, then show new tab
        task.delay(0.25, function()
            self.CurrentTab = tab
            tab:Select()
            
            task.delay(0.4, function()
                self._switchingTab = false
            end)
        end)
    else
        -- No current tab, show immediately
        self.CurrentTab = tab
        tab:Select()
        self._switchingTab = false
    end
end

function Window:Notify(config)
    -- Use local Notification system instead of loadstring
    if not self.Notification then
        self.Notification = Notification
        self.Notification:Init(self.ScreenGui)
    end
    
    self.Notification:Show(config)
end


function Window:SetBlurSize(size)
    self.BlurSize = size
    if self.Blur and not self.Minimized then
        TweenService:Create(self.Blur, TweenInfo.new(0.2), {Size = size}):Play()
    end
end

function Window:SetAccentColor(color)
    self.AccentColor = color
    
    -- Update particle system color
    if self.ParticleSystem then
        self.ParticleSystem:SetAccentColor(color)
    end
    
    -- Update all accent elements safely with smooth transition
    for i = #self.AccentElements, 1, -1 do
        local element = self.AccentElements[i]
        if not element or not element.Parent then
            table.remove(self.AccentElements, i)
        else
            pcall(function()
                if element:IsA("UIStroke") then
                    TweenService:Create(element, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Color = color
                    }):Play()
                elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
                    TweenService:Create(element, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        ImageColor3 = color
                    }):Play()
                elseif element:IsA("ScrollingFrame") then
                    TweenService:Create(element, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        ScrollBarImageColor3 = color
                    }):Play()
                elseif element:IsA("Frame") or element:IsA("TextButton") then
                    TweenService:Create(element, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = color
                    }):Play()
                end
            end)
        end
    end
    
    -- Update active tab background with smooth transition
    if self.CurrentTab and self.CurrentTab.Button then
        pcall(function()
            TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = color
            }):Play()
        end)
    end
    
    -- Update all active toggles and dropdowns with smooth transition
    for _, tab in pairs(self.Tabs) do
        for _, element in pairs(tab.Elements) do
            if element and element.Parent then
                pcall(function()
                    -- Toggle switches
                    local switchBg = element:FindFirstChild("SwitchBg", true)
                    if switchBg and switchBg.BackgroundColor3 ~= Color3.fromRGB(50, 50, 50) then
                        TweenService:Create(switchBg, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundColor3 = color
                        }):Play()
                    end
                    
                    -- Dropdown checkmarks
                    for _, child in pairs(element:GetDescendants()) do
                        if child.Name == "Check" and child:IsA("Frame") then
                            local stroke = child:FindFirstChildOfClass("UIStroke")
                            if stroke and child.BackgroundColor3 ~= Color3.fromRGB(25, 25, 25) then
                                TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                    BackgroundColor3 = color
                                }):Play()
                                TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                    Color = color
                                }):Play()
                            end
                        end
                    end
                end)
            end
        end
    end
end


function Window:SetTheme(themeName)
    local themes = {
        -- Существующие темы
        Ocean = {accent = Color3.fromRGB(52, 152, 219), bg = Color3.fromRGB(15, 25, 35)},
        Sunset = {accent = Color3.fromRGB(255, 107, 107), bg = Color3.fromRGB(35, 20, 20)},
        Forest = {accent = Color3.fromRGB(46, 213, 115), bg = Color3.fromRGB(20, 30, 20)},
        Purple = {accent = Color3.fromRGB(155, 89, 182), bg = Color3.fromRGB(30, 20, 35)},
        Midnight = {accent = Color3.fromRGB(108, 122, 137), bg = Color3.fromRGB(10, 12, 15)},
        Cherry = {accent = Color3.fromRGB(255, 71, 87), bg = Color3.fromRGB(30, 15, 18)},
        Mint = {accent = Color3.fromRGB(85, 239, 196), bg = Color3.fromRGB(18, 28, 25)},
        Gold = {accent = Color3.fromRGB(253, 203, 110), bg = Color3.fromRGB(30, 25, 15)},
        Rose = {accent = Color3.fromRGB(253, 121, 168), bg = Color3.fromRGB(32, 18, 25)},
        Sky = {accent = Color3.fromRGB(116, 185, 255), bg = Color3.fromRGB(18, 22, 30)},
        Lavender = {accent = Color3.fromRGB(179, 136, 255), bg = Color3.fromRGB(25, 20, 32)},
        Coral = {accent = Color3.fromRGB(255, 127, 80), bg = Color3.fromRGB(32, 22, 18)},
        Teal = {accent = Color3.fromRGB(72, 219, 251), bg = Color3.fromRGB(15, 28, 30)},
        Amber = {accent = Color3.fromRGB(255, 193, 7), bg = Color3.fromRGB(30, 27, 15)},
        Crimson = {accent = Color3.fromRGB(220, 20, 60), bg = Color3.fromRGB(28, 12, 15)},
        
        -- Новые экзотические темы
        Neon = {accent = Color3.fromRGB(0, 255, 255), bg = Color3.fromRGB(10, 10, 20)},
        Toxic = {accent = Color3.fromRGB(185, 255, 0), bg = Color3.fromRGB(18, 25, 12)},
        Magma = {accent = Color3.fromRGB(255, 69, 0), bg = Color3.fromRGB(35, 15, 10)},
        Galaxy = {accent = Color3.fromRGB(138, 43, 226), bg = Color3.fromRGB(15, 10, 25)},
        Arctic = {accent = Color3.fromRGB(175, 238, 238), bg = Color3.fromRGB(18, 25, 28)},
        Sakura = {accent = Color3.fromRGB(255, 182, 193), bg = Color3.fromRGB(30, 22, 24)},
        Venom = {accent = Color3.fromRGB(148, 0, 211), bg = Color3.fromRGB(20, 10, 25)},
        Ember = {accent = Color3.fromRGB(255, 140, 0), bg = Color3.fromRGB(32, 20, 12)},
        Aqua = {accent = Color3.fromRGB(0, 206, 209), bg = Color3.fromRGB(12, 22, 25)},
        Void = {accent = Color3.fromRGB(75, 0, 130), bg = Color3.fromRGB(8, 5, 12)},
    }
    
    local theme = themes[themeName] or themes.Ocean
    self:SetAccentColor(theme.accent)
    
    -- Update background colors
    local duration = 0.6
    local easing = Enum.EasingStyle.Quint
    
    TweenService:Create(self.Container, TweenInfo.new(duration, easing), {
        BackgroundColor3 = theme.bg
    }):Play()
    
    local titleBg = Color3.fromRGB(
        math.max(0, theme.bg.R * 255 - 3),
        math.max(0, theme.bg.G * 255 - 3),
        math.max(0, theme.bg.B * 255 - 3)
    )
    TweenService:Create(self.TitleBar, TweenInfo.new(duration, easing), {
        BackgroundColor3 = titleBg
    }):Play()
    
    local profileBg = Color3.fromRGB(
        math.min(255, theme.bg.R * 255 + 3),
        math.min(255, theme.bg.G * 255 + 3),
        math.min(255, theme.bg.B * 255 + 3)
    )
    TweenService:Create(self.ProfileContainer, TweenInfo.new(duration, easing), {
        BackgroundColor3 = profileBg
    }):Play()
    
    -- Update tab buttons
    for _, tab in pairs(self.Tabs) do
        if tab.Button then
            if tab.Selected then
                -- Active tab - use accent color
                TweenService:Create(tab.Button, TweenInfo.new(duration, easing), {
                    BackgroundColor3 = theme.accent,
                    BackgroundTransparency = 0.85
                }):Play()
            else
                -- Inactive tab - use theme background
                local tabBg = Color3.fromRGB(
                    math.min(255, theme.bg.R * 255 + 5),
                    math.min(255, theme.bg.G * 255 + 5),
                    math.min(255, theme.bg.B * 255 + 5)
                )
                TweenService:Create(tab.Button, TweenInfo.new(duration, easing), {
                    BackgroundColor3 = tabBg,
                    BackgroundTransparency = 0
                }):Play()
            end
        end
        
        -- Update elements
        for _, section in pairs(tab.Sections) do
            if section.Container then
                for _, child in pairs(section.Container:GetDescendants()) do
                    if child:IsA("Frame") and child.Parent and child.Parent:IsA("ScrollingFrame") then
                        local isSwitchBg = child.Name == "SwitchBg"
                        local isCheck = child.Name == "Check"
                        
                        if not isSwitchBg and not isCheck then
                            local elemBg = Color3.fromRGB(
                                math.min(255, theme.bg.R * 255 + 5),
                                math.min(255, theme.bg.G * 255 + 5),
                                math.min(255, theme.bg.B * 255 + 5)
                            )
                            TweenService:Create(child, TweenInfo.new(duration, easing), {
                                BackgroundColor3 = elemBg
                            }):Play()
                        end
                    end
                end
            end
        end
    end
    
    return theme.accent
end


function Window:SetColorScheme(scheme)
    local schemes = {
        Dark = {
            Container = Color3.fromRGB(15, 15, 15),
            TitleBar = Color3.fromRGB(12, 12, 12),
            Content = Color3.fromRGB(12, 12, 12),
            TabButton = Color3.fromRGB(20, 20, 20),
            Profile = Color3.fromRGB(18, 18, 18),
            Border = Color3.fromRGB(40, 40, 40),
            Element = Color3.fromRGB(20, 20, 20),
        },
        Coffee = {
            Container = Color3.fromRGB(40, 30, 25),
            TitleBar = Color3.fromRGB(35, 25, 20),
            Content = Color3.fromRGB(35, 25, 20),
            TabButton = Color3.fromRGB(50, 38, 30),
            Profile = Color3.fromRGB(45, 33, 25),
            Border = Color3.fromRGB(70, 55, 45),
            Element = Color3.fromRGB(50, 38, 30),
        },
        Navy = {
            Container = Color3.fromRGB(15, 20, 30),
            TitleBar = Color3.fromRGB(12, 17, 27),
            Content = Color3.fromRGB(12, 17, 27),
            TabButton = Color3.fromRGB(20, 28, 40),
            Profile = Color3.fromRGB(18, 25, 35),
            Border = Color3.fromRGB(40, 50, 65),
            Element = Color3.fromRGB(20, 28, 40),
        },
        Forest = {
            Container = Color3.fromRGB(20, 25, 20),
            TitleBar = Color3.fromRGB(17, 22, 17),
            Content = Color3.fromRGB(17, 22, 17),
            TabButton = Color3.fromRGB(28, 35, 28),
            Profile = Color3.fromRGB(23, 30, 23),
            Border = Color3.fromRGB(45, 55, 45),
            Element = Color3.fromRGB(28, 35, 28),
        },
        Purple = {
            Container = Color3.fromRGB(25, 15, 30),
            TitleBar = Color3.fromRGB(22, 12, 27),
            Content = Color3.fromRGB(22, 12, 27),
            TabButton = Color3.fromRGB(35, 20, 40),
            Profile = Color3.fromRGB(30, 18, 35),
            Border = Color3.fromRGB(55, 40, 65),
            Element = Color3.fromRGB(35, 20, 40),
        },
        Midnight = {
            Container = Color3.fromRGB(10, 10, 15),
            TitleBar = Color3.fromRGB(8, 8, 12),
            Content = Color3.fromRGB(8, 8, 12),
            TabButton = Color3.fromRGB(15, 15, 22),
            Profile = Color3.fromRGB(13, 13, 18),
            Border = Color3.fromRGB(30, 30, 40),
            Element = Color3.fromRGB(15, 15, 22),
        },
    }
    
    local colors = schemes[scheme] or schemes.Dark
    
    -- Animate color transitions
    local duration = 0.6
    local easing = Enum.EasingStyle.Quint
    
    -- Update container
    TweenService:Create(self.Container, TweenInfo.new(duration, easing), {
        BackgroundColor3 = colors.Container
    }):Play()
    
    -- Update title bar
    TweenService:Create(self.TitleBar, TweenInfo.new(duration, easing), {
        BackgroundColor3 = colors.TitleBar
    }):Play()
    
    -- Update profile
    TweenService:Create(self.ProfileContainer, TweenInfo.new(duration, easing), {
        BackgroundColor3 = colors.Profile
    }):Play()
    
    -- Update all tab buttons
    for _, tab in pairs(self.Tabs) do
        if tab.Button and not tab.Selected then
            TweenService:Create(tab.Button, TweenInfo.new(duration, easing), {
                BackgroundColor3 = colors.TabButton
            }):Play()
        end
        
        -- Update all elements in sections
        for _, section in pairs(tab.Sections) do
            if section.Container then
                -- Update all child elements
                for _, child in pairs(section.Container:GetDescendants()) do
                    if child:IsA("Frame") and child.Parent and child.Parent:IsA("ScrollingFrame") then
                        -- This is a toggle/element container
                        local isSwitchBg = child.Name == "SwitchBg"
                        local isCheck = child.Name == "Check"
                        
                        if not isSwitchBg and not isCheck then
                            TweenService:Create(child, TweenInfo.new(duration, easing), {
                                BackgroundColor3 = colors.Element
                            }):Play()
                        end
                    end
                end
            end
        end
    end
    
    -- Update borders
    local containerStroke = self.Container:FindFirstChildOfClass("UIStroke")
    if containerStroke then
        TweenService:Create(containerStroke, TweenInfo.new(duration, easing), {
            Color = colors.Border
        }):Play()
    end
    
    local profileStroke = self.ProfileContainer:FindFirstChildOfClass("UIStroke")
    if profileStroke then
        TweenService:Create(profileStroke, TweenInfo.new(duration, easing), {
            Color = colors.Border
        }):Play()
    end
    
    -- Store current scheme
    self.CurrentColorScheme = scheme
    self.ColorSchemeColors = colors
end

function Window:ApplyTheme(accentTheme, colorScheme)
    self:SetTheme(accentTheme)
    self:SetColorScheme(colorScheme or "Dark")
end


function Window:SetHubStatus(status, expiryDate)
    if not self.StatusLabel then return end
    
    local statusText = ""
    local statusColor = Color3.fromRGB(150, 150, 150)
    
    if status == "dev" then
        statusText = "👑 dev"
        statusColor = Color3.fromRGB(90, 200, 250)
    elseif status == "shub+" then
        if expiryDate then
            local daysLeft = math.floor((expiryDate - os.time()) / 86400)
            if daysLeft > 0 then
                statusText = "⭐ shub+ (" .. daysLeft .. "d left)"
            else
                statusText = "⭐ shub+ (expires today)"
            end
        else
            statusText = "⭐ shub+"
        end
        statusColor = Color3.fromRGB(255, 215, 0)
    else
        statusText = "shub"
        statusColor = Color3.fromRGB(150, 150, 150)
    end
    
    self.StatusLabel.Text = statusText
    TweenService:Create(self.StatusLabel, TweenInfo.new(0.3), {
        TextColor3 = statusColor
    }):Play()
end

function Window:Show()
    if not self._delayShow then return end
    
    -- Force remove loading screen by name with fade animation
    local coreGui = game:GetService("CoreGui")
    local lighting = game:GetService("Lighting")
    
    -- Find loading elements
    local loadingGui = coreGui:FindFirstChild("SsolyLoading")
    local loadingBlur = lighting:FindFirstChild("SsolyLoadingBlur")
    
    -- Fade out loading screen
    if loadingGui then
        local container = loadingGui:FindFirstChild("Frame")
        
        -- Stop dot animations
        loadingGui:SetAttribute("StopAnimation", true)
        
        -- Fade out all text elements first
        for _, child in pairs(loadingGui:GetDescendants()) do
            if child:IsA("TextLabel") then
                TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = 1
                }):Play()
            end
        end
        
        -- Fade out dots
        task.delay(0.1, function()
            for _, child in pairs(loadingGui:GetDescendants()) do
                if child.Name == "Frame" and child.Parent and child.Parent.Name == "Frame" and child.BackgroundColor3 == Color3.fromRGB(74, 158, 255) then
                    TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end
        end)
        
        -- Scale down and fade container
        if container then
            task.delay(0.2, function()
                TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Size = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1
                }):Play()
                
                local stroke = container:FindFirstChildOfClass("UIStroke")
                if stroke then
                    TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Transparency = 1
                    }):Play()
                end
            end)
        end
        
        -- Destroy after animation
        task.delay(0.75, function()
            if loadingGui and loadingGui.Parent then
                loadingGui:Destroy()
            end
        end)
    end
    
    -- Fade out blur
    if loadingBlur then
        TweenService:Create(loadingBlur, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = 0}):Play()
        task.delay(0.65, function()
            if loadingBlur and loadingBlur.Parent then
                loadingBlur:Destroy()
            end
        end)
    end
    
    -- Also try from config
    if self.Config._loadingGui and self.Config._loadingGui.Parent then
        task.delay(0.75, function()
            if self.Config._loadingGui and self.Config._loadingGui.Parent then
                self.Config._loadingGui:Destroy()
            end
        end)
    end
    
    if self.Config._loadingBlur and self.Config._loadingBlur.Parent then
        task.delay(0.65, function()
            if self.Config._loadingBlur and self.Config._loadingBlur.Parent then
                self.Config._loadingBlur:Destroy()
            end
        end)
    end
    
    -- Clear references
    self.Config._loadingGui = nil
    self.Config._loadingBlur = nil
    
    -- Wait for loading fade out to start, then show window
    task.wait(0.3)
    
    -- Enable ScreenGui
    self.ScreenGui.Enabled = true
    
    -- Fade in main blur
    if self.Blur then
        TweenService:Create(self.Blur, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = self.BlurSize}):Play()
    end
    
    -- Show window with animation
    self.Container.Visible = true
    self.Container.Size = UDim2.fromOffset(0, 0)
    
    TweenService:Create(self.Container, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = self.Config.Size
    }):Play()
    
    -- Show resize handles after window animation
    task.delay(0.7, function()
        self.ResizeHandle.Visible = true
        self.ResizeHandleV.Visible = true
        self.ResizeHandleH.Visible = true
        
        -- IMPORTANT: Refresh all elements after window is shown
        task.wait(0.1)
        self:RefreshElements()
    end)
end

function Window:RefreshElements()
    -- Force refresh all UI elements transparency
    for _, descendant in pairs(self.ContentContainer:GetDescendants()) do
        if descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
            if descendant.Name == "Toggle" or descendant.Name == "Dropdown" or descendant.Name == "Slider" or descendant.Name == "Button" or descendant.Name == "Input" then
                descendant.BackgroundTransparency = 0.5
            elseif descendant.Parent and (descendant.Parent.Name == "Toggle" or descendant.Parent.Name == "Dropdown" or descendant.Parent.Name == "Slider" or descendant.Parent.Name == "Button" or descendant.Parent.Name == "Input") then
                if descendant.Name == "Button" or descendant.Name == "Options" then
                    descendant.BackgroundTransparency = 0.3
                elseif descendant.Name == "SwitchBg" or descendant.Name == "Check" then
                    descendant.BackgroundTransparency = 0
                end
            end
        end
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            descendant.TextTransparency = 0
        end
        if descendant:IsA("UIStroke") then
            if descendant.Parent and (descendant.Parent.Name == "Toggle" or descendant.Parent.Name == "Dropdown" or descendant.Parent.Name == "Slider" or descendant.Parent.Name == "Button" or descendant.Parent.Name == "Input") then
                descendant.Transparency = 0.5
            end
        end
    end
end


function Window:InitParticles()
    -- Use local Particles class instead of loadstring
    self.ParticleSystem = Particles.new(self.Container, self.AccentColor)
    self.ParticleSystem.Running = true
    self.ParticleSystem:Start()
end

function Window:CreateSmokeEffect()
    -- Smoke container at bottom (INSIDE Container but with proper ZIndex)
    local smokeContainer = Instance.new("Frame")
    smokeContainer.Name = "SmokeEffect"
    smokeContainer.Size = UDim2.new(1, 0, 0, 200)
    smokeContainer.Position = UDim2.new(0, 0, 1, -200)
    smokeContainer.BackgroundTransparency = 1
    smokeContainer.ClipsDescendants = false
    smokeContainer.ZIndex = 1
    smokeContainer.Parent = self.Container
    
    self.SmokeContainer = smokeContainer
    self.SmokeParticles = {}
    
    -- Create smoke particles
    local function createSmoke()
        if not smokeContainer or not smokeContainer.Parent then return end
        
        local smoke = Instance.new("Frame")
        smoke.Size = UDim2.fromOffset(math.random(60, 100), math.random(60, 100))
        smoke.Position = UDim2.new(math.random(0, 100) / 100, 0, 1, 0)
        smoke.BackgroundColor3 = self.AccentColor
        smoke.BackgroundTransparency = 0.9
        smoke.BorderSizePixel = 0
        smoke.ZIndex = 2
        smoke.Parent = smokeContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = smoke
        
        table.insert(self.SmokeParticles, smoke)
        
        -- Animate upward with fade
        local duration = math.random(5, 8)
        local endY = -200
        
        TweenService:Create(smoke, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.new(smoke.Position.X.Scale + math.random(-30, 30) / 100, 0, 0, endY),
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(smoke.AbsoluteSize.X * 1.8, smoke.AbsoluteSize.Y * 1.8)
        }):Play()
        
        -- Remove after animation
        task.delay(duration, function()
            if smoke and smoke.Parent then
                smoke:Destroy()
            end
            for i, s in ipairs(self.SmokeParticles) do
                if s == smoke then
                    table.remove(self.SmokeParticles, i)
                    break
                end
            end
        end)
    end
    
    -- Spawn smoke continuously
    self.SmokeSpawnLoop = task.spawn(function()
        while self.Container and self.Container.Parent and smokeContainer and smokeContainer.Parent do
            if smokeContainer.Visible then
                createSmoke()
            end
            task.wait(math.random(600, 1200) / 1000)
        end
    end)
end

function Window:SetParticlesEnabled(enabled)
    -- Load particles module if not loaded
    if not self.ParticleSystem then
        self:InitParticles()
    end
    
    if enabled then
        self.ParticleSystem.Running = true
    else
        self.ParticleSystem.Running = false
        -- Удаляем все существующие частицы
        for i = #self.ParticleSystem.Particles, 1, -1 do
            if self.ParticleSystem.Particles[i] and self.ParticleSystem.Particles[i].Parent then
                self.ParticleSystem.Particles[i]:Destroy()
            end
            table.remove(self.ParticleSystem.Particles, i)
        end
        self.ParticleSystem.Container.Visible = false
    end
    
    -- Use local Particles class instead of loadstring
    Particles.SetEnabled(enabled)
end

function Window:Destroy()
    if self.ParticleSystem then
        self.ParticleSystem:Destroy()
    end
    if self.Blur then
        self.Blur:Destroy()
    end
    self.ScreenGui:Destroy()
end


-- ============================================================================
-- COLORPICKER ELEMENT
-- ============================================================================

local Colorpicker = {}
Colorpicker.__index = Colorpicker

function Colorpicker.new(tab, config)
    local self = setmetatable({}, Colorpicker)
    
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
    self.Container.Size = UDim2.new(1, -30, 0, self.Description and 46 or 38)
    self.Container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = false
    self.Container.ZIndex = 1
    self.Container.Parent = self.ParentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = self.Container
    
    -- Subtle border
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Transparency = 0.5
    Stroke.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -70, 0, 18)
    self.TitleLabel.Position = UDim2.fromOffset(10, 8)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.SourceSans
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.Container
    
    -- Color preview button
    self.ColorButton = Instance.new("TextButton")
    self.ColorButton.Name = "ColorButton"
    self.ColorButton.Size = UDim2.fromOffset(36, 22)
    self.ColorButton.Position = UDim2.new(1, -44, 0, 7)
    self.ColorButton.BackgroundColor3 = self.Default
    self.ColorButton.BorderSizePixel = 0
    self.ColorButton.Text = ""
    self.ColorButton.AutoButtonColor = false
    self.ColorButton.SelectionImageObject = nil
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
        self.DescLabel.Size = UDim2.new(1, -70, 0, 14)
        self.DescLabel.Position = UDim2.fromOffset(10, 26)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 10
        self.DescLabel.Font = Enum.Font.SourceSans
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    -- Picker container (hidden by default)
    self.PickerContainer = Instance.new("Frame")
    self.PickerContainer.Name = "Picker"
    self.PickerContainer.Size = UDim2.new(1, -20, 0, 0)
    self.PickerContainer.Position = UDim2.fromOffset(10, self.Description and 46 or 38)
    self.PickerContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.PickerContainer.BorderSizePixel = 0
    self.PickerContainer.ClipsDescendants = true
    self.PickerContainer.Visible = false
    self.PickerContainer.ZIndex = 100
    self.PickerContainer.Parent = self.Container
    
    local PickerCorner = Instance.new("UICorner")
    PickerCorner.CornerRadius = UDim.new(0, 6)
    PickerCorner.Parent = self.PickerContainer
    
    local PickerStroke = Instance.new("UIStroke")
    PickerStroke.Color = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    PickerStroke.Thickness = 1
    PickerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    PickerStroke.Parent = self.PickerContainer
    
    if self.Window.AccentElements then
        table.insert(self.Window.AccentElements, PickerStroke)
    end
    
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
    
    -- Hue slider (rainbow gradient)
    self.HueSlider = Instance.new("Frame")
    self.HueSlider.Name = "HueSlider"
    self.HueSlider.Size = UDim2.fromOffset(30, 150)
    self.HueSlider.Position = UDim2.new(1, -50, 0, 10)
    self.HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.HueSlider.BorderSizePixel = 0
    self.HueSlider.Parent = self.PickerContainer
    
    local HueCorner = Instance.new("UICorner")
    HueCorner.CornerRadius = UDim.new(0, 6)
    HueCorner.Parent = self.HueSlider
    
    -- Create rainbow gradient
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    gradient.Parent = self.HueSlider
    
    -- Make it clickable
    local HueButton = Instance.new("TextButton")
    HueButton.Size = UDim2.new(1, 0, 1, 0)
    HueButton.BackgroundTransparency = 1
    HueButton.Text = ""
    HueButton.Parent = self.HueSlider
    
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
        inputLabel.Font = Enum.Font.SourceSansBold
        inputLabel.Parent = inputFrame
        
        local inputBox = Instance.new("TextBox")
        inputBox.Size = UDim2.new(1, -25, 1, 0)
        inputBox.Position = UDim2.fromOffset(22, 0)
        inputBox.BackgroundTransparency = 1
        inputBox.Text = "255"
        inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        inputBox.TextSize = 12
        inputBox.Font = Enum.Font.SourceSans
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
            
            local color = Color3.fromRGB(r, g, b)
            local h, s, v = color:ToHSV()
            
            -- Update palette cursor position
            self.PaletteCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            
            -- Update hue cursor
            self.HueCursor.Position = UDim2.new(0, -2, h, 0)
            
            -- Update palette background color
            self.Palette.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            
            self:SetValue(color)
        end)
    end
    
    -- HEX input
    local hexFrame = Instance.new("Frame")
    hexFrame.Size = UDim2.new(1, -20, 0, 30)
    hexFrame.Position = UDim2.fromOffset(10, 210)
    hexFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    hexFrame.BorderSizePixel = 0
    hexFrame.Parent = self.PickerContainer
    
    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 5)
    hexCorner.Parent = hexFrame
    
    local hexLabel = Instance.new("TextLabel")
    hexLabel.Size = UDim2.fromOffset(35, 30)
    hexLabel.BackgroundTransparency = 1
    hexLabel.Text = "HEX"
    hexLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    hexLabel.TextSize = 12
    hexLabel.Font = Enum.Font.SourceSansBold
    hexLabel.Parent = hexFrame
    
    self.HexInput = Instance.new("TextBox")
    self.HexInput.Size = UDim2.new(1, -40, 1, 0)
    self.HexInput.Position = UDim2.fromOffset(37, 0)
    self.HexInput.BackgroundTransparency = 1
    self.HexInput.Text = "#FFFFFF"
    self.HexInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.HexInput.TextSize = 12
    self.HexInput.Font = Enum.Font.SourceSans
    self.HexInput.ClearTextOnFocus = false
    self.HexInput.Parent = hexFrame
    
    -- HEX validation
    self.HexInput:GetPropertyChangedSignal("Text"):Connect(function()
        local text = self.HexInput.Text:upper()
        if not text:match("^#") then
            text = "#" .. text
        end
        text = text:gsub("[^#0-9A-F]", "")
        if #text > 7 then
            text = text:sub(1, 7)
        end
        if text ~= self.HexInput.Text then
            self.HexInput.Text = text
        end
    end)
    
    self.HexInput.FocusLost:Connect(function()
        local hex = self.HexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16) or 0
            local g = tonumber(hex:sub(3, 4), 16) or 0
            local b = tonumber(hex:sub(5, 6), 16) or 0
            
            local color = Color3.fromRGB(r, g, b)
            local h, s, v = color:ToHSV()
            
            -- Update palette cursor position
            self.PaletteCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            
            -- Update hue cursor
            self.HueCursor.Position = UDim2.new(0, -2, h, 0)
            
            -- Update palette background color
            self.Palette.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            
            self:SetValue(color)
        end
    end)
    
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
    
    HueButton.InputBegan:Connect(function(input)
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
    self.PickerContainer.Size = UDim2.new(1, -24, 0, 0)
    
    -- Expand container first
    local newHeight = (self.Description and 46 or 38) + 220
    TweenService:Create(self.Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, -30, 0, newHeight)
    }):Play()
    
    -- Then expand picker
    TweenService:Create(self.PickerContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, -20, 0, 255)
    }):Play()
end

function Colorpicker:Close()
    self.Opened = false
    
    -- Close picker and container simultaneously
    local closeTween1 = TweenService:Create(self.PickerContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(1, -20, 0, 0)
    })
    closeTween1:Play()
    
    local newHeight = self.Description and 46 or 38
    local closeTween2 = TweenService:Create(self.Container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(1, -30, 0, newHeight)
    })
    closeTween2:Play()
    
    closeTween1.Completed:Connect(function()
        self.PickerContainer.Visible = false
    end)
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
    
    -- Update HEX input
    local hex = string.format("#%02X%02X%02X", r, g, b)
    if self.HexInput then
        self.HexInput.Text = hex
    end
    
    if not silent then
        task.spawn(function()
            self.Callback(color)
        end)
    end
end


-- ============================================================================
-- EXPORT
-- ============================================================================

local Ssoly = {}
Ssoly.Window = Window
Ssoly.Version = "1.1.0"
Ssoly.Author = "Sosalkin hub"

function Ssoly:CreateWindow(config)
    return Window.new(config)
end

return Ssoly
