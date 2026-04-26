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
    self.Sections = {}
    self.Selected = false
    
    self:CreateButton()
    self:CreateContentContainer()
    
    return self
end

function Tab:CreateContentContainer()
    -- Content container for sections
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "Content_" .. self.Title
    self.ContentContainer.Size = UDim2.new(1, 0, 1, 0)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Visible = false
    self.ContentContainer.Parent = self.Window.ContentContainer
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
            TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.1
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                ImageColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
        end
    end)
end

function Tab:Select()
    self.Selected = true
    
    local accentColor = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    
    -- Animate selection with bounce effect
    TweenService:Create(self.Button, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.8
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    -- Indicator grows with bounce
    TweenService:Create(self.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 3, 0, 30)
    }):Play()
    
    -- Show elements with staggered fade-in (no position change)
    for i, element in pairs(self.Elements) do
        element.Visible = true
        element.BackgroundTransparency = 1
        
        -- Store original transparencies
        local originalTransparencies = {}
        for _, child in pairs(element:GetDescendants()) do
            if child:IsA("GuiObject") then
                originalTransparencies[child] = {
                    Background = child.BackgroundTransparency,
                    Text = (child:IsA("TextLabel") or child:IsA("TextButton")) and 0 or nil,
                    Image = (child:IsA("ImageLabel") or child:IsA("ImageButton")) and child.ImageTransparency or nil,
                    Stroke = child:FindFirstChildOfClass("UIStroke") and child:FindFirstChildOfClass("UIStroke").Transparency or nil
                }
            end
        end
        
        -- Staggered animation for each element
        task.delay(i * 0.03, function()
            if element and element.Parent then
                -- Fade in container background
                TweenService:Create(element, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.5
                }):Play()
                
                -- Fade in all descendants
                for child, transparencies in pairs(originalTransparencies) do
                    if child and child.Parent then
                        -- Fade in backgrounds
                        if transparencies.Background < 1 then
                            TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = transparencies.Background
                            }):Play()
                        end
                        
                        -- Fade in text
                        if transparencies.Text and (child:IsA("TextLabel") or child:IsA("TextButton")) then
                            child.TextTransparency = 1
                            local targetTransparency = child.Name == "Title" and 0 or (child.Name == "Description" and 0.3 or 0.2)
                            TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                TextTransparency = targetTransparency
                            }):Play()
                        end
                        
                        -- Fade in images
                        if transparencies.Image and (child:IsA("ImageLabel") or child:IsA("ImageButton")) then
                            child.ImageTransparency = 1
                            TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                ImageTransparency = transparencies.Image
                            }):Play()
                        end
                        
                        -- Fade in strokes
                        local stroke = child:FindFirstChildOfClass("UIStroke")
                        if stroke and transparencies.Stroke then
                            stroke.Transparency = 1
                            TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                Transparency = transparencies.Stroke
                            }):Play()
                        end
                    end
                end
            end
        end)
    end
end

function Tab:Deselect()
    self.Selected = false
    
    -- Animate deselection smoothly
    TweenService:Create(self.Button, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BackgroundTransparency = 0.3
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 3, 0, 0)
    }):Play()
    
    -- Fade out elements smoothly without position change
    for i, element in pairs(self.Elements) do
        if element and element.Parent then
            -- Fade out background
            TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
            
            -- Fade out all descendants
            for _, child in pairs(element:GetDescendants()) do
                if child:IsA("GuiObject") then
                    -- Fade backgrounds
                    if child.BackgroundTransparency < 1 then
                        TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                    
                    -- Fade text
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            TextTransparency = 1
                        }):Play()
                    end
                    
                    -- Fade images
                    if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            ImageTransparency = 1
                        }):Play()
                    end
                    
                    -- Fade strokes
                    if child:IsA("UIStroke") then
                        TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Transparency = 1
                        }):Play()
                    end
                end
            end
        end
    end
    
    -- Hide elements after animation
    task.delay(0.35, function()
        for _, element in pairs(self.Elements) do
            if element and element.Parent then
                element.Visible = false
            end
        end
    end)
end

-- Section creation
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

