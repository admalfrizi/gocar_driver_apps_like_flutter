import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar_driver_app/global/global.dart';
import 'package:gocar_driver_app/push_notifications/push_notification_system.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../assistant/assistant_methods.dart';
import '../../../assistant/black_theme_google_map.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );


  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locatedDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(driverCurrentPosition!, context);
    if (kDebugMode) {
      print("this is your address = $humanReadableAddress");
    }

    AssistantMethods.readDriverRatings(context);

  }

  readCurrentDriverInformation() async {
    currentFirebaseUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).once().then((snap){
      if(snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_number = (snap.snapshot.value as Map)["car_details"]["car_number"];

        driverVehicleType = (snap.snapshot.value as Map)["car_details"]["type"];


        print("Car Details : ");
        print(onlineDriverData.car_color);
        print(onlineDriverData.car_model);
        print(onlineDriverData.car_number);

      } else {

      }
    });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeFcm(context);
    pushNotificationSystem.generateAndGetToken();

    AssistantMethods.readDriverEarnings(context);
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  newGoogleMapController = controller;
                  blackThemeGoogleMap(newGoogleMapController);
                  locatedDriverPosition();
                },
              ),
              statusText != "Now Online" ?
              Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              ) :
              Container(),

              Positioned(
                top: statusText != "Now Online" ? MediaQuery.of(context).size.height * 0.45 : 25,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if(isDriverActive != true) {
                              driverIsOnlineNow();
                              updateDriversLocationAtRealTime();

                              setState(() {
                                statusText = "Now Online";
                                isDriverActive = true;
                                statusColor = Colors.transparent;
                              });

                              Fluttertoast.showToast(msg: "You are online now");
                            }
                            else {
                              driverIsOfflineNow();
                              setState(() {
                                statusText = "Now Offline";
                                isDriverActive = false;
                                statusColor = Colors.grey;
                              });
                              Fluttertoast.showToast(msg: "You are offline now");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColor,
                            padding:const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),

                            )
                          ),
                          child: statusText != "Now Online" ? Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ) : Icon(Icons.phonelink_ring, color: Colors.white, size: 26,)
                      )
                    ],
                  )
              )
            ],
          )
      ),
    );
  }

  driverIsOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    driverCurrentPosition = position;

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.set("idle");
    reference.onValue.listen((event) {

    });
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position) {
          driverCurrentPosition = position;

          if(isDriverActive = true) {
            Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
          }

          LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
        });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? reference = FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.onDisconnect();
    reference.remove();
    reference = null;

    Future.delayed(const Duration(milliseconds: 2000), (){
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });

  }
}
