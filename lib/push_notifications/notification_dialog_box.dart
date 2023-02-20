import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gocar_driver_app/assistant/assistant_methods.dart';
import 'package:gocar_driver_app/models/user_ride_request_info.dart';
import 'package:gocar_driver_app/global/global.dart';
import 'package:gocar_driver_app/screen/homeScreens/trip_screen.dart';


class NotificationDialogBox extends StatefulWidget {

  UserRideRequestInfo? userRideRequestInfo;
  
  NotificationDialogBox({
    this.userRideRequestInfo
  });
  
  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14,
            ),
            Image.asset(
                "assets/images/car_logo.png",
              width: 160,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Penumpangmu Sedang Mencari Tumpangan !",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.grey
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
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
                    height: 25.0,
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
                ],
              ),
            ),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();

                        FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestInfo!.rideRequestId!)
                          .remove().then((snap){
                          FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("newRideStatus").set("idle");
                        }).then((value){
                          FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("trips_history").child(widget.userRideRequestInfo!.rideRequestId!).remove();
                        }).then((value){
                          Fluttertoast.showToast(msg: "Pembatalan Permintaan Supir, Telah Berhasil");
                        });

                        Future.delayed(const Duration(
                            milliseconds: 2000
                        ),(){
                          SystemNavigator.pop();
                        });
                      },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      elevation: 0
                    ),
                      child: Text(
                        "Tolak".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14.0
                        ),
                      ),
                  ),
                  SizedBox(
                    width: 25.0,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0
                      ),
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();

                        acceptRideRequest(context);
                      },
                      child: Text(
                        "Terima".toUpperCase(),
                        style: TextStyle(
                            fontSize: 14.0
                        ),
                      )
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context){
    String getRideRequestId = "";

    FirebaseDatabase.instance.ref().child('drivers')
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus").once().then((data){
          if(data.snapshot.value != null){
            getRideRequestId = data.snapshot.value.toString();

          }
          else {
            Fluttertoast.showToast(msg: "Permintaan supir tidak ada !");
          }


          if(getRideRequestId == widget.userRideRequestInfo!.rideRequestId){

            FirebaseDatabase.instance.ref().child('drivers')
                .child(currentFirebaseUser!.uid)
                .child("newRideStatus").set("accepted");

            AssistantMethods.pauseLiveLocationUpdate();
            
            Navigator.push(context, MaterialPageRoute(builder: (c)=> TripScreen(userRideRequestInfo: widget.userRideRequestInfo)));
          }
          else {
            Fluttertoast.showToast(msg: "Permintaan supir di tolak!");
          }
    });
  }
}
