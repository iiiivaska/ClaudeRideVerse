# Recording

> Fullscreen overlay, экран активной записи поездки.

## Элементы

### Карта (фон)
- Та же тёмная карта, что и [[Map]], с fog overlay и hex grid.
- **Track polyline**: accent цвет, двойная линия -- halo `accent 44%` 7px + основная `accent` 2.5px, `stroke-linecap: round`, `stroke-linejoin: round`.
- **Start marker**: зелёный круг (green fill, white stroke 1.5px, r=5px) в начале трека.
- **User location**: accent точка (r=8, white stroke 2.5) + пульс (accent 15%, r=20) в конце трека.
- **Hex unlock pulse**: анимация при открытии нового hex -- `hexGlow` + glow stroke 6px.

### Top bar
- **Chevron-down** (слева): glass circle 36px, стрелка влево (stroke 2px, white). Сворачивает overlay.
- **REC status** (справа): glass pill -- красная точка 7px с анимацией `rPulse` (box-shadow пульс красный) + текст "REC \u00b7 00:04:23", IBM Plex Mono 11px 500, white.
- Позиция: top 68px, left/right 16px.

### Mini-compass (правый край)
- Glass-карточка: `T.glass`, blur 20px, border `T.glassB`, radius 12px, padding 10px.
- **Стрелка**: SVG-стрелка направления к ближайшему fog, повёрнута на 35deg, accent fill.
- **Расстояние**: "240m", IBM Plex Mono 10px, `tt`.
- Позиция: right 16px, top 36%.

### HUD bar (нижняя зона)
- Glass-карточка: `T.glass`, blur 28px, border `T.glassB`, radius 20px, padding `14px 6px`.
- **4-колоночная сетка** (`grid-template-columns: 1fr 1fr 1fr 1fr`), разделители `sep` 1px между колонками:

| Метрика | Значение | Цвет | Label |
|---------|----------|------|-------|
| Speed | `24.7` | `tp` (white) | `KM/H` |
| Hex | `47` | `acc` (accent) | `HEX` |
| Distance | `18.3` | `tp` | `KM` |
| Time | `1:23` | `tp` | `TIME` |

- Значения: IBM Plex Mono 20px 600, `line-height: 1`.
- Labels: IBM Plex Mono 8px, `letter-spacing: 0.12em`, uppercase, `tq`.

### Page dots
- 4 точки под HUD: первая accent, остальные `tq`. Размер 5px, gap 5px. Указывают на переключаемые страницы HUD.

### Control bar
- **Pause**: glass pill (flex: 1, radius 100px, padding `14px 20px`). Иконка pause (2 прямоугольника 4.5x16, gap, white fill) + текст "Pause", DM Sans 14px 500, white.
- **Stop**: красный круг 60px, `T.red` фон. Белый квадрат 20x20px (radius 4px) по центру. `box-shadow: 0 4px 28px red 55%`. Не растягивается (`flex-shrink: 0`).
- Gap между Pause и Stop: 12px.
- Отступ снизу: 92px (под tab bar).

### Dynamic Island (expanded)
- Красный пульс + время записи + badge "+47" (новые hex).
- Подробнее в [[Live Activity]].

## Состояния

- **Запись**: все метрики обновляются каждую секунду (speed +/- случайное, km += 0.004, hex += 1 с вероятностью 2.5%).
- **Пауза**: при нажатии Pause -- метрики замораживаются, кнопка меняется на Resume.
- **Остановка**: при нажатии Stop -- переход к [[Trip Summary]].

## Связи

- Пакеты: [[LocationKit]], [[MapVerse]], [[HexKit]]
- Дизайн: [[Дизайн-система]]
