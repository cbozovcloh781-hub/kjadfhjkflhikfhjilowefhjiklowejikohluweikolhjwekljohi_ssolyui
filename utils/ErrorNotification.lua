---@diagnostic disable: undefined-global
-- Ssoly UI Library - Error Notification (Roblox Style)
-- Center-screen error display with smooth animations

local TweenService = game:GetService("TweenService")

local ErrorNotification = {}
ErrorNotification.__index = ErrorNotification

function ErrorNotification:Init(parent)
    self.Parent = parent
    self.Container = nil
    self.IsShowing = false
    return self
end

function ErrorNotification:Show(config)
    if self.IsShowing then
        self:Hide()
        task.wait(0.4)
    end
    
    self.IsShowing = true
    
    local title = config.Title or "Error"
    local message = config.Message or "An error occurred"
    local duration = config.Duration or 5
    
    -- Main container (centered)
    self.Container = Instance.new("Frame")
    self.Container.Name = "ErrorNotification"
    self.Container.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Container.Size = UDim2.new(0, 480, 0, 0)
    self.Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Container.BorderSizePixel = 0
    self.Container.ZIndex = 10000
    self.Container.Parent = self.Parent
    
    -- Smooth corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    -- Red border (strict style)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(220, 50, 50)
    Stroke.Thickness = 2.5
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Transparency = 0
    Stroke.Parent = self.Container
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = 9999
    Shadow.Parent = self.Container
    
    -- Content container
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.Parent = self.Container
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 20)
    ContentPadding.PaddingBottom = UDim.new(0, 20)
    ContentPadding.PaddingLeft = UDim.new(0, 24)
    ContentPadding.PaddingRight = UDim.new(0, 24)
    ContentPadding.Parent = Content
    
    -- Error icon (strict red X)
    local Icon = Instance.new("Frame")
    Icon.Name = "Icon"
    Icon.Size = UDim2.fromOffset(48, 48)
    Icon.Position = UDim2.new(0.5, -24, 0, 0)
    Icon.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    Icon.BorderSizePixel = 0
    Icon.Parent = Content
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = Icon
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "✕"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.TextSize = 28
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Parent = Icon
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.Position = UDim2.fromOffset(0, 60)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextWrapped = false
    Title.Parent = Content
    
    -- Message
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Size = UDim2.new(1, 0, 0, 0)
    Message.Position = UDim2.fromOffset(0, 92)
    Message.BackgroundTransparency = 1
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 13
    Message.Font = Enum.Font.Gotham
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Center
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.Parent = Content
    
    -- Calculate message height
    local textService = game:GetService("TextService")
    local textBounds = textService:GetTextSize(
        message,
        13,
        Enum.Font.Gotham,
        Vector2.new(432, math.huge)
    )
    Message.Size = UDim2.new(1, 0, 0, textBounds.Y)
    
    -- OK Button (strict style)
    local Button = Instance.new("TextButton")
    Button.Name = "OKButton"
    Button.Size = UDim2.new(0, 120, 0, 38)
    Button.Position = UDim2.new(0.5, -60, 1, -58)
    Button.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Content
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    local ButtonLabel = Instance.new("TextLabel")
    ButtonLabel.Size = UDim2.new(1, 0, 1, 0)
    ButtonLabel.BackgroundTransparency = 1
    ButtonLabel.Text = "OK"
    ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonLabel.TextSize = 14
    ButtonLabel.Font = Enum.Font.GothamBold
    ButtonLabel.Parent = Button
    
    -- Calculate total height
    local totalHeight = 92 + textBounds.Y + 78
    
    -- Smooth entrance animation (scale + fade)
    self.Container.Size = UDim2.new(0, 480, 0, totalHeight)
    self.Container.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 20)
    
    for _, child in pairs(Content:GetDescendants()) do
        if child:IsA("GuiObject") then
            child.BackgroundTransparency = 1
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = 1
            end
        end
    end
    
    Stroke.Transparency = 1
    Shadow.ImageTransparency = 1
    
    -- Smooth scale animation
    local scaleInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    TweenService:Create(self.Container, fadeInfo, {
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(Content, scaleInfo, {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    TweenService:Create(Stroke, fadeInfo, {
        Transparency = 0
    }):Play()
    
    TweenService:Create(Shadow, fadeInfo, {
        ImageTransparency = 0.7
    }):Play()
    
    task.wait(0.15)
    
    -- Fade in all elements smoothly
    for _, child in pairs(Content:GetDescendants()) do
        if child:IsA("GuiObject") then
            if child.Name == "Icon" then
                TweenService:Create(child, fadeInfo, {
                    BackgroundTransparency = 0
                }):Play()
            elseif child ~= Icon and child.Name ~= "OKButton" then
                TweenService:Create(child, fadeInfo, {
                    BackgroundTransparency = child.Name == "Shadow" and 0.7 or 0
                }):Play()
            end
            
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenService:Create(child, fadeInfo, {
                    TextTransparency = 0
                }):Play()
            end
        end
    end
    
    TweenService:Create(Button, fadeInfo, {
        BackgroundTransparency = 0
    }):Play()
    
    -- Button hover effect (smooth)
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(240, 70, 70)
        }):Play()
        TweenService:Create(Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 126, 0, 40)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        }):Play()
        TweenService:Create(Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 120, 0, 38)
        }):Play()
    end)
    
    -- Close on button click
    Button.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    -- Auto-hide after duration
    if duration > 0 then
        task.delay(duration, function()
            if self.IsShowing then
                self:Hide()
            end
        end)
    end
end

function ErrorNotification:Hide()
    if not self.Container or not self.IsShowing then return end
    
    self.IsShowing = false
    
    local fadeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    local scaleInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    -- Fade out all elements
    local content = self.Container:FindFirstChild("Content")
    if content then
        for _, child in pairs(content:GetDescendants()) do
            if child:IsA("GuiObject") then
                TweenService:Create(child, fadeInfo, {
                    BackgroundTransparency = 1
                }):Play()
                
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    TweenService:Create(child, fadeInfo, {
                        TextTransparency = 1
                    }):Play()
                end
            end
        end
        
        TweenService:Create(content, scaleInfo, {
            Position = UDim2.new(0, 0, 0, -20)
        }):Play()
    end
    
    local stroke = self.Container:FindFirstChildOfClass("UIStroke")
    if stroke then
        TweenService:Create(stroke, fadeInfo, {
            Transparency = 1
        }):Play()
    end
    
    local shadow = self.Container:FindFirstChild("Shadow")
    if shadow then
        TweenService:Create(shadow, fadeInfo, {
            ImageTransparency = 1
        }):Play()
    end
    
    TweenService:Create(self.Container, fadeInfo, {
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.4, function()
        if self.Container then
            self.Container:Destroy()
            self.Container = nil
        end
    end)
end

return ErrorNotification
