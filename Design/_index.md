# Дизайн FogRide

Визуальная система приложения FogRide -- велосипедный трекер с механикой fog-of-war на гексагональной сетке. Dark-first, Liquid Glass, iOS 26+.

## Дизайн-система

[[Дизайн-система]] -- цвета, шрифты, glass-эффекты, скругления, hex-стили, общие правила.

## Экраны

| Экран | Описание |
|-------|----------|
| [[Onboarding]] | Welcome-экран с hex-анимацией + 3 экрана запроса разрешений (Location, Motion, HealthKit) |
| [[Map]] | Главный таб -- полноэкранная карта с fog overlay, hex-дырами, floating glass UI и кнопкой Start Ride |
| [[Recording]] | Fullscreen overlay записи поездки -- Dynamic Island, HUD-метрики, track polyline, управление |
| [[Trip Summary]] | Post-ride sheet -- результаты поездки, мини-карта, highlight, действия |
| [[Trip Detail]] | Push-экран деталей поездки -- hero-карта, графики скорости/высоты, таблица сплитов |
| [[Rides]] | Таб списка поездок -- группировка по дням, summary-карточка недели, thumbnail polyline |
| [[Stats]] | Таб статистики -- heatmap, hex-метрики, 30-дневный bar chart, achievements |
| [[Profile]] | Таб профиля -- настройки записи, дисплея, приватности, интеграции |
| [[Paywall]] | Модальный sheet -- Premium-подписка, 3 ценовых плана, hero-анимация |
| [[Live Activity]] | Lock Screen виджет + Dynamic Island (3 состояния) -- не экран приложения |

## Ресурсы

- Прототип: `Design/Prototype/FogRide Prototype.html` (интерактивный React-прототип)
- Скриншоты: `Design/Assets/` (PNG-файлы экранов)
- Шрифты: [DM Sans](https://fonts.google.com/specimen/DM+Sans), [IBM Plex Mono](https://fonts.google.com/specimen/IBM+Plex+Mono)
