---@diagnostic disable: undefined-global
-- Sosalkin Hub Console
-- Styled console matching Ssoly UI design

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Console = {}
Console.__index = Console

function Console.new(accentColor)
    local self = setmetatable({}, Console)
    
    self.AccentColor = accentColor or Color3.fromRGB(74, 158, 255)
    self.Logs = {}
    self.MaxLogs = 100
    self.Visible = false
    
    self:CreateGUI()
    self:SetupHotkey()
    self:HookOutput()
    
    return self
end

function Console:CreateGUI()
    local coreGui = game:GetService("CoreGui")
    local oldConsole = coreGui:FindFirstChild("SosalkinConsole")
    if oldConsole then oldConsole:Destroy() end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SosalkinConsole"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Enabled = false
    self.ScreenGui.Parent = coreGui
    
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.Size = UDim2.fromOffset(700, 400)
    self.Container.Position = UDim2.new(0.5, -350, 0.5, -200)
    self.Container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.Container.BackgroundTransparency = 0.1
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = self.Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1
    Stroke.Parent = self.Container
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 35)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Container
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = self.TitleBar
    
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, 0)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Divider.BorderSizePixel = 0
    Divider.Parent = self.TitleBar
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(12, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = "Sosalkin Hub Console"
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "Close"
    self.CloseButton.Size = UDim2.fromOffset(25, 25)
    self.CloseButton.Position = UDim2.new(1, -32, 0.5, -12.5)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
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
    
    -- Clear button
    self.ClearButton = Instance.new("TextButton")
    self.ClearButton.Name = "Clear"
    self.ClearButton.Size = UDim2.fromOffset(25, 25)
    self.ClearButton.Position = UDim2.new(1, -62, 0.5, -12.5)
    self.ClearButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.ClearButton.BorderSizePixel = 0
    self.ClearButton.Text = "🗑"
    self.ClearButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.ClearButton.TextSize = 14
    self.ClearButton.Font = Enum.Font.GothamBold
    self.ClearButton.AutoButtonColor = false
    self.ClearButton.Parent = self.TitleBar
    
    local ClearCorner = Instance.new("UICorner")
    ClearCorner.CornerRadius = UDim.new(0, 4)
    ClearCorner.Parent = self.ClearButton
    
    self.ClearButton.MouseButton1Click:Connect(function()
        self:Clear()
    end)
    
    self.ClearButton.MouseEnter:Connect(function()
        TweenService:Create(self.ClearButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    self.ClearButton.MouseLeave:Connect(function()
        TweenService:Create(self.ClearButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
    end)
    
    -- Log container
    self.LogContainer = Instance.new("ScrollingFrame")
    self.LogContainer.Name = "Logs"
    self.LogContainer.Size = UDim2.new(1, -20, 1, -50)
    self.LogContainer.Position = UDim2.fromOffset(10, 40)
    self.LogContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    self.LogContainer.BackgroundTransparency = 0.3
    self.LogContainer.BorderSizePixel = 0
    self.LogContainer.ScrollBarThickness = 4
    self.LogContainer.ScrollBarImageColor3 = self.AccentColor
    self.LogContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.LogContainer.Parent = self.Container
    
    local LogCorner = Instance.new("UICorner")
    LogCorner.CornerRadius = UDim.new(0, 10)
    LogCorner.Parent = self.LogContainer
    
    local LogLayout = Instance.new("UIListLayout")
    LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LogLayout.Padding = UDim.new(0, 2)
    LogLayout.Parent = self.LogContainer
    
    local LogPadding = Instance.new("UIPadding")
    LogPadding.PaddingTop = UDim.new(0, 5)
    LogPadding.PaddingBottom = UDim.new(0, 5)
    LogPadding.PaddingLeft = UDim.new(0, 8)
    LogPadding.PaddingRight = UDim.new(0, 8)
    LogPadding.Parent = self.LogContainer
    
    LogLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.LogContainer.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 10)
        self.LogContainer.CanvasPosition = Vector2.new(0, self.LogContainer.CanvasSize.Y.Offset)
    end)
    
    -- Bottom glow
    self.BottomGlow = Instance.new("Frame")
    self.BottomGlow.Name = "Glow"
    self.BottomGlow.Size = UDim2.new(1, 0, 0, 3)
    self.BottomGlow.Position = UDim2.new(0, 0, 1, -3)
    self.BottomGlow.BackgroundColor3 = self.AccentColor
    self.BottomGlow.BackgroundTransparency = 0.7
    self.BottomGlow.BorderSizePixel = 0
    self.BottomGlow.Parent = self.Container
    
    local GlowGradient = Instance.new("UIGradient")
    GlowGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    GlowGradient.Parent = self.BottomGlow
    
    -- Dragging
    self:SetupDragging()
end

function Console:SetupDragging()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
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
            self.Container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Console:SetupHotkey()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F9 then
            self:Toggle()
        end
    end)
end

function Console:HookOutput()
    local function addLog(message, messageType)
        self:AddLog(message, messageType)
    end
    
    local logService = game:GetService("LogService")
    logService.MessageOut:Connect(function(message, messageType)
        addLog(message, messageType)
    end)
end

function Console:AddLog(message, messageType)
    if #self.Logs >= self.MaxLogs then
        local oldest = self.Logs[1]
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
        table.remove(self.Logs, 1)
    end
    
    local logFrame = Instance.new("Frame")
    logFrame.Name = "Log"
    logFrame.Size = UDim2.new(1, -10, 0, 0)
    logFrame.BackgroundTransparency = 1
    logFrame.BorderSizePixel = 0
    logFrame.Parent = self.LogContainer
    
    local timestamp = Instance.new("TextLabel")
    timestamp.Name = "Time"
    timestamp.Size = UDim2.new(0, 60, 0, 16)
    timestamp.BackgroundTransparency = 1
    timestamp.Text = os.date("%H:%M:%S")
    timestamp.TextColor3 = Color3.fromRGB(120, 120, 120)
    timestamp.TextSize = 10
    timestamp.Font = Enum.Font.GothamMedium
    timestamp.TextXAlignment = Enum.TextXAlignment.Left
    timestamp.Parent = logFrame
    
    local typeColor = Color3.fromRGB(200, 200, 200)
    if messageType == Enum.MessageType.MessageWarning then
        typeColor = Color3.fromRGB(255, 200, 0)
    elseif messageType == Enum.MessageType.MessageError then
        typeColor = Color3.fromRGB(255, 80, 80)
    elseif messageType == Enum.MessageType.MessageInfo then
        typeColor = self.AccentColor
    end
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -70, 1, 0)
    messageLabel.Position = UDim2.fromOffset(65, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = typeColor
    messageLabel.TextSize = 11
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = logFrame
    
    local textBounds = game:GetService("TextService"):GetTextSize(
        message,
        11,
        Enum.Font.Gotham,
        Vector2.new(messageLabel.AbsoluteSize.X, math.huge)
    )
    
    logFrame.Size = UDim2.new(1, -10, 0, math.max(16, textBounds.Y + 4))
    messageLabel.Size = UDim2.new(1, -70, 0, math.max(16, textBounds.Y + 4))
    
    table.insert(self.Logs, logFrame)
end

function Console:Clear()
    for _, log in ipairs(self.Logs) do
        if log and log.Parent then
            log:Destroy()
        end
    end
    self.Logs = {}
end

function Console:Show()
    self.Visible = true
    self.ScreenGui.Enabled = true
end

function Console:Hide()
    self.Visible = false
    self.ScreenGui.Enabled = false
end

function Console:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

function Console:SetAccentColor(color)
    self.AccentColor = color
    self.LogContainer.ScrollBarImageColor3 = color
    TweenService:Create(self.BottomGlow, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
        BackgroundColor3 = color
    }):Play()
end

function Console:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return Console
