# 🚀 Инструкция по загрузке и тестированию

## Шаг 1: Создай GitHub репозиторий

1. Зайди на https://github.com
2. Нажми зеленую кнопку **"New"** (или **"+"** → **"New repository"**)
3. Заполни:
   - **Repository name**: `ssoly-ui` (или любое другое)
   - **Description**: `Modern minimalist UI library for Roblox`
   - **Public** ✅ (обязательно!)
   - **НЕ добавляй** README, .gitignore, license
4. Нажми **"Create repository"**

## Шаг 2: Установи Git (если нет)

Скачай и установи: https://git-scm.com/download/win

## Шаг 3: Загрузи файлы

### Вариант А: Через bat файл (проще)

1. Открой `upload_to_github.bat`
2. Введи URL своего репозитория (например: `https://github.com/твой_ник/ssoly-ui.git`)
3. Дождись завершения

### Вариант Б: Вручную

```bash
cd e:\folders\codes\roblox\games\yba\ssoly
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/твой_ник/ssoly-ui.git
git branch -M main
git push -u origin main
```

## Шаг 4: Получи ссылку для загрузки

После загрузки твоя ссылка будет:
```
https://raw.githubusercontent.com/твой_ник/ssoly-ui/main/init.lua
```

## Шаг 5: Протестируй в Roblox

### Способ 1: Через loader.lua

1. Открой `loader.lua`
2. Замени `YOUR_USERNAME` на свой GitHub ник
3. Скопируй весь код
4. Вставь в executor (Solara, Synapse, и т.д.)
5. Execute!

### Способ 2: Напрямую

```lua
local Ssoly = loadstring(game:HttpGet("https://raw.githubusercontent.com/твой_ник/ssoly-ui/main/init.lua"))()

local Window = Ssoly:CreateWindow({
    Title = "Test",
    Size = UDim2.fromOffset(700, 500)
})

local Tab = Window:AddTab({Title = "Main", Icon = "⚡"})

Tab:AddToggle({
    Title = "Test Toggle",
    Callback = function(v)
        print("Toggle:", v)
    end
})

Window:Notify({
    Title = "Success!",
    Content = "UI loaded",
    Type = "Success"
})
```

## Шаг 6: Запусти полный тест

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/твой_ник/ssoly-ui/main/test.lua"))()
```

Это загрузит демо со ВСЕМИ элементами!

## 🐛 Если что-то не работает

### Ошибка: "Unable to cast value to Object"
- Проверь что все файлы загружены на GitHub
- Проверь что URL правильный
- Убедись что репозиторий Public

### Ошибка: "HTTP 404"
- Подожди 1-2 минуты после загрузки (GitHub кэширует)
- Проверь что ветка называется `main` (не `master`)

### Ошибка: "attempt to index nil"
- Проверь что `init.lua` загружен корректно
- Проверь что все папки (`core`, `elements`, `utils`) на месте

## 📝 Структура URL

```
https://raw.githubusercontent.com/ТВОй_НИК/ssoly-ui/main/
├── init.lua              ← Главный файл
├── test.lua              ← Демо скрипт
├── loader.lua            ← Быстрый загрузчик
├── core/
│   ├── Window.lua
│   └── Tab.lua
├── elements/
│   ├── Toggle.lua
│   ├── Slider.lua
│   ├── Dropdown.lua
│   ├── Button.lua
│   ├── Input.lua
│   ├── Colorpicker.lua
│   └── Keybind.lua
└── utils/
    └── Notification.lua
```

## ✅ Что тестировать

1. **Перетаскивание** - Тяни за title bar
2. **Ресайз** - Тяни за белую полоску в левом нижнем углу
3. **Минимизация** - Нажми синюю кнопку или RightControl
4. **Табы** - Переключайся между вкладками
5. **Toggle** - Включай/выключай
6. **Slider** - Двигай ползунок или вводи значение
7. **Dropdown** - Открывай меню, выбирай опции
8. **Button** - Нажимай, смотри ripple эффект
9. **Input** - Вводи текст
10. **Colorpicker** - Открывай палитру, выбирай цвет
11. **Keybind** - Нажми кнопку, нажми клавишу
12. **Notifications** - Нажми "Test Notifications"

## 🎯 Ожидаемый результат

- Окно открывается плавно
- Все анимации работают
- Нет лагов
- Все элементы кликабельны
- Уведомления появляются справа сверху
- Можно перетаскивать и ресайзить

## 📸 Скриншоты

После тестирования можешь сделать скриншоты и добавить в README!

---

**Готово!** Если всё работает - можем интегрировать в yba.lua 🚀
