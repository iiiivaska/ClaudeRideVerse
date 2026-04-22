# Roadmap RideVerse

Дорожная карта проекта RideVerse (FogRide) на 18 месяцев. Фазы выполняются последовательно, каждая имеет Go/No-Go критерии для перехода к следующей.

## Текущий статус

**Активная фаза:** [[Phase 1 — MVP]]
**Прогресс:** Phase F ✅, Phase 0 ✅. Следующий: SCRUM-31 (LocationKit full).
**DevTools:** [[#EPIC-DT]] Debug Panel (SCRUM-74, 7 задач) — кросс-фазовый эпик для отладки и тестирования.

## Фазы

| Фаза | Название | Длительность | Статус | Go/No-Go критерий |
|------|----------|-------------|--------|-------------------|
| [[Phase F — Foundation\|F]] | Foundation | 1-2 недели | ✅ **Готово** | Skeleton собирается, CI зелёный, DesignSystem готов |
| [[Phase 0 — Prototype\|0]] | Prototype | 3-4 недели | ✅ **Готово** | Prototype polish, TestFlight prep done |
| [[Phase 1 — MVP\|1]] | MVP | ~3 недели (150-160ч) | **В работе** | Go-решение по Phase 0 |
| [[Phase 2 — Social\|2]] | Social | 8-10 недель | Ожидает | 500+ WAU |
| [[Phase 3 — Backend\|3]] | Backend | 12-14 недель | Ожидает | 3000+ WAU, 8%+ конверсия, $2000+ MRR |
| [[Phase 4 — POI & AI\|4]] | POI & AI | 8-10 недель | Ожидает | Успешный Phase 3 |
| [[Phase 5 — Watch & BLE\|5]] | Watch & BLE | 8-10 недель | Ожидает | Успешный Phase 3 |

## Последовательность

```
F → 0 → 1 → 2 → 3 → 4
                    ↘ 5
```

Phase 4 и Phase 5 могут выполняться параллельно после Phase 3.

## Связанные разделы

- [[Architecture/_index|Архитектура]] — трёхслойная структура и SPM-пакеты
- [[Design/_index|Дизайн]] — Liquid Glass, UI-компоненты
