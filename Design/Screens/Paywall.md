# Paywall

> Модальный sheet, Premium-подписка.

## Элементы

### Hero (верхние 40%)
- Фон: градиент `linear-gradient(180deg, #080F1C 0%, #05090F 100%)`.
- **Hex grid**: SVG, 60 hex-ячеек (6 рядов по 10), pointy-top, r=17px. Каждая ячейка -- accent fill, opacity зависит от расстояния до центра (от 55% в центре до 4% по краям). Stroke: `accent 22%`, 0.5px. Имитация "растворяющегося тумана" -- чем ближе к центру, тем ярче.
- **Gradient fade**: снизу hero -- `linear-gradient(to bottom, transparent, bg)`, 65% высоты.
- **Close button**: правый верхний угол (top 58px, right 16px). Круг 30px, `rgba(255,255,255,0.1)`, символ "\u2715", `ts`, 16px.

### Content

- **Заголовок**: "Explore without limits", DM Sans 26px 700, white, text-align center.

### Feature list
- 5 bullet points, gap 9px:

| Иконка | Текст |
|--------|-------|
| `\u2713` (mono 13px 600, accent) | Global fog -- no region limits |
| `\u2713` | Offline maps for any area |
| `\u2713` | Advanced stats: Eddington, Max Square, heatmap |
| `\u2713` | Fading fog mode |
| `\u2713` | Live Activity with full metrics |

- Текст: DM Sans 14px, `ts`. Gap между иконкой и текстом: 10px.

### Pricing tiers
- 3 кнопки, gap 8px, полная ширина:

| Plan ID | Текст | Badge | Стиль (selected) |
|---------|-------|-------|-------------------|
| `monthly` | $4.99/month | -- | |
| `yearly` | $39.99/year | "Save 33%" (pill: mono 10px 600, accent bg, white) | **Default selected** |
| `lifetime` | $89 one-time | -- | |

- **Selected**: фон `accS`, border 2px accent. Текст: DM Sans 15px 600, accent.
- **Unselected**: фон `bg2`, border 1px `sep`. Текст: DM Sans 14px 400, white.
- Высота: 52px, pill (radius 100px).

### CTA
- **Get Premium**: полная ширина, 52px, pill, accent фон, white текст, DM Sans 16px 600. `box-shadow: 0 4px 28px accent 44%`.

### Footer
- "Restore purchase \u00b7 Terms \u00b7 Privacy", DM Sans 11px, `tt`, text-align center.

## Состояния

- **Появление**: анимация `slideUp` 0.35s ease-out.
- **Default**: yearly plan выбран.
- **Переключение плана**: нажатие на tier меняет selection (accent border + фон).
- **Close**: нажатие на "\u2715" -- dismiss modal.

## Связи

- Дизайн: [[Дизайн-система]]
