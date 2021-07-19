import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RatingContainer extends StatelessWidget {
  final String ratingPercentage;
  final double voteCount;

  RatingContainer(this.ratingPercentage, this.voteCount);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff032541),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              child: CircularPercentIndicator(
                radius: 55.0,
                lineWidth: 3.0,
                percent: double.parse(ratingPercentage),
                center: Text(
                  '${(double.parse(ratingPercentage) * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Color(0xff204529),
                progressColor: Color(0xff21d07a),
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text('From $voteCount votes'),
        ),
      ],
    );
  }
}
