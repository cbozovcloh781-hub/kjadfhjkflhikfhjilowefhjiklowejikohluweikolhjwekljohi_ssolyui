---@diagnostic disable: undefined-global
-- Particles system for Ssoly UI
-- Beautiful animated particles with settings toggle

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Particles = {}
Particles.Enabled = true
Particles.Active = {}

function Particles.new(parent, accentColor)
    local self = setmetatable({}, {__index = Particles})
    
    self.Parent = parent
    self.AccentColor = accentColor or Color3.fromRGB(74, 158, 255)
    self.Container = Instance.new("Frame")
    self.Container.Name = "ParticlesContainer"
    self.Container.Size = UDim2.fromScale(1, 1)
    self.Container.BackgroundTransparency = 1
    self.Container.ZIndex = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = parent
    
    self.Particles = {}
    self.MaxParticles = 100
    self.SpawnRate = 0.08
    self.LastSpawn = 0
    self.Running = false
    
    return self
end

function Particles:CreateParticle()
    if not Particles.Enabled then return end
    if not self.Running then return end
    if not self.Container or not self.Container.Parent then return end
    if #self.Particles >= self.MaxParticles then return end
    
    -- Одинаковый размер для круглых частиц
    local size = math.random(2, 5)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.fromOffset(size, size)  -- Квадрат для идеального круга
    
    -- Случайное направление: сверху (70%), слева (15%), справа (15%)
    local direction = math.random(1, 100)
    local startPos, endPos
    
    if direction <= 70 then
        -- Сверху вниз
        startPos = UDim2.new(math.random(0, 100) / 100, 0, 0, -10)
        endPos = UDim2.new(startPos.X.Scale + math.random(-10, 10) / 100, 0, 1, 10)
    elseif direction <= 85 then
        -- Слева направо
        startPos = UDim2.new(0, -10, math.random(0, 100) / 100, 0)
        endPos = UDim2.new(1, 10, startPos.Y.Scale + math.random(-10, 10) / 100, 0)
    else
        -- Справа налево
        startPos = UDim2.new(1, 10, math.random(0, 100) / 100, 0)
        endPos = UDim2.new(0, -10, startPos.Y.Scale + math.random(-10, 10) / 100, 0)
    end
    
    particle.Position = startPos
    
    -- Use accent color with slight variation
    local function clamp(val, min, max) return math.max(min, math.min(max, val)) end
    local r = clamp(self.AccentColor.R * 255 + math.random(-15, 15), 0, 255)
    local g = clamp(self.AccentColor.G * 255 + math.random(-15, 15), 0, 255)
    local b = clamp(self.AccentColor.B * 255 + math.random(-15, 15), 0, 255)
    
    particle.BackgroundColor3 = Color3.fromRGB(r, g, b)
    particle.BackgroundTransparency = math.random(40, 80) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 1
    particle.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)  -- Полностью круглый
    corner.Parent = particle
    
    table.insert(self.Particles, particle)
    
    -- Медленная анимация с долгим исчезновением
    local duration = math.random(6, 12)
    
    local tween = TweenService:Create(
        particle,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Position = endPos, BackgroundTransparency = 1}
    )
    
    tween.Completed:Connect(function()
        if particle and particle.Parent then
            particle:Destroy()
        end
        for i, p in ipairs(self.Particles) do
            if p == particle then
                table.remove(self.Particles, i)
                break
            end
        end
    end)
    
    tween:Play()
end

function Particles:Start()
    if self.Connection then return end
    
    self.Running = true
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not Particles.Enabled or not self.Running then
            self.Container.Visible = false
            return
        end
        
        self.Container.Visible = true
        local now = tick()
        if now - self.LastSpawn >= self.SpawnRate then
            self:CreateParticle()
            self.LastSpawn = now
        end
    end)
    
    table.insert(Particles.Active, self)
end

function Particles:Stop()
    self.Running = false
    
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    -- Медленно и плавно исчезаем все частицы
    for i = #self.Particles, 1, -1 do
        local particle = self.Particles[i]
        if particle and particle.Parent then
            -- Долгая анимация исчезновения (2 секунды)
            TweenService:Create(particle, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
            
            -- Удаляем после анимации
            task.delay(2, function()
                if particle and particle.Parent then
                    particle:Destroy()
                end
            end)
        end
        table.remove(self.Particles, i)
    end
    
    for i, p in ipairs(Particles.Active) do
        if p == self then
            table.remove(Particles.Active, i)
            break
        end
    end
end

function Particles:Destroy()
    self:Stop()
    self.Container:Destroy()
end

-- Global toggle for all particles
function Particles.SetEnabled(enabled)
    Particles.Enabled = enabled
    
    for _, particleSystem in ipairs(Particles.Active) do
        if not enabled then
            -- Останавливаем систему и медленно удаляем все частицы
            particleSystem.Running = false
            if particleSystem.Container then
                particleSystem.Container.Visible = false
            end
            -- Долгое исчезновение всех частиц (2 секунды)
            for i = #particleSystem.Particles, 1, -1 do
                local particle = particleSystem.Particles[i]
                if particle and particle.Parent then
                    TweenService:Create(particle, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                    
                    task.delay(2, function()
                        if particle and particle.Parent then
                            particle:Destroy()
                        end
                    end)
                end
                table.remove(particleSystem.Particles, i)
            end
        else
            -- Включаем систему
            particleSystem.Running = true
            if particleSystem.Container then
                particleSystem.Container.Visible = true
            end
        end
    end
end

function Particles:SetAccentColor(color)
    self.AccentColor = color
end

return Particles
