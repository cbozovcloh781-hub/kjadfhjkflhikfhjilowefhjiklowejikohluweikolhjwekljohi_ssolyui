---@diagnostic disable: undefined-global
-- Ssoly UI Library - Window Class
-- Handles main window creation, dragging, resizing, and animations

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Window = {}
Window.__index = Window

-- Default configuration
local DEFAULT_CONFIG = {
    Title = "Sosalkin Hub",
    Size = UDim2.fromOffset(700, 500),
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(1200, 800),
    Position = UDim2.new(0.5, -350, 0.5, -250),
    Transparency = 0.1,
    BlurEnabled = true,
    Draggable = true,
    Resizable = true,
    MinimizeKey = Enum.KeyCode.RightControl,
    HubStatus = "shub", -- "shub", "shub+", or "dev"
    StatusColor = Color3.fromRGB(150, 150, 150),
    PremiumExpiry = nil, -- Unix timestamp for shub+ expiry
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
    self.ScreenGui.Enabled = not self._delayShow  -- Hide if delayed
    self.ScreenGui.Parent = coreGui
    
    -- Blur effect
    if self.Config.BlurEnabled then
        self.Blur = Instance.new("BlurEffect")
        self.Blur.Name = "SsolyBlur"
        self.Blur.Size = self._delayShow and 0 or 10  -- Start at 0 if delayed
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
    
    -- Title text
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(12, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Config.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Minimize button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "Minimize"
    self.MinimizeButton.Size = UDim2.fromOffset(25, 25)
    self.MinimizeButton.Position = UDim2.new(1, -32, 0.5, -12.5)
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
    self.ContentContainer.BackgroundTransparency = 0.3
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
    
    -- Auto-update canvas size
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 15)
    ContentPadding.PaddingRight = UDim.new(0, 15)
    ContentPadding.Parent = self.ContentContainer
    
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
    
    -- Minimized indicator (hidden by default) - small icon that follows window
    self.MinimizedIndicator = Instance.new("Frame")
    self.MinimizedIndicator.Name = "MinimizedIndicator"
    self.MinimizedIndicator.Size = UDim2.fromOffset(50, 50)
    self.MinimizedIndicator.Position = self.Config.Position
    self.MinimizedIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MinimizedIndicator.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    self.MinimizedIndicator.BackgroundTransparency = 0.1
    self.MinimizedIndicator.BorderSizePixel = 0
    self.MinimizedIndicator.Visible = false
    self.MinimizedIndicator.Parent = self.ScreenGui
    
    local MinIndCorner = Instance.new("UICorner")
    MinIndCorner.CornerRadius = UDim.new(1, 0)
    MinIndCorner.Parent = self.MinimizedIndicator
    
    local MinIndStroke = Instance.new("UIStroke")
    MinIndStroke.Color = Color3.fromRGB(60, 60, 60)
    MinIndStroke.Thickness = 1
    MinIndStroke.Parent = self.MinimizedIndicator
    
    local MinIndLabel = Instance.new("TextLabel")
    MinIndLabel.Size = UDim2.new(1, 0, 1, 0)
    MinIndLabel.BackgroundTransparency = 1
    MinIndLabel.Text = self.Config.Title:sub(1, 1)
    MinIndLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinIndLabel.TextSize = 24
    MinIndLabel.Font = Enum.Font.SourceSansBold
    MinIndLabel.Parent = self.MinimizedIndicator
    
    -- Snow particles effect (deprecated, use new particles system)
    -- self:CreateSnowEffect()
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
    
    -- Minimized indicator dragging
    local minDragging = false
    local minDragStart = nil
    local minStartPos = nil
    local hasMoved = false
    
    self.MinimizedIndicator.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            minDragging = true
            hasMoved = false
            minDragStart = input.Position
            minStartPos = self.MinimizedIndicator.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if minDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - minDragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                hasMoved = true
                self.MinimizedIndicator.Position = UDim2.new(
                    minStartPos.X.Scale,
                    minStartPos.X.Offset + delta.X,
                    minStartPos.Y.Scale,
                    minStartPos.Y.Offset + delta.Y
                )
                -- Update config position for restore
                self.Config.Position = self.MinimizedIndicator.Position
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and minDragging then
            minDragging = false
            if not hasMoved then
                -- Click without drag = restore
                self:ToggleMinimize()
            end
        end
    end)
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
    -- Prevent rapid toggling
    if self._minimizing then return end
    self._minimizing = true
    
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        -- Hide blur
        if self.Blur then
            TweenService:Create(self.Blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = 0}):Play()
        end
        
        -- Hide particles
        if self.ParticleSystem and self.ParticleSystem.Container then
            self.ParticleSystem.Container.Visible = false
        end
        
        -- Hide resize handles
        self.ResizeHandle.Visible = false
        self.ResizeHandleV.Visible = false
        self.ResizeHandleH.Visible = false
        
        -- Hide profile
        self.ProfileContainer.Visible = false
        
        -- Store current position and size
        local currentPos = self.Container.Position
        local currentSize = self.Container.Size
        self.Config.Size = currentSize
        self.Config.Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset)
        
        -- Minimize animation to center
        local tween = TweenService:Create(self.Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset + currentSize.X.Offset/2, currentPos.Y.Scale, currentPos.Y.Offset + currentSize.Y.Offset/2)
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            self.Container.Visible = false
            
            -- Show indicator at same position
            self.MinimizedIndicator.Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset + currentSize.X.Offset/2, currentPos.Y.Scale, currentPos.Y.Offset + currentSize.Y.Offset/2)
            self.MinimizedIndicator.Visible = true
            self.MinimizedIndicator.Size = UDim2.fromOffset(0, 0)
            
            TweenService:Create(self.MinimizedIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(50, 50)
            }):Play()
            
            -- Allow next toggle
            task.delay(0.5, function()
                self._minimizing = false
            end)
        end)
    else
        -- Show blur
        if self.Blur then
            TweenService:Create(self.Blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = self.BlurSize}):Play()
        end
        
        -- Show particles
        if self.ParticleSystem and self.ParticleSystem.Container then
            self.ParticleSystem.Container.Visible = true
        end
        
        -- Show profile
        self.ProfileContainer.Visible = true
        
        -- Get indicator position
        local indPos = self.MinimizedIndicator.Position
        
        -- Hide indicator
        TweenService:Create(self.MinimizedIndicator, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
        
        task.wait(0.4)
        self.MinimizedIndicator.Visible = false
        
        -- Restore window from indicator position with saved size
        self.Container.Visible = true
        self.Container.Size = UDim2.fromOffset(0, 0)
        self.Container.Position = indPos
        
        TweenService:Create(self.Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = self.Config.Size,
            Position = UDim2.new(indPos.X.Scale, indPos.X.Offset - self.Config.Size.X.Offset/2, indPos.Y.Scale, indPos.Y.Offset - self.Config.Size.Y.Offset/2)
        }):Play()
        
        -- Show resize handles AFTER animation completes
        task.delay(0.5, function()
            self.ResizeHandle.Visible = true
            self.ResizeHandleV.Visible = true
            self.ResizeHandleH.Visible = true
            
            -- Allow next toggle
            self._minimizing = false
        end)
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
    -- Prevent rapid tab switching
    if self._switchingTab then return end
    if self.CurrentTab == tab then return end
    
    self._switchingTab = true
    
    -- Fade out current tab content quickly
    if self.CurrentTab then
        -- Immediately hide elements without animation to prevent bugs
        for _, element in pairs(self.CurrentTab.Elements) do
            if element and element.Parent then
                element.Visible = false
            end
        end
        
        -- Deselect tab
        self.CurrentTab:Deselect()
    end
    
    -- Select new tab with fade in
    self.CurrentTab = tab
    tab:Select()
    
    -- Allow next tab switch quickly
    task.delay(0.3, function()
        self._switchingTab = false
    end)
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
    
    -- Update minimized indicator border
    if self.MinimizedIndicator then
        local stroke = self.MinimizedIndicator:FindFirstChildOfClass("UIStroke")
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Color = color
            }):Play()
        end
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
        Blue = Color3.fromRGB(74, 158, 255),
        Purple = Color3.fromRGB(138, 43, 226),
        Pink = Color3.fromRGB(255, 105, 180),
        Red = Color3.fromRGB(255, 69, 58),
        Orange = Color3.fromRGB(255, 149, 0),
        Green = Color3.fromRGB(52, 199, 89),
        Cyan = Color3.fromRGB(90, 200, 250),
        Yellow = Color3.fromRGB(255, 214, 10),
    }
    
    local color = themes[themeName] or themes.Blue
    self:SetAccentColor(color)
    
    -- Return the color so it can be used for other purposes
    return color
end

function Window:SetHubStatus(status, expiryDate)
    if not self.StatusLabel then return end
    
    local statusText = ""
    local statusColor = Color3.fromRGB(150, 150, 150)
    
    if status == "dev" then
        statusText = "👑 dev"
        statusColor = Color3.fromRGB(90, 200, 250) -- Cyan/Light Blue
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
        statusColor = Color3.fromRGB(255, 215, 0) -- Gold
    else -- "shub" or default
        statusText = "shub"
        statusColor = Color3.fromRGB(150, 150, 150) -- Gray
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
    end)
end

function Window:InitParticles()
    -- Load particles system
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Particles = loadstring(game:HttpGet(baseUrl .. "utils/Particles.lua"))()
    
    -- Create particles for window
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
    
    local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"
    local Particles = loadstring(game:HttpGet(baseUrl .. "utils/Particles.lua"))()
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

return Window
