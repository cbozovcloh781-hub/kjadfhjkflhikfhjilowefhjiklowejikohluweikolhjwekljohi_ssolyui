-- Ssoly UI Library - Window Class
-- Handles main window creation, dragging, resizing, and animations

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Window = {}
Window.__index = Window

-- Default configuration
local DEFAULT_CONFIG = {
    Title = "Ssoly UI",
    Size = UDim2.fromOffset(700, 500),
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(1200, 800),
    Position = UDim2.new(0.5, -350, 0.5, -250),
    Transparency = 0.1,
    BlurEnabled = true,
    Draggable = true,
    Resizable = true,
    MinimizeKey = Enum.KeyCode.RightControl,
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
    
    -- Create GUI
    self:CreateGUI()
    self:SetupDragging()
    self:SetupResizing()
    self:SetupMinimize()
    
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
    self.ScreenGui.Parent = coreGui
    
    -- Blur effect
    if self.Config.BlurEnabled then
        self.Blur = Instance.new("BlurEffect")
        self.Blur.Name = "SsolyBlur"
        self.Blur.Size = 10
        self.Blur.Parent = lighting
    end
    
    -- Main container (rounded)
    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.Size = self.Config.Size
    self.Container.Position = self.Config.Position
    self.Container.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    self.Container.BackgroundTransparency = self.Config.Transparency
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = self.ScreenGui
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = self.Container
    
    -- Border (stroke)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(45, 45, 45)
    UIStroke.Thickness = 2
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = self.Container
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.TitleBar.BackgroundTransparency = 0.3
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Container
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = self.TitleBar
    
    -- Title text
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(15, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Config.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 15
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.TextStrokeTransparency = 0.8
    self.TitleLabel.Parent = self.TitleBar
    
    -- Minimize button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "Minimize"
    self.MinimizeButton.Size = UDim2.fromOffset(30, 30)
    self.MinimizeButton.Position = UDim2.new(1, -40, 0.5, -15)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(74, 158, 255)
    self.MinimizeButton.BackgroundTransparency = 0.2
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.Text = "−"
    self.MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.MinimizeButton.TextSize = 20
    self.MinimizeButton.Font = Enum.Font.SourceSansBold
    self.MinimizeButton.Parent = self.TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = self.MinimizeButton
    
    -- Tab container (left side)
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, -50)
    self.TabContainer.Position = UDim2.fromOffset(10, 45)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.Container
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = self.TabContainer
    
    -- Content container (right side) - with visible scrollbar
    self.ContentContainer = Instance.new("ScrollingFrame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -175, 1, -50)
    self.ContentContainer.Position = UDim2.fromOffset(165, 45)
    self.ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.ContentContainer.BackgroundTransparency = 0.5
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.ScrollBarThickness = 6
    self.ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(74, 158, 255)
    self.ContentContainer.ScrollBarImageTransparency = 0
    self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentContainer.Parent = self.Container
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = self.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = self.ContentContainer
    
    -- Auto-update canvas size
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.Parent = self.ContentContainer
    
    -- Resize handle (bottom-right corner) - separate rounded bar outside window
    self.ResizeHandle = Instance.new("Frame")
    self.ResizeHandle.Name = "ResizeHandle"
    self.ResizeHandle.Size = UDim2.fromOffset(6, 40)
    self.ResizeHandle.Position = UDim2.new(1, 5, 1, -50)
    self.ResizeHandle.BackgroundColor3 = Color3.fromRGB(74, 158, 255)
    self.ResizeHandle.BackgroundTransparency = 0.3
    self.ResizeHandle.BorderSizePixel = 0
    self.ResizeHandle.ZIndex = 5
    self.ResizeHandle.Parent = self.ScreenGui
    
    local ResizeCorner = Instance.new("UICorner")
    ResizeCorner.CornerRadius = UDim.new(1, 0)
    ResizeCorner.Parent = self.ResizeHandle
    
    -- Minimized indicator (hidden by default)
    self.MinimizedIndicator = Instance.new("Frame")
    self.MinimizedIndicator.Name = "MinimizedIndicator"
    self.MinimizedIndicator.Size = UDim2.fromOffset(150, 40)
    self.MinimizedIndicator.Position = UDim2.new(0.5, -75, 0.95, -20)
    self.MinimizedIndicator.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    self.MinimizedIndicator.BackgroundTransparency = 0.1
    self.MinimizedIndicator.BorderSizePixel = 0
    self.MinimizedIndicator.Visible = false
    self.MinimizedIndicator.Parent = self.ScreenGui
    
    local MinIndCorner = Instance.new("UICorner")
    MinIndCorner.CornerRadius = UDim.new(0, 10)
    MinIndCorner.Parent = self.MinimizedIndicator
    
    local MinIndStroke = Instance.new("UIStroke")
    MinIndStroke.Color = Color3.fromRGB(74, 158, 255)
    MinIndStroke.Thickness = 2
    MinIndStroke.Parent = self.MinimizedIndicator
    
    local MinIndLabel = Instance.new("TextLabel")
    MinIndLabel.Size = UDim2.new(1, 0, 1, 0)
    MinIndLabel.BackgroundTransparency = 1
    MinIndLabel.Text = "📋 " .. self.Config.Title
    MinIndLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinIndLabel.TextSize = 14
    MinIndLabel.Font = Enum.Font.SourceSansBold
    MinIndLabel.Parent = self.MinimizedIndicator
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
            TweenService:Create(self.Container, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
    
    self.MinimizedIndicator.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Double click detection
            local currentTime = tick()
            if currentTime - lastClickTime < 0.3 then
                self:ToggleMinimize()
                lastClickTime = 0
                return
            end
            lastClickTime = currentTime
            
            minDragging = true
            minDragStart = input.Position
            minStartPos = self.MinimizedIndicator.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if minDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - minDragStart
            self.MinimizedIndicator.Position = UDim2.new(
                minStartPos.X.Scale,
                minStartPos.X.Offset + delta.X,
                minStartPos.Y.Scale,
                minStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            minDragging = false
        end
    end)
end

function Window:SetupResizing()
    if not self.Config.Resizable then return end
    
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    
    -- Update resize handle position when window moves/resizes
    local function updateResizePosition()
        local containerPos = self.Container.AbsolutePosition
        local containerSize = self.Container.AbsoluteSize
        self.ResizeHandle.Position = UDim2.fromOffset(
            containerPos.X + containerSize.X + 5,
            containerPos.Y + containerSize.Y - 50
        )
    end
    
    self.Container:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateResizePosition)
    self.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateResizePosition)
    updateResizePosition()
    
    self.ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = self.Container.AbsoluteSize
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.clamp(startSize.X + delta.X, self.Config.MinSize.X, self.Config.MaxSize.X)
            local newHeight = math.clamp(startSize.Y + delta.Y, self.Config.MinSize.Y, self.Config.MaxSize.Y)
            
            self.Container.Size = UDim2.fromOffset(newWidth, newHeight)
            updateResizePosition()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    
    -- Hover effect
    self.ResizeHandle.MouseEnter:Connect(function()
        TweenService:Create(self.ResizeHandle, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(8, 45)
        }):Play()
    end)
    
    self.ResizeHandle.MouseLeave:Connect(function()
        if not resizing then
            TweenService:Create(self.ResizeHandle, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                Size = UDim2.fromOffset(6, 40)
            }):Play()
        end
    end)
