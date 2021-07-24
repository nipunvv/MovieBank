import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/models/genre.dart';
import 'package:movie_bank/providers/provider.dart';
import 'package:movie_bank/screens/movie_detail.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:http/http.dart' as http;
import 'package:movie_bank/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<Movie> results = [];
  bool isSearching = false;
  bool showAdvancedSearch = false;
  String selectedGenre = 'All';
  String selectedOrderBy = 'All';
  String selectedRating = 'All';
  List<Genre> allGenres = [];

  final queryTextController = TextEditingController();
  final yearTextController = TextEditingController();

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

  getRatingValue() {
    if (selectedRating == 'All') return '';
    return selectedRating.substring(0, 1);
  }

  getSortValue() {
    if (selectedOrderBy == 'All') {
      return '';
    } else if (selectedOrderBy == 'Popularity') {
      return 'popularity.desc';
    } else if (selectedOrderBy == 'Release date') {
      return 'release_date.desc';
    } else if (selectedOrderBy == 'Title') {
      return 'original_title.asc';
    } else if (selectedOrderBy == 'Rating') {
      return 'vote_average.desc';
    } else if (selectedOrderBy == 'Vote count') {
      return 'vote_count.desc';
    }
  }

  getGenreId() {
    if (allGenres.length == 0 || selectedGenre == 'All') return '';
    int genreId =
        allGenres.where((element) => element.name == selectedGenre).first.id;
    return genreId.toString();
  }

  discoverMovies() async {
    String query = queryTextController.text;
    String year = yearTextController.text;
    String rating = getRatingValue();
    String sortValue = getSortValue();
    String genreId = getGenreId();
    String url =
        "${TMDB_API_URL}discover/movie?query=$query&year=$year&vote_average.gte=$rating&sort_by=$sortValue&with_genres=$genreId";
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

  List<String> getGenres(genres) {
    List<String> genreNames = ['All'];
    genres.forEach((genre) => genreNames.add(genre.name));
    return genreNames;
  }

  InputDecoration inputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(3),
      ),
      borderSide: BorderSide.none,
    ),
    fillColor: Colors.white,
    filled: true,
    contentPadding: EdgeInsets.symmetric(
      vertical: 5.0,
      horizontal: 5.0,
    ),
  );

  toggleAdvancedSearch() {
    this.setState(() {
      showAdvancedSearch = !showAdvancedSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final genreModel = Provider.of<GenreProvider>(context);
    if (genreModel.genres.length != 0) {
      setState(() {
        allGenres = genreModel.genres;
      });
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 1000),
        child: SearchBar(searchMovies, toggleAdvancedSearch),
      ),
      body: SingleChildScrollView(
        child: Column(
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
              height: 10,
            ),
            if (showAdvancedSearch)
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 30,
                      child: TextField(
                        controller: queryTextController,
                        decoration: inputDecoration,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.15,
                            height: 30,
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              focusColor: Colors.white,
                              value: selectedGenre,
                              underline: SizedBox(),
                              style: TextStyle(color: Colors.white),
                              iconEnabledColor: Colors.black,
                              isExpanded: true,
                              items: getGenres(genreModel.genres)
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                "Select genre",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedGenre = newValue!;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 30,
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              focusColor: Colors.white,
                              value: selectedRating,
                              underline: SizedBox(),
                              style: TextStyle(color: Colors.white),
                              iconEnabledColor: Colors.black,
                              isExpanded: true,
                              items: <String>[
                                'All',
                                '9+',
                                '8+',
                                '7+',
                                '6+',
                                '5+',
                                '4+',
                                '3+',
                                '2+',
                                '1+',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                "Rating",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedRating = newValue!;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 30,
                            margin: EdgeInsets.only(right: 5),
                            child: TextField(
                              controller: yearTextController,
                              decoration: inputDecoration,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.15,
                            height: 30,
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: DropdownButton<String>(
                              focusColor: Colors.white,
                              value: selectedOrderBy,
                              underline: SizedBox(),
                              style: TextStyle(color: Colors.white),
                              iconEnabledColor: Colors.black,
                              isExpanded: true,
                              items: <String>[
                                'All',
                                'Popularity',
                                'Release date',
                                'Title',
                                'Rating',
                                'Vote count',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                "Select sort category",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOrderBy = newValue!;
                                });
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.blue.shade600,
                            ),
                            child: IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.search),
                              onPressed: () {
                                discoverMovies();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 50,
            ),
            if (!isSearching)
              results.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: 50,
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 0.6,
                          viewportFraction: 0.2,
                          enlargeCenterPage: false,
                          enlargeStrategy: CenterPageEnlargeStrategy.scale,
                          disableCenter: false,
                          aspectRatio: 16 / 9,
                          initialPage: 0,
                          enableInfiniteScroll:
                              results.length > 5 ? true : false,
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
                      ),
                    )
                  : Center(
                      child: Text('No Results'),
                    ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 76,
        child: Footer(),
      ),
    );
  }
}
