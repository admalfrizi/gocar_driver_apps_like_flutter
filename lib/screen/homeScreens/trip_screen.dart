import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar_driver_app/components/fare_amount_collection.dart';
import 'package:gocar_driver_app/global/global.dart';
import 'package:gocar_driver_app/models/user_ride_request_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../assistant/assistant_methods.dart';
import '../../assistant/black_theme_google_map.dart';
import '../../components/progress_dialog.dart';

class TripScreen extends StatefulWidget {

  UserRideRequestInfo? userRideRequestInfo;

  TripScreen({
    this.userRideRequestInfo
});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  GoogleMapController? newTripGoogleMapController;

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();

  List<LatLng> polylinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String? rideRequestStatus = "accepted";
  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng) async {

    showDialog(context: context,
        builder: (BuildContext context)=> ProgressDialog(
          msg: "Mohon Tunggu...",
        ));

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("There are points");
    print(directionDetailsInfo?.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    polylinePositionCoordinates.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
    {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
      {
        polylinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });

  }

  @override
  void initState() {
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }

  getDriversLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);
    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
        .listen((Position position) {

      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
          markerId: const MarkerId("AnimatedMarker"),
          position: latLngLiveDriverPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: "Ini Lokasi Anda"
          ),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(
            target: latLngLiveDriverPosition,
            zoom: 16
        );
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString()
      };
      
      FirebaseDatabase.instance.ref().child("All Ride Requests")
          .child(widget.userRideRequestInfo!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if(isRequestDirectionDetails == false){

      isRequestDirectionDetails = true;

      if(onlineDriverCurrentPosition == null){
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
      var destinationLatLng;

      if(rideRequestStatus == "accepted"){
        destinationLatLng = widget.userRideRequestInfo!.originLatLng;
      } else {
        destinationLatLng = widget.userRideRequestInfo!.destinationLatLng;
      }

      var directionInformation = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
      if(directionInformation != null){
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;

    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: _kGooglePlex,
              markers: setOfMarkers,
              circles: setOfCircle,
              polylines: setOfPolyline,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                newTripGoogleMapController = controller;

                setState(() {
                  mapPadding = 350;
                });

                blackThemeGoogleMap(newTripGoogleMapController);

                var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
                var userPickUpLatLng = widget.userRideRequestInfo!.originLatLng;

                drawPolyLineFromOriginToDestination(driverCurrentLatLng, userPickUpLatLng!);
                getDriversLocationUpdatesAtRealTime();
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white30,
                      blurRadius: 18,
                      spreadRadius: .5,
                      offset: Offset(0.6, 0.6)
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        durationFromOriginToDestination,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightGreenAccent
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      const Divider(
                        thickness: 2,
                        height: 2,
                        color: Colors.grey
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: [
                          Text(
                          widget.userRideRequestInfo!.userName!,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightGreenAccent
                            ),
                          ),
                          const Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.phone_android,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/origin.png",
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.userRideRequestInfo!.originAddress!,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/destination.png",
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          Text(
                            widget.userRideRequestInfo!.destinationAddress!,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      const Divider(
                          thickness: 2,
                          height: 2,
                          color: Colors.grey
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            if(rideRequestStatus == "accepted"){

                              rideRequestStatus = "arrived";
                              FirebaseDatabase.instance.ref().child("All Ride Requests")
                                  .child(widget.userRideRequestInfo!.rideRequestId!)
                                  .child("status").set(rideRequestStatus);

                              setState(() {
                                buttonTitle = "Let's Go";
                                buttonColor = Colors.lightGreen;
                              });

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext c) => ProgressDialog(
                                  msg: "Loading..."
                                )
                              );

                              await drawPolyLineFromOriginToDestination(
                                widget.userRideRequestInfo!.originLatLng!,
                                widget.userRideRequestInfo!.destinationLatLng!
                              );

                              Navigator.pop(context);

                            }
                            else if(rideRequestStatus == "arrived"){
                              rideRequestStatus = "onTrip";

                              FirebaseDatabase.instance.ref().child("All Ride Requests")
                                  .child(widget.userRideRequestInfo!.rideRequestId!)
                                  .child("status").set(rideRequestStatus);

                              setState(() {
                                buttonTitle = "End Trip";
                                buttonColor = Colors.redAccent;
                              });

                            }
                            else if(rideRequestStatus == "onTrip"){
                              endTripNow();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          icon: Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 25,
                          ),
                          label: Text(
                            buttonTitle!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  endTripNow() async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) => ProgressDialog(
          msg: "Harap Menunggu...",
        )
    );

    var currentDriverPositionLatLng = LatLng(
      onlineDriverCurrentPosition!.latitude,
      onlineDriverCurrentPosition!.longitude
    );

    var tripDirectionDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
      currentDriverPositionLatLng,
      widget.userRideRequestInfo!.originLatLng!
    );

    double totalFareAmount = AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails!);
    FirebaseDatabase.instance.ref().child("All Ride Requests")
        .child(widget.userRideRequestInfo!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());

    FirebaseDatabase.instance.ref().child("All Ride Requests")
        .child(widget.userRideRequestInfo!.rideRequestId!).child("status").set("ended");

    streamSubscriptionDriverLivePosition!.cancel();

    Navigator.pop(context);

    showDialog(context: context, builder: (BuildContext context) => FareAmountCollection(totalFareAmount: totalFareAmount));

    saveFareAmountToDriverEarnings(totalFareAmount);

  }

  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
        .child("earnings").once().then((snap){
          if(snap.snapshot.value != null){
            double oldEarnings = double.parse(snap.snapshot.value.toString());
            double driverTotalEarnings = totalFareAmount + oldEarnings;

            FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
                .child("earnings").set(driverTotalEarnings.toString());

          }else {
            FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid)
                .child("earnings").set(totalFareAmount.toString());
          }
    });
  }

  saveAssignedDriverDetailsToUserRideRequest(){
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInfo!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    ref.child("driverLocation").set(driverLocationDataMap);

    ref.child("status").set("accepted");
    ref.child("driverId").set(onlineDriverData.id);
    ref.child("driverName").set(onlineDriverData.name);
    ref.child("driverPhone").set(onlineDriverData.phone);
    ref.child("car_details").set("${onlineDriverData.car_color.toString()} ${onlineDriverData.car_model.toString()} ${onlineDriverData.car_number.toString()}");

    //saveRideRequestIdToDriverHistory();
  }

  // saveRideRequestIdToDriverHistory() {
  //  DatabaseReference tripRef = FirebaseDatabase.instance.ref()
  //       .child("drivers")
  //       .child(currentFirebaseUser!.uid).child("trips_history");
  //
  //  tripRef.child(widget.userRideRequestInfo!.rideRequestId!).set(true);
  // }





}
