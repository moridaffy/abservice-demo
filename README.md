# ABTestingService

Попытался реализовать прототип новой системы AB-тестирования в Windy. Данная реализация выполняет все поставленные задачи:
- есть три слоя хранения значений тогглов:
	- **overridden** - конфиг, который настраивает тестировщик/разработчик локально на устройстве
	- **remote** - конфиг, который загружается с бекенда при каждом запуске приложения
	- **local** - конфиг, который зашит в ресурсах приложения (`offline_config.json`) и используется только в случае отсутствия закешированного **remote** конфига (~дефолтные значения). + хорошей идеей будет автоматизировать процесс подгрузки актуального конфига с бека и его подкладывания в ресурсы проекта при сборке релизной сборки.
- тогглы могут быть как простые (ключ-значение), так и с условиями. В таком случае у тоггла есть два значения (`pre_condition_value` и `after_condition_value`) и массив условий (`conditions`). У таких тогглов до выполнения всех условий из `conditions` будет использоваться `pre_condition_value`, а после `after_condition_value`. При этом значение этого тоггла также можно перезаписать локально в **overridden** конфиге, условия в таком случае будут игнорироваться
- есть возможность сбросить весь **overridden** конфиг, а также временно его отключить
- **overridden** конфиг записывается в `UserDefaults`, чтобы переживать перезапуски приложения, а **remote** - чтобы при следующем запуске использовать самый актуальный конфиг в случае невозможности запросить новый с бека. При этом при необходимости `UserDefaults` конечно же можно заменить на другой метод хранения
- сам экран локального редактирования тогглов также подлежит доработке, это пока что просто прототип :)