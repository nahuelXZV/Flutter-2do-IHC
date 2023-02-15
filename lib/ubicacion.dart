

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Ubicacion extends StatefulWidget {
  const Ubicacion({Key? key}) : super(key: key);

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  var _latitude = "";
  var _longitude = "";
  var _altitude = "";
  var _speed = "";
  var _address = "";

  Future<void> _updatePosition() async {
    Position position = await _determinatePosition();
    List pm = await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
      _altitude = position.altitude.toString();
      _speed = position.speed.toString();

      //_address = pm[0].toString();
      _address = "${pm[0].street}, ${pm[0].locality}, ${pm[0].country}";
    });
  }

  Future<Position> _determinatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if(permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    _updatePosition();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Latitud: $_latitude'),
            Text('Longitud: $_longitude'),
            Text('Altitud: $_altitude'),
            Text('Velocidad: $_speed'),
            Text('Dirección: $_address'),
          ],
        ),
      ),
    );
  }
}