# Trip Detail

> Push-экран, детальная информация о поездке.

![[trip-detail.png]]

## Элементы

### Nav bar
- **Back button** (слева): круг 36px, фон `accS`, border `accB`. Шеврон влево (accent stroke 2.2px, round).
- **Заголовок** (центр): "Trip details", DM Sans 15px 500, white.
- **More button** (справа): glass circle 36px, три точки (ellipsis), `ts` fill.
- Padding top: 58px.

### Hero map
- Высота 200px, overflow hidden.
- Та же hex-карта с track polyline (accent, halo + основная линия).
- **Start marker**: зелёный круг (r=5, green fill, white stroke 1.5). Позиция: cx=62, cy=190.
- **Finish marker**: красный круг (r=5, red fill, white stroke 1.5). Позиция: cx=224, cy=118.
- Highlighted hex вдоль трека.

### Meta block
- **Название**: "Morning ride", DM Sans 22px 700, white.
- **Время**: "Today \u00b7 06:42 -- 08:05", IBM Plex Mono 12px, `tt`.
- Separator: 1px `sep`, margin `0 20px`.

### Stat grid (2x2)
- Тот же паттерн, что в [[Trip Summary]]: grid `1fr 1fr`, gap 1px, radius 14px, border `sep`.

| Label | Значение (MonoVal 22px) | Цвет | Подпись |
|----|----|----|----|
| `DISTANCE` | `18.3` | `tp` | `km` |
| `HEX` | `+47` | `acc` | `total 1,284` |
| `MOVING` | `1:23` | `tp` | `total 1:28` |
| `ELEV` | `342` | `green` | `\u2191m` |

### Speed chart
- Секция `SPEED` (SectionLabel -- mono 9px caps).
- Контейнер: `bg1`, border `sep`, radius 12px, высота 100px, padding 14px.
- **Area chart**: SVG viewBox `0 0 320 72`.
  - Gradient fill: accent 30% сверху -> 0% снизу.
  - Линия: accent stroke 1.8px, round caps.
  - Кривые Безье, волнистый профиль скорости.

### Elevation chart
- Секция `ELEVATION` (SectionLabel).
- Тот же контейнер, что Speed chart.
- **Area chart**: SVG viewBox `0 0 320 72`.
  - Gradient fill: green 30% сверху -> 0% снизу.
  - Линия: green stroke 1.8px, round caps.
  - Кривые Безье, профиль высоты (подъём-спуск).

### Splits table
- Секция `SPLITS` (SectionLabel).
- Контейнер: `bg1`, border `sep`, radius 12px, overflow hidden.
- **Header row**: фон `bg2`, padding `8px 14px`. Колонки: `KM`, `TIME`, `SPEED`, `\u2191M` (все MonoLabel).
- **Data rows**: grid `1fr 1fr 1fr 1fr`, padding `10px 14px`, border-top `sep`.

| KM | TIME | SPEED | \u2191M | Highlight |
|----|------|-------|---------|-----------|
| 1 | 2:34 | 23.4 | +12 | -- |
| 2 | 2:14 | 26.8 | -4 | **Best split**: фон `accS`, текст accent 600 |
| 3 | 2:42 | 22.2 | +38 | -- |
| 4 | 2:51 | 21.0 | +28 | -- |

- Все значения: IBM Plex Mono 11px, обычные -- weight 400 `tp`, best -- weight 600 `acc`.

## Состояния

- **Появление**: анимация `slideUp` 0.3s ease-out.
- **Основное**: все данные заполнены.
- **Back**: возврат к предыдущему экрану (Rides или Trip Summary).

## Связи

- Пакеты: [[MapVerse]], [[LocationKit]]
- Дизайн: [[Дизайн-система]]
