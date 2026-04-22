# Phase 5 — Watch & BLE
> 8-10 недель (месяцы 15-17). Standalone Watch-приложение, BLE-сенсоры, интеграции с Garmin/Wahoo.

## Цель

Standalone Apple Watch приложение для записи поездок без iPhone. Поддержка BLE-сенсоров для велокомпьютерных метрик: пульс (HR), мощность (Power), каденс (Cadence), FTMS-тренажёры. Синхронизация с Garmin Connect и Wahoo, импорт FIT-файлов.

## Go/No-Go критерии

- Успешный релиз [[Phase 3 — Backend]]
- Бэкенд стабилен для синхронизации данных Watch ↔ iPhone ↔ Cloud

## Задачи (Jira)

Задачи в Jira пока не декомпозированы — эпик SCRUM-11 содержит только описание. Предполагаемые направления:

- Standalone watchOS-приложение с записью поездок
- [[BLESensorCore]] — менеджмент BLE-соединений (AsyncBluetooth)
- [[CyclingSensors]] — парсинг HR, Power, Cadence, FTMS профилей
- Garmin Connect API интеграция
- Wahoo API интеграция
- FIT-файл импорт/экспорт (расширение [[TrackExport]])
- Watch Connectivity для синхронизации iPhone ↔ Watch

## Ключевые решения

- Детальная декомпозиция будет выполнена ближе к началу фазы (через ~15 месяцев)
- AsyncBluetooth для всех BLE-взаимодействий (никакого CoreBluetooth напрямую)
- BLE-пакеты ([[BLESensorCore]], [[CyclingSensors]]) из [[SensorKit]] — переиспользуемые, без доменной логики
- Watch-приложение использует тот же [[LocationRecording]], что и iPhone
- FIT-формат критичен для совместимости с Garmin/Wahoo экосистемой

## Зависимости

- Требует: [[Phase 3 — Backend]]
- Блокирует: ничего (может выполняться параллельно с [[Phase 4 — POI & AI]])
