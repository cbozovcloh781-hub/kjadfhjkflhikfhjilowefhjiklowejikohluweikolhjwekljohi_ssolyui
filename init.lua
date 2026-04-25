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
    
    -- Create blur effect
    local blur = Instance.new("BlurEffect")
    blur.Name = "SsolyLoadingBlur"
    blur.Size = 0
    blur.Parent = lighting
    
    local TweenService = game:GetService("TweenService")
    TweenService:Create(blur, TweenInfo.new(0.3), {Size = 15}):Play()
    
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "SsolyLoading"
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.Parent = coreGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(300, 150)
    container.Position = UDim2.new(0.5, -150, 0.5, -75)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Parent = loadingGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Parent = container
    
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
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = container
    
    -- Spinning loader
    local spinnerContainer = Instance.new("Frame")
    spinnerContainer.Size = UDim2.fromOffset(40, 40)
    spinnerContainer.Position = UDim2.fromOffset(130, 95)
    spinnerContainer.BackgroundTransparency = 1
    spinnerContainer.Parent = container
    
    local spinner = Instance.new("ImageLabel")
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://106296997072730"
    spinner.ImageColor3 = Color3.fromRGB(74, 158, 255)
    spinner.Parent = spinnerContainer
    
    -- Animate spinner
    local rotation = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        rotation = rotation + 5
        spinner.Rotation = rotation
    end)
    
    return loadingGui, blur
end

local loadingGui, loadingBlur = createLoadingScreen()

-- Load core modules
Ssoly.Window = loadstring(game:HttpGet(baseUrl .. "core/Window.lua"))()
Ssoly.Tab = loadstring(game:HttpGet(baseUrl .. "core/Tab.lua"))()

-- Load elements
local Toggle = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
local Slider = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
local Dropdown = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
local Button = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
local Input = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
local Colorpicker = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
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

-- Don't close loading screen automatically
-- User must call Window:Show() to close it

-- Create window
function Ssoly:CreateWindow(config)
    config = config or {}
    config._delayShow = true
    config._loadingGui = loadingGui
    config._loadingBlur = loadingBlur
    return self.Window.new(config)
end

-- Version info
Ssoly.Version = "1.0.0"
Ssoly.Author = "Sosalkin hub"

return Ssoly
