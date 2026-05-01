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
    -- Tab button with card style
    self.Button = Instance.new("TextButton")
    self.Button.Name = self.Title
    self.Button.Size = UDim2.new(1, 0, 0, 40)
    self.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Button.BackgroundTransparency = 0
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.SelectionImageObject = nil
    self.Button.Parent = self.Window.TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
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
            TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            }):Play()
            TweenService:Create(self.TitleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
            TweenService:Create(self.IconLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ImageColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
        end
    end)
end

function Tab:Select()
    self.Selected = true
    
    local accentColor = self.Window.AccentColor or Color3.fromRGB(74, 158, 255)
    
    -- Smooth button animation
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.85
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 3, 0, 30)
    }):Play()
    
    -- Show content container for sections instantly
    if #self.Sections > 0 then
        self.ContentContainer.Visible = true
        
        -- Show sections instantly
        for _, section in pairs(self.Sections) do
            if section.Container then
                section.Container.Visible = true
            end
        end
    end
    
    -- Show elements instantly
    for i, element in pairs(self.Elements) do
        if element and element.Parent then
            element.Visible = true
        end
    end
end

function Tab:Deselect()
    self.Selected = false
    
    -- Smooth button animation
    TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(self.TitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
    
    TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 3, 0, 0)
    }):Play()
    
    -- Hide content instantly
    if #self.Sections > 0 then
        self.ContentContainer.Visible = false
        
        for _, section in pairs(self.Sections) do
            if section.Container then
                section.Container.Visible = false
            end
        end
    end
    
    for i, element in pairs(self.Elements) do
        if element and element.Parent then
            element.Visible = false
        end
    end
end

-- Section creation
local baseUrl = "https://raw.githubusercontent.com/cbozovcloh781-hub/kjadfhjkflhikfhjilowefhjiklowejikohluweikolhjwekljohi_ssolyui/main/"

function Tab:AddSection(side)
    side = side or "Left"
    
    -- Create section container if not exists
    local sectionContainer = self.ContentContainer:FindFirstChild(side .. "Section")
    if not sectionContainer then
        -- Use regular Frame instead of ScrollingFrame to avoid empty space
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = side .. "Section"
        scrollFrame.Size = UDim2.new(0.5, -7.5, 1, 0)
        scrollFrame.Position = side == "Left" and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 7.5, 0, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Visible = false
        scrollFrame.Parent = self.ContentContainer
        
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = scrollFrame
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 10)
        Padding.PaddingBottom = UDim.new(0, 10)
        Padding.Parent = scrollFrame
        
        -- Update canvas size smoothly
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local contentHeight = Layout.AbsoluteContentSize.Y + 20
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        end)
        
        sectionContainer = scrollFrame
        
        -- Add divider line between sections (only once)
        if side == "Right" and not self.ContentContainer:FindFirstChild("Divider") then
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Size = UDim2.new(0, 1, 1, 0)
            divider.Position = UDim2.new(0.5, 0, 0, 0)
            divider.AnchorPoint = Vector2.new(0.5, 0)
            divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            divider.BorderSizePixel = 0
            divider.ZIndex = 2
            divider.Parent = self.ContentContainer
        end
    end
    
    local section = {Container = sectionContainer, Tab = self, Side = side, Window = self.Window}
    
    function section:AddToggle(config)
        local s, r = pcall(function()
            local T = loadstring(game:HttpGet(baseUrl .. "elements/Toggle.lua"))()
            local t = T.new(section, config)
            t.Container.Visible = false
            table.insert(self.Tab.Elements, t.Container)
            return t
        end)
        if not s then warn("Toggle failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddSlider(config)
        local s, r = pcall(function()
            local S = loadstring(game:HttpGet(baseUrl .. "elements/Slider.lua"))()
            local sl = S.new(section, config)
            sl.Container.Visible = false
            table.insert(self.Tab.Elements, sl.Container)
            return sl
        end)
        if not s then warn("Slider failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddDropdown(config)
        local s, r = pcall(function()
            local D = loadstring(game:HttpGet(baseUrl .. "elements/Dropdown.lua"))()
            local d = D.new(section, config)
            d.Container.Visible = false
            table.insert(self.Tab.Elements, d.Container)
            return d
        end)
        if not s then warn("Dropdown failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddButton(config)
        local s, r = pcall(function()
            local B = loadstring(game:HttpGet(baseUrl .. "elements/Button.lua"))()
            local b = B.new(section, config)
            b.Container.Visible = false
            table.insert(self.Tab.Elements, b.Container)
            return b
        end)
        if not s then warn("Button failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddInput(config)
        local s, r = pcall(function()
            local I = loadstring(game:HttpGet(baseUrl .. "elements/Input.lua"))()
            local i = I.new(section, config)
            i.Container.Visible = false
            table.insert(self.Tab.Elements, i.Container)
            return i
        end)
        if not s then warn("Input failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddColorpicker(config)
        local s, r = pcall(function()
            local C = loadstring(game:HttpGet(baseUrl .. "elements/Colorpicker.lua"))()
            local c = C.new(section, config)
            c.Container.Visible = false
            table.insert(self.Tab.Elements, c.Container)
            return c
        end)
        if not s then warn("Colorpicker failed: " .. tostring(r)) return nil end
        return r
    end
    
    function section:AddKeybind(config)
        local s, r = pcall(function()
            local K = loadstring(game:HttpGet(baseUrl .. "elements/Keybind.lua"))()
            local k = K.new(section, config)
            k.Container.Visible = false
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
        local t = T.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
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
        local sl = S.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
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
        local d = D.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
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
        local b = B.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
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
        local i = I.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
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
        local c = C.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
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
        local k = K.new({Tab = self, Window = self.Window, Container = self.Window.ContentContainer}, config)
        k.Container.Visible = false
        table.insert(self.Elements, k.Container)
        return k
    end)
    if not s then warn("Keybind failed: " .. tostring(r)) return nil end
    return r
end

return Tab
