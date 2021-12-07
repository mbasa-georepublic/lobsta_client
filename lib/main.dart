import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/pages/login_page.dart';
import 'package:lobsta_client/pages/main_page.dart';

void main() async {
  DatabaseHelper dbh = DatabaseHelper();
  String userToken = await dbh.getUserToken();

  runApp(MyApp(userToken.isNotEmpty));
}

class MyApp extends StatelessWidget {
  final bool _isLoggedIn;

  const MyApp(this._isLoggedIn, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPrint("isLoggedIn: $_isLoggedIn");

    return MaterialApp(
      title: 'Lobsta Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: _isLoggedIn ? const MainPage() : const LoginPage(),
    );
  }
}
