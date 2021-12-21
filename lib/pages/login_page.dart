import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';

import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbh = DatabaseHelper();

  String _user = "";
  String _password = "";
  String _url = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("LOBSTA Client"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(
                  height: 32,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(200, 200, 201, 1.0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: TextFormField(
                    obscureText: false,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Field can not be empty";
                      }
                      _user = v;
                      return null;
                    },
                    //style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(200, 200, 201, 1.0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: TextFormField(
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Field can not be empty";
                      }
                      _password = v;
                      return null;
                    },
                    //style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(200, 200, 201, 1.0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.url,
                    obscureText: false,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Field can not be empty";
                      } else if (!Uri.parse(v).isAbsolute) {
                        return "Not a valid URL Address";
                      }
                      _url = v;
                      return null;
                    },
                    //style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Redmine Server URL',
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                SizedBox(
                  width: 160,
                  height: 40,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: const BorderSide(color: Colors.red)))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          DialogUtil.showOnSendDialog(
                              context, "Sending Login Information");

                          String apiToken = await NetworkHelper.getApiKey(
                              _user, _password, _url);

                          Navigator.pop(context);

                          if (apiToken.isNotEmpty) {
                            debugPrint("Registered: $apiToken");

                            _dbh.insertUserCredential(
                                _user, _password, _url, apiToken);

                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(
                              builder: (context) {
                                return const MainPage();
                              },
                            ), (route) => false);
                          } else {
                            DialogUtil.showCustomDialog(
                                context,
                                "Error",
                                "An Error has Occurred. \nCheck entered parameters.",
                                "Close");
                          }
                        }
                      },
                      child: const Text("Send")),
                ),
              ],
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
