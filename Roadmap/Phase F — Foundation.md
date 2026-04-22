# Phase F — Foundation
> 1-2 недели (до Phase 0). Заложить фундамент проекта: workspace, пакеты, CI, дизайн-система, persistence.

## Цель

Создать скелет Xcode workspace со всеми SPM-пакетами Phase 0, настроить CI через [[CI|GitHub Actions]] (build + test), реализовать [[DesignSystem]] с Liquid Glass токенами и компонентами, подготовить [[PersistenceCore]] на GRDB 7 с WAL и миграциями, сконфигурировать privacy-манифесты.

Это стартовая точка всего проекта — ни одна другая фаза не может начаться без завершения Foundation.

## Go/No-Go критерии

- SPM skeleton собирается без ошибок
- CI pipeline ([[CI|GitHub Actions]]) зелёный на `main` и на каждом PR
- DesignSystem содержит все Liquid Glass токены и базовые компоненты
- PersistenceCore проходит unit-тесты (GRDB 7 + WAL + миграции)
- Info.plist, PrivacyInfo.xcprivacy и Capabilities настроены

## Задачи (Jira)

- **SCRUM-12** [F.1] Xcode workspace + SPM skeleton — **DONE** (коммит `8a7aa36`)
  - SCRUM-13 Create workspace + app target — **DONE**
  - SCRUM-14 Create SPM packages Phase 0 — **DONE**
  - SCRUM-15 Enable Swift 6 Approachable Concurrency — **DONE**
  - SCRUM-16 Git + .gitignore + README — **DONE**
- **SCRUM-17** [F.2] CI — build + test (GitHub Actions, 2-3ч) — **DONE** (PR #1, коммит `4a07ee8`)
  - _Scope-change:_ Xcode Cloud недоступен для текущего Apple Developer аккаунта, переключено на GitHub Actions hosted macOS runner. TestFlight-деплой вынесен в отдельный follow-up тикет ([[#Follow-up|см. ниже]]).
  - Детали: [[CI]]
- **SCRUM-18** [F.3] DesignSystem — Liquid Glass tokens + components (18-20ч) — **DONE** (PR #2, merge commit `9e3b480`)
  - 6 подфаз за одну сессию: F.3.1 tokens → F.3.2 primitives + hex geometry + pulse → F.3.3 buttons → F.3.4 hex cells + cards → F.3.5 navigation + indicators + onboarding → F.3.6 gallery view + README
  - 20+ публичных компонентов, 49 Swift Testing assertions в 13 suites (`swift test` green)
  - Дополнительно: DesignSystemGallery app target в Xcode для Simulator-валидации
  - _Отклонения:_ платформа `.macOS(.v26)` добавлена для `swift build` на CLI; SF Pro/SF Mono вместо DM Sans/IBM Plex Mono (убран custom-font registrar); snapshot-тесты заменены на `ImageRenderer` smoke checks — реальные screenshots отложены до SCRUM-72
  - Детали: [[../Architecture/Прочие пакеты#DesignSystem|Architecture/Прочие пакеты → DesignSystem]], `Packages/DesignSystem/README.md`
- **SCRUM-19** [F.4] Info.plist + PrivacyInfo + Capabilities — **DONE** (коммит `19ba2d2`)
  - 6 usage descriptions (Location WhenInUse + Always, Motion, Health Share/Update, Bluetooth)
  - UIBackgroundModes: location, bluetooth-central
  - BGTaskSchedulerPermittedIdentifiers для GPX/FIT export
  - NSSupportsLiveActivitiesFrequentUpdates = YES
  - PrivacyInfo.xcprivacy: tracking=NO, Location+Health data, FileTimestamp/UserDefaults/SystemBootTime API
  - HealthKit entitlement
- **SCRUM-20** [F.5] PersistenceCore — GRDB 7 + WAL + migrations — **DONE** (коммит `84f24fb`)
  - GRDB 7.10.0 SPM, `DatabaseProvider` (file-based + in-memory), `Migration` protocol
  - WAL + synchronous NORMAL + journal_size_limit 4 MB
  - Async observation (`observe`), batch writes (`writeInTransaction`), `vacuum()`
  - `@_exported import GRDB` — downstream получает GRDB-типы автоматически
  - 13 тестов Swift Testing: WAL, sync, migrations, idempotency, vacuum, batch 1000 rows, concurrent reads, observation
  - Детали: [[../Architecture/Прочие пакеты#PersistenceCore|Architecture/Прочие пакеты → PersistenceCore]], `Packages/PersistenceCore/README.md`

### Follow-up

- **SCRUM-70** [F.2+] SwiftLint config + zero warnings baseline (2-3ч) — добавить `.swiftlint.yml` и шаг линтинга в CI
- **SCRUM-71** [F.2+] TestFlight auto-deploy on tag v\* (3-4ч) — `xcrun altool --upload-app`, секреты ASC API key в GitHub Actions
- **SCRUM-72** [F.6] Snapshot-тесты DesignSystem — screenshot baselines на iOS 26 Simulator (6-8ч) — swift-snapshot-testing + CI job с `xcodebuild test` на macOS-latest runner; замена `ImageRenderer` smoke-тестам из SCRUM-18

## Ключевые решения

- DesignSystem (SCRUM-18) занимает 18-20 часов — это больше половины трудозатрат фазы. Liquid Glass требует тщательной проработки токенов, т.к. от них зависит весь UI в последующих фазах
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` включается на уровне проекта (SCRUM-15, выполнено)
- PersistenceCore использует GRDB 7, а не SwiftData — для офлайн-производительности и контроля над миграциями
- **CI-провайдер: GitHub Actions.** Xcode Cloud отклонён (недоступен аккаунту); Codemagic/Bitrise — возможны, но GitHub Actions выиграл за нативную интеграцию с remote и отсутствие сторонних dashboard-ов. Детали — [[CI]].

## Зависимости

- Требует: ничего (стартовая точка)
- Блокирует: [[Phase 0 — Prototype]]
