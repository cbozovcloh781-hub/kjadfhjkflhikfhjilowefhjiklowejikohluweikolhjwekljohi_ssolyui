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
    
    -- Initialize notification system
    local Notification = require(script.Parent.utils.Notification)
    Notification:Init(self.ScreenGui)
    self.Notification = Notification
    
    return self
end

function Window:CreateGUI()
    -- Main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SsolyUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Blur effect
    if self.Config.BlurEnabled then
        self.Blur = Instance.new("BlurEffect")
        self.Blur.Size = 10
        self.Blur.Parent = game:GetService("Lighting")
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
    self.TitleLabel.TextSize = 16
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
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
    self.MinimizeButton.Font = Enum.Font.GothamBold
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
    
    -- Content container (right side)
    self.ContentContainer = Instance.new("ScrollingFrame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -175, 1, -50)
    self.ContentContainer.Position = UDim2.fromOffset(165, 45)
    self.ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.ContentContainer.BackgroundTransparency = 0.5
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.ScrollBarThickness = 4
    self.ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(74, 158, 255)
    self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentContainer.Parent = self.Container
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = self.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = self.ContentContainer
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.Parent = self.ContentContainer
    
    -- Resize handle (bottom-left corner)
    self.ResizeHandle = Instance.new("Frame")
    self.ResizeHandle.Name = "ResizeHandle"
    self.ResizeHandle.Size = UDim2.fromOffset(40, 40)
    self.ResizeHandle.Position = UDim2.new(0, 5, 1, -45)
    self.ResizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.ResizeHandle.BackgroundTransparency = 0.8
    self.ResizeHandle.BorderSizePixel = 0
    self.ResizeHandle.Parent = self.Container
    
    local ResizeCorner = Instance.new("UICorner")
    ResizeCorner.CornerRadius = UDim.new(0, 8)
    ResizeCorner.Parent = self.ResizeHandle
    
    -- Resize icon (3 lines)
    for i = 1, 3 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 2, 0, 15 - (i * 3))
        line.Position = UDim2.new(0, 10 + (i * 6), 1, -10 - (15 - (i * 3)))
        line.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        line.BorderSizePixel = 0
        line.Parent = self.ResizeHandle
        
        local lineCorner = Instance.new("UICorner")
        lineCorner.CornerRadius = UDim.new(1, 0)
        lineCorner.Parent = line
    end
    
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
    MinIndLabel.Font = Enum.Font.GothamBold
    MinIndLabel.Parent = self.MinimizedIndicator
    
    local MinIndButton = Instance.new("TextButton")
    MinIndButton.Size = UDim2.new(1, 0, 1, 0)
    MinIndButton.BackgroundTransparency = 1
    MinIndButton.Text = ""
    MinIndButton.Parent = self.MinimizedIndicator
    
    MinIndButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
end

function Window:SetupDragging()
    if not self.Config.Draggable then return end
    
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
end

function Window:SetupResizing()
    if not self.Config.Resizable then return end
    
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    
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
            
            -- Smooth animation
            TweenService:Create(self.Container, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(newWidth, newHeight)
            }):Play()
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
            BackgroundTransparency = 0.5
        }):Play()
    end)
    
    self.ResizeHandle.MouseLeave:Connect(function()
        TweenService:Create(self.ResizeHandle, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.8
        }):Play()
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
    local Tab = require(script.Parent.Tab)
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
    if self.Notification then
        self.Notification:Show(config)
    end
end

function Window:Destroy()
    if self.Blur then
        self.Blur:Destroy()
    end
    self.ScreenGui:Destroy()
end

return Window
