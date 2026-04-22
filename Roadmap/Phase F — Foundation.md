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
- **SCRUM-17** [F.2] CI — build + test (GitHub Actions, 2-3ч) — **IN PROGRESS**
  - _Scope-change:_ Xcode Cloud недоступен для текущего Apple Developer аккаунта, переключено на GitHub Actions hosted macOS runner. TestFlight-деплой вынесен в отдельный follow-up тикет.
  - Детали: [[CI]]
- **SCRUM-18** [F.3] DesignSystem — Liquid Glass tokens + components (18-20ч) — **самая крупная задача фазы**
- **SCRUM-19** [F.4] Info.plist + PrivacyInfo + Capabilities (2-3ч)
- **SCRUM-20** [F.5] PersistenceCore — GRDB 7 + WAL + migrations (3-4ч)

### Follow-up (созданы во время SCRUM-17)

- **SwiftLint config + zero warnings baseline** (2-3ч) — добавить `.swiftlint.yml` и шаг линтинга в CI
- **TestFlight auto-deploy on tag v\*** (3-4ч) — Fastlane/pilot или `xcrun altool`, секреты ASC API key в GitHub Actions

## Ключевые решения

- DesignSystem (SCRUM-18) занимает 18-20 часов — это больше половины трудозатрат фазы. Liquid Glass требует тщательной проработки токенов, т.к. от них зависит весь UI в последующих фазах
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` включается на уровне проекта (SCRUM-15, выполнено)
- PersistenceCore использует GRDB 7, а не SwiftData — для офлайн-производительности и контроля над миграциями
- **CI-провайдер: GitHub Actions.** Xcode Cloud отклонён (недоступен аккаунту); Codemagic/Bitrise — возможны, но GitHub Actions выиграл за нативную интеграцию с remote и отсутствие сторонних dashboard-ов. Детали — [[CI]].

## Зависимости

- Требует: ничего (стартовая точка)
- Блокирует: [[Phase 0 — Prototype]]
