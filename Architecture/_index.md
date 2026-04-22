# Архитектура RideVerse
> Навигационная страница базы знаний по архитектуре проекта RideVerse (FogRide).

Проект RideVerse построен на модульной SPM-архитектуре из 18 пакетов, разделённых на три слоя: App, Features, Domain и переиспользуемые Packages. Здесь собрана вся архитектурная документация.

## Заметки

- [[Обзор]] -- философия, правила, структура слоёв, сводная таблица пакетов, стратегия хранения и порядок разработки
- [[MapVerse]] -- группа пакетов для карт: MapCore, MapOverlays, MapFogOfWar, MapOfflineRegions
- [[LocationKit]] -- группа пакетов для GPS: LocationRecording, LocationFiltering, LocationAnalysis, LocationMotion
- [[HexKit]] -- группа пакетов для H3-сетки: HexCore, HexGeometry, двухуровневое хранение, compaction
- [[SensorKit]] -- группа пакетов для BLE-сенсоров: BLESensorCore, CyclingSensors (фаза 5)
- [[Domain]] -- доменный слой: FogRideModels, FogRidePersistence, FogRideServices, composition root
- [[Прочие пакеты]] -- WorkoutKit, TrackExport, PersistenceCore, DesignSystem
- [[Антипаттерны]] -- собрание антипаттернов, которых следует избегать при развитии кодовой базы
