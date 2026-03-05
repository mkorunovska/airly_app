import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('mk')];

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return loc ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const _strings = <String, Map<String, String>>{
    'en': {
      'skip': 'Skip',
      'next': 'Next',
      'done': 'Done',
      'air_quality_notifications': 'Air Quality Notifications',
      'notif_desc':
          'We need your authorization to send you alerts and pollution reports',
      'allow': 'ALLOW',
      'decline': 'DECLINE',
      'find_city_title': "Let's find your city",
      'find_city_desc':
          "In order to do so we will need to use your phone's GPS",
      'locate_me': 'LOCATE ME',
      'my_location': 'My Location',
      'all': 'All',
      'map': 'Map',
      'insights': 'Insights',
      'summary_title': 'Weather Summary',
      'summary_subtitle': 'Next 24h overview',
      'temp': 'Temperature',
      'humidity': 'Humidity',
      'wind': 'Wind',
      'pm10': 'PM10',
      'pm25': 'PM2.5',
      'good_morning': 'Good Morning',
      'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening',
      'search_hint': 'Search',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'sunny': 'Sunny',
      'rainy': 'Rainy',
      'cloudy': 'Cloudy',
      'storm': 'Storm',
      'snow': 'Snow',
      'unknown': 'Unknown',
      'gps_not_ready': 'GPS not available yet. Open the app again after granting permission.',
        'weather_load_failed': 'Could not load weather data.',

        'air_good': 'Air quality is good',
        'air_moderate': 'Air quality is moderate',
        'air_high': 'Air pollution is high',
        'air_very_high': 'Air pollution is very high',

        'air_good_line1': '🌿 Great time for a walk or light workout outside.',
        'air_good_line2': '🪟 Open the windows for 10–15 minutes to refresh indoor air.',
        'air_good_line3': '😊 Fresh air supports mood, focus, and better sleep.',

        'air_mod_line1': '🚶‍♀️ Prefer parks/green areas instead of busy roads.',
        'air_mod_line2': '😷 If you feel irritation, shorten outdoor time.',
        'air_mod_line3': '💧 Drink water and take breaks indoors if needed.',

        'air_high_line1': '🏃‍♀️ Avoid running or intense exercise outdoors.',
        'air_high_line2': '😷 Wear an FFP2/N95 mask if you must stay outside longer.',
        'air_high_line3': '🪟 Keep windows closed near traffic; ventilate briefly later.',
        'air_high_line4': '🚿 Wash face/nose after coming inside.',

        'air_vhigh_line1': '🏠 Stay indoors as much as possible (kids/elderly especially).',
        'air_vhigh_line2': '🌀 Use an air purifier if you have one; keep windows closed.',
        'air_vhigh_line3': '😷 If you go outside: FFP2/N95 mask + short time.',
        'air_vhigh_line4': '🩺 If breathing issues occur, follow medical advice.',


    },
    'mk': {
      'skip': 'Прескокни',
      'next': 'Следно',
      'done': 'Готово',
      'air_quality_notifications': 'Известувања за квалитет на воздух',
      'notif_desc':
          'Потребна е дозвола за да ти праќаме аларми и извештаи за загадување',
      'allow': 'ДОЗВОЛИ',
      'decline': 'ОДБИЈ',
      'find_city_title': 'Да го пронајдеме твојот град',
      'find_city_desc':
          'За тоа ќе треба да го користиме GPS-от на телефонот',
      'locate_me': 'ЛОЦИРАЈ МЕ',
      'my_location': 'Моја локација',
      'all': 'Сите',
      'map': 'Мапа',
      'insights': 'Статистика',
      'summary_title': 'Временска анализа',
      'summary_subtitle': 'Преглед за следните 24ч',
      'temp': 'Температура',
      'humidity': 'Влажност',
      'wind': 'Ветер',
      'pm10': 'PM10',
      'pm25': 'PM2.5',
      'good_morning': 'Добро утро',
      'good_afternoon': 'Добар ден',
      'good_evening': 'Добро вечер',
      'search_hint': 'Пребарај',
      'monday': 'Понеделник',
      'tuesday': 'Вторник',
      'wednesday': 'Среда',
      'thursday': 'Четврток',
      'friday': 'Петок',
      'saturday': 'Сабота',
      'sunday': 'Недела',
      'sunny': 'Сончево',
      'rainy': 'Врнежливо',
      'cloudy': 'Облачно',
      'storm': 'Бура',
      'snow': 'Снег',
      'unknown': 'Непознато',
      'gps_not_ready': 'GPS не е подготвен. Отвори ја апликацијата повторно по дозвола.',
      'weather_load_failed': 'Не може да се вчитаат податоци за времето.',

      'air_good': 'Воздухот е добар',
      'air_moderate': 'Воздухот е умерен',
      'air_high': 'Загадувањето е високо',
      'air_very_high': 'Загадувањето е многу високо',

      'air_good_line1': '🌿 Одлично време за прошетка или лесна активност надвор.',
      'air_good_line2': '🪟 Проветри 10–15 минути за да се освежи воздухот дома.',
      'air_good_line3': '😊 Свежиот воздух помага за расположение, фокус и сон.',

      'air_mod_line1': '🚶‍♀️ Избери паркови/зелени места наместо прометни улици.',
      'air_mod_line2': '😷 Ако почувствуваш иритација, скрати го времето надвор.',
      'air_mod_line3': '💧 Пиј вода и прави паузи внатре ако треба.',

      'air_high_line1': '🏃‍♀️ Избегнувај трчање и интензивно вежбање надвор.',
      'air_high_line2': '😷 Носи FFP2/N95 маска ако мораш да си надвор подолго.',
      'air_high_line3': '🪟 Држи прозорци затворени покрај сообраќај; проветри кратко подоцна.',
      'air_high_line4': '🚿 Измиј лице/нос по враќање дома.',

      'air_vhigh_line1': '🏠 Остани внатре колку што можеш (особено деца/стари лица).',
      'air_vhigh_line2': '🌀 Користи прочистувач ако имаш; држи прозорци затворени.',
      'air_vhigh_line3': '😷 Ако излегуваш: FFP2/N95 маска + кратко време.',
      'air_vhigh_line4': '🩺 Ако има проблем со дишење, следи медицински совет.',



    },
  };

  String t(String key) {
    final lang = _strings[locale.languageCode] ?? _strings['en']!;
    return lang[key] ?? (_strings['en']![key] ?? key);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
