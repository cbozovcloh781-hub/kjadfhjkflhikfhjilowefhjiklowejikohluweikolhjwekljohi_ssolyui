-- Ssoly UI Library - Keybind Element
-- Customizable keybind selector

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(tab, config)
    local self = setmetatable({}, Keybind)
    
    self.Tab = tab
    self.Title = config.Title or "Keybind"
    self.Description = config.Description
    self.Default = config.Default or Enum.KeyCode.E
    self.Callback = config.Callback or function() end
    self.Value = self.Default
    self.Listening = false
    
    self:CreateElement()
    self:SetupListener()
    
    return self
end

function Keybind:CreateElement()
    -- Main container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Keybind"
    self.Container.Size = UDim2.new(1, -20, 0, self.Description and 60 or 45)
    self.Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.Tab.Window.ContentContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -100, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(12, 10)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Container
    
    -- Description (optional)
    if self.Description then
        self.DescLabel = Instance.new("TextLabel")
        self.DescLabel.Name = "Description"
        self.DescLabel.Size = UDim2.new(1, -100, 0, 15)
        self.DescLabel.Position = UDim2.fromOffset(12, 32)
        self.DescLabel.BackgroundTransparency = 1
        self.DescLabel.Text = self.Description
        self.DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        self.DescLabel.TextSize = 11
        self.DescLabel.Font = Enum.Font.Gotham
        self.DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescLabel.TextWrapped = true
        self.DescLabel.Parent = self.Container
    end
    
    -- Keybind button
    self.KeybindButton = Instance.new("TextButton")
    self.KeybindButton.Name = "Button"
    self.KeybindButton.Size = UDim2.fromOffset(80, 25)
    self.KeybindButton.Position = UDim2.new(1, -90, 0.5, -12.5)
    self.KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.KeybindButton.BackgroundTransparency = 0.3
    self.KeybindButton.BorderSizePixel = 0
    self.KeybindButton.Text = self:GetKeyName(self.Value)
    self.KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.KeybindButton.TextSize = 12
    self.KeybindButton.Font = Enum.Font.GothamBold
    self.KeybindButton.AutoButtonColor = false
    self.KeybindButton.Parent = self.Container
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = self.KeybindButton
    
    -- Border (listening indicator)
    self.Border = Instance.new("UIStroke")
    self.Border.Color = Color3.fromRGB(74, 158, 255)
    self.Border.Thickness = 0
    self.Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self.Border.Parent = self.KeybindButton
    
    -- Click to listen
    self.KeybindButton.MouseButton1Click:Connect(function()
        self:StartListening()
    end)
    
    -- Hover effects
    self.KeybindButton.MouseEnter:Connect(function()
        if not self.Listening then
            TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end
    end)
    
    self.KeybindButton.MouseLeave:Connect(function()
        if not self.Listening then
            TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
end

function Keybind:GetKeyName(keyCode)
    local keyName = keyCode.Name
    
    -- Shorten common keys
    local shortcuts = {
        LeftShift = "LShift",
        RightShift = "RShift",
        LeftControl = "LCtrl",
        RightControl = "RCtrl",
        LeftAlt = "LAlt",
        RightAlt = "RAlt",
        CapsLock = "Caps",
        Return = "Enter",
        Backspace = "Back"
    }
    
    return shortcuts[keyName] or keyName
end

function Keybind:StartListening()
    self.Listening = true
    self.KeybindButton.Text = "..."
    
    -- Animate border
    TweenService:Create(self.Border, TweenInfo.new(0.2), {
        Thickness = 2
    }):Play()
    
    TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(74, 158, 255),
        BackgroundTransparency = 0.8
    }):Play()
end

function Keybind:StopListening()
    self.Listening = false
    self.KeybindButton.Text = self:GetKeyName(self.Value)
    
    -- Animate border
    TweenService:Create(self.Border, TweenInfo.new(0.2), {
        Thickness = 0
    }):Play()
    
    TweenService:Create(self.KeybindButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = 0.3
    }):Play()
end

function Keybind:SetupListener()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if self.Listening then
            -- Cancel with Escape
            if input.KeyCode == Enum.KeyCode.Escape then
                self:StopListening()
                return
            end
            
            -- Set new keybind
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self:SetValue(input.KeyCode)
                self:StopListening()
            end
        else
            -- Trigger callback when key is pressed
            if not gameProcessed and input.KeyCode == self.Value then
                task.spawn(function()
                    self.Callback(self.Value)
                end)
            end
        end
    end)
end

function Keybind:SetValue(keyCode, silent)
    self.Value = keyCode
    self.KeybindButton.Text = self:GetKeyName(keyCode)
    
    if not silent then
        -- Don't call callback on set, only on key press
    end
end

return Keybind
