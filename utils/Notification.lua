-- Ssoly UI Library - Notification System
-- Toast-style notifications with animations

local TweenService = game:GetService("TweenService")

local Notification = {}
Notification.Container = nil
Notification.Queue = {}
Notification.Active = {}

function Notification:Init(screenGui)
    if self.Container then return end
    
    -- Notification container (bottom-right)
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
    
    -- Auto-resize container
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.Size = UDim2.fromOffset(300, Layout.AbsoluteContentSize.Y)
    end)
end

function Notification:Show(config)
    if not self.Container then return end
    
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 3
    local type = config.Type or "Info" -- Info, Success, Warning, Error
    
    -- Create notification
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = false
    notif.Parent = self.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = notif
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 45)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = notif
    
    -- Type indicator (colored bar)
    local typeColors = {
        Info = Color3.fromRGB(74, 158, 255),
        Success = Color3.fromRGB(80, 255, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80)
    }
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 4, 1, 0)
    indicator.BackgroundColor3 = typeColors[type] or typeColors.Info
    indicator.BorderSizePixel = 0
    indicator.Parent = notif
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 10)
    IndCorner.Parent = indicator
    
    -- Icon
    local typeIcons = {
        Info = "ℹ️",
        Success = "✅",
        Warning = "⚠️",
        Error = "❌"
    }
    
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(30, 30)
    icon.Position = UDim2.fromOffset(12, 10)
    icon.BackgroundTransparency = 1
    icon.Text = typeIcons[type] or typeIcons.Info
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 18
    icon.Font = Enum.Font.SourceSansBold
    icon.Parent = notif
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.fromOffset(48, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.TextStrokeTransparency = 0.8
    titleLabel.Parent = notif
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -60, 0, 0)
    contentLabel.Position = UDim2.fromOffset(48, 32)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 12
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = notif
    
    -- Calculate height based on content
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
    
    -- Progress bar
    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = typeColors[type] or typeColors.Info
    progress.BorderSizePixel = 0
    progress.Parent = notif
    
    -- Slide in animation from right with bounce
    notif.Size = UDim2.new(1, 0, 0, totalHeight)
    notif.Position = UDim2.new(1, 50, 0, 0)
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    -- Progress bar animation
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()
    
    -- Auto-dismiss
    task.delay(duration, function()
        self:Dismiss(notif)
    end)
    
    -- Click to dismiss
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
    
    -- Slide out animation to right
    local tween = TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 50, 0, 0)
    })
    tween:Play()
    
    -- Fade out
    TweenService:Create(notif, TweenInfo.new(0.4), {
        BackgroundTransparency = 1
    }):Play()
    
    for _, child in pairs(notif:GetDescendants()) do
        if child:IsA("GuiObject") then
            TweenService:Create(child, TweenInfo.new(0.4), {
                BackgroundTransparency = 1
            }):Play()
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.4), {
                    TextTransparency = 1
                }):Play()
            end
        end
    end
    
    tween.Completed:Connect(function()
        notif:Destroy()
        
        -- Remove from active list
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

return Notification
