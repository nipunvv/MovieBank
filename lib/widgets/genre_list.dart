import 'package:flutter/material.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/models/genre.dart';

class GenreList extends StatelessWidget {
  final Movie movie;
  final List<Genre> genres;

  GenreList(this.movie, this.genres);

  final List<Color> colors = [
    Colors.amber,
    Colors.blue.shade400,
    Colors.red.shade400,
    Colors.orange.shade400,
  ];

  @override
  Widget build(BuildContext context) {
    if (!(movie.genreIds is List)) return Container();
    List<dynamic> genreIds = movie.genreIds;
    List<Genre> genreNames = [];
    genreIds.forEach((id) {
      genreNames =
          genres.where((element) => genreIds.contains(element.id)).toList();
    });

    if (genreNames.length > 0) {
      return Row(children: [
        for (var i = 0; i < genreNames.length; i++)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            margin: EdgeInsets.only(
              right: 5,
            ),
            decoration: BoxDecoration(
              color: colors[i % 4],
              border: Border.all(
                color: colors[i % 4],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              genreNames[i].name,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ]);
    }
    return Container();
  }
}
