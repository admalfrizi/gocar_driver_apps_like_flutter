import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gocar_driver_app/global/global.dart';
import 'package:gocar_driver_app/screen/splashScreen.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({Key? key}) : super(key: key);

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {

  FToast? fToast;

  TextEditingController carModelTxtEditController = TextEditingController();
  TextEditingController carNumberTxtEditController = TextEditingController();
  TextEditingController carColorTxtEditController = TextEditingController();

  List<String> carTypeList = ["X-tra Besar", "Standar", "Ojek"];
  String? selectedCarType;

  @override
  void initState(){
    super.initState();
    fToast = FToast();
    fToast?.init(context);
  }

  _showToast(String? toastMsg){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12.0,
          ),
          Text(
            toastMsg!,
            style: const TextStyle(
                color: Colors.white
            ),
          ),
        ],
      ),
    );
  }

  saveCarInfo(){
    Map driverCarInfo = {
      "car_color": carColorTxtEditController.text.trim(),
      "car_number": carNumberTxtEditController.text.trim(),
      "car_model": carModelTxtEditController.text.trim(),
      "type": selectedCarType
    };

    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers");
    driverRef.child(currentFirebaseUser!.uid).child("car_details").set(driverCarInfo);

    fToast!.showToast(
      child: _showToast("Selamat Anda Telah Menjadi Supir Online"),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );

    Navigator.push(context, MaterialPageRoute(builder: (c)=> const SplashScreen()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/icons/logo1.png"),
              ),
              const Text(
                "Tambahkan Mobil Anda",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                ),
              ),
              TextField(
                controller: carModelTxtEditController,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Mobil Anda",
                  hintText: "Masukan Nama Mobil Anda",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              TextField(
                controller: carNumberTxtEditController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Nomor Plat Anda",
                  hintText: "Masukan Nomor Plat Mobil Anda",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              TextField(
                controller: carColorTxtEditController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Warna Mobil Anda",
                  hintText: "Masukan Warna Mobil Anda",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton(
                dropdownColor: Colors.grey,
                hint: const Text(
                  "Silahkan Pilih Tipe Mobil",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey
                  ),
                ),
                value: selectedCarType,
                onChanged: (newValue){
                  setState(() {
                    selectedCarType = newValue.toString();
                  });
                },
                items: carTypeList.map((car){
                  return DropdownMenuItem(
                      value: car,
                      child: Text(
                        car,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                      ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: (){
                  if(carColorTxtEditController.text.isNotEmpty
                      && carNumberTxtEditController.text.isNotEmpty
                      && carModelTxtEditController.text.isNotEmpty && selectedCarType != null)
                  {
                    saveCarInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: const Text(
                  "Simpan Mobil Anda",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
