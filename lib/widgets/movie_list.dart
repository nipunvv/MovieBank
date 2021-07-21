import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/screens/movie_detail.dart';

class MovieList extends StatefulWidget {
  final List<Movie> movies;

  MovieList(this.movies);

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 5,
      mainAxisSpacing: 1.0,
      childAspectRatio: 0.67,
      children: List.generate(
        widget.movies.length,
        (index) {
          return Container(
            width: 185,
            height: 360,
            padding: EdgeInsets.all(15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetail(
                        widget.movies[index],
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'movie_image${widget.movies[index].id}',
                  child: CachedNetworkImage(
                    imageUrl:
                        "$TMDB_WEB_URL/w185/${widget.movies[index].posterPath}",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
