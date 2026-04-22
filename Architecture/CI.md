# CI -- GitHub Actions pipeline

> Единственный CI-провайдер проекта — GitHub Actions на hosted macOS runner. Xcode Cloud не используется (недоступен для текущего Apple Developer аккаунта).

## Что автоматизируется

Один workflow `CI` — [.github/workflows/ci.yml](../.github/workflows/ci.yml) — строит и тестирует весь проект на каждый push в `main` и каждый pull request против `main`. Состоит из двух job-ов: matrix SPM-тестов (5 пакетов параллельно) и одного app-target build.

## Триггеры

| Событие | Цель | Поведение |
|---------|------|-----------|
| `push` в `main` | Status на коммите, blocker для следующих коммитов | Оба job-а |
| `pull_request` в `main` | Обязательный check перед merge | Оба job-а |
| Tag `v*` | _Не настроено_ — отдельный тикет на TestFlight auto-deploy | -- |

`concurrency: cancel-in-progress: true` — если на той же ветке появился новый коммит, предыдущий прогон отменяется (экономит macOS-минуты).

## Два job-а

### 1. `test-packages` (matrix, 5 параллельно)

Стратегия: для каждого из 5 пакетов (HexKit, MapVerse, LocationKit, DesignSystem, PersistenceCore) запускается отдельный job `swift test`. `fail-fast: false` — падение одного пакета не отменяет остальные, видно все проблемы сразу.

Шаги:
- `actions/checkout@v4`
- `maxim-lobanov/setup-xcode@v1` с `latest-stable` — активирует актуальный stable Xcode, уже установленный на runner
- `actions/cache@v4` — кэш `.build/` по ключу `spm-<package>-macOS-<hash of Package.resolved + Package.swift>`
- `swift test` в `working-directory: Packages/<package>`

Почему `swift test` на host macOS, а не симулятор: тесты в проекте — чистая Swift-логика без iOS-only зависимостей. `swift test` на macos-arm64 работает напрямую, не требует симулятора, быстрее в разы. Платформы пакетов (`platforms: [.iOS(.v26)]`) задают минимальный iOS для рантайма — swift-build сам подставляет host-tuple при тестовом прогоне.

Почему не `xcodebuild test` через scheme `RideVerse`: Xcode 26 (на apr 2026) нестабильно загружает `.xctestplan` из workspace через CLI — сообщение `Tests cannot be run because the test plan "RideVerse" could not be read`. Через Xcode UI (⌘U) test plan работает; в CI обходим через `swift test`.

### 2. `build-app`

Один job, проверяет что app target компилируется с 5 подключёнными Local Package Dependencies:

- `xcodebuild -resolvePackageDependencies` — резолвит SPM graph workspace
- `actions/cache@v4` — кэш `~/Library/Developer/Xcode/DerivedData/**/SourcePackages` + `~/Library/Caches/org.swift.swiftpm`
- `xcodebuild build` scheme `RideVerse` с destination `generic/platform=iOS Simulator` (generic — быстрее, не требует boot симулятора). `CODE_SIGNING_ALLOWED=NO` — подпись на симулятор не нужна.

Назначение — ловить regression-ы, когда app target перестаёт линковаться после изменений в пакетах (например, если SCRUM-18 сломает publicAPI `DesignSystem`).

## Runner

- `runs-on: macos-15`. На apr 2026 должен иметь Xcode 26.x. Если регрессия — смотреть `xcodebuild -version` в логах шага «Show toolchain».
- `timeout-minutes: 15` для теста-matrix, `20` для app-build. Превышение — сигнал диагностировать кэш, не увеличивать таймаут.

## Покрытие тестами

На момент SCRUM-17 — 8 тестов в 7 test targets, scaffold-версия:

| Пакет | Test targets | @Test функций |
|-------|--------------|---------------|
| [[HexKit]] | `HexCoreTests`, `HexGeometryTests` | 2 |
| [[MapVerse]] | `MapCoreTests`, `MapFogOfWarTests` | 3 |
| [[LocationKit]] | `LocationRecordingTests` | 1 |
| [[Прочие пакеты]] / DesignSystem | `DesignSystemTests` | 1 |
| [[Прочие пакеты]] / PersistenceCore | `PersistenceCoreTests` | 1 |
| **Итого** | 7 bundles | **8** |

По мере наполнения пакетов число тестов растёт автоматически — `swift test` подхватывает все `@Test` функции без явной регистрации в scheme.

## Локальная воспроизводимость

Полный эквивалент CI, запускается на Mac разработчика:

```bash
# SPM tests (test-packages job)
for p in HexKit MapVerse LocationKit DesignSystem PersistenceCore; do
  (cd "Packages/$p" && swift test) || break
done

# App target (build-app job)
xcodebuild build \
  -workspace RideVerse.xcworkspace \
  -scheme RideVerse \
  -destination 'generic/platform=iOS Simulator' \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO
```

Для повседневной разработки удобнее Xcode UI: ⌘U на scheme `RideVerse` использует test plan (`RideVerse.xctestplan`), который видит все 7 test bundles в одном окне. CLI этот путь не использует — расхождение известное, не критичное.

## Ограничения и scope exclusions

- **Нет TestFlight-деплоя.** Отдельный follow-up тикет. Требует ASC API key, Fastlane/pilot или `xcrun altool`, секретов в GitHub Actions → Settings → Secrets and variables → Actions.
- **Нет SwiftLint.** Отдельный тикет. Добавление: шаг `brew install swiftlint` + `swiftlint lint --strict` перед `swift test`. Конфиг `.swiftlint.yml` — пока отсутствует.
- **Нет `xcodebuild test` через workspace scheme.** Причина — ненадёжная загрузка xctestplan через CLI в Xcode 26. Если Apple починят, можно свернуть matrix в один job с одной командой.
- **Нет artifact caching для DerivedData.** Осознанный выбор — DerivedData capped по размеру и требует инвалидации на каждый Xcode-update.
- **Runner quota.** Публичное репо: бесплатно. Приватное: 2000 min/мес на аккаунт × multiplier `10` для macOS → ~200 real min. При 5+1 job-ах в параллель и ~3-5 min на job — один push тратит ~25 min. Следить через Settings → Billing → Plans and usage.

## Секреты (когда появятся)

Управляются в **Settings → Secrets and variables → Actions** репозитория. Никогда не лежат в файлах репо. Ожидаемые в будущем для TestFlight:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY` (PEM-контент приватного ключа .p8)

До появления ASC API key и TestFlight-пайплайна в workflow нет ни одной строки `secrets.*` — любые утечки исключены.

## Связанные заметки

- [[Обзор]] — как CI встраивается в общую архитектуру
- [[Phase F — Foundation]] — место SCRUM-17 в дорожной карте
- [[Антипаттерны]] — чего не делать с CI (отключать тесты чтобы «зелёным было», хардкодить секреты)
