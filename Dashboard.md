# RideVerse — Dashboard

> Велотрекер с fog of war для iOS 26. Соло-разработка, 18-месячный роадмап.

## Статус проекта

| Что | Статус |
|-----|--------|
| Фаза | [[Roadmap/Phase 0 — Prototype\|Phase 0 — Prototype]] (6 из 7 задач закрыто) |
| Завершено | **SCRUM-29** (PrototypeApp — map + hex fog-of-war + Start/Stop, gridDisk viewport, throttled live updates, thread-safe boundary cache) |
| Следующий шаг | SCRUM-30 TestFlight + публикация + feedback + go/no-go решение |
| Phase F | ✅ Полностью завершена: SCRUM-12, 17, 18, 19, 20 |
| Jira | [SCRUM Board](https://rideverse.atlassian.net/jira/software/projects/SCRUM/boards/1) |

## Навигация

### Архитектура
- [[Architecture/_index\|Архитектура]] — 18 SPM пакетов, 3 слоя, правила
  - [[Architecture/Обзор\|Обзор]] — философия, структура, стратегии
  - [[Architecture/MapVerse\|MapVerse]] — карта, оверлеи, fog, оффлайн
  - [[Architecture/LocationKit\|LocationKit]] — GPS, фильтрация, метрики, motion
  - [[Architecture/HexKit\|HexKit]] — H3 обёртка, геометрия, компакция
  - [[Architecture/SensorKit\|SensorKit]] — BLE, датчики
  - [[Architecture/Domain\|Domain]] — модели, персистенция, сервисы
  - [[Architecture/Прочие пакеты\|Прочие пакеты]] — WorkoutKit, TrackExport, PersistenceCore, DesignSystem
  - [[Architecture/Антипаттерны\|Антипаттерны]] — что НЕ делать

### Дизайн
- [[Design/_index\|Дизайн]] — дизайн-система и экраны
  - [[Design/Дизайн-система\|Дизайн-система]] — токены, шрифты, glass, hex
  - Экраны: [[Design/Screens/Onboarding\|Onboarding]], [[Design/Screens/Map\|Map]], [[Design/Screens/Recording\|Recording]], [[Design/Screens/Trip Summary\|Trip Summary]], [[Design/Screens/Trip Detail\|Trip Detail]], [[Design/Screens/Rides\|Rides]], [[Design/Screens/Stats\|Stats]], [[Design/Screens/Profile\|Profile]], [[Design/Screens/Paywall\|Paywall]], [[Design/Screens/Live Activity\|Live Activity]]

### Роадмап
- [[Roadmap/_index\|Роадмап]] — все фазы и прогресс
  - [[Roadmap/Phase F — Foundation\|F: Foundation]] (1-2 нед) → [[Roadmap/Phase 0 — Prototype\|0: Prototype]] (3-4 нед) → [[Roadmap/Phase 1 — MVP\|1: MVP]] (3 нед)
  - [[Roadmap/Phase 2 — Social\|2: Social]] (8-10 нед) → [[Roadmap/Phase 3 — Backend\|3: Backend]] (12-14 нед)
  - [[Roadmap/Phase 4 — POI & AI\|4: POI & AI]] (8-10 нед) → [[Roadmap/Phase 5 — Watch & BLE\|5: Watch & BLE]] (8-10 нед)

### Журнал
- `Journal/` — daily notes (пока пусто)

## Ссылки

- [Jira Board](https://rideverse.atlassian.net/jira/software/projects/SCRUM/boards/1)
- [[Design/Prototype/FogRide Prototype\|HTML Прототип]] (открыть в браузере)
- `CLAUDE.md` — инструкции для AI-агентов
- `AGENTS.md` — Swift/SwiftUI конвенции
