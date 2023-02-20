import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar_driver_app/assistant/request_assistant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../global/map_key.dart';
import '../handler/app_info.dart';
import '../models/direction_details.dart';
import '../models/directions.dart';
import '../models/trips_history_model.dart';

class AssistantMethods {

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddr = "";

    var reqResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(reqResponse != "Error Occured, Failed. No Response"){
      humanReadableAddr = reqResponse["results"][0]["formatted_address"];

      Directions userPickUpAddr = Directions();
      userPickUpAddr.locationLat = position.latitude;
      userPickUpAddr.locationLong = position.longitude;
      userPickUpAddr.locationName = humanReadableAddr;

      Provider.of<AppInfo>(context, listen: false).updatePickupLocationAddr(userPickUpAddr);
    }

    return humanReadableAddr;
  }

  static Future<DirectionDetails?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{
    String urlOriginToDestinationWays = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationWays);

    if(responseDirectionApi == "Error Ocurred, Failed, No Response"){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetails.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];


    return directionDetails;
  }

  static pauseLiveLocationUpdate(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static startLiveLocationUpdate(){
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetails directionDetails){
    double timeTraveledFareAmountPerMinute = (directionDetails.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetails.duration_value! / 1000) * 0.1;

    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    double localCurrencyTotalAmount = totalFareAmount * 14990;

    if(driverVehicleType == "Ojek"){

      double resultFareAmount = (localCurrencyTotalAmount.truncate()) / 2.0 ;
      return resultFareAmount;

    } else if(driverVehicleType == "Standar"){

      return localCurrencyTotalAmount.truncate().toDouble();

    } else if(driverVehicleType == "X-tra Besar"){

      double resultFareAmount = (localCurrencyTotalAmount.truncate()) * 2.0 ;
      return resultFareAmount;

    } else {
      return totalFareAmount.truncate().toDouble();
    }

  }

  static void readTripsKeysForOnlineDriver(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests")
        .orderByChild("driverId").equalTo(firebaseAuth.currentUser!.uid)
        .once().then((snap){
      if(snap.snapshot.value != null){
        Map keysTripsId = snap.snapshot.value as Map;

        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        List<String> tripKeysList = [];
        keysTripsId.forEach((key, value) {
          tripKeysList.add(key);
        });

        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripKeysList);

        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripKeysList;

    for(String eachKey in tripAllKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once()
          .then((snap){
        var eachTripsHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended"){
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInfo(eachTripsHistory);
        }
      });
    }
  }

  static void readDriverEarnings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid)
        .child("earnings").once().then((snap){
          if(snap.snapshot.value != null){
              String driverEarnings = snap.snapshot.value.toString();
              Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);
          }
    });

    readTripsKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid)
        .child("ratings").once().then((snap){
      if(snap.snapshot.value != null){
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverAverageRatings(driverRatings);
      }
    });
  }
}