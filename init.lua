---@diagnostic disable: undefined-global
-- Ssoly UI Library v1.0
-- Modern minimalist UI library for Roblox exploits
-- Created for YBA Enhanced Script

local Ssoly = {}
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

-- Create loading screen
local function createLoadingScreen()
    local coreGui = game:GetService("CoreGui")
    local lighting = game:GetService("Lighting")
    
    -- Remove old UI if exists
    local oldUI = coreGui:FindFirstChild("SsolyUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Remove old loading screen if exists
    local oldLoading = coreGui:FindFirstChild("SsolyLoading")
    if oldLoading then
        oldLoading:Destroy()
    end
    
    -- Remove old blurs
    local oldBlur = lighting:FindFirstChild("SsolyBlur")
    if oldBlur then
        oldBlur:Destroy()
    end
    
    local oldLoadingBlur = lighting:FindFirstChild("SsolyLoadingBlur")
    if oldLoadingBlur then
        oldLoadingBlur:Destroy()
    end
    
    -- Create blur effect
    local blur = Instance.new("BlurEffect")
    blur.Name = "SsolyLoadingBlur"
    blur.Size = 0
    blur.Parent = lighting
    
    local TweenService = game:GetService("TweenService")
    TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = 15}):Play()
    
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "SsolyLoading"
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.Parent = coreGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(0, 0)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = loadingGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 2
    stroke.Transparency = 1
    stroke.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.fromOffset(0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Sosalkin Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextTransparency = 1
    title.Parent = container
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.fromOffset(20, 70)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTransparency = 1
    status.Parent = container
    
    -- Spinning loader (3 dots animation)
    local dotsContainer = Instance.new("Frame")
    dotsContainer.Size = UDim2.fromOffset(60, 20)
    dotsContainer.Position = UDim2.fromOffset(120, 100)
    dotsContainer.BackgroundTransparency = 1
    dotsContainer.Parent = container
    
    local dots = {}
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(8, 8)
        dot.Position = UDim2.fromOffset((i-1) * 20 + 6, 6)
        dot.BackgroundColor3 = Color3.fromRGB(74, 158, 255)
        dot.BorderSizePixel = 0
        dot.BackgroundTransparency = 1
        dot.Parent = dotsContainer
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        table.insert(dots, dot)
    end
    
    -- Animate container appearance
    TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(300, 150),
        BackgroundTransparency = 0.1
    }):Play()
    
    TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Transparency = 0
    }):Play()
    
    -- Fade in text elements
    task.delay(0.3, function()
        TweenService:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        
        TweenService:Create(status, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextTransparency = 0.3
        }):Play()
        
        -- Fade in dots
        for i, dot in ipairs(dots) do
            task.delay(i * 0.1, function()
                TweenService:Create(dot, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0
                }):Play()
            end)
        end
    end)
    
    -- Animate dots
    local TweenService = game:GetService("TweenService")
    local animationRunning = true
    
    -- Store cleanup function
    loadingGui:SetAttribute("StopAnimation", false)
    
    task.delay(0.8, function()
        for i, dot in ipairs(dots) do
            coroutine.wrap(function()
                while loadingGui.Parent and not loadingGui:GetAttribute("StopAnimation") do
                    task.wait((i-1) * 0.15)
                    if not loadingGui.Parent then break end
                    TweenService:Create(dot, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.8}):Play()
                    task.wait(0.4)
                    if not loadingGui.Parent then break end
                    TweenService:Create(dot, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                    task.wait(0.4 + (3-i) * 0.15)
                end
            end)()
        end
    end)
    
    return loadingGui, blur, status
end

-- Error screen
local function showErrorScreen()
    local coreGui = game:GetService("CoreGui")
    local lighting = game:GetService("Lighting")
    
    -- Remove loading screen
    local oldLoading = coreGui:FindFirstChild("SsolyLoading")
    if oldLoading then
        oldLoading:Destroy()
    end
    
    local oldBlur = lighting:FindFirstChild("SsolyLoadingBlur")
    if oldBlur then
        oldBlur:Destroy()
    end
    
    -- Create error screen
    local errorGui = Instance.new("ScreenGui")
    errorGui.Name = "SsolyError"
    errorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    errorGui.ResetOnSpawn = false
    errorGui.IgnoreGuiInset = true
    errorGui.Parent = coreGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(350, 180)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Parent = errorGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 69, 58)
    stroke.Thickness = 2
    stroke.Parent = container
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.fromOffset(60, 60)
    icon.Position = UDim2.new(0.5, 0, 0, 25)
    icon.AnchorPoint = Vector2.new(0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚠️"
    icon.TextSize = 48
    icon.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.fromOffset(20, 90)
    title.BackgroundTransparency = 1
    title.Text = "Ошибка загрузки"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 40)
    desc.Position = UDim2.fromOffset(20, 125)
    desc.BackgroundTransparency = 1
    desc.Text = "Не удалось загрузить UI библиотеку.\nПроверьте подключение к интернету."
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.TextSize = 12
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.Parent = container
    
    -- Auto-close after 5 seconds
    task.delay(5, function()
        if errorGui and errorGui.Parent then
            errorGui:Destroy()
        end
    end)
end

local loadingGui, loadingBlur, statusLabel = createLoadingScreen()

-- Load core modules with error handling
local success, err = pcall(function()
    Ssoly.Window = loadstring(game:HttpGet(baseUrl .. "core/Window.lua"))()
    Ssoly.Tab = loadstring(game:HttpGet(baseUrl .. "core/Tab.lua"))()
end)

if not success then
    showErrorScreen()
    error("Failed to load Ssoly UI: " .. tostring(err))
end

-- Create window
function Ssoly:CreateWindow(config)
    config = config or {}
    config._delayShow = true
    config._loadingGui = loadingGui
    config._loadingBlur = loadingBlur
    return self.Window.new(config)
end

-- Version info
Ssoly.Version = "1.1.0"
Ssoly.Author = "Sosalkin hub"
Ssoly.Features = {
    "Theme System (8 accents + 6 schemes)",
    "Smooth tab animations",
    "Particle effects",
    "Notification system",
    "Resizable windows",
    "Draggable interface"
}

return Ssoly
