// =====================================================================
// КУРСОВОЙ ПРОЕКТ, ПМ07.
// Тема: приложение для составления лучшего маршрута из точки А в точку Б.
// Приложение «ЖолТап» (каз. «жол» — дорога, «тап» — найди).
// =====================================================================
//
// Как запустить:
//   1. flutter create moy_proekt
//   2. Открыть moy_proekt/lib/main.dart
//   3. Стереть всё, вставить этот файл целиком
//   4. flutter run -d chrome   (или flutter run на телефоне)
//
// Внешних библиотек НЕТ. Интернет для запуска не нужен:
// карта точек Астаны и дорог между ними лежит прямо в коде (класс Hranilishe).
//
// Все мои изменения шаблона помечены комментарием  // >>> ИЗМЕНЕНО
// =====================================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------
// >>> ИЗМЕНЕНО (критерий 2). Название, подзаголовок и цвет приложения.
// Бирюзовый цвет выбран как «транспортный», как у карт и навигаторов.
// ---------------------------------------------------------------------
const String nazvanieProekta = 'ЖолТап';
const String podzagolovok = 'лучший маршрут из А в Б';
const MaterialColor osnovnoyCvet = Colors.teal;

// ---------------------------------------------------------------------
// >>> ИЗМЕНЕНО (критерий 9). Приложение работает с маршрутами.
// ---------------------------------------------------------------------
const String imyaObyekta = 'Маршрут';
const String imyaObyektovMnozhestvo = 'Маршруты';

// >>> ИЗМЕНЕНО (08.10, критерий 9). Два статуса маршрута в одном месте.
// Раньше слова были написаны в шести местах кода: если переименовать
// не везде, нажатие на маршрут перестаёт менять статус, а счётчики
// замирают на нуле без всякой ошибки. Теперь все места читают эти две
// постоянные величины по имени.
const String statusNovyy = 'запланирован'; // сохранил, ещё не ездил
const String statusGotov = 'пройден'; // доехал и отметил

// >>> ИЗМЕНЕНО. Способы передвижения и критерии «лучшего» маршрута.
const List<String> sposoby = ['Пешком', 'Автобус', 'Такси'];
const List<String> kriterii = ['Быстрее', 'Короче'];

void main() {
  runApp(const MoyoPrilozhenie());
}

class MoyoPrilozhenie extends StatelessWidget {
  const MoyoPrilozhenie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: nazvanieProekta,
      debugShowCheckedModeBanner: false,
      // >>> ИЗМЕНЕНО (критерий 2, единый дизайн). В новых версиях Flutter
      // primarySwatch почти не влияет на цвета, поэтому вся палитра
      // строится от одного цвета через colorSchemeSeed.
      theme: ThemeData(
        colorSchemeSeed: osnovnoyCvet,
        appBarTheme: const AppBarTheme(
          backgroundColor: osnovnoyCvet,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashEkran(),
    );
  }
}

// =====================================================================
// ХРАНИЛИЩЕ. Здесь живут пользователи, маршруты и карта города.
// Это и есть «состояние выше экранов», про которое говорили на паре:
// его читают и главная, и раздел маршрутов, и профиль.
// =====================================================================

class Polzovatel {
  final String imya;
  final String email;
  final String parol;
  // >>> ИЗМЕНЕНО (критерий 3). Место 3 из 4: поля в классе Polzovatel.
  // Вводятся текстом (контроллер + TextFormField + validator):
  // telefon — номер Казахстана, чтобы восстановить доступ и прислать маршрут;
  // vremyaVyezda — во сколько человек обычно выезжает: от времени
  //   зависят пробки, приложение предупреждает про час пик.
  final String telefon;
  final String vremyaVyezda;
  // Выбираются из списка (ошибиться нельзя):
  // sposob — как человек обычно передвигается (подставляется в поиск сам),
  // dom — откуда он обычно выезжает (точка А по умолчанию).
  final String sposob;
  final String dom;

  Polzovatel({
    required this.imya,
    required this.email,
    required this.parol,
    required this.telefon,
    required this.vremyaVyezda,
    required this.sposob,
    required this.dom,
  });
}

// >>> ИЗМЕНЕНО (критерий 9). Запись теперь хранит построенный маршрут.
class Zapis {
  final int id;
  String nazvanie; // «AITU → Байтерек» или своё, например «На пары»
  String opisanie; // >>> ИЗМЕНЕНО (08.10): комментарий из формы
  String status; // statusNovyy или statusGotov
  // >>> ИЗМЕНЕНО (08.10, критерий 9). СВОЁ ПОЛЕ ЗАПИСИ, место 1 из 4:
  // когда человек собирается ехать по этому маршруту.
  String kogda;
  final String cherez; // >>> ИЗМЕНЕНО (08.10): через какие точки идёт путь
  // >>> ИЗМЕНЕНО. Свои поля записи:
  final String sposob; // Пешком / Автобус / Такси
  final String kriteriy; // Быстрее / Короче
  final int minuty; // сколько минут в пути
  final double km; // длина пути в километрах
  final int stoimost; // сколько стоит, в тенге
  // >>> ИЗМЕНЕНО (06.10). Чей это маршрут: почта владельца.
  // Нужно, чтобы у каждого пользователя был свой список маршрутов.
  final String vladelec;

  Zapis({
    required this.id,
    required this.nazvanie,
    required this.opisanie,
    required this.kogda, // >>> своё поле, место 1: параметр конструктора
    required this.cherez,
    required this.sposob,
    required this.kriteriy,
    required this.minuty,
    required this.km,
    required this.stoimost,
    required this.vladelec,
    this.status = statusNovyy, // >>> ИЗМЕНЕНО (08.10): по имени
  });
}

// >>> ИЗМЕНЕНО. Точка на карте города (вершина графа).
class Tochka {
  final String nazvanie;
  final IconData ikonka;

