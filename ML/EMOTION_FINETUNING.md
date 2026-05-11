## Emotion Fine-Tuning Track

Этот документ описывает второй этап развития emotion analysis после интеграции zero-shot модели.

### Цель

Перейти от zero-shot/multilingual baseline к модели, дообученной на русскоязычных текстах и затем адаптированной под дневниковые заметки приложения.

### Базовое пространство меток

Нормализованный label space в runtime:

- `joy`
- `sadness`
- `anger`
- `fear`
- `surprise`
- `neutral`

Дополнительно производное поле:

- `valence`: `positive`, `neutral`, `negative`

### Рекомендуемые внешние датасеты

1. `AiLab-IMCS-UL/go_emotions-ru`
   Подходит как основной стартовый emotion dataset для русскоязычной многоклассовой классификации.

2. `Djacon/ru_goemotions`
   Удобен как дополнительный validation/evaluation source и для проверки устойчивости label mapping.

3. `RuSentiment`
   Полезен для вспомогательной проверки `valence`, если понадобится усилить качество positive/neutral/negative поверх emotion labels.

### Mapping меток к runtime-схеме

Пример агрегации внешних лейблов в доменные:

- `joy` <- joy, amusement, approval, gratitude, love, optimism, relief
- `sadness` <- sadness, grief, disappointment, remorse
- `anger` <- anger, annoyance, disapproval
- `fear` <- fear, nervousness
- `surprise` <- surprise, realization
- `neutral` <- neutral, curiosity, confusion

Точный mapping должен храниться как отдельный конфиг training pipeline, а не быть зашитым в runtime API.

### Этапы обучения

1. Собрать единый training dataset с нормализованными метками.
2. Fine-tune multilingual encoder на 6 эмоций.
3. Отдельно измерить:
   - macro-F1
   - per-class precision/recall/F1
   - confusion matrix
4. Подготовить небольшую доменную выборку реальных заметок.
5. Провести second-stage fine-tuning или calibration на доменной выборке.

### Что сохранять для будущей доразметки

Для каждой заметки желательно сохранять:

- текст заметки
- предсказанные `emotion_scores`
- `dominant_emotion`
- ручную метку человека, если появится UI подтверждения

Это позволит со временем перейти на domain-adapted модель, а не оставаться на general-purpose датасетах.

### Критерии готовности к миграции с zero-shot

Переходить на fine-tuned checkpoint имеет смысл, если:

- macro-F1 на validation заметно выше zero-shot baseline
- ошибки на `sadness` / `fear` / `anger` уменьшились на реальных заметках
- модель стабильно работает на коротких и длинных текстах
- инференс укладывается в допустимую latency для API
