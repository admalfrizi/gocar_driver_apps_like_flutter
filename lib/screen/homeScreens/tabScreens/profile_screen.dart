import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gocar_driver_app/global/global.dart';

import '../../../components/info_design_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              onlineDriverData.name!,
              style: const TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              "Supir yang $titleRatings",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w200
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 38,
            ),
            InfoDesignUI(
              textInfo: onlineDriverData.phone!,
              iconData: Icons.email,
            ),
            const SizedBox(
              height: 20,
            ),
            InfoDesignUI(
              textInfo: onlineDriverData.email!,
              iconData: Icons.phone_iphone,
            ),
            const SizedBox(
              height: 20,
            ),
            InfoDesignUI(
              textInfo: "${onlineDriverData.car_color!} ${onlineDriverData.car_model!} ${onlineDriverData.car_number!}",
              iconData: Icons.car_rental,
            ),
            ElevatedButton(
                onPressed: (){
                  firebaseAuth.signOut();
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                      color: Colors.white
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
