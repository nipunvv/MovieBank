import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:http/http.dart' as http;
import 'package:movie_bank/providers/provider.dart';
import 'package:movie_bank/screens/movie_detail.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:movie_bank/widgets/top_bar_contents.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  runApp(
    MultiProvider(
      providers: providers,
      child: MovieBank(),
    ),
  );
}

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<GenreProvider>(create: (_) => GenreProvider()),
];

class MovieBank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Bank',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(title: 'Movie Bank'),
      localizationsDelegates: [
        LocaleNamesLocalizationsDelegate(),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> popularMovies;
  late ScrollController _scrollController;
  double _scrollPosition = 0;
  double _opacity = 0;

  Future<List<Movie>> fetchMovies(int index) async {
    String url =
        "${TMDB_API_URL}movie/${index == 0 ? 'popular' : 'now_playing'}?language=en-US&page=1";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      List<Movie> movies = [];
      Movie m;
      for (Map<String, dynamic> movie in jsonDecode(response.body)['results']) {
        m = Movie.fromJson(movie);
        if (m.releaseDate != '') movies.add(m);
      }

      return movies;
    } else {
      throw Exception('Failed to load Movies');
    }
  }

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    popularMovies = fetchMovies(0);
    final genreModel = Provider.of<GenreProvider>(context, listen: false);
    genreModel.getPostData();
  }

  void handleCategoryChange(int index) {
    setState(() {
      popularMovies = fetchMovies(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _opacity = _scrollPosition < screenSize.height * 0.40
        ? _scrollPosition / (screenSize.height * 0.40)
        : 1;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 1000),
        child: TopBarContents(_opacity),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: ClampingScrollPhysics(),
        child: Container(
          child: Container(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      child: SizedBox(
                        height: screenSize.height * 0.5,
                        width: screenSize.width,
                        child: Image.asset(
                          'assets/images/cover.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                FlutterToggleTab(
                  width: 20,
                  borderRadius: 20,
                  height: 30,
                  initialIndex: 0,
                  selectedBackgroundColors: [Colors.blue],
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unSelectedTextStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  labels: ["Popular", "Latest"],
                  selectedLabelIndex: (index) {
                    handleCategoryChange(index);
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                FutureBuilder<List<Movie>>(
                  future: popularMovies,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Movie>? movies = snapshot.data;
                      return CarouselSlider(
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 0.6,
                          viewportFraction: 0.2,
                          enlargeCenterPage: false,
                          enlargeStrategy: CenterPageEnlargeStrategy.scale,
                          disableCenter: false,
                          aspectRatio: 16 / 9,
                          initialPage: 0,
                        ),
                        items: movies!.map((item) {
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
                                  child: Hero(
                                    tag: 'movie_image${item.id}',
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "$TMDB_WEB_URL/w342/${item.posterPath}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 50,
                ),
                Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
