# Phase 0 — Prototype
> 3-4 недели. Дешёвый прототип для валидации: "работает ли fog of war как retention-механика?"

## Цель

Собрать минимальное приложение: карта + туман войны + Start/Stop. Выложить в TestFlight, снять видео, опубликовать, собрать обратную связь. Цель — проверить гипотезу, что fog of war на реальных поездках цепляет пользователей, прежде чем вкладывать 150+ часов в MVP.

Реализуются базовые пакеты: [[HexCore]], [[HexGeometry]], [[MapCore]], [[MapFogOfWar]], [[LocationRecording]].

## Go/No-Go критерии

- **500+ upvotes** на видео (TikTok / Reddit / Twitter)
- **20-30 pre-orders** или подписок на waitlist
- Субъективная оценка: туман войны действительно вызывает желание "открыть ещё"

## Задачи (Jira)

- **SCRUM-21** [0.1] [[HexCore]] — SwiftyH3 wrapper (3-4ч)
  - SCRUM-22 Add SwiftyH3 0.5.0 SPM dependency
  - SCRUM-23 Create HexCell + HexResolution types
  - SCRUM-24 HexCell API + unit tests
- **SCRUM-25** [0.2] [[HexGeometry]] — compaction, multipolygon, viewport culling (3-4ч)
- **SCRUM-26** [0.3] [[MapCore]] — MapLibre SwiftUI wrapper + Stadia Outdoors (3-4ч)
- **SCRUM-27** [0.4] [[MapFogOfWar]] — inverted MultiPolygon (4-5ч)
- **SCRUM-28** [0.5] [[LocationRecording]] — minimal foreground version (2-3ч)
- **SCRUM-29** [0.6] PrototypeApp — map + fog + Start/Stop screen (3-4ч код + 2-3ч полевые тесты)
- **SCRUM-30** [0.7] TestFlight + публикация + feedback + go/no-go решение (4-6ч + 1-2 недели ожидания)

## Ключевые решения

- Прототип — одноразовый: код может быть грязным, главное — быстро проверить гипотезу
- LocationRecording только foreground — фоновая запись будет в Phase 1
- MapLibre выбран вместо Apple Maps ради офлайн-карт (PMTiles) и гибкости стилей
- SwiftyH3 0.5.0 — обёртка над C-библиотеку H3 от Uber, Resolution 9 (~174м) как основной уровень

## Зависимости

- Требует: [[Phase F — Foundation]]
- Блокирует: [[Phase 1 — MVP]]