  const Tochka(this.nazvanie, this.ikonka);
}

// >>> ИЗМЕНЕНО. Дорога между двумя точками (ребро графа).
// a и b — номера точек в списке Hranilishe.tochki.
// estAvtobus — ходит ли здесь автобус.
// probka — во сколько раз пробки замедляют транспорт (1.0 — пробок нет).
class Doroga {
  final int a;
  final int b;
  final double km;
  final bool estAvtobus;
  final double probka;

  const Doroga(this.a, this.b, this.km, this.estAvtobus, this.probka);
}

// >>> ИЗМЕНЕНО. Результат поиска: путь и его итоги.
class Rezultat {
  final List<int> put; // номера точек по порядку, от А до Б
  final double km;
  final int minuty;
  final int stoimost;

  Rezultat({
    required this.put,
    required this.km,
    required this.minuty,
    required this.stoimost,
  });
}

class Hranilishe {
  // Список зарегистрированных пользователей.
  static final List<Polzovatel> polzovateli = [];

  // Кто сейчас вошёл. Пусто, значит никто не вошёл.
  static Polzovatel? tekushiy;

  // Сохранённые маршруты.
  static final List<Zapis> zapisi = [];
  static int _sleduyushiyId = 1;

  // -------------------------------------------------------------------
  // >>> ИЗМЕНЕНО. Карта Астаны: 12 точек и дороги между ними.
  // Расстояния приблизительные, это упрощённая модель города.
  // -------------------------------------------------------------------
  static const List<Tochka> tochki = [
    Tochka('AITU (EXPO)', Icons.school), // 0
    Tochka('EXPO, Нур Алем', Icons.public), // 1
    Tochka('ТРЦ Mega Silk Way', Icons.shopping_bag), // 2
    Tochka('Вокзал Нурлы Жол', Icons.train), // 3
    Tochka('Хан Шатыр', Icons.store), // 4
    Tochka('ЕНУ им. Гумилёва', Icons.account_balance), // 5
    Tochka('Байтерек', Icons.location_city), // 6
    Tochka('Мечеть Хазрет Султан', Icons.place), // 7
    Tochka('Дворец Мира и Согласия', Icons.change_history), // 8
    Tochka('Вокзал Астана-1', Icons.train), // 9
    Tochka('Аэропорт', Icons.flight), // 10
    Tochka('Центральный парк', Icons.park), // 11
  ];

  static const List<Doroga> dorogi = [
    Doroga(0, 1, 0.7, true, 1.0),
    Doroga(0, 2, 1.0, true, 1.2),
    Doroga(1, 2, 0.8, false, 1.0), // пешеходная дорожка через площадь
    Doroga(1, 3, 3.0, true, 1.3),
    Doroga(2, 4, 3.2, true, 2.2), // коротко, но в час пик сильные пробки
    Doroga(2, 5, 4.6, true, 1.0), // в обход центра: длиннее, зато без пробок
    Doroga(3, 4, 4.5, true, 1.8), // проспект с сильными пробками
    Doroga(4, 5, 2.2, true, 1.4),
    Doroga(4, 6, 1.9, true, 1.7),
    Doroga(5, 6, 1.6, true, 1.3),
    Doroga(6, 11, 2.6, true, 1.2),
    Doroga(11, 7, 1.8, true, 1.1),
    Doroga(6, 7, 3.4, true, 1.6),
    Doroga(7, 8, 0.9, false, 1.0), // к Пирамиде автобус не подъезжает
    Doroga(5, 9, 5.5, true, 1.5),
    Doroga(11, 9, 4.8, true, 1.3),
    Doroga(3, 10, 13.0, true, 1.1),
    Doroga(1, 10, 14.5, true, 1.0),
    Doroga(3, 7, 8.5, true, 1.2),
  ];

  static List<String> get nazvaniyaTochek =>
      tochki.map((t) => t.nazvanie).toList();

  static bool emailZanyat(String email) {
    for (var p in polzovateli) {
      if (p.email.toLowerCase() == email.toLowerCase()) return true;
    }
    return false;
  }

  static void zaregistrirovat(Polzovatel p) {
    polzovateli.add(p);
  }

  static Polzovatel? nayti(String email, String parol) {
    for (var p in polzovateli) {
      if (p.email.toLowerCase() == email.toLowerCase() && p.parol == parol) {
        return p;
      }
    }
    return null;
  }

  // >>> ИЗМЕНЕНО (06.10, критерий 4). Поиск ТОЛЬКО по почте.
  // Нужен, чтобы при входе отличить «такого пользователя нет»
  // от «пользователь есть, но пароль не тот».
  static Polzovatel? naytiPoPochte(String email) {
    for (var p in polzovateli) {
      if (p.email.toLowerCase() == email.toLowerCase()) {
        return p;
      }
    }
    return null;
  }

  static void vyyti() {
    tekushiy = null;
  }

  // >>> ИЗМЕНЕНО. Сохраняем найденный маршрут вместе с итогами.
  // >>> ИЗМЕНЕНО (08.10). Название, комментарий и своё поле kogda
  // приходят из формы сохранения. Своё поле, место 2 из 4.
  static void dobavitZapis(String nazvanie, String opisanie, String kogda,
      String sposob, String kriteriy, Rezultat r) {
    zapisi.add(Zapis(
      id: _sleduyushiyId,
      nazvanie: nazvanie,
      opisanie: opisanie,
      kogda: kogda, // >>> своё поле, место 2: передача значения
      cherez: r.put.map((i) => tochki[i].nazvanie).join(' → '),
      sposob: sposob,
      kriteriy: kriteriy,
      minuty: r.minuty,
      km: r.km,
      stoimost: r.stoimost,
      vladelec: tekushiy?.email ?? '', // >>> ИЗМЕНЕНО (06.10)
    ));
    _sleduyushiyId = _sleduyushiyId + 1;
  }

