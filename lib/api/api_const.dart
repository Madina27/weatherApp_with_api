class ApiConst {
  static const String apiKey = 'c3b8d9915f1e3fe4331c26af0687d8e4';

  static String getWeatherCityName({String? city}) {
    return 'https://api.openweathermap.org/data/2.5/weather?q=${city ?? 'bishkek'}&appid=$apiKey';
  }

  static String getLocation({
    required String lat,
    required String long,
  }) {
    return 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$apiKey';
  }
}
