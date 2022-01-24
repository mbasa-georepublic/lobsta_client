import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';

class SwitchAccountPage extends StatefulWidget {
  const SwitchAccountPage({Key? key}) : super(key: key);

  @override
  SwitchAccountPageState createState() => SwitchAccountPageState();
}

class SwitchAccountPageState extends State<SwitchAccountPage> {
  final DatabaseHelper _dbh = DatabaseHelper();
  bool _isLoaded = false;
  Widget _listPage = Container();

  @override
  void initState() {
    super.initState();
    initPage();
  }

  initPage() async {
    Map<String, Object?> presentAcct = await _dbh.getUserCredential();
    List<Map<String, Object?>> loggedAcct = await _dbh.getLoggedCredentials();

    List<Widget> la = [
      const Text(
        "Present Account",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      ListTile(
        title: Text(presentAcct["username"].toString()),
        subtitle: Text(presentAcct["url"].toString()),
        leading: const Icon(Icons.vignette_sharp),
      ),
    ];

    if (loggedAcct.isEmpty) {
      la.add(
        const SizedBox(
          height: 180,
          child: Center(
            child:
                Text("No other Accounts Registered. Login into other Accounts"),
          ),
        ),
      );
    } else {
      la.add(const SizedBox(
        height: 20,
      ));
      la.add(
        const Text(
          "Switch To Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      for (var l in loggedAcct) {
        la.add(Card(
          child: ListTile(
            leading: const Icon(
              Icons.login,
              color: Colors.green,
            ),
            title: Text(l["username"].toString()),
            subtitle: Text(l["url"].toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () async {
                bool del = await DialogUtil.showConfirmDialog(
                    context,
                    "Delete Log",
                    "Delete this Logged Account?",
                    "Cancel",
                    "Delete");

                if (del) {
                  await _dbh.deleteLoggedCredential(
                      l["username"].toString(), l["url"].toString());

                  setState(() {
                    _isLoaded = false;
                    initPage();
                  });
                }
              },
            ),
            onTap: () async {
              await _dbh.deleteUserCredential();
              await _dbh.insertUserCredential(
                  l["username"].toString(),
                  l["password"].toString(),
                  l["url"].toString(),
                  l["last_name"].toString(),
                  l["first_name"].toString(),
                  l["redmine_token"].toString(),
                  insertLog: false);
              Navigator.pop(context, true);
            },
          ),
        ));
      }
    }

    _listPage = ListView(
      padding: const EdgeInsets.all(20.0),
      children: la,
    );
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget waiting = const Center(
      child: CircularProgressIndicator(
        semanticsLabel: "Waiting",
        semanticsValue: "Waiting",
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Switch Account"),
        centerTitle: true,
      ),
      body: _isLoaded ? _listPage : waiting,
    );
  }
}
