import 'package:flutter/material.dart';
import 'package:gocar_driver_app/handler/app_info.dart';
import 'package:gocar_driver_app/screen/homeScreens/trips_history_screen.dart';
import 'package:provider/provider.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({Key? key}) : super(key: key);

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Column(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  const Text(
                    "Total Pendapatan Kamu",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Rp. ${Provider.of<AppInfo>(context, listen: false).driverTotalEarnings}",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 50,
                        fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          ),
          ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const TripsHistoryScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white54
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Image.asset(
                        "assets/images/car_logo.png",
                      width: 100,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Text(
                      "Perjalanan Yang Udh Dilalui",
                      style: TextStyle(
                        color: Colors.black54
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                            Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                              color: Colors.black54
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
