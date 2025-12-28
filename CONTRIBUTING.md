# Участие в разработке

## Формат коммитов

Проект использует [Conventional Commits](https://www.conventionalcommits.org/).

### Формат

```
<тип>(<область>): <описание>
```

### Типы

- `feat` - Новая функция
- `fix` - Исправление бага
- `docs` - Изменения документации
- `style` - Изменения стиля кода (форматирование, без изменения логики)
- `refactor` - Рефакторинг кода
- `perf` - Улучшение производительности
- `test` - Добавление или обновление тестов
- `chore` - Служебные задачи
- `ci` - Изменения CI/CD

### Области (опционально)

- `gui` - Изменения связанные с GUI
- `core` - Основной функционал
- `config` - Изменения конфигурации

### Примеры

```
feat(gui): add copy button for diagnostics output
fix(gui): resolve window drag issue
docs: update README with GUI section
chore: remove emojis from templates
ci: add release workflow
```

## Pull Requests

1. Сделайте форк репозитория
2. Создайте ветку для фичи
3. Внесите изменения следуя формату коммитов
4. Отправьте pull request

## Сообщения об ошибках

Используйте GitHub Issues для сообщений о багах или запросов функций.
