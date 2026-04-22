# Phase 2 — Social
> 8-10 недель. Социальный слой через CloudKit: синхронизация, друзья, совместный туман.

## Цель

Добавить социальные функции поверх CloudKit (private + shared database). Бесплатные пользователи получают синхронизацию между устройствами. Premium-подписчики — круг друзей, сравнение тумана, и уникальную фичу: совместный туман для групповых поездок (bikepacking).

## Go/No-Go критерии

- **500+ WAU** (Weekly Active Users) по данным Phase 1
- Стабильная работа офлайн-трекера, crash-free rate > 99%

## Задачи (Jira)

- **SCRUM-50** [2.1] CloudKit Setup & Schema — M, P0
- **SCRUM-51** [2.2] Sign in with Apple + User Identity — M, P0
- **SCRUM-52** [2.3] Multi-device Sync of Personal Trips — L, P0
- **SCRUM-53** [2.4] Friends Circle (invite + manage) — L, P0
- **SCRUM-54** [2.5] Friends Fog Comparison Screen — M, P1
- **SCRUM-55** [2.6] Push Notifications about friends' trips — S, P1
- **SCRUM-56** [2.7] **Collaborative Fog Mode (bikepacking)** — XL, P1
- **SCRUM-57** [2.8] Premium Gating for social features — S, P0
- **SCRUM-58** [2.9] Phase 2 Release — M, P0

### Уникальная фича: Collaborative Fog

> SCRUM-56 — **Collaborative Fog Mode**

Группа друзей открывает общий туман в совместной поездке (bikepacking, велопоход). Используется CloudKit shared database — каждый участник видит, как туман рассеивается от всех членов группы в реальном времени. Это принципиально новая механика, отсутствующая в конкурентах (Strava, Komoot, Fog of World).

## Ключевые решения

- CloudKit вместо собственного бэкенда — нулевые серверные расходы на этом этапе
- Private database для личных данных, shared database для Collaborative Fog
- Sign in with Apple как единственный способ аутентификации (без email/password)
- Free-tier получает sync — это стимулирует привязку к экосистеме до покупки Premium
- Collaborative Fog — XL-задача и основной selling point Phase 2

## Зависимости

- Требует: [[Phase 1 — MVP]] (500+ WAU)
- Блокирует: [[Phase 3 — Backend]]
