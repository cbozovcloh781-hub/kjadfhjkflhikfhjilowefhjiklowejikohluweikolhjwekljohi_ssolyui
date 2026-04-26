-- Icon system with animations for Ssoly UI
-- Inspired by maclib's beautiful icon animations

local TweenService = game:GetService("TweenService")

local Icons = {}

-- Icon assets (using rbxassetid)
Icons.Assets = {
    -- UI Elements
    dropdown = "rbxassetid://18865373378",
    search = "rbxassetid://86737463322606",
    checkmark = "✓",
    cross = "✗",
    
    -- Arrows
    arrowDown = "rbxassetid://18865373378",
    arrowRight = "▶",
    arrowLeft = "◀",
    
    -- Common icons
    settings = "⚙",
    info = "ℹ",
    warning = "⚠",
    error = "✗",
    success = "✓",
    
    -- Shapes
    circle = "●",
    square = "■",
    diamond = "◆",
}

-- Create animated icon
function Icons.Create(config)
    config = config or {}
    
    local icon
    local isImage = config.Image and config.Image:match("rbxassetid://")
    
    if isImage then
        icon = Instance.new("ImageLabel")
        icon.Image = config.Image
        icon.ImageColor3 = config.Color or Color3.fromRGB(255, 255, 255)
        icon.ImageTransparency = config.Transparency or 0.5
        icon.ScaleType = Enum.ScaleType.Fit
    else
        icon = Instance.new("TextLabel")
        icon.Text = config.Icon or config.Image or "?"
        icon.TextColor3 = config.Color or Color3.fromRGB(255, 255, 255)
        icon.TextTransparency = config.Transparency or 0.5
        icon.TextSize = config.TextSize or 14
        icon.Font = Enum.Font.GothamBold
    end
    
    icon.Name = config.Name or "Icon"
    icon.Size = config.Size or UDim2.fromOffset(16, 16)
    icon.Position = config.Position or UDim2.fromOffset(0, 0)
    icon.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    
    return icon
end

-- Animate icon on hover
function Icons.AnimateHover(icon, config)
    config = config or {}
    
    local defaultTransparency = config.DefaultTransparency or 0.5
    local hoverTransparency = config.HoverTransparency or 0.2
    local duration = config.Duration or 0.2
    local easingStyle = config.EasingStyle or Enum.EasingStyle.Sine
    
    local tweenInfo = TweenInfo.new(duration, easingStyle)
    
    return {
        Enter = function()
            local props = {}
            if icon:IsA("ImageLabel") then
                props.ImageTransparency = hoverTransparency
            else
                props.TextTransparency = hoverTransparency
            end
            TweenService:Create(icon, tweenInfo, props):Play()
        end,
        
        Leave = function()
            local props = {}
            if icon:IsA("ImageLabel") then
                props.ImageTransparency = defaultTransparency
            else
                props.TextTransparency = defaultTransparency
            end
            TweenService:Create(icon, tweenInfo, props):Play()
        end
    }
end

-- Rotate animation (for dropdowns, etc)
function Icons.AnimateRotation(icon, angle, duration)
    duration = duration or 0.2
    
    local tween = TweenService:Create(
        icon,
        TweenInfo.new(duration, Enum.EasingStyle.Quad),
        {Rotation = angle}
    )
    
    tween:Play()
    return tween
end

-- Scale animation (for buttons, etc)
function Icons.AnimateScale(icon, scale, duration)
    duration = duration or 0.15
    
    local originalSize = icon.Size
    local targetSize = UDim2.new(
        originalSize.X.Scale * scale,
        originalSize.X.Offset * scale,
        originalSize.Y.Scale * scale,
        originalSize.Y.Offset * scale
    )
    
    local tween = TweenService:Create(
        icon,
        TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    
    tween:Play()
    return tween
end

-- Pulse animation (for notifications, etc)
function Icons.AnimatePulse(icon, config)
    config = config or {}
    
    local scale = config.Scale or 1.2
    local duration = config.Duration or 0.3
    local loops = config.Loops or 1
    
    local originalSize = icon.Size
    
    for i = 1, loops do
        task.spawn(function()
            task.wait((i - 1) * duration * 2)
            
            -- Scale up
            local scaleUp = TweenService:Create(
                icon,
                TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    Size = UDim2.new(
                        originalSize.X.Scale * scale,
                        originalSize.X.Offset * scale,
                        originalSize.Y.Scale * scale,
                        originalSize.Y.Offset * scale
                    )
                }
            )
            
            scaleUp:Play()
            scaleUp.Completed:Wait()
            
            -- Scale down
            local scaleDown = TweenService:Create(
                icon,
                TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Size = originalSize}
            )
            
            scaleDown:Play()
        end)
    end
end

-- Spin animation (for loading, etc)
function Icons.AnimateSpin(icon, duration, continuous)
    duration = duration or 1
    continuous = continuous ~= false
    
    local function spin()
        local tween = TweenService:Create(
            icon,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {Rotation = icon.Rotation + 360}
        )
        
        tween:Play()
        
        if continuous then
            tween.Completed:Connect(spin)
        end
        
        return tween
    end
    
    return spin()
end

-- Fade animation
function Icons.AnimateFade(icon, transparency, duration)
    duration = duration or 0.2
    
    local props = {}
    if icon:IsA("ImageLabel") then
        props.ImageTransparency = transparency
    else
        props.TextTransparency = transparency
    end
    
    local tween = TweenService:Create(
        icon,
        TweenInfo.new(duration, Enum.EasingStyle.Sine),
        props
    )
    
    tween:Play()
    return tween
end

-- Color animation
function Icons.AnimateColor(icon, color, duration)
    duration = duration or 0.2
    
    local props = {}
    if icon:IsA("ImageLabel") then
        props.ImageColor3 = color
    else
        props.TextColor3 = color
    end
    
    local tween = TweenService:Create(
        icon,
        TweenInfo.new(duration, Enum.EasingStyle.Sine),
        props
    )
    
    tween:Play()
    return tween
end

return Icons
