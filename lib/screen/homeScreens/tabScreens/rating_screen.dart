import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../../../global/global.dart';
import '../../../handler/app_info.dart';


class RatingScreen extends StatefulWidget {
  const RatingScreen({Key? key}) : super(key: key);


  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {

  double? ratingsNumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRatingsNumber();
  }

  getRatingsNumber(){
    setState(() {
      ratingsNumber = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });
    setupRatingsTitle();
  }

  setupRatingsTitle(){
    if(ratingsNumber == 1){
      setState(() {
        titleRatings = "Sangat Buruk";
      });
    }
    if(ratingsNumber == 2){
      setState(() {
        titleRatings = "Buruk";
      });
    }
    if(ratingsNumber == 3){
      setState(() {
        titleRatings = "Ok";
      });
    }
    if(ratingsNumber == 4){
      setState(() {
        titleRatings = "Bagus";
      });
    }
    if(ratingsNumber == 5){
      setState(() {
        titleRatings = "Sangat Bagus";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22,
              ),
              const Text(
                "Rating Anda",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(
                height: 22.0,
              ),
              const Divider(
                height: 4.0,
                thickness: 4.0,
              ),
              const SizedBox(
                height: 22.0,
              ),
              SmoothStarRating(
                rating: ratingsNumber!,
                allowHalfRating: false,
                starCount: 5,
                size: 46,
                color: Colors.green,
                borderColor: Colors.green,
              ),
              const SizedBox(
                height: 12.0,
              ),
              Text(
                titleRatings,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