  // >>> ИЗМЕНЕНО (06.10). Только маршруты того, кто сейчас вошёл.
  // Главная, раздел «Маршруты» и профиль берут список отсюда.
  static List<Zapis> moiZapisi() {
    final email = tekushiy?.email ?? '';
    return zapisi.where((z) => z.vladelec == email).toList();
  }

  static void udalitZapis(int id) {
    zapisi.removeWhere((z) => z.id == id);
  }

  static void pomenyatStatus(int id) {
    for (var z in zapisi) {
      if (z.id == id) {
        // >>> ИЗМЕНЕНО (08.10): статусы по имени, а не текстом
        z.status = (z.status == statusNovyy) ? statusGotov : statusNovyy;
      }
    }
  }

  // >>> ИЗМЕНЕНО (05.10). Попадает ли время «ЧЧ:ММ» в час пик.
  // Утром с 7:30 до 9:30 и вечером с 17:30 до 19:30.
  static bool chasPik(String vremya) {
    final chasti = vremya.split(':');
    final minuty = int.parse(chasti[0]) * 60 + int.parse(chasti[1]);
    final utrom = minuty >= 7 * 60 + 30 && minuty <= 9 * 60 + 30;
    final vecherom = minuty >= 17 * 60 + 30 && minuty <= 19 * 60 + 30;
    return utrom || vecherom;
  }

  // >>> ИЗМЕНЕНО. Сколько километров человек уже прошёл или проехал.
  static double proydenoKm() {
    double summa = 0;
    for (var z in moiZapisi()) { // >>> ИЗМЕНЕНО (06.10): только свои
      if (z.status == statusGotov) summa = summa + z.km; // >>> 08.10
    }
    return summa;
  }

  // -------------------------------------------------------------------
  // >>> ИЗМЕНЕНО. Время на одной дороге, в минутах.
  // Пешеход идёт 5 км/ч, пробки ему не мешают.
  // Автобус едет 20 км/ч, такси 35 км/ч, и обоих замедляют пробки.
  // -------------------------------------------------------------------
  static double minutyNaDoroge(Doroga d, String sposob) {
    if (sposob == 'Пешком') return d.km / 5 * 60;
    if (sposob == 'Автобус') return d.km / 20 * 60 * d.probka;
    return d.km / 35 * 60 * d.probka; // Такси
  }

  // -------------------------------------------------------------------
  // >>> ИЗМЕНЕНО. ГЛАВНАЯ ФУНКЦИЯ ПРИЛОЖЕНИЯ. Поиск лучшего маршрута.
  // Алгоритм Дейкстры: от точки А шаг за шагом расходимся к соседям
  // и для каждой точки запоминаем самый дешёвый путь до неё.
  // «Дешёвый» зависит от критерия: Быстрее — минуты, Короче — километры.
  // Возвращает null, если выбранным способом до точки Б не добраться.
  // -------------------------------------------------------------------
  static Rezultat? naytiMarshrut(
      int otkuda, int kuda, String sposob, String kriteriy) {
    final n = tochki.length;
    final ves = List<double>.filled(n, double.infinity);
    final otkudaPrishli = List<int>.filled(n, -1);
    final gotovo = List<bool>.filled(n, false);
    ves[otkuda] = 0;

    for (var shag = 0; shag < n; shag++) {
      // 1. Берём ещё не обработанную точку с самым маленьким весом.
      var u = -1;
      for (var i = 0; i < n; i++) {
        if (!gotovo[i] && (u == -1 || ves[i] < ves[u])) u = i;
      }
      if (u == -1 || ves[u] == double.infinity) break;
      if (u == kuda) break; // до точки Б лучший путь уже найден
      gotovo[u] = true;

      // 2. Пробуем улучшить путь до каждого соседа через точку u.
      for (var d in dorogi) {
        int sosed;
        if (d.a == u) {
          sosed = d.b;
        } else if (d.b == u) {
          sosed = d.a;
        } else {
          continue; // эта дорога не выходит из точки u
        }
        if (gotovo[sosed]) continue;
        if (sposob == 'Автобус' && !d.estAvtobus) continue;

        final cena = (kriteriy == 'Быстрее') ? minutyNaDoroge(d, sposob) : d.km;
        if (ves[u] + cena < ves[sosed]) {
          ves[sosed] = ves[u] + cena;
          otkudaPrishli[sosed] = u;
        }
      }
    }

    if (ves[kuda] == double.infinity) return null;

    // 3. Восстанавливаем путь с конца: от Б идём назад до А.
    final put = <int>[];
    var tek = kuda;
    while (tek != -1) {
      put.insert(0, tek);
      tek = otkudaPrishli[tek];
    }

    // 4. Считаем итоги по найденному пути.
    double km = 0;
    double minuty = 0;
    for (var i = 0; i < put.length - 1; i++) {
      final d = _dorogaMezhdu(put[i], put[i + 1]);
      km = km + d.km;
      minuty = minuty + minutyNaDoroge(d, sposob);
    }
    if (sposob == 'Автобус') minuty = minuty + 8; // ожидание на остановке
    if (sposob == 'Такси') minuty = minuty + 5; // подача машины

    // Тарифы условные, для примера.
    int stoimost = 0;
    if (sposob == 'Автобус') stoimost = 100;
    if (sposob == 'Такси') stoimost = 600 + (km * 130).round();

    return Rezultat(
      put: put,
      km: km,
      minuty: minuty.round(),
      stoimost: stoimost,
    );
  }

  static Doroga _dorogaMezhdu(int a, int b) {
    return dorogi.firstWhere(
        (d) => (d.a == a && d.b == b) || (d.a == b && d.b == a));
  }
}

