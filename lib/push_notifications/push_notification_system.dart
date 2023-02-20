import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gocar_driver_app/global/global.dart';
import 'package:gocar_driver_app/models/user_ride_request_info.dart';
import 'package:gocar_driver_app/push_notifications/notification_dialog_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeFcm(BuildContext context) async {

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? rmtMsg){
      if(rmtMsg != null){
        print("This is Ride Request ID");
        print(rmtMsg.data["rideRequestId"]);
        readUserRideRequestInformation(rmtMsg.data["rideRequestId"], context);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? rmtMsg) {
      print("This is Ride Request ID");
      print(rmtMsg?.data["rideRequestId"]);
      readUserRideRequestInformation(rmtMsg?.data["rideRequestId"], context);

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? rmtMsg) {
      print("This is Ride Request ID");
      print(rmtMsg?.data["rideRequestId"]);
      readUserRideRequestInformation(rmtMsg?.data["rideRequestId"], context);

    });
  }

  Future generateAndGetToken() async {

    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token : ");
    print(registrationToken);

    FirebaseDatabase.instance.ref().child("drivers")
        .child(currentFirebaseUser!.uid).child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");

  }

  readUserRideRequestInformation(String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance.ref()
        .child("All Ride Requests").child(userRideRequestId).once().then((snapData){
          if(snapData.snapshot.value != null){

            audioPlayer.open(Audio("assets/audio/music-notification.mp3"));
            audioPlayer.play();

            double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"].toString()) ;
            double originLong = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"].toString()) ;
            String originAddr = (snapData.snapshot.value! as Map)["originAddress"];

            double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"].toString()) ;
            double destinationLong = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"].toString()) ;
            String destinationAddr = (snapData.snapshot.value! as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInfo userRideRequestInfo = UserRideRequestInfo();
            userRideRequestInfo.originLatLng = LatLng(originLat, originLong);
            userRideRequestInfo.originAddress = originAddr;
            userRideRequestInfo.destinationLatLng = LatLng(destinationLat, destinationLong);
            userRideRequestInfo.destinationAddress = destinationAddr;
            userRideRequestInfo.userName = userName;
            userRideRequestInfo.userPhone = userPhone;
            userRideRequestInfo.rideRequestId = rideRequestId;

            print("user Ride Request Information :");
            print(userRideRequestInfo.userName);
            print(userRideRequestInfo.userPhone);
            print(userRideRequestInfo.originAddress);
            print(userRideRequestInfo.destinationAddress);
            
            showDialog(context: context,
                builder: (BuildContext context)=> NotificationDialogBox(
                  userRideRequestInfo: userRideRequestInfo
                )
            );

          } else {
            Fluttertoast.showToast(msg: "This Ride Request didn't exist");
          }
    });

  }
}

