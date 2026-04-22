# SensorKit -- группа пакетов для BLE-сенсоров
> Два пакета: BLESensorCore и CyclingSensors. Подключение к Bluetooth-сенсорам и парсинг данных HR/Power/Cadence. Фаза 5 роудмапа.

---

## BLESensorCore

**Назначение:** обёртка над AsyncBluetooth -- discovery, connection management, reconnect.

| Свойство | Значение |
|---|---|
| Зависимости | AsyncBluetooth |
| Публичный контракт | Discovery, connection management, reconnect |
| Фаза | 5 |

Пакет инкапсулирует сложности BLE-жизненного цикла: сканирование устройств, установка соединения, авто-переподключение при потере связи. Предоставляет async-native API для работы с Bluetooth-периферией.

---

## CyclingSensors

**Назначение:** типизированные AsyncStream для HR/Power/Cadence/FTMS парсеров.

| Свойство | Значение |
|---|---|
| Зависимости | BLESensorCore |
| Публичный контракт | Типизированные streams HR/Power/Cadence |
| Фаза | 5 |

Пакет парсит сырые BLE-характеристики в типобезопасные Swift-структуры и предоставляет AsyncStream для каждого типа сенсора:
- **Heart Rate** -- BLE Heart Rate Profile
- **Power** -- Cycling Power Service
- **Cadence** -- Cycling Speed and Cadence (CSC)
- **FTMS** -- Fitness Machine Service

### Зависимости

- BLESensorCore

Используется в: [[Domain|TripRecorder]] (фаза 5, расширение записи тренировки с автопаузой по пульсу).
