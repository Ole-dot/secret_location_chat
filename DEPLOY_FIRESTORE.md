# Деплой Firestore: правила и индексы

Проект Firebase: **`me-c-69d57`**

Файлы-источники в репозитории:
- `firestore.rules` — правила безопасности
- `firestore.indexes.json` — составные индексы

> Зачем: вкладка **EVENTS TERMINAL** падает с ошибкой, потому что серверные
> правила/индексы Firestore рассинхронизированы с этими файлами:
> - GLOBAL (`messages`) → `PERMISSION_DENIED` — правило для `messages` не задеплоено
> - MY LOGS (`geo_messages` по `authorUid`) → нужен составной индекс
> - MY LOGS (`collectionGroup('replies')`) → `PERMISSION_DENIED` — нет рекурсивного правила

---

## Вариант A — через Firebase CLI (рекомендуется)

### 1. Установить CLI (один раз)
```bash
npm install -g firebase-tools
```

### 2. Войти в аккаунт (один раз)
В терминале Claude Code запусти с префиксом `!` (интерактивный логин):
```
! firebase login
```

### 3. Привязать проект (один раз)
В корне проекта уже лежат `firebase.json` и `.firebaserc` (см. ниже). Проверить:
```bash
firebase use me-c-69d57
```

### 4. Задеплоить
```bash
# только правила:
firebase deploy --only firestore:rules

# только индексы:
firebase deploy --only firestore:indexes

# и то, и другое сразу:
firebase deploy --only firestore:rules,firestore:indexes
```

Индексы строятся в фоне (от нескольких секунд до пары минут) — статус виден в
[консоли → Firestore → Indexes](https://console.firebase.google.com/project/me-c-69d57/firestore/indexes).

---

## Вариант B — через веб-консоль (без CLI)

### Правила
1. Открой [Firestore → Rules](https://console.firebase.google.com/project/me-c-69d57/firestore/rules).
2. Скопируй всё содержимое файла `firestore.rules` и вставь в редактор.
3. Нажми **Publish**.

Это чинит GLOBAL (`messages`) и доступ к `replies` в MY LOGS.

### Индексы
1. Открой [Firestore → Indexes](https://console.firebase.google.com/project/me-c-69d57/firestore/indexes).
2. Создай **Composite** индексы (Add Index):

   **geo_messages**
   | Поле | Порядок |
   |---|---|
   | `authorUid` | Ascending |
   | `createdAt` | Descending |
   - Query scope: **Collection**

   **replies**
   | Поле | Порядок |
   |---|---|
   | `authorUid` | Ascending |
   | `createdAt` | Descending |
   - Query scope: **Collection group**

> Самый быстрый способ для первого индекса: открой ссылку, которую Firestore
> выводит прямо в логе ошибки (`The query requires an index. You can create it here: …`)
> — она создаёт нужный индекс `geo_messages(authorUid, createdAt)` в один клик.

---

## Проверка после деплоя
1. Перезапусти приложение: `fvm flutter run -d emulator-5554`.
2. Открой нижний лист **EVENTS TERMINAL** → вкладки **GLOBAL** и **MY LOGS**.
3. Ошибка должна пропасть (вместо неё — список событий или пустое состояние
   `NO GLOBAL EVENTS` / `NO PERSONAL LOGS`).