end

function Window:SetupMinimize()
    -- Button click
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Hotkey
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.Config.MinimizeKey then
            self:ToggleMinimize()
        end
    end)
    
    -- Hover effect
    self.MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(self.MinimizeButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)
    
    self.MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(self.MinimizeButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        -- Hide blur
        if self.Blur then
            TweenService:Create(self.Blur, TweenInfo.new(0.3), {Size = 0}):Play()
        end
        
        -- Minimize animation
        local tween = TweenService:Create(self.Container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            self.Container.Visible = false
            self.MinimizedIndicator.Visible = true
            
            -- Show indicator animation
            TweenService:Create(self.MinimizedIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(150, 40)
            }):Play()
        end)
    else
        -- Show blur
        if self.Blur then
            TweenService:Create(self.Blur, TweenInfo.new(0.3), {Size = 10}):Play()
        end
        
        -- Restore animation
        self.MinimizedIndicator.Visible = false
        self.Container.Visible = true
        
        TweenService:Create(self.Container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = self.Config.Size,
            Position = self.Config.Position
        }):Play()
    end
end

function Window:AddTab(config)
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Tab = loadstring(game:HttpGet(baseUrl .. "core/Tab.lua"))()
    local tab = Tab.new(self, config)
    table.insert(self.Tabs, tab)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function Window:SelectTab(tab)
    -- Deselect current tab
    if self.CurrentTab then
        self.CurrentTab:Deselect()
    end
    
    -- Select new tab
    self.CurrentTab = tab
    tab:Select()
    
    -- Clear content container
    for _, child in pairs(self.ContentContainer:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            child.Visible = false
        end
    end
    
    -- Show tab content
    for _, element in pairs(tab.Elements) do
        element.Visible = true
    end
end

function Window:Notify(config)
    -- Lazy load notification system
    if not self.Notification then
        local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
        self.Notification = loadstring(game:HttpGet(baseUrl .. "utils/Notification.lua"))()
        self.Notification:Init(self.ScreenGui)
    end
    
    self.Notification:Show(config)
end

function Window:Destroy()
    if self.Blur then
        self.Blur:Destroy()
    end
    self.ScreenGui:Destroy()
end

return Window
