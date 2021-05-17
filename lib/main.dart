import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temperature;
  String location = 'Ankara';
  String weather = 'clear';
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';
  initState() {
    super.initState();
    fetchLocation();
  }

  int woeid = 2343732;
  String abbreviation = '';
  var error = '';
  void fetchSearch(String input) async {
    try {
      var searchResults = await http.get(searchApiUrl + input);
      var result = jsonDecode(searchResults.body)[0];
      setState(() {
        location = result['title'];
        woeid = result['woeid'];
        error = '';
      });
    } catch (err) {
      setState(() {
        error = 'Üzgünüz, ' + input + ' isimli şehri bulamadık.';
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = jsonDecode(locationResult.body);
    var consolidatedWeather = result['consolidated_weather'];
    var data = consolidatedWeather[0];
    setState(() {
      temperature = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abbreviation = data['weather_state_abbr'];
    });
  }

  void onTextFildSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/$weather.png'), fit: BoxFit.cover)),
          child: temperature == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Center(
                              child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/' +
                                abbreviation +
                                '.png',
                            width: 100,
                          )),
                          Center(
                              child: Text(
                            temperature.toString() + '°C',
                            style: TextStyle(color: Colors.white, fontSize: 60),
                          )),
                          Center(
                            child: Text(
                              location,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 55),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 300,
                            child: TextField(
                              onSubmitted: (String input) {
                                onTextFildSubmitted(input);
                              },
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                              decoration: InputDecoration(
                                  hintText: 'Bir şehir giriniz.',
                                  hintStyle: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                  prefix: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
        ));
  }
}
