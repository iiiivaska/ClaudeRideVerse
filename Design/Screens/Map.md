# Map

> Главный таб, полноэкранная карта с fog-of-war overlay и floating UI.

![[map-screen.png]]

## Элементы

### Карта (фон)
- Полноэкранная тёмная карта (Stadia Outdoors dark), фон `#0B1118`.
- Имитация рельефа: эллипсы `#101A12` (зелень), линии `#1E2530` (дороги), линия `#111A24` 10px (река).
- **Fog overlay**: `rgba(0,0,0,0.76)` поверх карты. Hex-ячейки "вырезаны" из тумана.
- **Hex grid**: pointy-top, размер hex r=9px, шаг по X ~22px, шаг по Y ~15.6px (hh * 0.78). Кластер explored hex по центру (~30 ячеек), 2 new hex по краю.
- **User location**: синяя точка (accent fill, white stroke 2.5px, r=8px) + пульс-кольцо (accent 15%, r=20px).
- Тонкая dot grid поверх: `rgba(255,255,255,0.012)`, шаг 8px.

### Floating UI (верхняя полоса)
- **City pill** (слева): glass pill (`GlassPill`), иконка-бургер (3 горизонтальные линии, stroke 1.6px) + текст "Berlin \u00b7 23%", DM Sans 12px 500, white.
- **Layers button** (справа): glass circle 36px, иконка layers (3 ромба), stroke `ts` 1.6px.
- Позиция: top 68px, left/right 16px.

### Crosshair (правый край)
- Glass circle 36px, иконка crosshair (circle r=8 + 4 линии), stroke `ts` 1.6px.
- Позиция: right 16px, top 44%.

### Stat strip (нижняя зона)
- Glass pill с `borderRadius: 12px`, padding `10px 16px`, `justify-content: space-around`.
- Содержимое (все IBM Plex Mono):
  - `1,284` -- mono 14px 600, accent + `hex` mono 10px `tt`
  - Разделитель `\u00b7` -- `sepS`, mono 13px
  - `18.3 km today` -- mono 11px `ts`
  - Разделитель `\u00b7`
  - `E` mono 10px `tt` + `42` mono 12px 500 `ts`

### Start Ride (кнопка)
- Полная ширина (left/right 16px), высота 56px, pill (radius 100px).
- Фон: accent. Текст: white, DM Sans 16px 600. Иконка play (белый треугольник 13x15px) слева от текста, gap 9px.
- **Glow**: `box-shadow: 0 4px 32px accent 55%, 0 2px 10px accent 33%`.
- Текст: "Start Ride".

### Tab bar
- Floating glass tab bar внизу (см. [[Дизайн-система]]).
- Активный таб: Map.

## Состояния

- **Обычное**: карта с fog overlay, explored hex-кластер, stat strip, Start Ride.
- **Empty state**: tooltip для новых пользователей (нет hex, "Start your first ride to explore the map").
- **При нажатии Start Ride**: переход к [[Recording]].

## Связи

- Пакеты: [[MapVerse]], [[HexKit]]
- Дизайн: [[Дизайн-система]]
