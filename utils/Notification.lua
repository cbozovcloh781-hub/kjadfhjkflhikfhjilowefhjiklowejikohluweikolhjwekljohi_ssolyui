---@diagnostic disable: undefined-global
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
    
    -- Type colors
    local typeColors = {
        Info = Color3.fromRGB(74, 158, 255),
        Success = Color3.fromRGB(80, 255, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80)
    }
    
    -- Type indicator dot (top-left corner)
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
    
    -- Icon
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
    
    -- Title
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
    
    -- Content
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
    
    -- Progress bar (inside bottom edge, respecting rounded corners)
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
    
    -- Slide in animation from right edge of screen (smooth)
    notif.Size = UDim2.new(1, 0, 0, totalHeight)
    notif.Position = UDim2.new(1, 50, 0, 0)
    notif.BackgroundTransparency = 1
    
    -- Store original transparencies
    local originalTransparencies = {}
    for _, child in pairs(notif:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            originalTransparencies[child] = {text = child.TextTransparency}
            child.TextTransparency = 1
        end
        if child:IsA("GuiObject") and child ~= notif then
            originalTransparencies[child] = {bg = child.BackgroundTransparency}
            if child.Name ~= "Progress" then
                child.BackgroundTransparency = 1
            end
        end
    end
    
    local slideTween = TweenService:Create(notif, TweenInfo.new(1.0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    })
    slideTween:Play()
    
    local fadeTween = TweenService:Create(notif, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    })
    fadeTween:Play()
    
    -- Fade in all text and elements with delay
    task.delay(0.2, function()
        for child, trans in pairs(originalTransparencies) do
            if child and child.Parent then
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        TextTransparency = trans.text or 0
                    }):Play()
                end
                if child:IsA("GuiObject") and child.Name ~= "Progress" then
                    TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = trans.bg or 0
                    }):Play()
                end
            end
        end
    end)
    
    -- Progress bar animation (starts after fade in)
    task.delay(0.3, function()
        TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 3)
        }):Play()
    end)
    
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
    local tween = TweenService:Create(notif, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 50, 0, 0)
    })
    tween:Play()
    
    -- Fade out
    TweenService:Create(notif, TweenInfo.new(0.8), {
        BackgroundTransparency = 1
    }):Play()
    
    for _, child in pairs(notif:GetDescendants()) do
        if child:IsA("GuiObject") then
            TweenService:Create(child, TweenInfo.new(0.8), {
                BackgroundTransparency = 1
            }):Play()
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.8), {
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
