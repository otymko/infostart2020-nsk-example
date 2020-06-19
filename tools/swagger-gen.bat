chcp 65001

@call swagger generate --src-path src --out build\swagger --format json
@call bootprint openapi build\swagger\Пример_Заказы.json build\swagger