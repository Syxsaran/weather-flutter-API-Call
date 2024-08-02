import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env").then((_) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CityListPage(),
    );
  }
}

class CityListPage extends StatelessWidget {
  final List<String> cities = [
    'Bangkok',
    'New York',
    'London',
    'Tokyo',
    'Sydney',
    'Paris',
    'Berlin',
    'Moscow',
    'Cairo',
    'Los Angeles',
    'San Francisco',
    'Hong Kong',
    'Singapore',
    'Mumbai',
    'Dubai',
    'Istanbul',
    'Toronto',
    'Rio de Janeiro',
    'Buenos Aires',
    'Cape Town',
    'Seoul',
    'Beijing',
    'Shanghai',
    'Melbourne',
    'Rome',
    'Madrid',
    'Mexico City',
    'Lima',
    'Jakarta',
    'Phnom Penh',
    'Seoul',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Weather App',
              style: TextStyle(
                fontSize: 18, // Adjust size as needed
                color: Colors.white,
              ),
            ),
            Text(
              'by Saran Sunsang',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 110, 255),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              leading: const Icon(Icons.location_city,
                  color: Color.fromARGB(255, 0, 110, 255)),
              title: Text(
                cities[index],
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WeatherDetailPage(city: cities[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class WeatherDetailPage extends StatefulWidget {
  final String city;

  const WeatherDetailPage({required this.city});

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  late Future<WeatherResponse> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getData(widget.city);
  }

  Future<WeatherResponse> getData(String city) async {
    var client = http.Client();
    try {
      var apiKey = dotenv.env['API_KEY']; // ดึง API Key จาก .env
      var response = await client.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey'));
      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception("Failed to load data");
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city),
        backgroundColor: const Color.fromARGB(255, 0, 110, 255),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/background.jpg"), // Your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: FutureBuilder<WeatherResponse>(
              future: weatherData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading weather data');
                } else if (snapshot.hasData) {
                  var data = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.name ?? "",
                        style:
                            const TextStyle(fontSize: 40, color: Colors.black),
                      ),
                      Text(
                        'Current Temp: ${data.main?.temp?.toStringAsFixed(2) ?? "0.00"} °C',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Min Temp: ${data.main?.tempMin?.toStringAsFixed(2) ?? "0.00"} °C',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Max Temp: ${data.main?.tempMax?.toStringAsFixed(2) ?? "0.00"} °C',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Pressure: ${data.main?.pressure?.toString() ?? "N/A"} hPa',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Humidity: ${data.main?.humidity?.toString() ?? "N/A"} %',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Sea Level: ${data.main?.seaLevel?.toString() ?? "N/A"} hPa',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Clouds: ${data.clouds?.all?.toString() ?? "N/A"} %',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Rain (1h): ${data.rain?.d1h?.toString() ?? "N/A"} mm',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Sunset: ${data.sys?.sunset != null ? DateTime.fromMillisecondsSinceEpoch(data.sys!.sunset! * 1000).toLocal().toString() : "N/A"}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      if (data.weather != null && data.weather!.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 204, 202, 202)
                                .withOpacity(
                                    0.5), // Gray background with opacity
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(
                              10), // Padding inside the container
                          child: Image.network(
                            'http://openweathermap.org/img/wn/${data.weather![0].icon}@2x.png',
                            width: 100, // Adjust width as needed
                            height: 100, // Adjust height as needed
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  );
                } else {
                  return const Text('No data available');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
