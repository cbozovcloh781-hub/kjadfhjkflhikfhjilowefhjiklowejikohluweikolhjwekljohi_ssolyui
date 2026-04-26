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
    self.MaxParticles = 50
    self.SpawnRate = 0.2
    self.LastSpawn = 0
    self.Running = false
    
    return self
end

function Particles:CreateParticle()
    if not Particles.Enabled then return end
    if not self.Running then return end
    if not self.Container or not self.Container.Parent then return end
    if #self.Particles >= self.MaxParticles then return end
    
    local particle = Instance.new("Frame")
    particle.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
    particle.Position = UDim2.new(
        math.random(0, 100) / 100,
        0,
        math.random(0, 100) / 100,
        0
    )
    
    -- Use accent color with slight variation
    local r = math.clamp(self.AccentColor.R * 255 + math.random(-15, 15), 0, 255)
    local g = math.clamp(self.AccentColor.G * 255 + math.random(-15, 15), 0, 255)
    local b = math.clamp(self.AccentColor.B * 255 + math.random(-15, 15), 0, 255)
    
    particle.BackgroundColor3 = Color3.fromRGB(r, g, b)
    particle.BackgroundTransparency = math.random(40, 80) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 1
    particle.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    table.insert(self.Particles, particle)
    
    -- Animate particle
    local duration = math.random(3, 6)
    local endPos = UDim2.new(
        math.random(0, 100) / 100,
        0,
        math.random(0, 100) / 100,
        0
    )
    
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
    
    -- Плавно исчезаем все частицы
    for i = #self.Particles, 1, -1 do
        local particle = self.Particles[i]
        if particle and particle.Parent then
            -- Анимация исчезновения
            TweenService:Create(particle, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
            
            -- Удаляем после анимации
            task.delay(0.8, function()
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
            -- Останавливаем систему и плавно удаляем все частицы
            particleSystem.Running = false
            if particleSystem.Container then
                particleSystem.Container.Visible = false
            end
            -- Плавно исчезаем все частицы
            for i = #particleSystem.Particles, 1, -1 do
                local particle = particleSystem.Particles[i]
                if particle and particle.Parent then
                    TweenService:Create(particle, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                    
                    task.delay(0.8, function()
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
