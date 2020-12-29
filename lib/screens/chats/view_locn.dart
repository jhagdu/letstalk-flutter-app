//Importing Required Modules
import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letstalk/global_variables.dart';
import 'package:letstalk/screens/chats/messanger.dart';

//Globally Declared Variables
var rcvdLocationPoint = [0.0, 0.0];

//Class for Send Location Page
class SendLocation extends StatefulWidget {
  @override
  _SendLocationState createState() => _SendLocationState();
}

class _SendLocationState extends State<SendLocation> {
  Completer<GoogleMapController> _mapController = Completer();

  var crntLocn = [1.0, 77.77];
  var markedLocn = [0.0, 0.0];
  Set<Marker> _marker = HashSet<Marker>();

  //Function to get and show current location
  showCrntLocn() async {
    var crntPosn = await Geolocator.getCurrentPosition();
    crntLocn[0] = crntPosn.latitude;
    crntLocn[1] = crntPosn.longitude;
    final CameraPosition _toCrntPosn =
        CameraPosition(target: LatLng(crntLocn[0], crntLocn[1]), zoom: 14);

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_toCrntPosn));
  }

  //Function to Set Marker on Map
  void _setMarker(LatLng point) {
    final String markerIdVal = 'locn_$point';
    setState(() {
      _marker.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
        ),
      );
    });
  }

  @override
  void initState() {
    showCrntLocn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Location'),
        actions: [
          IconButton(
            tooltip: 'Refresh Location',
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _marker.clear();
              });
              showCrntLocn();
              markedLocn = [0.0, 0.0];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: deviceWidth,
              height: deviceHeight * 0.64,
              child: GoogleMap(
                onLongPress: (point) {
                  setState(() {
                    _marker.clear();
                  });
                  _setMarker(point);
                  markedLocn = [point.latitude, point.longitude];
                },
                markers: _marker,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(crntLocn[0], crntLocn[1]),
                  zoom: 0,
                ),
              ),
            ),
            SizedBox(height: 5),
            InkWell(
              splashColor: Colors.green,
              onTap: () {
                Messanger.messageSender(
                    'Location', '${[crntLocn[0], crntLocn[1]].toString()}');
                Navigator.pop(context);
              },
              child: Card(
                elevation: 7,
                child: Container(
                    decoration: BoxDecoration(
                      color: ThemeData.light().primaryColorLight,
                      borderRadius: BorderRadius.all(
                        Radius.circular(11),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 7, 20, 7),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Color.fromRGBO(0, 150, 0, 1),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              )),
                          child: Icon(
                            Icons.my_location,
                            size: 30,
                            color: Color.fromRGBO(0, 150, 0, 1),
                          ),
                        ),
                        Text(
                          'Send Current Location',
                          style: TextStyle(color: Colors.black, fontSize: 21),
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(height: 5),
            _marker.length == 1
                ? InkWell(
                    splashColor: Colors.red,
                    onTap: () {
                      Messanger.messageSender('Location',
                          '${[markedLocn[0], markedLocn[1]].toString()}');
                      Navigator.pop(context);
                    },
                    child: Card(
                      elevation: 7,
                      child: Container(
                          decoration: BoxDecoration(
                            color: ThemeData.light().primaryColorLight,
                            borderRadius: BorderRadius.all(
                              Radius.circular(11),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(20, 7, 20, 7),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: Color.fromRGBO(246, 0, 0, 1),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50),
                                    )),
                                child: Icon(
                                  Icons.location_on,
                                  size: 30,
                                  color: Color.fromRGBO(246, 0, 0, 1),
                                ),
                              ),
                              Text(
                                'Send Marked Location',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 21),
                              ),
                            ],
                          )),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

//View Recieved Location Page Class
class ViewRcvdLocn extends StatefulWidget {
  @override
  _ViewRcvdLocnState createState() => _ViewRcvdLocnState();
}

class _ViewRcvdLocnState extends State<ViewRcvdLocn> {
  Set<Marker> _marker = HashSet<Marker>();

  //Function to Mark Recieved Location on Map
  void _setMarker(LatLng point) {
    final String markerIdVal = 'locn_$point';
    setState(() {
      _marker.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
        ),
      );
    });
  }

  @override
  void initState() {
    _setMarker(LatLng(rcvdLocationPoint[0], rcvdLocationPoint[1]));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Location'),
      ),
      body: SafeArea(
        child: Container(
          child: GoogleMap(
            markers: _marker,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(rcvdLocationPoint[0], rcvdLocationPoint[1]),
              zoom: 14,
            ),
          ),
        ),
      ),
    );
  }
}
