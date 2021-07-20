import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final searchFieldController = TextEditingController();
  final Function searchMovies;
  SearchBar(
    this.searchMovies,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Color(0xff161b2e),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'MOVIE BANK',
                  style: TextStyle(
                    color: Colors.blueGrey[100],
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 250,
                  height: 30,
                  child: Center(
                    child: TextField(
                      controller: searchFieldController,
                      showCursor: true,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) {
                        searchMovies(value);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 5.0,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(left: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: new CircleBorder(),
                      onTap: () {
                        searchMovies(searchFieldController.text);
                      },
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
