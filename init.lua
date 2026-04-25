-- Ssoly UI Library v1.0
-- Modern minimalist UI library for Roblox exploits
-- Created for YBA Enhanced Script

local Ssoly = {}
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

-- Create loading screen
local function createLoadingScreen()
    local coreGui = game:GetService("CoreGui")
    
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "SsolyLoading"
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.Parent = coreGui
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    bg.BorderSizePixel = 0
    bg.Parent = loadingGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(300, 150)
    container.Position = UDim2.new(0.5, -150, 0.5, -75)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BorderSizePixel = 0
    container.Parent = bg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.fromOffset(0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Ssoly UI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.fromOffset(20, 70)
    status.BackgroundTransparency = 1
    status.Text = "Loading modules..."
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = container
    
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -40, 0, 6)
    progressBg.Position = UDim2.fromOffset(20, 100)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = container
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBg
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(74, 158, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = progressBar
    
    return loadingGui, status, progressBar
end

local loadingGui, statusLabel, progressBar = createLoadingScreen()

local function updateProgress(text, progress)
    statusLabel.Text = text
    local TweenService = game:GetService("TweenService")
    TweenService:Create(progressBar, TweenInfo.new(0.3), {
        Size = UDim2.new(progress, 0, 1, 0)
    }):Play()
end

-- Load core modules
updateProgress("Loading Window module...", 0.1)
Ssoly.Window = loadstring(game:HttpGet(baseUrl .. "core/Window.lua"))()

updateProgress("Loading Tab module...", 0.2)
Ssoly.Tab = loadstring(game:HttpGet(baseUrl .. "core/Tab.lua"))()

-- Load elements
updateProgress("Loading Toggle element...", 0.3)
local Toggle = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()

updateProgress("Loading Slider element...", 0.4)
local Slider = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()

updateProgress("Loading Dropdown element...", 0.5)
local Dropdown = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()

updateProgress("Loading Button element...", 0.6)
local Button = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()

updateProgress("Loading Input element...", 0.7)
local Input = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()

updateProgress("Loading Colorpicker element...", 0.8)
local Colorpicker = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()

updateProgress("Loading Keybind element...", 0.9)
local Keybind = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()

Ssoly.Elements = {
    Toggle = Toggle,
    Slider = Slider,
    Dropdown = Dropdown,
    Button = Button,
    Input = Input,
    Colorpicker = Colorpicker,
    Keybind = Keybind,
}

updateProgress("Finalizing...", 1.0)
task.wait(0.5)

-- Remove loading screen
local TweenService = game:GetService("TweenService")
TweenService:Create(loadingGui, TweenInfo.new(0.3), {
    BackgroundTransparency = 1
}):Play()
task.wait(0.3)
loadingGui:Destroy()

-- Create window
function Ssoly:CreateWindow(config)
    return self.Window.new(config)
end

-- Version info
Ssoly.Version = "1.0.0"
Ssoly.Author = "Sosalkin hub"

return Ssoly
