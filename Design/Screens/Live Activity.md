# Live Activity

> Системный компонент (не экран приложения). Lock Screen виджет + Dynamic Island в 3 состояниях.

## Lock Screen Widget

Glass-карточка поверх Lock Screen:

### Header
- **App icon** (слева): маленькая иконка FogRide.
- **Текст**: "Recording ride", DM Sans, white.
- **Время записи** (справа): таймер, IBM Plex Mono.

### Metric grid (2x2)
Тот же паттерн, что в HUD на [[Recording]], но компактнее:

| Метрика | Значение | Label |
|---------|----------|-------|
| Speed | текущая | KM/H |
| Hex | новые | HEX |
| Distance | пройдено | KM |
| Time | длительность | TIME |

- Значения: IBM Plex Mono, weight 600.
- Labels: IBM Plex Mono, uppercase, `tq`.

### Progress pulse
- Тонкая accent-полоска с пульсирующей анимацией -- индикатор активной записи.

### Controls
- **Pause**: glass pill с иконкой pause.
- **Stop**: красный круг с квадратом.

## Dynamic Island

### Compact (pill)
- Минимальное представление в Dynamic Island.
- Слева: красная точка с пульсом `rPulse` (индикатор записи).
- Центр: текущая скорость, IBM Plex Mono, white.
- Справа: hex count, IBM Plex Mono, accent.

### Expanded (развёрнутое)
- При long press на Dynamic Island.
- **Top row**: красный пульс + время записи + badge "+47" (новые hex за поездку).
- **Metric grid**: полный набор метрик (speed, hex, distance, time) -- как в HUD [[Recording]].
- **Mini controls**: compact Pause/Stop кнопки.

### Minimal (точка)
- При свёрнутом Dynamic Island с другим active приложением.
- Accent точка (синяя) + красный пульс-ореол.
- Минимальная индикация активной записи.

## Стилизация

- Glass-эффект для Lock Screen widget: `rgba(22,22,24,0.86)`, blur 24px, border `rgba(255,255,255,0.10)`.
- Все числовые значения -- IBM Plex Mono.
- Цветовая схема соответствует основному приложению ([[Дизайн-система]]).
- Красный пульс `rPulse` -- анимация box-shadow `rgba(255,69,58,0.6)`, 0-7px, цикл 1.5s.

## Связи

- Пакеты: [[LocationKit]], [[HexKit]]
- Дизайн: [[Дизайн-система]]
- Связанный экран: [[Recording]]
