# Secret Location Chat (SLC)

Геозависимый анонимный мессенджер. Cyberpunk / Y2K эстетика.
Flutter + Firebase + flutter_map.

---

## Стек

| Слой | Технология | Источник |
|------|-----------|---------|
| UI | Flutter / Dart | — |
| Карта | flutter_map + OpenStreetMap/Stadia | kumbel_map_sample |
| State | flutter_bloc | kiru + firebase_test |
| Навигация | go_router | kiru + firebase_test |
| Auth | Firebase Auth | firebase_test |
| БД | Cloud Firestore | firebase_test |
| Анонимность | Client-side hash + Cloud Functions | SLC |
| Геолокация | geolocator | SLC |
| Хранилище настроек | flutter_secure_storage | firebase_test |

---

## Быстрый старт

### 1. Предусловия
```bash
flutter --version   # 3.22+
dart --version      # 3.4+
```

### 2. Клонировать и установить зависимости
```bash
git clone <your-repo>
cd secret_location_chat
flutter pub get
```

### 3. Настроить Firebase

```bash
# Установить FlutterFire CLI
dart pub global activate flutterfire_cli

# Создать проект в https://console.firebase.google.com
# Включить: Authentication (Email/Password), Firestore, Cloud Functions

# Привязать проект
flutterfire configure --project=YOUR_PROJECT_ID
```

Это создаст `lib/firebase_options.dart`.

Затем в `lib/main.dart` раскомментировать импорт:
```dart
import 'firebase_options.dart';
// и изменить строку:
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 4. Задеплоить правила Firestore
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### 5. Android — добавить разрешения

В `android/app/src/main/AndroidManifest.xml` внутри `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### 6. iOS — добавить разрешения

В `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>SLC показывает сообщения рядом с тобой</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>SLC показывает сообщения рядом с тобой</string>
```

### 7. Запустить
```bash
flutter run
```

---

## Структура проекта

```
lib/
├── main.dart                          # Точка входа
├── core/
│   ├── router/router.dart             # go_router маршруты
│   ├── theme/
│   │   ├── app_colors.dart            # Cyberpunk палитра
│   │   └── app_theme.dart             # ThemeData
│   └── widgets/
│       └── slc_button.dart            # Кнопка с неоном
├── data/
│   ├── auth/auth_repository.dart      # Firebase Auth
│   ├── geo/geo_message_repository.dart # Firestore geo
│   ├── models/
│   │   ├── user_model.dart
│   │   └── geo_message_model.dart     # TTL-сообщение
│   └── prefs/user_prefs_service.dart  # Анонимность, настройки
└── features/
    ├── app/
    │   ├── bloc/app_auth_bloc.dart    # Глобальная авторизация
    │   └── ui/app.dart                # Корневой виджет
    ├── splash/ui/splash_screen.dart   # Стартовый экран
    ├── auth/
    │   ├── bloc/auth_form_bloc.dart
    │   └── ui/auth_screen.dart
    ├── register/
    │   ├── bloc/register_bloc.dart
    │   └── ui/register_screen.dart
    └── map/
        ├── bloc/map_bloc.dart          # Карта + сообщения
        └── ui/
            ├── map_screen.dart         # Главный экран
            ├── message_card.dart       # Карточка сообщения
            └── send_message_sheet.dart # Отправка + TTL + анон
```

---

## Монетизация

| Тариф | Цена | Что открывает |
|-------|------|--------------|
| Free | ₸ 0 | 5 сообщ/день, TTL 1ч |
| Premium | ₸ 5 000/мес | Анонимность, TTL до 24ч, подарки, аватарки |
| Enterprise | ₸ 50 000+/мес | Приватные зоны, API, аналитика |
| Скачать | ₸ 500–1000 | Разовая оплата при установке |

---

## TTL — как работает

1. При отправке пользователь выбирает TTL (10 мин – 24 ч)
2. В Firestore пишется поле `expiresAt = now + ttl`
3. Клиент запрашивает только `where expiresAt > now`
4. Cloud Function (опционально) удаляет просроченные документы раз в час

---

## Анонимность

- Реальный `uid` всегда в Firebase Auth (для модерации)
- При включённом режиме: `authorName = Shadow_XXXX` (hash от uid)
- Другие пользователи видят только псевдоним
- Cloud Function может раскрыть личность при жалобе

---

## TODO

- [ ] Cloud Function для удаления просроченных сообщений
- [ ] Тред ответов (ReplyScreen)
- [ ] Totem Compass (IndikatorBloc)
- [ ] Unity-игра (flutter_unity_widget)
- [ ] In-App покупки (purchases_flutter)
- [ ] Push-уведомления (firebase_messaging)
- [ ] Аватарки (firebase_storage)
