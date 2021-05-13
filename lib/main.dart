import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class User {
  final String id;
  final String firstName;
  final String lastName;

  User({this.id, this.firstName, this.lastName});
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<User> users = [];
  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: Text("Create"),
                  onPressed: _create,
                ),
                TextButton(
                  child: Text("Read"),
                  onPressed: _read,
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return Dismissible(
                    onDismissed: (val) {
                      _delete("${users[index].id}");
                    },
                    key: Key("${users[index].id}"),
                    child: ListTile(
                      title: Text(
                          "${users[index].firstName} ${users[index].lastName}"),
                      trailing: TextButton(
                        child: Text("Update"),
                        onPressed: () => _update(users[index].id.toString()),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: users.length,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _create() async {
    try {
      var faker = new Faker();
      await firestore
          .collection('users')
          .doc('${Random.secure().nextInt(9999999)}')
          .set({
        'first_name': '${faker.person.firstName()}',
        'last_name': '${faker.person.lastName()}',
      });
      _read();
    } catch (e) {
      print(e);
    }
  }

  void _update(String id) async {
    try {
      var faker = new Faker();
      firestore.collection('users').doc('$id').update({
        'first_name': '${faker.person.firstName()}',
        'last_name': '${faker.person.lastName()}',
      });
      _read();
    } catch (e) {
      print(e);
    }
  }

  void _read() async {
    try {
      users.clear();
      var usersData = await firestore.collection('users').get();
      usersData.docs.forEach((element) {
        var data = element.data();
        setState(() {
          users.add(User(
            id: element.id,
            firstName: data['first_name'],
            lastName: data['last_name'],
          ));
        });
      });
      // documentSnapshot = await firestore
      //     .collection('users')
      //     .doc('user0.4011772341903397')
      //     .get();
      // print(documentSnapshot.data());
    } catch (e) {
      print(e);
    }
  }

  void _delete(String id) async {
    try {
      firestore.collection('users').doc('$id').delete();
      _read();
    } catch (e) {
      print(e);
    }
  }
}
