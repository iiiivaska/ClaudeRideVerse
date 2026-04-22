# Onboarding

> Полноэкранный flow, знакомство с приложением и запрос системных разрешений.

![[onboarding-welcome.png]]

![[onboarding-permission.png]]

## Элементы

### Welcome-экран (страница 1)

- **Hex-иллюстрация**: анимированная гексагональная сетка (pointy-top) из 13 hex-ячеек в форме соты. Центральный кластер из 10 "discovered" hex (accent fill 30%, accent stroke), остальные -- fog (`bg2` 80%, серый stroke 50%). Анимация `hexGlow` с разными фазами для каждого hex. Обёрнута в `drop-shadow(0 0 30px rgba(10,132,255,0.25))`. Radial gradient подложка accent 22% -> 0%.
- **Page dots**: 4 точки, активная -- pill 18x6px accent, неактивные -- circle 6x6px `tq`. Gap 6px.
- **Заголовок**: "Discover where you've ridden", DM Sans 26px 700, white, center, `line-height: 1.18`, `white-space: pre-line`.
- **Подзаголовок**: "FogRide turns every ride into exploration. Cover the map, hex by hex.", DM Sans 14px, `ts`, center, `line-height: 1.6`, max-width 290px.
- **CTA-кнопка**: "Get started", полная ширина, 52px высота, pill (radius 100px), accent фон, white текст, DM Sans 15px 600. `box-shadow: 0 4px 28px accent 44%`.
- **Ссылка**: "I have an account", DM Sans 13px, `tt`, без фона/бордера, padding 8px.

### Permission-экраны (страницы 2-4)

Общая структура для всех трёх:

- **Иконка**: 88x88px, radius 24px. Фон и бордер зависят от типа. SVG-иконка 44x44px, stroke 1.8px.
- **Page dots**: та же система, текущая страница подсвечена.
- **Заголовок + подзаголовок**: тот же стиль, что у Welcome.
- **CTA-кнопка**: тот же стиль.
- **Ссылка**: "Not now" -- тот же стиль.

#### Location (страница 2)
- Иконка: map pin. Фон `accS`, бордер `accB`, stroke `acc`.
- Заголовок: "Show your rides on the map"
- Подзаголовок: "We need your location to record GPS tracks during rides. Your data stays on your device."
- CTA: "Allow location access"

#### Motion (страница 3)
- Иконка: фигура человека с линиями движения. Фон `accS`, бордер `accB`, stroke `acc`.
- Заголовок: "Auto-pause when you stop"
- Подзаголовок: "Detect when you stop or resume riding. Never miss a moment of your journey."
- CTA: "Allow motion access"

#### HealthKit (страница 4)
- Иконка: сердце. Фон `rgba(255,69,58,0.12)`, бордер `rgba(255,69,58,0.35)`, stroke `red`.
- Заголовок: "Sync with Apple Health"
- Подзаголовок: "Save your workouts automatically and monitor your heart rate during rides."
- CTA: "Allow Health access"

## Состояния

- **Начальное**: Welcome-экран (страница 0)
- **Навигация**: свайп/нажатие CTA переключает страницы последовательно
- **Завершение**: после последней страницы -- переход на главный экран (Map tab)
- **Прогресс**: сохраняется в localStorage (`fr_ob_page`)

## Связи

- Архитектура: [[Обзор]]
- Дизайн: [[Дизайн-система]]
