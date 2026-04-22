# Trip Summary

> Post-ride sheet, итоги завершённой поездки.

![[trip-summary.png]]

## Элементы

### Header
- **Checkmark**: зелёный круг 64px, green фон, `box-shadow: 0 0 40px green 44%`. Внутри -- белая галочка SVG (stroke 3px, round).
- **Заголовок**: "Ride complete", DM Sans 26px 700, white. Отступ снизу 5px.
- **Название поездки**: "Morning ride" + иконка-карандаш (accent, cursor pointer), DM Sans 14px, `ts`. Редактируемое поле.

### Stat grid (2x2)
- Grid `1fr 1fr`, gap 1px, фон `sep` (видна сетка-разделитель), radius 16px, overflow hidden, border `sep`.
- Каждая ячейка: фон `bg1`, padding `13px 15px`.

| Label (MonoLabel) | Значение (MonoVal 24px) | Цвет | Подпись (mono 10px `tt`) |
|----|----|----|-----|
| `DISTANCE` | `18.3` | `tp` | `km` |
| `NEW HEX` | `+47` | `acc` | `total: 1,284` |
| `MOVING` | `1:23` | `tp` | `avg 13.2 km/h` |
| `ELEV` | `342` | `green` | `\u2191m \u00b7 \u2193318m` |

### Mini-map
- Контейнер: ширина 100%, высота 110px, фон `#0B1118`, radius 12px, border `sep`, overflow hidden.
- **Track polyline**: accent, stroke 2.2px, round caps/joins. Точки от left-bottom к right-top.
- **Start marker**: зелёный круг (r=5, green fill, white stroke 1.5).
- **Finish marker**: красный круг (r=5, red fill, white stroke 1.5).

### Highlight card
- Gradient фон: `linear-gradient(135deg, rgba(255,214,10,0.08), rgba(255,159,10,0.05))`.
- Border: `rgba(255,214,10,0.22)`, radius 12px, padding `12px 14px`.
- Иконка trophy (emoji), gap 10px.
- **Заголовок**: "Best 1km: 2:14 (26.8 km/h)", DM Sans 13px 600, white.
- **Подпись**: "Personal best for this distance", DM Sans 11px, `tt`.

### Действия
- **View ride details**: accent кнопка (Btn), полная ширина, 52px, pill. Переход к [[Trip Detail]].
- **Share**: outline кнопка -- transparent фон, border `sep`, white текст.
- **Discard**: текстовая кнопка, DM Sans 13px, `red`, без фона/бордера, padding 8px.

## Состояния

- **Появление**: анимация `slideUp` 0.35s ease-out.
- **Основное**: все данные заполнены из завершённой поездки.
- **Редактирование имени**: при нажатии на карандаш -- inline editing названия.

## Связи

- Пакеты: [[Domain]]
- Дизайн: [[Дизайн-система]]