function Tab:AddSection(side)
    side = side or "Left"
    
    -- Create section container if not exists
    local sectionContainer = self.ContentContainer:FindFirstChild(side .. "Section")
    if not sectionContainer then
        sectionContainer = Instance.new("ScrollingFrame")
        sectionContainer.Name = side .. "Section"
        sectionContainer.Size = UDim2.new(0.5, -7.5, 1, 0)
        sectionContainer.Position = side == "Left" and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 7.5, 0, 0)
        sectionContainer.BackgroundTransparency = 1
        sectionContainer.BorderSizePixel = 0
        sectionContainer.ScrollBarThickness = 4
        sectionContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        sectionContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        sectionContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sectionContainer.Visible = false
        sectionContainer.Parent = self.ContentContainer
        
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = sectionContainer
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 10)
        Padding.PaddingBottom = UDim.new(0, 10)
        Padding.Parent = sectionContainer
    end
    
    local section = {Container = sectionContainer, Tab = self, Side = side, Window = self.Window}
    
    function section:AddToggle(config)
        local s, r = pcall(function()
            local T = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
            local t = T.new(self, config)
            t.Container.Visible = false
            t.Container.Parent = self.Container
            table.insert(self.Tab.Elements, t.Container)
            return t
        end)
        if not s then warn("Toggle failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddSlider(config)
        local s, r = pcall(function()
            local S = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
            local sl = S.new(self, config)
            sl.Container.Visible = false
            sl.Container.Parent = self.Container
            table.insert(self.Tab.Elements, sl.Container)
            return sl
        end)
        if not s then warn("Slider failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddDropdown(config)
        local s, r = pcall(function()
            local D = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
            local d = D.new(self, config)
            d.Container.Visible = false
            d.Container.Parent = self.Container
            table.insert(self.Tab.Elements, d.Container)
            return d
        end)
        if not s then warn("Dropdown failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddButton(config)
        local s, r = pcall(function()
            local B = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
            local b = B.new(self, config)
            b.Container.Visible = false
            b.Container.Parent = self.Container
            table.insert(self.Tab.Elements, b.Container)
            return b
        end)
        if not s then warn("Button failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddInput(config)
        local s, r = pcall(function()
            local I = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
            local i = I.new(self, config)
            i.Container.Visible = false
            i.Container.Parent = self.Container
            table.insert(self.Tab.Elements, i.Container)
            return i
        end)
        if not s then warn("Input failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddColorpicker(config)
        local s, r = pcall(function()
            local C = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
            local c = C.new(self, config)
            c.Container.Visible = false
            c.Container.Parent = self.Container
            table.insert(self.Tab.Elements, c.Container)
            return c
        end)
        if not s then warn("Colorpicker failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddKeybind(config)
        local s, r = pcall(function()
            local K = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()
            local k = K.new(self, config)
            k.Container.Visible = false
            k.Container.Parent = self.Container
            table.insert(self.Tab.Elements, k.Container)
            return k
        end)
        if not s then warn("Keybind failed: " .. tostring(r)) return nil end
        return r
    end
    
    table.insert(self.Sections, section)
    return section
end

function Tab:AddToggle(config)
    local s, r = pcall(function()
        local T = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
        local t = T.new(self, config)
        t.Container.Visible = false
        table.insert(self.Elements, t.Container)
        return t
    end)
    if not s then warn("Toggle failed: " .. tostring(r)) return nil end
    return r
end

function Tab:AddSlider(config)
    local s, r = pcall(function()
        local S = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
        local sl = S.new(self, config)
        sl.Container.Visible = false
        table.insert(self.Elements, sl.Container)
        return sl
    end)
    if not s then warn("Slider failed: " .. tostring(r)) return nil end
    return r
end

function Tab:AddDropdown(config)
    local s, r = pcall(function()
        local D = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
        local d = D.new(self, config)
        d.Container.Visible = false
        table.insert(self.Elements, d.Container)
        return d
    end)
    if not s then warn("Dropdown failed: " .. tostring(r)) return nil end
    return r
end

function Tab:AddButton(config)
    local s, r = pcall(function()
        local B = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
        local b = B.new(self, config)
        b.Container.Visible = false
        table.insert(self.Elements, b.Container)
        return b
    end)
    if not s then warn("Button failed: " .. tostring(r)) return nil end
    return r
end

function Tab:AddInput(config)
    local s, r = pcall(function()
        local I = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
        local i = I.new(self, config)
        i.Container.Visible = false
        table.insert(self.Elements, i.Container)
        return i
    end)
    if not s then warn("Input failed: " .. tostring(r)) return nil end
    return r
end

function Tab:AddColorpicker(config)
    local s, r = pcall(function()
        local C = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
        local c = C.new(self, config)
        c.Container.Visible = false
        table.insert(self.Elements, c.Container)
        return c
    end)
    if not s then warn("Colorpicker failed: " .. tostring(r)) return nil end
    return r
end

function Tab:AddKeybind(config)
    local s, r = pcall(function()
        local K = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()
        local k = K.new(self, config)
        k.Container.Visible = false
        table.insert(self.Elements, k.Container)
        return k
    end)
    if not s then warn("Keybind failed: " .. tostring(r)) return nil end
    return r
end

return Tab
