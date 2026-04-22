# Phase 1 — MVP
> ~3 недели full-time solo (150-160ч). App Store-ready MVP: офлайн-трекер с fog of war + StoreKit 2 paywall.

## Цель

Полноценный релиз в App Store. Офлайн-трекер велопоездок с fog of war, подробной статистикой, экспортом треков, Live Activity, виджетами, и freemium-моделью через StoreKit 2. Liquid Glass UI на iOS 26.

Критический путь: F.1 → F.3 → 1.17 AppShell → 1.7 Map → 1.5 Recording → 1.18 Summary → 1.6 Detail

## Go/No-Go критерии

- Положительное Go-решение по результатам [[Phase 0 — Prototype]]
- Все 19 задач выполнены, приложение прошло App Review

## Задачи (Jira)

### Пакеты и сервисы
- **SCRUM-31** [1.1] LocationKit full — фильтрация, анализ, motion, фоновая запись (12-16ч)
- **SCRUM-32** [1.2] [[MapOverlays]] + [[MapOfflineRegions]] (6ч)
- **SCRUM-33** [1.3] Domain: [[FogRideModels]] + [[FogRidePersistence]] (6ч)
- **SCRUM-34** [1.4] [[FogRideServices]] — TripRecorder + FogCalculator (8ч)

### Feature-модули
- **SCRUM-47** [1.17] AppShell + FloatingGlassTabBar iOS 26 (7-8ч)
- **SCRUM-35** [1.5] [[RecordingFeature]] — HUD + compass + controls (12-14ч)
- **SCRUM-48** [1.18] [[TripSummaryFeature]] — post-ride screen (10-11ч)
- **SCRUM-36** [1.6] [[RidesFeature]] + [[TripDetailFeature]] (14-16ч)
- **SCRUM-37** [1.7] [[FogMapFeature]] — Map tab floating glass UI (10-11ч)
- **SCRUM-38** [1.8] [[StatsFeature]] — heatmap + metrics + charts + achievements (14-16ч)
- **SCRUM-39** [1.9] [[ProfileFeature]] + [[OnboardingFeature]] (14-16ч)

### Интеграции
- **SCRUM-40** [1.10] [[WorkoutKit]] — HKWorkoutSession on iPhone iOS 26 (6ч)
- **SCRUM-41** [1.11] [[TrackExport]] — GPX writer/reader (4ч)
- **SCRUM-42** [1.12] Live Activity + Dynamic Island + Lock Screen widget (11-12ч)
- **SCRUM-43** [1.13] WidgetKit — Home/Lock + Control Center "Start Ride" (8ч)

### Монетизация и релиз
- **SCRUM-44** [1.14] StoreKit 2 + Paywall freemium (8ч)
- **SCRUM-49** [1.19] Paywall screen — hex-unlocking hero + 3 tiers (10-12ч)
- **SCRUM-45** [1.15] Analytics (TelemetryDeck) + MetricKit + Sentry (6ч)
- **SCRUM-46** [1.16] App Store submission (8ч)
- **SCRUM-30** [1.16] TestFlight релиз MVP + публикация + сбор фидбэка + go/no-go (перенесён из Phase 0, prep done)
- **SCRUM-73** Перенести API-ключи в CloudKit Remote Config

### DevTools (EPIC-DT: SCRUM-74)
- **SCRUM-75** Beta build config + DEBUG_PANEL active compilation condition
- **SCRUM-76** DebugPanelView scaffold + gear button entry point
- **SCRUM-77** Resets section: онбординг, hex cache, БД, Reset All
- **SCRUM-78** GPS Diagnostics section: live location dashboard
- **SCRUM-79** Build Info section + Copy All для баг-репортов
- **SCRUM-80** FeatureFlagManager + Feature Flags section
- **SCRUM-81** os.Logger infrastructure + Log Viewer section

## Ключевые решения

- Freemium-модель: бесплатный трекер + платный fog of war и расширенная статистика
- FloatingGlassTabBar — кастомный tab bar с Liquid Glass эффектом для iOS 26
- HKWorkoutSession запускается прямо на iPhone (iOS 26 feature), Watch-приложение будет в Phase 5
- TelemetryDeck для аналитики (privacy-first), Sentry для crash reporting
- GPX-only экспорт в MVP, FIT-формат добавится в Phase 5 вместе с BLE-сенсорами
- Критический путь определяет порядок разработки: сначала shell и карта, потом запись и детали

## Зависимости

- Требует: [[Phase F — Foundation]], Go-решение [[Phase 0 — Prototype]]
- Блокирует: [[Phase 2 — Social]]
