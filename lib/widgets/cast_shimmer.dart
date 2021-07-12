import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CastShimmer extends StatelessWidget {
  const CastShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Text(
          'CAST',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            for (int i = 0; i < 5; i++)
              Container(
                margin: EdgeInsets.only(
                  right: 7,
                  top: 10,
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: CircleAvatar(
                    radius: 30,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
