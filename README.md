<div align="center" style="font-size:4vw">FAP</div>
<div align="center" style="font-size:2vw">Feature Availability Provider</div>

<p align="center">
  <a href="#Возможности">Возможности</a> •
  <a href="#Использование">Использование</a> •
  <a href="#Интеграция-в-проект">Интеграция в проект</a> •
  <a href="#Добавление-нового-флага/коллекции">Добавление нового флага/коллекции</a> •
  <a href="#TODO">TODO</a>
</p>

## Возможности

- Подписка на изменение конкретных флагов, коллекций или всех значений
- Работа с несколькими провайдерами для сложных сетапов, например:
    - провайдер дебаг значений, которые разработчик включил локально
    - провайдер настроек пользователя, которые пользователь включил на экране настроек
    - провайдер remote-значений, которые загружаются при запуске приложения с сервера и кешируются
    - провайдер локальных значений, которые зашиты в ресурсах проекта и доступны всегда, даже если приложение ни разу не подключалось к сети

## Использование

``` swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        MainFAPLoader.shared.addObserver(self)
    }
}

extension ViewController: FAPILoaderObserver {
    func didChangeValues(_ loader: FAPILoader) {
        guard let loader = loader as? MainFAPLoader else { return }

        titleLabel.text = loader.texts.title
    }
}
```

## Интеграция в проект

1. Создать класс, реализующий протокол `FAPLoader` - это будет главная точка входа
2. Создать класс, реализующий протокол `FAPICollection` - это может быть как единственная коллекция, в которой будут все флаги, так и корневая коллекция, включающая в себя подколлекции с флагами
3. Создать один или несколько классов, реализующих протокол `FAPIProvider` или наследующихся от `FAPProvider` - это будет провайдер значений. Можно использовать как один провайдер, так и несколько для более сложных сетапов
4. Расширить `FAPKeyPath` и добавить ключи флагов проекта

## Добавление нового флага/коллекции

### Коллекции
С коллекциями все достаточно просто - нужно создать класс, реализующий протокол `FAPICollection` и добавить объект этого класса как переменную в корневой категории через `@propertyWrapper`:
``` swift
struct FAPRootCollection: FAPICollection {
    @FAPCollection(key: "main")
    var main: FAPMainCollection
}
```

### Флаги

Для добавления нового флага нужно расширить `FAPKeyPath` и добавить переменную в нужную коллекцию через `@propertyWrapper`:

``` swift
struct FAPMainCollection: FAPICollection {
    @FAPFlag(keyPath: FAPKeyPath.Main.backgroundColor.keyPath, default: "FF0000")
    var backgroundColor: String?
}
```

Тут задается `keyPath` значения, а также его дефолтное значение, если ни один из доступных провайдеров не вернет значения.

При необходимости использовать кастомный тип данных, нужно реализовать протокол `FAPIValue` у этого типа, например:
``` swift
struct SomeCodable: Codable {
    let title: String
}

extension SomeCodable: FAPIValue {
    init?(encoded value: FAPValueType) {
    switch value {
    case let .model(value):
      guard let value = value as? SomeCodable else { return nil }
      self = value

    case let .data(value):
      do {
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: value)
      } catch {
        return nil
      }

    default:
      return nil
    }
  }

  func encoded() -> FAPValueType {
    .model(self)
  }
}
```

Здесь реализуется две функции - преобразование объекта В и ИЗ `FAPValueType`. 

## TODO

- [ ] проверять, на самом ли деле изменилось значение перед уведомлением слушателей
- [ ] поиск по дебаг-меню
- [ ] редактирование массивов из дебаг меню
- [ ] SPM-пакет