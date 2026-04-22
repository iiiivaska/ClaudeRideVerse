# Profile

> Таб-экран, профиль пользователя и настройки приложения.

![[profile-screen.png]]

## Элементы

### Header
- **Заголовок**: "Profile", DM Sans 28px 700, white. Padding top: 62px.

### Profile card
- Контейнер: `bg1`, border `sep`, radius 16px, padding `14px 16px`. Display flex, gap 12px.
- **Аватар**: 48x48px, круг. Фон `accS`, border `accB`. Emoji велосипедиста по центру (20px).
- **Имя**: "Anna Schmidt", DM Sans 16px 600, white.
- **Подпись**: "Member since Apr 2026", IBM Plex Mono 11px, `tt`.

### Premium upsell card
- Фон: `linear-gradient(135deg, accS, rgba(48,209,88,0.06))`, border `accB`, radius 14px, padding `14px 16px`.
- **Заголовок**: diamond emoji + "Free tier \u00b7 Berlin region only", DM Sans 13px 600, white.
- **Описание**: "Unlock global fog, offline maps, advanced stats and more.", DM Sans 11px, `ts`, `line-height: 1.5`.
- **Кнопка**: "Upgrade to Premium \u203a", accent фон, white текст, DM Sans 12px 600, radius 8px, padding `8px 14px`. Переход к [[Paywall]].

### Recording (секция настроек)
- Section label: `RECORDING`.
- Контейнер: `bg1`, border `sep`, radius 14px, overflow hidden.
- Строки с toggle (Switch 51x31px):

| Настройка | Состояние по умолчанию |
|-----------|----------------------|
| Auto-pause | ON |
| Haptic on hex unlock | ON |
| Sound on hex unlock | OFF |
| Show direction to fog | ON |

- Label: DM Sans 14px, white, flex: 1.
- Toggle: шар 27px белый, фон ON -- accent, OFF -- `bg3`. Анимация перемещения 0.2s.

### Display (секция)
- Section label: `DISPLAY`.
- Контейнер: `bg1`, border `sep`, radius 14px.
- Строки с disclosure (шеврон `tq`, stroke 1.8px):

| Настройка | Значение |
|-----------|----------|
| Units | Metric |
| Map style | Outdoors |

- Label: DM Sans 14px, white.
- Value: DM Sans 13px, `tt`, marginRight 6px.

### Privacy (секция)
- Section label: `PRIVACY`.
- Контейнер: `bg1`, border `sep`, radius 14px.

| Настройка | Значение | Цвет |
|-----------|----------|------|
| Privacy zones | 2 zones | default |
| Free tier region | Berlin | default |
| Export all my data | -- | default |
| Delete my data | -- | **red** (текст и шеврон) |

### Integrations (секция)
- Section label: `INTEGRATIONS`.
- Контейнер: `bg1`, border `sep`, radius 14px.

| Интеграция | Статус |
|------------|--------|
| Apple Health | "Connected \u2713" -- DM Sans 13px, green |
| Bluetooth sensors | "HR strap" -- disclosure row |

### Tab bar
- Floating glass tab bar, активный таб: Profile.

## Состояния

- **Обычное**: все настройки отображены с текущими значениями.
- **Toggle**: мгновенное переключение ON/OFF с анимацией.
- **Disclosure**: нажатие на строку с шевроном -- push-переход к детальному экрану.
- **Delete my data**: красный текст, нажатие -- confirmation alert.
- **Scroll**: header фиксирован, контент скроллится. Padding bottom 90px.

## Связи

- Пакеты: [[Domain]]
- Дизайн: [[Дизайн-система]]
