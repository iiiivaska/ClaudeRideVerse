# Rides

> Таб-экран, список поездок с группировкой по дням.

![[rides-screen.png]]

## Элементы

### Header
- **Заголовок**: "Rides", DM Sans 28px 700, white. Padding top: 62px.
- **Иконки** (справа, gap 8px):
  - Search: кнопка 34x34px, radius 8px, фон `bg2`, border `sep`. SVG лупа, stroke `ts` 1.8px.
  - Filter: кнопка 34x34px, тот же стиль. SVG три горизонтальные линии убывающей длины.

### Summary card (неделя)
- Фон: `linear-gradient(135deg, accS, rgba(48,209,88,0.07))`, border `accB`, radius 12px, padding `11px 16px`.
- **Label**: "THIS WEEK" -- MonoLabel (mono 9px caps `tq`).
- **Содержимое**: "3 rides \u00b7 47.8 km \u00b7 +103 hex", IBM Plex Mono 13px 500, `ts`. Hex count выделен accent 600.

### Секции дней
- Section labels: "TODAY", "YESTERDAY", "LAST WEEK" -- SectionLabel (mono 9px caps `tq`, padding `16px 20px 6px`).

### Ride items
Каждая поездка -- горизонтальная строка, padding `10px 0`, border-bottom `sep` (кроме последней в группе).

- **Thumbnail** (слева): 56x42px, фон `bg2`, border `sep`, radius 8px. Внутри -- Sparkline SVG (accent polyline 1.5px, round caps).
- **Текст** (центр, flex: 1):
  - Название: DM Sans 14px 500, white. Примеры: "Morning ride", "Evening loop", "Weekend explore", "Commute home".
  - Мета: IBM Plex Mono 10px, `tt`. Формат: "06:42 \u00b7 +47 hex" (hex count accent).
- **Числа** (справа, text-align right):
  - Расстояние: IBM Plex Mono 13px 500, white. Формат: "18.3 km".
  - Длительность: IBM Plex Mono 10px, `tt`. Формат: "1h 23m".

### Примеры поездок

| Группа | Название | Время | Hex | Расстояние | Длительность |
|--------|----------|-------|-----|-----------|--------------|
| TODAY | Morning ride | 06:42 | +47 | 18.3 km | 1h 23m |
| YESTERDAY | Evening loop | 18:10 | +12 | 24.1 km | 1h 02m |
| LAST WEEK | Weekend explore | 09:15 | +103 | 47.8 km | 2h 41m |
| LAST WEEK | Commute home | 17:42 | +8 | 11.2 km | 28m |

### Tab bar
- Floating glass tab bar, активный таб: Rides.

## Состояния

- **Обычное**: список поездок, сгруппированных по дням.
- **Empty state**: иллюстрация + текст "No rides yet. Start your first ride from the Map tab." со ссылкой на [[Map]].
- **Tap на поездку**: переход к [[Trip Detail]].
- **Scroll**: верхний header фиксирован, список скроллится под ним. Padding bottom 90px (под tab bar).

## Связи

- Пакеты: [[Domain]]
- Дизайн: [[Дизайн-система]]
