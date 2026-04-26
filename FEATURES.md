# Новые возможности Ssoly UI

## 🎨 Система частиц

Добавлена красивая система анимированных частиц для фона UI.

### Использование:

```lua
-- Включить/выключить частицы глобально
Window:SetParticlesEnabled(true)  -- включить
Window:SetParticlesEnabled(false) -- выключить
```

### В настройках:

```lua
SettingsTab:AddToggle({
    Title = "Particles Effect",
    Description = "Enable/disable animated particles",
    Default = true,
    Callback = function(Value)
        Window:SetParticlesEnabled(Value)
    end
})
```

### Особенности:
- ✨ Плавная анимация частиц
- 🎯 Автоматическое управление производительностью
- 🔧 Глобальное переключение для всех окон
- 💫 Красивые эффекты без нагрузки на FPS

---

## 🎭 Система иконок с анимациями

Добавлена продвинутая система иконок с плавными анимациями (вдохновлено maclib).

### Анимации в Dropdown:

1. **Стрелка (Arrow)**:
   - Плавное вращение при открытии/закрытии
   - Изменение цвета при наведении
   - Bounce эффект при анимации

2. **Чекмарки (Checkmarks)**:
   - Плавное появление/исчезновение
   - Scale анимация при выборе
   - Цветовые переходы с accent color

### Примеры анимаций:

```lua
-- Hover эффект для иконки
Icons.AnimateHover(icon, {
    DefaultTransparency = 0.5,
    HoverTransparency = 0.2,
    Duration = 0.2
})

-- Вращение (для dropdown)
Icons.AnimateRotation(icon, 180, 0.3)

-- Пульсация (для уведомлений)
Icons.AnimatePulse(icon, {
    Scale = 1.2,
    Duration = 0.3,
    Loops = 2
})

-- Плавное появление
Icons.AnimateFade(icon, 0, 0.2)
```

---

## 📝 Что добавлено:

### Файлы:
- `utils/Particles.lua` - Система частиц
- `utils/Icons.lua` - Система иконок с анимациями

### Обновления:
- `core/Window.lua` - Интеграция частиц
- `elements/Dropdown.lua` - Анимации иконок и чекмарков
- `test.lua` - Пример настройки частиц

---

## 🎯 Планы на будущее:

- [ ] Добавить иконки во все элементы (Toggle, Button, Slider)
- [ ] Больше типов анимаций (spin, bounce, shake)
- [ ] Кастомные иконки через rbxassetid
- [ ] Настройки скорости анимаций
- [ ] Particle presets (snow, stars, bubbles)

---

## 💡 Вдохновение:

Система иконок и анимаций вдохновлена **maclib** - одной из лучших UI библиотек для Roblox.

Особенности, взятые из maclib:
- Плавные hover эффекты
- Bounce анимации для интерактивных элементов
- Цветовые переходы с accent color
- Профессиональная полировка UI
