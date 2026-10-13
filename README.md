# ЖолТап (ZholTap)

Курсовой проект, ПМ07. Приложение на Flutter для составления лучшего маршрута из точки А в точку Б по Астане
(каз. «жол» — дорога, «тап» — найди). Внешних библиотек нет, интернет для работы не нужен: карта точек и дорог лежит прямо в коде.

## Запуск (Windows)

- `запустить.bat` — в Chrome
- `zapustit_android.bat` — на Android-телефоне, эмуляторе или BlueStacks (или собирает `ZholTap.apk`)
- `zapustit_iphone.bat` — web-версия для iPhone через Safari в одной Wi-Fi сети

Нужен установленный Flutter. Скрипты при первом запуске сами создают Flutter-проект и копируют в него `main.dart`.

## Вручную

```
flutter create zholtap
# заменить zholtap/lib/main.dart на main.dart из репозитория
cd zholtap
flutter run -d chrome
```