// >>> ИЗМЕНЕНО. Значок для способа передвижения, используется на нескольких экранах.
IconData ikonkaSposoba(String sposob) {
  if (sposob == 'Пешком') return Icons.directions_walk;
  if (sposob == 'Автобус') return Icons.directions_bus;
  return Icons.local_taxi;
}

// >>> ИЗМЕНЕНО. Выпадающий список с подписью. Нужен на регистрации и в поиске.
// Список сам защищает от неверного ввода: выбрать можно только то, что в нём есть.
class VypadayushiySpisok extends StatelessWidget {
  final String podpis;
  final String znachenie;
  final List<String> varianty;
  final ValueChanged<String> priVybore;

  const VypadayushiySpisok({
    Key? key,
    required this.podpis,
    required this.znachenie,
    required this.varianty,
    required this.priVybore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: podpis,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: znachenie,
          isExpanded: true,
          items: varianty
              .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) {
            if (v != null) priVybore(v);
          },
        ),
      ),
    );
  }
}

// =====================================================================
// ЭКРАН 1. SPLASH, экран запуска. Критерий 2, пять баллов.
// =====================================================================

class SplashEkran extends StatefulWidget {
  const SplashEkran({Key? key}) : super(key: key);

  @override
  State<SplashEkran> createState() => _SplashEkranState();
}

