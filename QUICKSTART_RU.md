# 🚀 Быстрый старт - Новые возможности

## Частицы

### Включить/выключить глобально:
```lua
Window:SetParticlesEnabled(true)  -- включить
Window:SetParticlesEnabled(false) -- выключить
```

### Добавить в настройки:
```lua
SettingsTab:AddToggle({
    Title = "Particles Effect",
    Description = "Красивые анимированные частицы",
    Default = true,
    Callback = function(Value)
        Window:SetParticlesEnabled(Value)
    end
})
```

## Анимации

Все анимации работают автоматически! Просто используй элементы как обычно:

### Dropdown:
- Стрелка вращается при открытии ✓
- Чекмарки появляются с анимацией ✓
- Hover эффекты на всех элементах ✓

### Что уже работает:
- ✅ Dropdown - полностью анимирован
- ✅ Частицы - можно включать/выключать
- ✅ Все цвета синхронизированы с accent color

### Что можно добавить дальше:
- Toggle с анимацией переключателя
- Button с hover эффектами
- Slider с плавным движением
- Colorpicker с анимацией палитры

## Пример полного кода:

```lua
local Ssoly = loadstring(game:HttpGet("..."))()

local Window = Ssoly:CreateWindow({
    Title = "Мой Hub",
    Size = UDim2.fromOffset(700, 500),
})

local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "⚙️"
})

-- Добавить настройку частиц
SettingsTab:AddToggle({
    Title = "Particles Effect",
    Description = "Анимированные частицы на фоне",
    Default = true,
    Callback = function(Value)
        Window:SetParticlesEnabled(Value)
    end
})

-- Показать окно (закроет loading screen)
Window:Show()
```

Готово! Теперь у тебя красивый UI с частицами и анимациями! 🎉
