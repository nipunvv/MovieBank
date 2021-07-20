import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/screens/movie_detail.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:http/http.dart' as http;
import 'package:movie_bank/widgets/search_bar.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<Movie> results = [];
  bool isSearching = false;

  searchMovies(String keyword) async {
    setState(() {
      isSearching = true;
    });
    String url = "${TMDB_API_URL}search/movie?query=$keyword";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      List<Movie> movies = [];
      Movie m;
      for (Map<String, dynamic> movie in jsonDecode(response.body)['results']) {
        m = Movie.fromJson(movie);
        if (m.releaseDate != '' && m.posterPath != '') movies.add(m);
      }

      setState(() {
        isSearching = false;
        results = movies;
      });
    } else {
      throw Exception('Failed to load Movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 1000),
        child: SearchBar(searchMovies),
      ),
      body: Column(
        children: [
          if (isSearching)
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          SizedBox(
            height: 50,
          ),
          if (!isSearching)
            results.length > 0
                ? CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.6,
                      viewportFraction: 0.2,
                      enlargeCenterPage: false,
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      disableCenter: false,
                      aspectRatio: 16 / 9,
                      initialPage: 0,
                      enableInfiniteScroll: results.length > 5 ? true : false,
                    ),
                    items: results.map((item) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetail(
                                      item,
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                "$TMDB_WEB_URL/w342/${item.posterPath}",
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text('No Results'),
                  ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 76,
        child: Footer(),
      ),
    );
  }
}
