---@diagnostic disable: undefined-global
-- Ssoly UI Library - Error Notification System
-- Roblox-style error notifications (center screen)

local TweenService = game:GetService("TweenService")

local ErrorNotification = {}
ErrorNotification.Container = nil
ErrorNotification.Active = nil

function ErrorNotification:Init(screenGui)
    if self.Container then return end
    
    -- Error container (center screen)
    self.Container = Instance.new("Frame")
    self.Container.Name = "ErrorNotifications"
    self.Container.Size = UDim2.fromScale(1, 1)
    self.Container.Position = UDim2.fromScale(0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.ZIndex = 1000
    self.Container.Parent = screenGui
end

function ErrorNotification:Show(config)
    if not self.Container then return end
    if self.Active then
        self:Dismiss()
        task.wait(0.3)
    end
    
    local title = config.Title or "Error"
    local message = config.Message or "An error occurred"
    local duration = config.Duration or 5
    
    -- Semi-transparent background overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1000
    overlay.Parent = self.Container
    
    -- Error box (Roblox style)
    local errorBox = Instance.new("Frame")
    errorBox.Name = "ErrorBox"
    errorBox.Size = UDim2.fromOffset(0, 0)
    errorBox.Position = UDim2.fromScale(0.5, 0.5)
    errorBox.AnchorPoint = Vector2.new(0.5, 0.5)
    errorBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    errorBox.BackgroundTransparency = 1
    errorBox.BorderSizePixel = 0
    errorBox.ZIndex = 1001
    errorBox.Parent = self.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = errorBox
    
    -- Red border (Roblox error style)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(220, 50, 50)
    Stroke.Thickness = 3
    Stroke.Transparency = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = errorBox
    
    -- Error icon (red X)
    local icon = Instance.new("Frame")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(50, 50)
    icon.Position = UDim2.fromOffset(20, 20)
    icon.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    icon.ZIndex = 1002
    icon.Parent = errorBox
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = icon
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.fromScale(1, 1)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "✕"
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextSize = 28
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextTransparency = 1
    iconLabel.ZIndex = 1003
    iconLabel.Parent = icon
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 0, 30)
    titleLabel.Position = UDim2.fromOffset(80, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    titleLabel.ZIndex = 1002
    titleLabel.Parent = errorBox
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -100, 0, 0)
    messageLabel.Position = UDim2.fromOffset(80, 55)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.TextTransparency = 1
    messageLabel.ZIndex = 1002
    messageLabel.Parent = errorBox
    
    -- Calculate message height
    local textService = game:GetService("TextService")
    local textBounds = textService:GetTextSize(
        message,
        14,
        Enum.Font.Gotham,
        Vector2.new(320, math.huge)
    )
    
    local messageHeight = math.max(textBounds.Y, 20)
    messageLabel.Size = UDim2.new(1, -100, 0, messageHeight)
    
    -- OK Button
    local okButton = Instance.new("TextButton")
    okButton.Name = "OKButton"
    okButton.Size = UDim2.fromOffset(100, 35)
    okButton.Position = UDim2.new(0.5, -50, 1, -50)
    okButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    okButton.BackgroundTransparency = 1
    okButton.BorderSizePixel = 0
    okButton.Text = "OK"
    okButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    okButton.TextSize = 14
    okButton.Font = Enum.Font.GothamBold
    okButton.TextTransparency = 1
    okButton.AutoButtonColor = false
    okButton.ZIndex = 1002
    okButton.Parent = errorBox
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = okButton
    
    -- Calculate total height
    local totalHeight = 90 + messageHeight + 60
    
    -- Animations
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Fade in overlay
    TweenService:Create(overlay, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.5
    }):Play()
    
    -- Scale in error box
    task.delay(0.1, function()
        TweenService:Create(errorBox, tweenInfo, {
            Size = UDim2.fromOffset(450, totalHeight),
            BackgroundTransparency = 0
        }):Play()
        
        TweenService:Create(Stroke, tweenInfo, {
            Transparency = 0
        }):Play()
        
        -- Fade in icon
        TweenService:Create(icon, tweenInfo, {
            BackgroundTransparency = 0
        }):Play()
        
        TweenService:Create(iconLabel, tweenInfo, {
            TextTransparency = 0
        }):Play()
        
        -- Fade in text
        TweenService:Create(titleLabel, tweenInfo, {
            TextTransparency = 0
        }):Play()
        
        TweenService:Create(messageLabel, tweenInfo, {
            TextTransparency = 0
        }):Play()
        
        -- Fade in button
        TweenService:Create(okButton, tweenInfo, {
            BackgroundTransparency = 0,
            TextTransparency = 0
        }):Play()
    end)
    
    -- Button hover effect
    okButton.MouseEnter:Connect(function()
        TweenService:Create(okButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        }):Play()
    end)
    
    okButton.MouseLeave:Connect(function()
        TweenService:Create(okButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        }):Play()
    end)
    
    -- Button click
    okButton.MouseButton1Click:Connect(function()
        self:Dismiss()
    end)
    
    -- Auto-dismiss
    if duration > 0 then
        task.delay(duration, function()
            if self.Active == overlay then
                self:Dismiss()
            end
        end)
    end
    
    self.Active = overlay
end

function ErrorNotification:Dismiss()
    if not self.Active then return end
    
    local overlay = self.Active
    local errorBox = overlay:FindFirstChild("ErrorBox")
    
    if errorBox then
        -- Scale out
        TweenService:Create(errorBox, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        -- Fade out all elements
        for _, child in pairs(errorBox:GetDescendants()) do
            if child:IsA("GuiObject") then
                TweenService:Create(child, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                }):Play()
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.2), {
                        TextTransparency = 1
                    }):Play()
                end
            end
        end
    end
    
    -- Fade out overlay
    local tween = TweenService:Create(overlay, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        overlay:Destroy()
        self.Active = nil
    end)
end

return ErrorNotification