class _SplashEkranState extends State<SplashEkran> {
  @override
  void initState() {
    super.initState();
    // Через две секунды уходим на экран входа.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VhodEkran()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: osnovnoyCvet,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // >>> ИЗМЕНЕНО. Значок «развилка дорог» вместо стандартного.
            const Icon(Icons.alt_route, size: 96, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              nazvanieProekta,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              podzagolovok,
              style: TextStyle(fontSize: 15, color: Colors.white70),
            ),
            // >>> ИЗМЕНЕНО. Город, по которому строятся маршруты.
            const SizedBox(height: 32),
            const Text(
              'Астана',
              style: TextStyle(fontSize: 13, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ЭКРАН 2. ВХОД. Критерий 4, десять баллов.
// =====================================================================

class VhodEkran extends StatefulWidget {
  const VhodEkran({Key? key}) : super(key: key);

  @override
  State<VhodEkran> createState() => _VhodEkranState();
}

class _VhodEkranState extends State<VhodEkran> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _parolController = TextEditingController();
  String _oshibka = '';

  @override
  void dispose() {
    _emailController.dispose();
    _parolController.dispose();
    super.dispose();
  }

  void _voyti() {
    setState(() {
      _oshibka = '';
    });

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    // >>> ИЗМЕНЕНО (06.10, критерий 4). Две проверки подряд.
    // Проверка первая: есть ли вообще пользователь с такой почтой.
    final naydennyy = Hranilishe.naytiPoPochte(email);

    if (naydennyy == null) {
      setState(() {
        _oshibka = 'Пользователь с такой почтой не зарегистрирован';
      });
      return;
    }

    // Проверка вторая: совпадает ли пароль.
    if (naydennyy.parol != _parolController.text) {
      setState(() {
        _oshibka = 'Неверный пароль';
      });
      return;
    }

    // Обе проверки пройдены. Запоминаем, кто вошёл (критерий 5):
    // это одно место, из которого все экраны берут данные пользователя.
    Hranilishe.tekushiy = naydennyy;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GlavnyyEkran()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // >>> ИЗМЕНЕНО (критерий 4). Оформление под тему маршрутов.
              const SizedBox(height: 8),
              const Icon(Icons.alt_route, size: 64, color: osnovnoyCvet),
              const SizedBox(height: 8),
              Text(
                nazvanieProekta,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Войдите, чтобы строить маршруты по Астане',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Почта',
                  hintText: 'например, student@mail.kz',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie == null || znachenie.trim().isEmpty) {
                    return 'Введите почту';
                  }
                  if (!znachenie.contains('@')) {
                    return 'В почте должен быть знак @';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parolController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie == null || znachenie.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
              ),
              if (_oshibka.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _oshibka,
                  style: const TextStyle(color: Colors.red, fontSize: 15),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _voyti,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Войти'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistraciyaEkran()),
                  );
                },
                child: const Text('Нет аккаунта? Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ЭКРАН 3. РЕГИСТРАЦИЯ. Критерий 3, десять баллов.
// =====================================================================

class RegistraciyaEkran extends StatefulWidget {
  const RegistraciyaEkran({Key? key}) : super(key: key);

  @override
  State<RegistraciyaEkran> createState() => _RegistraciyaEkranState();
}

class _RegistraciyaEkranState extends State<RegistraciyaEkran> {
  final _formKey = GlobalKey<FormState>();
  final _imyaController = TextEditingController();
  final _emailController = TextEditingController();
  final _parolController = TextEditingController();
  final _parol2Controller = TextEditingController();
  // >>> ИЗМЕНЕНО (критерий 3). Место 1 из 4: по контроллеру на своё поле.
  final _telefonController = TextEditingController();
  final _vremyaController = TextEditingController();
  String _oshibka = '';

  // >>> ИЗМЕНЕНО (критерий 3). Выбор в своих полях. Значения по умолчанию
  // стоят сразу, поэтому оставить эти поля пустыми невозможно.
  String _sposob = 'Автобус';
  String _dom = Hranilishe.tochki[0].nazvanie;

  @override
  void dispose() {
    _imyaController.dispose();
    _emailController.dispose();
    _parolController.dispose();
    _parol2Controller.dispose();
    _telefonController.dispose();
    _vremyaController.dispose();
    super.dispose();
  }

  void _zaregistrirovatsya() {
    setState(() {
      _oshibka = '';
    });

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    if (Hranilishe.emailZanyat(email)) {
      setState(() {
        _oshibka = 'Такая почта уже зарегистрирована';
      });
      return;
    }

    Hranilishe.zaregistrirovat(Polzovatel(
      imya: _imyaController.text.trim(),
      email: email,
      parol: _parolController.text,
      // >>> ИЗМЕНЕНО. Место 4 из 4: передаём свои поля при сохранении.
      telefon: _telefonController.text.trim().replaceAll(' ', ''),
      vremyaVyezda: _vremyaController.text.trim(),
      sposob: _sposob,
      dom: _dom,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Регистрация прошла успешно. Войдите.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _imyaController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie == null || znachenie.trim().isEmpty) {
                    return 'Введите имя';
                  }
                  if (znachenie.trim().length < 2) {
                    return 'Имя слишком короткое';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Почта',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie == null || znachenie.trim().isEmpty) {
                    return 'Введите почту';
                  }
                  if (!znachenie.contains('@') || !znachenie.contains('.')) {
                    return 'Почта введена неверно';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // >>> ИЗМЕНЕНО (критерий 3). Место 2 из 4: поле ввода с проверкой.
              // Телефон проверяется ПО ВИДУ: номер Казахстана,
              // 8 или +7, затем 7 и ещё 9 цифр. Пробелы можно.
              TextFormField(
                controller: _telefonController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  hintText: '87001234567',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie == null || znachenie.trim().isEmpty) {
                    return 'Введите телефон';
                  }
                  final tekst = znachenie.trim().replaceAll(' ', '');
                  if (!RegExp(r'^(\+7|8)7[0-9]{9}$').hasMatch(tekst)) {
                    return 'Номер Казахстана: 87001234567 или +77001234567';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // >>> ИЗМЕНЕНО (критерий 3). Своё поле: как обычно передвигаюсь.
              // Потом оно само подставляется в поиск маршрута.
              VypadayushiySpisok(
                podpis: 'Как вы обычно передвигаетесь',
                znachenie: _sposob,
                varianty: sposoby,
                priVybore: (v) => setState(() => _sposob = v),
              ),
              const SizedBox(height: 16),
              // >>> ИЗМЕНЕНО (критерий 3). Своё поле: откуда обычно выезжаю.
              // Становится точкой А по умолчанию.
              VypadayushiySpisok(
                podpis: 'Откуда вы обычно выезжаете',
                znachenie: _dom,
                varianty: Hranilishe.nazvaniyaTochek,
                priVybore: (v) => setState(() => _dom = v),
              ),
              const SizedBox(height: 16),
              // >>> ИЗМЕНЕНО (критерий 3). Место 2 из 4: время выезда.
              // Проверка ПО ВИДУ: ЧЧ:ММ, часы 00–23, минуты 00–59.
              TextFormField(
                controller: _vremyaController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Во сколько вы обычно выезжаете',
                  hintText: '08:15',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie == null || znachenie.trim().isEmpty) {
                    return 'Введите время выезда';
                  }
                  if (!RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$')
                      .hasMatch(znachenie.trim())) {
                    return 'Время в формате ЧЧ:ММ, например 08:15';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parolController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie == null || znachenie.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (znachenie.length < 6) {
                    return 'Пароль не короче шести символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parol2Controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Повторите пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (znachenie) {
                  if (znachenie != _parolController.text) {
                    return 'Пароли не совпадают';
                  }
                  return null;
                },
              ),
              if (_oshibka.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _oshibka,
                  style: const TextStyle(color: Colors.red, fontSize: 15),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _zaregistrirovatsya,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Зарегистрироваться'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ЭКРАН 4. ГЛАВНЫЙ, с нижней навигацией.
// Критерии 6 и 7, десять плюс пять баллов.
// =====================================================================

class GlavnyyEkran extends StatefulWidget {
  const GlavnyyEkran({Key? key}) : super(key: key);

  @override
  State<GlavnyyEkran> createState() => _GlavnyyEkranState();
}

class _GlavnyyEkranState extends State<GlavnyyEkran> {
  int _vybrannyy = 0;

  @override
  Widget build(BuildContext context) {
    final stranicy = [
      const GlavnayaStranica(),
      const OsnovnoyRazdel(),
      const ProfilStranica(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(nazvanieProekta)),
      body: stranicy[_vybrannyy],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _vybrannyy,
        type: BottomNavigationBarType.fixed,
        onTap: (indeks) {
          setState(() {
            _vybrannyy = indeks;
          });
        },
        // >>> ИЗМЕНЕНО (07.10, критерий 7). Названия и значки разделов
        // под тему. У выбранного раздела значок залитый (activeIcon),
        // у остальных контурный.
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me_outlined),
            activeIcon: Icon(Icons.near_me),
            label: 'В путь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_outlined),
            activeIcon: Icon(Icons.directions),
            label: imyaObyektovMnozhestvo,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Мой профиль',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Вкладка «Главная». Критерий 6.
// >>> ИЗМЕНЕНО. Стала StatefulWidget: после построения маршрута
// счётчики на главной надо перерисовать.
// ---------------------------------------------------------------------

class GlavnayaStranica extends StatefulWidget {
  const GlavnayaStranica({Key? key}) : super(key: key);

  @override
  State<GlavnayaStranica> createState() => _GlavnayaStranicaState();
}

class _GlavnayaStranicaState extends State<GlavnayaStranica> {
  Future<void> _postroit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NovyyMarshrutEkran()),
    );
    setState(() {}); // вернулись, перерисовываем счётчики
  }

  @override
  Widget build(BuildContext context) {
    final polzovatel = Hranilishe.tekushiy;
    final imya = polzovatel?.imya ?? 'гость';
    final moi = Hranilishe.moiZapisi(); // >>> ИЗМЕНЕНО (06.10)
    final vsego = moi.length;
    final proydeno =
        moi.where((z) => z.status == statusGotov).length; // >>> 08.10
    // >>> ИЗМЕНЕНО (07.10, критерий 6). Третий показатель тоже считается
    // из данных: сохранённые, но ещё не пройденные маршруты.
    final vPlanah = vsego - proydeno;
    final posledniy =
        moi.isEmpty ? null : moi.last;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Здравствуйте, $imya',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // >>> ИЗМЕНЕНО (07.10). Фраза о том, что конкретно делает человек.
        const Text(
          'Выберите, откуда и куда едете по Астане, и ЖолТап построит самый '
          'быстрый или самый короткий путь: пешком, на автобусе или на такси.',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        // >>> ИЗМЕНЕНО (критерий 6). Главная кнопка: переход к основной функции.
        ElevatedButton.icon(
          onPressed: _postroit,
          icon: const Icon(Icons.search),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Построить маршрут', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
        // >>> ИЗМЕНЕНО (07.10, критерий 6). Три показателя, все считаются
        // из Hranilishe.moiZapisi() при каждой отрисовке главной.
        Row(
          children: [
            Expanded(
                child: _Plitka(zagolovok: 'Маршрутов', znachenie: '$vsego')),
            const SizedBox(width: 12),
            Expanded(
                child: _Plitka(zagolovok: 'В планах', znachenie: '$vPlanah')),
            const SizedBox(width: 12),
            Expanded(
                child: _Plitka(zagolovok: 'Пройдено', znachenie: '$proydeno')),
          ],
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Пройдено километров'),
            trailing: Text(
              Hranilishe.proydenoKm().toStringAsFixed(1),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // >>> ИЗМЕНЕНО (05.10). Подсказка по времени выезда из регистрации.
        if (polzovatel != null)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.schedule,
                color: Hranilishe.chasPik(polzovatel.vremyaVyezda)
                    ? Colors.deepOrange
                    : osnovnoyCvet,
              ),
              title: Text('Обычно выезжаете в ${polzovatel.vremyaVyezda}'),
              subtitle: Text(Hranilishe.chasPik(polzovatel.vremyaVyezda)
                  ? 'Это час пик: на автобусе и такси закладывайте запас времени'
                  : 'Вне часа пик: дороги обычно свободнее'),
            ),
          ),
        // >>> ИЗМЕНЕНО. Последний построенный маршрут, если он есть.
        if (posledniy != null)
          Card(
            child: ListTile(
              leading: Icon(ikonkaSposoba(posledniy.sposob)),
              title: Text('Последний: ${posledniy.nazvanie}'),
              subtitle: Text(
                  '${posledniy.minuty} мин · ${posledniy.km.toStringAsFixed(1)} км'),
            ),
          ),
        const SizedBox(height: 8),
        // >>> ИЗМЕНЕНО (07.10). Подсказка о конкретном следующем действии.
        // Пока маршрутов нет — как построить первый; потом — как отметить.
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(vsego == 0 ? 'С чего начать' : 'Что дальше'),
            subtitle: Text(vsego == 0
                ? 'Нажмите «Построить маршрут». Точка А уже стоит: '
                    '«${polzovatel?.dom ?? "AITU (EXPO)"}», выберите, куда едете, '
                    'и нажмите «Найти лучший маршрут».'
                : 'Когда доедете, откройте раздел «$imyaObyektovMnozhestvo» '
                    'внизу и нажмите на маршрут: он станет пройденным, '
                    'а показатели выше обновятся.'),
          ),
        ),
      ],
    );
  }
}

class _Plitka extends StatelessWidget {
  final String zagolovok;
  final String znachenie;

  const _Plitka({required this.zagolovok, required this.znachenie});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              znachenie,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(zagolovok, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ЭКРАН 5. ОСНОВНОЙ РАЗДЕЛ. Критерий 9, десять баллов.
// >>> ИЗМЕНЕНО. Список сохранённых маршрутов.
// =====================================================================

class OsnovnoyRazdel extends StatefulWidget {
  const OsnovnoyRazdel({Key? key}) : super(key: key);

  @override
  State<OsnovnoyRazdel> createState() => _OsnovnoyRazdelState();
}

class _OsnovnoyRazdelState extends State<OsnovnoyRazdel> {
  // >>> ИЗМЕНЕНО. Вместо диалога открывается отдельный экран поиска.
  Future<void> _otkrytPoisk() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NovyyMarshrutEkran()),
    );
    setState(() {}); // вернулись, перерисовываем список
  }

  @override
  Widget build(BuildContext context) {
    final zapisi = Hranilishe.moiZapisi(); // >>> ИЗМЕНЕНО (06.10): только свои

    return Scaffold(
      body: zapisi.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // >>> ИЗМЕНЕНО (08.10, критерий 9). Пустое состояние под тему:
                  // значок дороги и подсказка, что именно сделать.
                  const Icon(Icons.route, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Сохранённых маршрутов пока нет',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Нажмите плюс, выберите, откуда и куда едете, '
                      'и сохраните лучший путь. Например: AITU → Байтерек '
                      'на автобусе.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: zapisi.length,
              itemBuilder: (context, indeks) {
                final zapis = zapisi[indeks];
                final proyden = zapis.status == statusGotov; // >>> 08.10
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      proyden ? Icons.check_circle : ikonkaSposoba(zapis.sposob),
                      color: proyden ? Colors.green : osnovnoyCvet,
                    ),
                    title: Text(zapis.nazvanie),
                    // >>> ИЗМЕНЕНО. В карточке видны свои поля записи.
                    // >>> ИЗМЕНЕНО (08.10). Первая строка: своё поле kogda
                    // (место 4 из 4) и статус. Последняя: комментарий.
                    subtitle: Text(
                      'Когда: ${zapis.kogda} · ${zapis.status}\n'
                      '${zapis.minuty} мин · ${zapis.km.toStringAsFixed(1)} км · '
                      '${zapis.stoimost} ₸ · ${zapis.sposob}, ${zapis.kriteriy.toLowerCase()}\n'
                      'Через: ${zapis.cherez}'
                      '${zapis.opisanie.isEmpty ? '' : '\n${zapis.opisanie}'}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          Hranilishe.udalitZapis(zapis.id);
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        Hranilishe.pomenyatStatus(zapis.id);
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _otkrytPoisk,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =====================================================================
// >>> ИЗМЕНЕНО. ЭКРАН 5а. ПОИСК ЛУЧШЕГО МАРШРУТА. Критерий 9.
// Человек выбирает А, Б, способ и критерий, нажимает «Найти»,
// видит путь по шагам, время, расстояние, цену и сравнение способов.
// =====================================================================

class NovyyMarshrutEkran extends StatefulWidget {
  const NovyyMarshrutEkran({Key? key}) : super(key: key);

  @override
  State<NovyyMarshrutEkran> createState() => _NovyyMarshrutEkranState();
}

class _NovyyMarshrutEkranState extends State<NovyyMarshrutEkran> {
  late String _otkuda;
  late String _kuda;
  late String _sposob;
  String _kriteriy = 'Быстрее';
  Rezultat? _rezultat;
  String _oshibka = '';

  @override
  void initState() {
    super.initState();
    // Подставляем то, что человек указал при регистрации.
    final p = Hranilishe.tekushiy;
    _otkuda = p?.dom ?? Hranilishe.tochki[0].nazvanie;
    _sposob = p?.sposob ?? 'Автобус';
    _kuda = (_otkuda == 'Байтерек') ? Hranilishe.tochki[0].nazvanie : 'Байтерек';
  }

  int _nomer(String nazvanie) => Hranilishe.nazvaniyaTochek.indexOf(nazvanie);

  // Любое изменение условий сбрасывает старый результат.
  void _sbrosit() {
    _rezultat = null;
    _oshibka = '';
  }

  void _nayti() {
    setState(() {
      _sbrosit();
      if (_otkuda == _kuda) {
        _oshibka = 'Точки А и Б совпадают. Выберите разные места.';
        return;
      }
      final r = Hranilishe.naytiMarshrut(
          _nomer(_otkuda), _nomer(_kuda), _sposob, _kriteriy);
      if (r == null) {
        _oshibka = 'Способом «$_sposob» сюда не добраться. '
            'Посмотрите другие способы ниже.';
      } else {
        _rezultat = r;
      }
    });
  }

  // >>> ИЗМЕНЕНО (08.10, критерий 9). ФОРМА СОХРАНЕНИЯ МАРШРУТА.
  // Три поля: название, комментарий и своё поле «Когда еду».
  // Своё поле, место 3 из 4: контроллер kogdaController и TextField.
  // Пустое название или пустое «Когда еду» — сообщение под полем,
  // маршрут не сохраняется.
  void _otkrytFormu() {
    final nazvanieController =
        TextEditingController(text: '$_otkuda → $_kuda');
    final opisanieController = TextEditingController();
    final kogdaController = TextEditingController(); // >>> своё поле
    final p = Hranilishe.tekushiy;
    String oshibkaNazvaniya = '';
    String oshibkaKogda = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: Text('Сохранить ${imyaObyekta.toLowerCase()}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nazvanieController,
                      decoration: InputDecoration(
                        labelText: 'Название маршрута',
                        hintText: 'например, На пары',
                        errorText:
                            oshibkaNazvaniya.isEmpty ? null : oshibkaNazvaniya,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: opisanieController,
                      decoration: const InputDecoration(
                        labelText: 'Комментарий',
                        hintText: 'например, взять зонт',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // >>> своё поле, место 3: TextField
                    TextField(
                      controller: kogdaController,
                      decoration: InputDecoration(
                        labelText: 'Когда еду',
                        hintText: 'например, пн 08:15',
                        helperText: p == null
                            ? null
                            : 'Обычно вы выезжаете в ${p.vremyaVyezda}',
                        errorText: oshibkaKogda.isEmpty ? null : oshibkaKogda,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nazvanie = nazvanieController.text.trim();
                    final kogda = kogdaController.text.trim();
                    setStateDialog(() {
                      oshibkaNazvaniya =
                          nazvanie.isEmpty ? 'Название не может быть пустым' : '';
                      oshibkaKogda =
                          kogda.isEmpty ? 'Укажите, когда вы едете' : '';
                    });
                    if (nazvanie.isEmpty || kogda.isEmpty) return;
                    Hranilishe.dobavitZapis(
                      nazvanie,
                      opisanieController.text.trim(),
                      kogda,
                      _sposob,
                      _kriteriy,
                      _rezultat!,
                    );
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Маршрут сохранён')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // >>> ИЗМЕНЕНО. Заголовок берётся из константы imyaObyekta.
      appBar: AppBar(title: Text('Новый ${imyaObyekta.toLowerCase()}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          VypadayushiySpisok(
            podpis: 'Откуда (точка А)',
            znachenie: _otkuda,
            varianty: Hranilishe.nazvaniyaTochek,
            priVybore: (v) => setState(() {
              _otkuda = v;
              _sbrosit();
            }),
          ),
          // Кнопка «поменять местами А и Б».
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Поменять А и Б местами',
              icon: const Icon(Icons.swap_vert),
              onPressed: () => setState(() {
                final t = _otkuda;
                _otkuda = _kuda;
                _kuda = t;
                _sbrosit();
              }),
            ),
          ),
          VypadayushiySpisok(
            podpis: 'Куда (точка Б)',
            znachenie: _kuda,
            varianty: Hranilishe.nazvaniyaTochek,
            priVybore: (v) => setState(() {
              _kuda = v;
              _sbrosit();
            }),
          ),
          const SizedBox(height: 16),
          VypadayushiySpisok(
            podpis: 'Способ',
            znachenie: _sposob,
            varianty: sposoby,
            priVybore: (v) => setState(() {
              _sposob = v;
              _sbrosit();
            }),
          ),
          const SizedBox(height: 16),
          VypadayushiySpisok(
            podpis: 'Что важнее',
            znachenie: _kriteriy,
            varianty: kriterii,
            priVybore: (v) => setState(() {
              _kriteriy = v;
              _sbrosit();
            }),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _nayti,
            icon: const Icon(Icons.search),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Найти лучший маршрут'),
            ),
          ),
          if (_oshibka.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _oshibka,
              style: const TextStyle(color: Colors.red, fontSize: 15),
            ),
            // Если выбранным способом не доехать, сразу показываем другие.
            if (_otkuda != _kuda) ...[
              const SizedBox(height: 12),
              _sravnenie(),
            ],
          ],
          if (_rezultat != null) ..._pokazatRezultat(_rezultat!),
        ],
      ),
    );
  }

  // Карточка с результатом поиска.
  List<Widget> _pokazatRezultat(Rezultat r) {
    final shagi = <Widget>[];
    for (var i = 0; i < r.put.length; i++) {
      final t = Hranilishe.tochki[r.put[i]];
      String metka = '';
      if (i == 0) metka = 'А  ';
      if (i == r.put.length - 1) metka = 'Б  ';
      shagi.add(ListTile(
        dense: true,
        leading: Icon(t.ikonka, color: osnovnoyCvet),
        title: Text('$metka${t.nazvanie}'),
      ));
    }

    return [
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(ikonkaSposoba(_sposob), color: osnovnoyCvet),
                  const SizedBox(width: 8),
                  Text(
                    '${r.minuty} мин',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${r.km.toStringAsFixed(1)} км · ${r.stoimost} ₸ · '
                'промежуточных точек: ${r.put.length - 2}',
                style: const TextStyle(color: Colors.black54),
              ),
              if (_sposob == 'Пешком' && r.minuty > 60)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Пешком это больше часа. Возможно, лучше автобус.',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
              const Divider(height: 24),
              ...shagi,
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      _sravnenie(),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: _otkrytFormu, // >>> ИЗМЕНЕНО (08.10): сначала форма
        icon: const Icon(Icons.bookmark_add_outlined),
        label: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Сохранить в мои маршруты'),
        ),
      ),
    ];
  }

  // Сравнение всех способов для тех же А и Б: помогает выбрать лучший.
  Widget _sravnenie() {
    final stroki = <Widget>[];
    for (var s in sposoby) {
      final r = Hranilishe.naytiMarshrut(
          _nomer(_otkuda), _nomer(_kuda), s, _kriteriy);
      stroki.add(ListTile(
        dense: true,
        leading: Icon(ikonkaSposoba(s)),
        title: Text(s),
        trailing: Text(r == null
            ? 'не доехать'
            : '${r.minuty} мин · ${r.stoimost} ₸'),
      ));
    }
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text('Сравнение способов',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...stroki,
        ],
      ),
    );
  }
}

// =====================================================================
// ЭКРАН 6. ПРОФИЛЬ И ВЫХОД. Критерии 8 и 10, пять плюс пять баллов.
// =====================================================================

class ProfilStranica extends StatelessWidget {
  const ProfilStranica({Key? key}) : super(key: key);

  void _vyyti(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Выход'),
          // >>> ИЗМЕНЕНО (08.10, критерий 10). Свой текст и кнопка «Остаться».
          content: const Text(
            'Выйти из аккаунта? Сохранённые маршруты не пропадут: '
            'они снова появятся, когда вы войдёте.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Остаться'),
            ),
            ElevatedButton(
              onPressed: () {
                // 1) забываем, кто вошёл; 2) закрываем окно подтверждения;
                // 3) открываем вход и убираем ВСЕ прошлые экраны:
                // (route) => false не оставляет ни одного, «назад» некуда.
                Hranilishe.vyyti();
                Navigator.pop(dialogContext);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const VhodEkran()),
                  (route) => false,
                );
              },
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final polzovatel = Hranilishe.tekushiy;

    if (polzovatel == null) {
      return const Center(child: Text('Вы не вошли в систему'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        CircleAvatar(
          radius: 44,
          backgroundColor: osnovnoyCvet,
          child: Text(
            polzovatel.imya.isNotEmpty
                ? polzovatel.imya[0].toUpperCase()
                : '?',
            style: const TextStyle(fontSize: 38, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            polzovatel.imya,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Почта'),
            subtitle: Text(polzovatel.email),
          ),
        ),
        // >>> ИЗМЕНЕНО (критерий 8). Поля, заведённые при регистрации.
        Card(
          child: ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Телефон'),
            subtitle: Text(polzovatel.telefon),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Обычно выезжаю в'),
            subtitle: Text(polzovatel.vremyaVyezda +
                (Hranilishe.chasPik(polzovatel.vremyaVyezda)
                    ? ' (час пик)'
                    : '')),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(ikonkaSposoba(polzovatel.sposob)),
            title: const Text('Обычно передвигаюсь'),
            subtitle: Text(polzovatel.sposob),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Обычно выезжаю из'),
            subtitle: Text(polzovatel.dom),
          ),
        ),
        // >>> ИЗМЕНЕНО (07.10, критерий 8). Показатель работы, считается из данных.
        Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Пройдено маршрутов'),
            subtitle: Text(
              '${Hranilishe.moiZapisi().where((z) => z.status == statusGotov).length}'
              ' из ${Hranilishe.moiZapisi().length}',
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.alt_route),
            title: Text('Мои ${imyaObyektovMnozhestvo.toLowerCase()}'),
            subtitle: Text('Сохранено: ${Hranilishe.moiZapisi().length}, '
                'пройдено ${Hranilishe.proydenoKm().toStringAsFixed(1)} км'),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _vyyti(context),
          icon: const Icon(Icons.logout),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Выйти из аккаунта'),
          ),
        ),
      ],
    );
  }
}
