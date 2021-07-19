import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

class MovieMeta extends StatelessWidget {
  final String type;
  final String content;

  MovieMeta(this.type, this.content);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Color(0xffd3d3d3),
        border: Border.all(
          color: Color(0xffd3d3d3),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            type == 'language' ? Icons.language : Icons.calendar_today,
            size: 18,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            type == 'language'
                ? LocaleNames.of(context)!.nameOf(content).toString()
                : content.substring(0, 4),
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
