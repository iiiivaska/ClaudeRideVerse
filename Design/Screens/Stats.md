# Stats

> Таб-экран, статистика исследования и достижения.

![[stats-screen.png]]

## Элементы

### Header
- **Заголовок**: "Stats", DM Sans 28px 700, white. Padding top: 62px.
- **Time segmented control** (справа): фон `bg2`, radius 8px, padding 3px. 4 сегмента: `All`, `Y`, `M`, `W`. Активный -- accent фон, radius 6px, white текст. Неактивный -- transparent, `ts`. IBM Plex Mono 11px.

### Personal heatmap (hero card)
- Контейнер: `bg1`, border `sep`, radius 12px, высота 156px, overflow hidden.
- **Фон**: `#0B1118` (тёмная карта).
- **Heat spots**: 5 размытых кругов accent цвета с разной opacity (0.18-0.46) и blur (18-34px). Имитация тепловой карты исследованных зон.
- **Линии карты**: тонкие белые линии (opacity 0.1) -- имитация дорог/рек.
- **Ссылка** под картой: "Open in Map \u2192", DM Sans 12px, accent, text-align right.

### Hex metrics list
- Секция `HEX METRICS` (SectionLabel).
- Контейнер: `bg1`, border `sep`, radius 12px, overflow hidden.
- Строки: display flex, padding `12px 16px`, border-bottom `sep` (кроме последней).

| Метрика | Значение | Цвет |
|---------|----------|------|
| Total hex | `1,284` | `tp` |
| Coverage | `134.8 km\u00b2` | `tp` |
| Eddington (E) | `42` | `acc` |
| Hex/day E | `8` | `acc` |
| Max Square | `7\u00d77` | `tp` |
| Max Cluster | `412 hex` | `tp` |

- Label: DM Sans 13px, `ts`, flex: 1.
- Значение: IBM Plex Mono 14px 600.

### 30-day bar chart
- Секция `LAST 30 DAYS` (SectionLabel).
- Контейнер: `bg1`, border `sep`, radius 12px, padding 14px.
- **Bars**: 30 вертикальных столбцов, flex: 1, gap 3px, высота пропорциональна значению (макс 60px).
  - Обычные дни: `accS` (accent 15%).
  - Воскресенья (каждый 7-й): `green`.
  - Последний день: `acc` (accent 100%).
  - Скругление верха: `2px 2px 0 0`.
- **Подписи**: "Apr 1" слева, "Apr 30" справа -- MonoLabel.

### Achievements grid
- Секция `ACHIEVEMENTS \u00b7 23/40` (SectionLabel).
- Grid: `repeat(4, 1fr)`, gap 6px.
- **Unlocked**: фон `accS`, border `accB`, radius 10px, aspect-ratio 1. Внутри -- сетка 3x3 мини-hex (8x8px, clip-path polygon). Чередование accent и `accS`.
- **Locked**: фон `bg2`, border `sep`, radius 10px. Иконка замка (emoji, opacity 0.35).
- В прототипе: 5 unlocked, 3 locked (8 видимых из 40).

### Tab bar
- Floating glass tab bar, активный таб: Stats.

## Состояния

- **Обычное**: все данные заполнены.
- **Переключение периода**: All/Y/M/W меняет данные в heatmap и bar chart.
- **Scroll**: header фиксирован, контент скроллится. Padding bottom 90px.

## Связи

- Пакеты: [[HexKit]], [[Domain]]
- Дизайн: [[Дизайн-система]]
