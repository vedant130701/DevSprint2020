import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new MyHomePage(title: 'MOVIES LIST'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key, key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<User>> _getUsers() async {
    var data = await http
        .get("https://limitless-fortress-81406.herokuapp.com/get_data");

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var u in jsonData) {
      User user = User(u["id"], u["description"], u["title"], u["year"],
          u["imageUrl"], u["duration"], u["rating"]);
      //this.id, this.description, this.title, this.year, this.imageUrl,
      //this.duration,this.rating
      users.add(user);
    }

    print(users.length);
    return users;
  }

//this is the main page homescreen
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                })
          ],
        ),
        body: Container(
            child: FutureBuilder(
                future: _getUsers(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(child: Center(child: Text("Loading...")));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data[index].imageUrl),
                            ),
                            title: Text(snapshot.data[index].title),
                            subtitle: Text(snapshot.data[index].rating),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPage(snapshot.data[index])));
                            },
                          );
                        });
                  }
                })));
  }
}

//this is the on click UI
class DetailPage extends StatelessWidget {
  final User user;
  DetailPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(user.title),
        ),
        body: ListView(children: <Widget>[
          SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  height: 250,
                  width: 300,
                  child: new Image(image: NetworkImage(user.imageUrl))),
              // Text("Title:" + user.title,
              //     style: TextStyle(
              //       fontSize: 25,
              //     )),
              Card(
                  color: Colors.grey,
                  child: Text("Title:" + user.title,
                      style: TextStyle(fontSize: 25, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Rating:" + user.rating,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Duration:" + user.duration,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Year of release:" + user.year,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
              Card(
                  color: Colors.grey,
                  child: Text("Description:" + user.description,
                      style: TextStyle(fontSize: 20, color: Colors.black))),
            ],
          ))
        ])
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: <Widget>[
        //     new Container(
        //         padding: EdgeInsets.all(10),
        //         height: 250,
        //         width: 300,
        //         child: new Image(image: NetworkImage(user.imageUrl))),
        //     new Center(
        //       child: Text("Title:" + user.title, style: TextStyle(fontSize: 25)),
        //     ),
        //     new Expanded(
        //         child: ListView(
        //             scrollDirection: Axis.horizontal,
        //             padding: EdgeInsets.all(10),
        //             children: <Widget>[
        //           Padding(
        //             padding: EdgeInsets.all(10),
        //           ),
        //           new Card(
        //             child: Text("Duration:" + user.duration,
        //                 style: TextStyle(fontSize: 20)),
        //             margin: EdgeInsets.all(5),
        //           ),
        //           new Card(
        //             child:
        //                 Text("Year:" + user.year, style: TextStyle(fontSize: 20)),
        //           ),
        //           Padding(
        //             padding: EdgeInsets.all(10),
        //           ),
        //         ])),
        //     new Card(
        //       child: Text("Description:" + user.description,
        //           style: TextStyle(fontSize: 20)),
        //     )
        //   ],
        // ),
        );
  }
}

class User {
  final String id;
  final String description;
  final String title;
  final String year;
  final String imageUrl;
  final String duration;
  final String rating;
  User(this.id, this.description, this.title, this.year, this.imageUrl,
      this.duration, this.rating);
}

//This class is for search
class DataSearch extends SearchDelegate<String> {
  Future<List<User>> _getUsers(query) async {
    var data = await http.get(
        "https://limitless-fortress-81406.herokuapp.com/search_data/$query");

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var u in jsonData) {
      User user = User(u["id"], u["description"], u["title"], u["year"],
          u["imageUrl"], u["duration"], u["rating"]);
      //this.id, this.description, this.title, this.year, this.imageUrl,
      //this.duration,this.rating
      users.add(user);
    }

    print(users.length);
    return users;
  }

  final cities = [];

  final recentCities = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for app bar

    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on left of appbar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    //show some result based on the selection
    return Center(
      child: Container(
          child: FutureBuilder(
              future: _getUsers(query),
              //Dio().get("https://limitless-fortress-81406.herokuapp.com/search_data/$query"),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(child: Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot.data[index].imageUrl),
                          ),
                          title: Text(snapshot.data[index].title),
                          subtitle: Text(snapshot.data[index].rating),
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(snapshot.data[index])));
                          },
                        );
                      });
                }
              }
              //    builder: (context,snapshot){
              //   if( !snapshot.hasData ) return CircularProgressIndicator();
              //   else if( snapshot.hasError ) return Text('Error');
              //   else{
              //         Response response = snapshot.data;
              //         Map dat = response.data;

              //         return
              //         ListView(
              //           children: <Widget>[
              //           SingleChildScrollView(child: Column(
              //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: <Widget>[
              //             Text("$query",style: TextStyle(fontSize: 40,)  ),
              //             Card(
              //               color: Colors.grey,
              //               child: Text(dat['result'],style: TextStyle(fontSize: 20, color: Colors.black))
              //               ),
              //           ],
              //         ))]);

              //    }
              // },
              )),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //show when someone searches for something
    int cnt = 0;
    for (int i = 0; i < cities.length; ++i) {
      if (query == cities[i]) {
        cnt++;
        break;
      }
    }
    if (cnt == 0) {
      cities.add(query);
    } else {
      cnt = 0;
    }
    //recentCities.add(query);
    final suggestionList = query.isEmpty
        ? recentCities
        : cities.where((p) => p.startsWith(query)).toList();
    //final suggestionList = recentCities;
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          if (query != "") {
            recentCities.add(query);

            showResults(context);
          } else {
            query = recentCities[index];
            showResults(context);
          }
        },
        leading: Icon(Icons.location_city),
        title: RichText(
            text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
              TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ])),
      ),
      itemCount: suggestionList.length,
    );
  }
}
