# Phase F — Foundation
> 1-2 недели (до Phase 0). Заложить фундамент проекта: workspace, пакеты, CI, дизайн-система, persistence.

## Цель

Создать скелет Xcode workspace со всеми SPM-пакетами Phase 0, настроить CI/CD через Xcode Cloud, реализовать [[DesignSystem]] с Liquid Glass токенами и компонентами, подготовить [[PersistenceCore]] на GRDB 7 с WAL и миграциями, сконфигурировать privacy-манифесты.

Это стартовая точка всего проекта — ни одна другая фаза не может начаться без завершения Foundation.

## Go/No-Go критерии

- SPM skeleton собирается без ошибок
- CI pipeline (Xcode Cloud) зелёный на main
- DesignSystem содержит все Liquid Glass токены и базовые компоненты
- PersistenceCore проходит unit-тесты (GRDB 7 + WAL + миграции)
- Info.plist, PrivacyInfo.xcprivacy и Capabilities настроены

## Задачи (Jira)

- **SCRUM-12** [F.1] Xcode workspace + SPM skeleton
  - SCRUM-13 Create workspace + app target — **DONE**
  - SCRUM-14 Create SPM packages Phase 0
  - SCRUM-15 Enable Swift 6 Approachable Concurrency
  - SCRUM-16 Git + .gitignore + README
- **SCRUM-17** [F.2] CI/CD via Xcode Cloud (2-3ч)
- **SCRUM-18** [F.3] DesignSystem — Liquid Glass tokens + components (18-20ч) — **самая крупная задача фазы**
- **SCRUM-19** [F.4] Info.plist + PrivacyInfo + Capabilities (2-3ч)
- **SCRUM-20** [F.5] PersistenceCore — GRDB 7 + WAL + migrations (3-4ч)

## Ключевые решения

- SCRUM-13 выполнена, но проект ещё не импортирован в workspace — нужно завершить SCRUM-14 для полного skeleton
- DesignSystem (SCRUM-18) занимает 18-20 часов — это больше половины трудозатрат фазы. Liquid Glass требует тщательной проработки токенов, т.к. от них зависит весь UI в последующих фазах
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` включается на уровне проекта (SCRUM-15)
- PersistenceCore использует GRDB 7, а не SwiftData — для офлайн-производительности и контроля над миграциями

## Зависимости

- Требует: ничего (стартовая точка)
- Блокирует: [[Phase 0 — Prototype]]
