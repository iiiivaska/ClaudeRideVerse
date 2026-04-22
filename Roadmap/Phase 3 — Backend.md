# Phase 3 — Backend
> 12-14 недель. Самая рискованная фаза. Supabase + PostGIS бэкенд, публичная heatmap, live-трекинг друзей, интеграции.

## Цель

Миграция с CloudKit на собственный бэкенд (Supabase + PostGIS). Публичная heatmap с k-anonymity, отслеживание друзей на карте в реальном времени, лента активности, импорт из Strava/Komoot. Повышение цены до $6.99/мес, $49.99/год.

## Go/No-Go критерии

- **3000+ WAU**
- **8%+ конверсия** в платную подписку
- **$2000+ MRR** (Monthly Recurring Revenue)
- **<5% monthly churn**

## Задачи (Jira)

### Инфраструктура
- **SCRUM-59** [3.1] Backend Infrastructure (Supabase + PostGIS + RLS) — L, P0
- **SCRUM-60** [3.2] SIWA as Primary Auth — M, P0
- **SCRUM-61** [3.3] Data Migration CloudKit → Supabase — L, P0 — **высокий риск**
- **SCRUM-62** [3.4] App Attest Security Layer — M, P0

### Социальные фичи
- **SCRUM-63** [3.5] **Global Heatmap (k-anonymity)** — L, P0 — **высокий риск**
- **SCRUM-64** [3.6] Public Track Publishing (opt-in) — M, P1
- **SCRUM-65** [3.7] Friends on Map (live tracking 1/15s) — L, P0
- **SCRUM-66** [3.8] Activity Feed (follows + kudos) — M, P1
- **SCRUM-67** [3.9] **Nearby Riders Mode** — XL, P1

### Интеграции и релиз
- **SCRUM-68** [3.10] Strava / Komoot Import — M, P1
- **SCRUM-69** [3.11] Phase 3 Release + price bump + GDPR — L, P0

### Уникальная фича: Nearby Riders

> SCRUM-67 — **Nearby Riders Mode**

Zenly-подобная механика: видишь других райдеров поблизости в реальном времени. XL-задача с высоким риском — возможен отказ App Store Review. Подготовлен Plan B на случай rejection.

### Global Heatmap

> SCRUM-63 — **Global Heatmap**

Агрегированная тепловая карта всех поездок всех пользователей. Применяется k-anonymity (k >= 5) и Laplace noise для приватности. Обновление — еженедельно. Высокий риск из-за сложности приватности и производительности PostGIS-запросов.

## Ключевые решения

- Supabase выбран как managed-бэкенд: PostGIS из коробки, RLS, realtime subscriptions
- Миграция CloudKit → Supabase (SCRUM-61) — самая рискованная задача; нужна стратегия "dual write" на переходный период
- App Attest обязателен для защиты API от abuse
- k-anonymity с k >= 5 и Laplace noise — минимальный стандарт для heatmap приватности
- Live tracking друзей — 1 update каждые 15 секунд через Supabase Realtime
- Nearby Riders имеет Plan B на случай App Store rejection
- Повышение цены до $6.99/мес, $49.99/год — обосновано расширением функциональности
- GDPR compliance обязателен для Phase 3 Release

## Зависимости

- Требует: [[Phase 2 — Social]] (3000+ WAU, $2000+ MRR)
- Блокирует: [[Phase 4 — POI & AI]], [[Phase 5 — Watch & BLE]]
