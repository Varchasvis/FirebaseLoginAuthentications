import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication/services/auth_service.dart';
import 'package:firebase_authentication/widgets/provider_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

///class User is used to extract data from the json data from the server
/// the fields exactly match the fields in the JSON data
class User {
  final int userId;
  final int id;
  final String title;
  final String body;

  User({this.userId, this.id, this.title, this.body}); //constructor

  factory User.fromJson(Map<String, dynamic> json) {
    //This is a mapping function
    //it maps between a string and a dynamic type, Dynamic can be any type
    //The Dynamic types are the different fields as mentioned above
    return User(
        userId: json['userId'],
        id: json['id'],
        title: json['title'],
        body: json['body']);
  }
}

Future<User> fetchUser(int x) async {
  //async is used for future libraries
  //it waits till it gets a response, meanwhile the other processes continue
  //when it does finally have a value it updates

  final response =
      await http.get('https://jsonplaceholder.typicode.com/posts/$x');
//The http.get() method returns a Future that contains a Response

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print('Status code = 200\n');
    return User.fromJson(
        json.decode(response.body)); //decodes the json response
    //uses the factory constructor mentioned above to construct a User object
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print('Status code : ERROR\n');
    throw Exception('Failed to load User data');
  }
}

final collection = Set<String>(); //collection is a Set containing the Strings:

//'00','01','02'.....'09'
//used to construct the call to the image assets
class ImageDisplayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int w = ModalRoute.of(context).settings.arguments;
    //This variable w gets its value through a RouteSettings
    return Scaffold(
      appBar: AppBar(
        title: Text('Enlarged Image'),
      ),
      body: Image.asset('book_images/' + collection.elementAt(w - 1) + '.jpg'),
    );
  }
}

class Listings extends StatefulWidget {
  @override
  _ListingsState createState() => _ListingsState();
}

class _ListingsState extends State<Listings> {
  final cart = Set<String>(); //contains list of books already in the cart
  final int numberOfBooks =
      10; //depending on the number of images in the book_images asset

  Future<User> futureUser; //A template of sorts
  //A Future of type class User
  @override
  void initState() {
    //called only once to initialize
    super.initState(); //called to initialize the base class
    futureUser = fetchUser(5); //initiates the Future of type User
  }

  void internetData() {
    //Page compiling the list of posts from the given url
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Internet Data'),
            ),
            body: ListView(
              children: <Widget>[
                for (int w = 1; w <= 10; w++)
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDisplayer(),
                          // Pass the arguments as part of the RouteSettings. The
                          // imageDisplayer reads the arguments from these settings.
                          settings: RouteSettings(
                            arguments: w,
                          ),
                        ),
                      );
                    },
                    leading: Container(
                      height: 60.0,
                      width: 40.0,
                      alignment: Alignment.topRight,
                      child: Image.asset('book_images/' +
                          collection.elementAt(w - 1) +
                          '.jpg'),
                    ),
                    title: FutureBuilder<User>(
                      //like ListView Builder, constructed of a series of futures
                      future: futureUser = fetchUser(w),
                      builder: (context, snapshot) {
                        //snapshot is the data from the future
                        if (snapshot.hasData) {
                          //The call has been correct and data is retrieved
                          print('Data found\n');
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment
                                .start, //To align text to the left
                            children: <Widget>[
                              Text('User Id :' +
                                  snapshot.data.userId.toString()),
                              Text('Id :' + snapshot.data.id.toString()),
                              Text('Title :' + snapshot.data.title),
                              Text('Body :' + snapshot.data.body),
                              Divider(
                                //adds a 1 pixel wide divider between the tiles
                                color: Colors.blueAccent,
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          print('Error detected\n');
                          return Text("${snapshot.error}");
                        }
                        // By default, show a loading spinner.
                        print('Spinning\n');
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
              ],
            ),
          );
        }, //build context
      ),
    ); //Navigator
  }

  Widget browse() {
    //main List with images on the home page
    for (int x = 0; x < numberOfBooks; x++) collection.add('0' + x.toString());

    return Scaffold(
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: numberOfBooks *
              2, //twice, as we alternatively we are adding a divider
          scrollDirection: Axis.vertical,
          itemBuilder: (context, i) {
            if (i.isOdd)
              return Divider(
                color: Colors.blue,
              );
            int r = i ~/ 2; // ~/ is int division
            return buildTile(r); //r=0,,1,2,3...9
          }),
      floatingActionButton: CircleAvatar(
        child: IconButton(
          //to get to the internet data
          icon: Icon(
            Icons.book,
            color: Colors.yellow,
            size: 30.0,
          ),
          onPressed: internetData, //goes to the internet loaded page
        ),
        radius: 25.0,
        backgroundColor: Colors.blueAccent.shade200,
      ),
    );
  }

  Widget buildTile(int bookNumber) {
    //builds the individual tiles for the main page
    final boolVal = cart.contains(collection.elementAt(bookNumber));
    return ListTile(
      leading: Image.asset(
          'book_images/' + collection.elementAt(bookNumber) + '.jpg'),
      title: Text('Book ' + collection.elementAt(bookNumber)),
      trailing: Icon(
        (Icons.add),
        color: boolVal ? Colors.red : Colors.grey,
      ),
      onTap: () {
        setState(() {
          if (boolVal) {
            //if the item is already in the cart remove it
            cart.remove(collection.elementAt(bookNumber));
          } else {
            //else add it
            cart.add(collection.elementAt(bookNumber));
          }
        });
      },
    );
  }

  void openCart() {
    //creates the page of the cart
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Center(child: Text('Your Cart')),
            ),
            body: ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                for (String n in cart)
                  Column(
                    children: [
                      ListTile(
                        leading: Image.asset('book_images/' + n + '.jpg'),
                        title: Text('Book ' + n),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //the main build method
    //this is where it all starts when the stateful widget Listings() is called
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.undo),
          onPressed: () async {
            try {
              AuthService auth = Provider.of(context).auth;
              await auth.signOut();
              print('Signed Out');
            } catch (e) {
              print(e);
            }
          },
        ),
        centerTitle: true,
        title: Text('Listings:'),
        backgroundColor: Colors.blueAccent.shade200,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            iconSize: 40.0,
            color: Colors.yellow.shade400,
            hoverColor: Colors.indigo,
            onPressed: openCart,
          ),
        ],
      ),
      body: SafeArea(
        child: browse(), //creates the ListTile View
      ),
    );
  }
}
