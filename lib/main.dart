import 'dart:async';
//import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MaterialApp(
      home: OpeningGoogleMap(),
    )); //runApp(MyApp());

class OpeningGoogleMap extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<OpeningGoogleMap> {
  String _homeloc = "searching...";
  Position _currentPosition;
  String gmaploc = "";
  double screenHeight, screenWidth;
  double latitude = 6.4676929;
  double longitude = 100.5067673;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _userpos;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    //var alheight = MediaQuery.of(context).size.height;
    //var alwidth = MediaQuery.of(context).size.width;
    try {
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );

      return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Google Map App'),
            ),
            body: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                    color: Colors.white,
                    child: Stack(children: <Widget>[
                      Container(
                        //height: MediaQuery.of(context).size.height,
                        //width: MediaQuery.of(context).size.width,
                        //margin: EdgeInsets.fromLTRB(10, 0, 10, 300),
                        //height: 400,
                        height: screenHeight - 225,
                        width: screenWidth - 10,
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                        //height: alheight - 220,
                        //width: alwidth - 50,
                        child: GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _userpos,
                            markers: markers.toSet(),
                            onMapCreated: (controller) {
                              _controller.complete(controller);
                            },
                            onTap: (newLatLng) {
                              _loadLoc(newLatLng);
                            }),
                      ),
                    ])),
                SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                      "  Your Current Location: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                Wrap(
                  direction: Axis.horizontal,
                  children:[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Text(
                      "  " + _homeloc,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ]),
              SizedBox(
                  height: 5,
                ),
                Text(
                      "  Your Current Latitude: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                Container(
                    child: Text(
                      "  " + latitude.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  SizedBox(
                  height: 5,
                ),
                Text(
                      "  Your Current Longitude: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                Text(
                      "  " + longitude.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                ]),

                
              ],
            )
            ),
      )
      );
    } catch (e) {
      print(e);
    }
  }

  void _loadLoc(LatLng loc) {
    markers.clear();
    latitude = loc.latitude;
    longitude = loc.longitude;
    _getLocationfromlatlng(latitude, longitude);
    _home = CameraPosition(
      target: loc,
      zoom: 17,
    );
    markers.add(Marker(
      markerId: markerId1,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: 'New Location',
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
    ));
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _homeloc = first.addressLine;
    setState(() {
      _homeloc = first.addressLine;
    });
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}
