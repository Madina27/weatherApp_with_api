import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:weather_app/api/api_const.dart';
import 'package:weather_app/model/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WeatherPageState();
  }
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherModel? weatherModel;
  List<String> cities = [
    'bishkek',
    'naryn',
    'jalalabad',
    'talas',
    'batken',
    'osh',
  ];

  Future<void> getWeatherLocation() async {
    try {
      setState(() {
        weatherModel = null;
      });
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition();
          final http = Client();
          final url = Uri.parse(ApiConst.getLocation(
            lat: '${position.latitude}',
            long: '${position.longitude}',
          ));
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            setState(() {
              weatherModel = WeatherModel(
                id: body['weather'][0]['id'],
                main: body['weather'][0]['main'],
                description: body['weather'][0]['description'],
                icon: body['weather'][0]['icon'],
                temp: body['main']['temp'],
                country: body['sys']['country'],
                name: body['name'],
              );
            });
          }
        }
      } else {
        Position position = await Geolocator.getCurrentPosition();
        final http = Client();
        final url = Uri.parse(ApiConst.getLocation(
          long: '${position.longitude}',
          lat: '${position.latitude}',
        ));
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          setState(() {
            weatherModel = WeatherModel(
              id: body['weather'][0]['id'],
              main: body['weather'][0]['main'],
              description: body['weather'][0]['description'],
              icon: body['weather'][0]['icon'],
              temp: body['main']['temp'],
              country: body['sys']['country'],
              name: body['name'],
            );
          });
        }
      }
    } catch (e) {
      log(e.toString(), name: 'error');
    }
  }

  Future<void> getWeather({String? cityName}) async {
    try {
      final http = Client();
      final url = Uri.parse(ApiConst.getWeatherCityName(city: cityName));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          weatherModel = WeatherModel(
            id: body['weather'][0]['id'],
            main: body['weather'][0]['main'],
            description: body['weather'][0]['description'],
            icon: body['weather'][0]['icon'],
            temp: body['main']['temp'],
            country: body['sys']['country'],
            name: body['name'],
          );
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    getWeather(cityName: 'bishkek');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Тапшырма-9',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: weatherModel == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/weather.jpeg'),
                      fit: BoxFit.cover)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          getWeatherLocation();
                        },
                        icon: const Icon(Icons.near_me),
                        color: Colors.white,
                        iconSize: 50,
                      ),
                      IconButton(
                        onPressed: () {
                          bottomSheet();
                        },
                        icon: const Icon(Icons.location_city),
                        color: Colors.white,
                        iconSize: 50,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          '${(weatherModel!.temp - 273.15).toInt()}',
                          style: const TextStyle(
                              fontSize: 100, color: Colors.white),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Image.network(
                            'https://openweathermap.org/img/wn/${weatherModel?.icon}@4x.png')
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        textAlign: TextAlign.end,
                        "${weatherModel?.description}".replaceAll(' ', '\n'),
                        style:
                            const TextStyle(fontSize: 60, color: Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        weatherModel!.name,
                        style: const TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void bottomSheet() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.grey,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  const Text(
                    'Choose city',
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];

                  return GestureDetector(
                    onTap: () {
                      getWeather(cityName: city);
                      Navigator.pop(context);
                    },
                    child: Card(
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          city,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }
}
