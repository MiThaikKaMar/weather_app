import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';

import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = "London";

  late Future<Map<String, dynamic>> weather;

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    final response = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(response.body.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Build called");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              weather = getCurrentWeather();
            }),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            debugPrint("snapshot has data");
            final data = snapshot.data!;
            final main = data["list"][0]["main"];
            final firstItem = data["list"][0];
            final curTemp = main["temp"];
            final curWeather = firstItem["weather"][0]["main"];
            final curWindSpeed = firstItem["wind"]["speed"];
            final curHu = main["humidity"];
            final curPre = main["pressure"];
            return Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Card
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Card(
                        color: const Color.fromARGB(100, 74, 74, 74),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Column(
                            children: [
                              SizedBox(height: 15),
                              Text(
                                "$curTemp °F",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              SizedBox(height: 15),
                              Icon(
                                "$curWeather" == "Clouds" ||
                                        "$curWeather" == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 50,
                              ),
                              SizedBox(height: 15),
                              Text(
                                "$curWeather",
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Hourly Forecast
                  Text(
                    "Weather Forecast",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final item = data["list"][index + 1];
                        final temp = item["main"]["temp"];
                        return HourlyForecastItem(
                          DateFormat.Hm().format(
                            DateTime.parse(item["dt_txt"].toString()),
                          ),
                          temp == "Clouds" || temp == "Rain"
                              ? Icons.cloud
                              : Icons.sunny,
                          firstItem["main"]["temp"].toString(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Additional Information
                  Text(
                    "Additional Information",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoItem(
                        icon: Icons.water_drop,
                        label: "Humidity",
                        value: "$curHu",
                      ),
                      AdditionalInfoItem(
                        icon: Icons.air,
                        label: "Wind Speed",
                        value: "$curWindSpeed",
                      ),
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        label: "Pressure",
                        value: "$curPre",
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }

          return Center(child: CircularProgressIndicator.adaptive());
        },
      ),
    );
  }
}
