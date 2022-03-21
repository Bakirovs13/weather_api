import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:weather_api/components/searchForm.dart';
import 'package:weather_api/components/weatherCard.dart';

import 'package:weather_api/helpers/weather.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Geolocator _geolocator = Geolocator()..forceAndroidLocationManager;
  late Position _position;
  late String _city;
  late int _temp;
  late String _icon;
  late String _desc;
   late Color _color;
  WeatherFetch _weatherFetch = new WeatherFetch();


  @override
  void initState() {
    _city = "";
    _temp = 0;
    _desc = "null";
    _icon = "04n";
    _color = Colors.black;

    super.initState();
    _getCurrent();
  }

  /* Render data */
  void updateData(weatherData) {
    setState(() {
      if (weatherData != null) {
        debugPrint(jsonEncode(weatherData));
        //{"temp":10.49,"feels_like":5.54,"temp_min":10,"temp_max":11,"pressure":1009,"humidity":61}
        _temp = weatherData['main']['temp'].toInt();
        _icon = weatherData['weather'][0]['icon'];
        _desc = weatherData['main']['feels_like'].toString();
        _color = _getBackgroudColor(_temp);
      } else {
        _temp = 0;
        _city = "In the middle of nowhere";
        _icon = "04n";
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (Container(child: Center(child: Column(children: [
      Search(parentCallback: _changeCity,),
        Text(_city,style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold
        ),
        ),
        WeatherCard(title: _desc, temperature: _temp, iconCode: _icon)
      ],)),)),
    );
  }



  _getBackgroudColor(temp) {
    if (temp > 25) return Colors.orange;
    if (temp > 15) return Colors.yellow;
    if (temp <= 0) return Colors.blue;
    return Colors.green;
  }


  _getCurrent() {
    _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _position = position;
        debugPrint(position.toString());
      });
      _getCityAndWeather();
    });
  }

  _getCityAndWeather() async{
    try {
    List<Placemark> p = await _geolocator.placemarkFromCoordinates(
        _position.latitude, _position.longitude);
    Placemark place = p[0];

    var data = await _weatherFetch.getWeatherByCoord(_position.latitude, _position.longitude);
    debugPrint(jsonEncode(data));
    updateData(data);
    setState(() {
      _city = place.name;
    });
  }catch(e ){
      print(e);
    }
}

 _changeCity(city)async{
    try{
      var data = await _weatherFetch.getWeatherByName(city);
      updateData(data);
      setState(() {
        _city= city;
      });
    }catch(e){
      print(e);
    }
 }
}
