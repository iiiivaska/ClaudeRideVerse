# Организация Obsidian Vault для RideVerse

**Дата:** 2026-04-22
**Статус:** Утверждён

## Контекст

Obsidian vault инициализирован в корне проекта (`/`), но не содержит структурированных заметок. Вся документация — flat .md файлы в корне: `fogride-architecture.md` (1417 строк), `fogride-architecture-part2.md` (926 строк). Дизайн-прототип существует локально в `~/Downloads/RideVerse-2/`. Jira (проект SCRUM, 65 задач, 7 эпиков) — source of truth для задач.

## Решения

- **Подход:** Knowledge Base (B) — тематические заметки с wiki-links и папочной структурой
- **Язык:** Русский
- **Задачи:** Только в Jira, в Obsidian — ссылки и контекст
- **Дизайн-ассеты:** Копируются из Downloads в vault

## Структура vault

```
Architecture/
  _index.md
  Обзор.md
  MapKit.md
  LocationKit.md
  HexKit.md
  SensorKit.md
  Domain.md
  Прочие пакеты.md
  Антипаттерны.md

Design/
  _index.md
  Дизайн-система.md
  Screens/
    Onboarding.md
    Map.md
    Recording.md
    Trip Summary.md
    Trip Detail.md
    Rides.md
    Stats.md
    Profile.md
    Paywall.md
    Live Activity.md
  Assets/
    (8 скриншотов)
  Prototype/
    FogRide Prototype.html
    ios-frame.jsx
    check.png

Roadmap/
  _index.md
  Phase F — Foundation.md
  Phase 0 — Prototype.md
  Phase 1 — MVP.md
  Phase 2 — Social.md
  Phase 3 — Backend.md
  Phase 4 — POI & AI.md
  Phase 5 — Watch & BLE.md

Journal/

Dashboard.md
```

## Шаблоны заметок

### Architecture note
```
# {Группа пакетов}
> Краткое описание группы

## {Пакет 1}
### Назначение
### Публичный API (ключевые типы)
### Зависимости
### Тестирование

## Связи
- Зависит от: [[...]]
- Используется в: [[...]]
```

### Design screen note
```
# {Экран}
> Тип, назначение

![[screenshot.png]]

## Элементы
(из fogride-screens-prompt.md)

## Связи
- Пакеты: [[...]]
- Фичи: {FeatureModule}
```

### Roadmap phase note
```
# {Phase} — {Название}
> Длительность, цель

## Цель
## Go/No-Go критерии
## Задачи (Jira)
- [SCRUM-XX] Описание
## Зависимости
- Требует: [[...]]
```

## Изменения в существующих файлах

1. **CLAUDE.md** — заменить секцию "Architecture Documentation" на указатели в vault
2. **fogride-architecture.md** — удалить после переноса контента
3. **fogride-architecture-part2.md** — удалить после переноса контента

## Что НЕ входит

- Дублирование задач из Jira (только ссылки)
- Daily notes (пустая папка Journal/ для будущего)
- Zettelkasten-стиль атомарных заметок (потом при необходимости)
