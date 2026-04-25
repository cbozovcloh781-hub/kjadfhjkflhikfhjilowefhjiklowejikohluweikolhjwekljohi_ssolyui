---@diagnostic disable: undefined-global
-- Ssoly UI Library - Tab Class
-- Handles individual tabs and their content

local TweenService = game:GetService("TweenService")

local Tab = {}
Tab.__index = Tab

function Tab.new(window, config)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Title = config.Title or "Tab"
    self.Icon = config.Icon or "📄"
    self.Elements = {}
    self.Selected = false
    
    self:CreateButton()
    
    return self
end

function Tab:CreateButton()
    -- Tab button
    self.Button = Instance.new("TextButton")
    self.Button.Name = self.Title
    self.Button.Size = UDim2.new(1, 0, 0, 40)
    self.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.Button.BackgroundTransparency = 0.3
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.SelectionImageObject = nil
    self.Button.Parent = self.Window.TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = self.Button
    
    -- Icon (Roblox Studio style with ImageLabel)
    local iconIds = {
        -- Movement icons
        ["⚡"] = "rbxassetid://7733992901",
        ["movement"] = "rbxassetid://7733992901",
        ["fly"] = "rbxassetid://7733992901",
        
        -- Vision/ESP icons  
        ["👁️"] = "rbxassetid://7733955511",
        ["👁"] = "rbxassetid://7733955511",
        ["esp"] = "rbxassetid://7733955511",
        ["eye"] = "rbxassetid://7733955511",
        
        -- Autofarm icons
        ["🤖"] = "rbxassetid://7733920644",
        ["🚜"] = "rbxassetid://7733920644",
        ["autofarm"] = "rbxassetid://7733920644",
        ["farm"] = "rbxassetid://7733920644",
        
        -- Settings icons
        ["⚙️"] = "rbxassetid://7733955511",
        ["⚙"] = "rbxassetid://7733955511",
        ["settings"] = "rbxassetid://7733955511",
        ["config"] = "rbxassetid://7733955511",
    }
    
    local iconId = iconIds[self.Icon] or iconIds[self.Title:lower()] or "rbxassetid://7733964126"
    
    self.IconLabel = Instance.new("ImageLabel")
    self.IconLabel.Name = "Icon"
    self.IconLabel.Size = UDim2.fromOffset(18, 18)
    self.IconLabel.Position = UDim2.fromOffset(12, 11)
    self.IconLabel.BackgroundTransparency = 1
    self.IconLabel.Image = iconId
    self.IconLabel.ImageColor3 = Color3.fromRGB(150, 150, 150)
    self.IconLabel.Parent = self.Button
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -45, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(38, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.TitleLabel.TextSize = 12
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Button
    
    -- Selection indicator
    self.Indicator = Instance.new("Frame")
    self.Indicator.Name = "Indicator"
    self.Indicator.Size = UDim2.new(0, 3, 0, 0)
    self.Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    self.Indicator.AnchorPoint = Vector2.new(0, 0.5)
    self.Indicator.BackgroundColor3 = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    self.Indicator.BorderSizePixel = 0
    self.Indicator.Parent = self.Button
    
    if self.Window.AccentElements then
        table.insert(self.Window.AccentElements, self.Indicator)
    end
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = self.Indicator
    
    -- Click handler
    self.Button.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)
    
    -- Hover effects
    self.Button.MouseEnter:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2), {
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2), {
                ImageColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
        end
    end)
end

function Tab:Select()
    self.Selected = true
    
    local accentColor = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    
    -- Animate selection
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.8
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3), {
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 3, 0, 30)
    }):Play()
    
    -- Show elements with fade-in animation
    for i, element in pairs(self.Elements) do
        element.Visible = true
        element.BackgroundTransparency = 1
        
        -- Store original transparency values
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("GuiObject") then
                if not child:GetAttribute("OriginalTransparency") then
                    child:SetAttribute("OriginalTransparency", child.BackgroundTransparency)
                end
                child.BackgroundTransparency = 1
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    child.TextTransparency = 1
                end
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    child.ImageTransparency = 1
                end
            end
        end
        
        task.delay(i * 0.02, function()
            -- Restore transparency
            TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = element:GetAttribute("OriginalTransparency") or 0.5
            }):Play()
            
            for _, child in pairs(element:GetDescendants()) do
                if child:IsA("GuiObject") then
                    local targetBg = child:GetAttribute("OriginalTransparency") or 0
                    TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = targetBg
                    }):Play()
                    
                    if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                        TweenService:Create(child, TweenInfo.new(0.2), {
                            TextTransparency = 0
                        }):Play()
                    end
                    if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        TweenService:Create(child, TweenInfo.new(0.2), {
                            ImageTransparency = 0
                        }):Play()
                    end
                end
            end
        end)
    end
end

function Tab:Deselect()
    self.Selected = false
    
    -- Animate deselection
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BackgroundTransparency = 0.3
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3), {
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3), {
        ImageColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 3, 0, 0)
    }):Play()
    
    -- Hide elements
    for _, element in pairs(self.Elements) do
        element.Visible = false
    end
end

-- Element creation methods
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

function Tab:AddToggle(config)
    local Toggle = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
    local toggle = Toggle.new(self, config)
    toggle.Container.Visible = false
    table.insert(self.Elements, toggle.Container)
    return toggle
end

function Tab:AddSlider(config)
    local Slider = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
    local slider = Slider.new(self, config)
    slider.Container.Visible = false
    table.insert(self.Elements, slider.Container)
    return slider
end

function Tab:AddDropdown(config)
    local Dropdown = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
    local dropdown = Dropdown.new(self, config)
    dropdown.Container.Visible = false
    table.insert(self.Elements, dropdown.Container)
    return dropdown
end

function Tab:AddButton(config)
    local Button = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
    local button = Button.new(self, config)
    button.Container.Visible = false
    table.insert(self.Elements, button.Container)
    return button
end

function Tab:AddInput(config)
    local Input = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
    local input = Input.new(self, config)
    input.Container.Visible = false
    table.insert(self.Elements, input.Container)
    return input
end

function Tab:AddColorpicker(config)
    local Colorpicker = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
    local colorpicker = Colorpicker.new(self, config)
    colorpicker.Container.Visible = false
    table.insert(self.Elements, colorpicker.Container)
    return colorpicker
end

function Tab:AddKeybind(config)
    local Keybind = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()
    local keybind = Keybind.new(self, config)
    keybind.Container.Visible = false
    table.insert(self.Elements, keybind.Container)
    return keybind
end

return Tab
