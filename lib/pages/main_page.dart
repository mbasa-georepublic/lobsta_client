import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/pages/login_page.dart';
import 'package:lobsta_client/pages/project_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool _isLoaded = false;
  int _bottomBarSel = 1;
  Map<String, Object?> _userCred = {};
  Widget _mainWidget = Container();

  final DatabaseHelper _dbh = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    initScreen();
  }

  void initScreen() async {
    _userCred = await _dbh.getUserCredential();
    await buildMainWidget();

    setState(() {
      _isLoaded = true;
    });
  }

  void handleMenu(int code) {
    debugPrint("Code: $code");
    switch (code) {
      case 1: //logout
        _dbh.deleteUserCredential();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return const LoginPage();
          },
        ), (route) => false);
        break;
    }
  }

  Future<List<Widget>> buildProjects() async {
    List<Widget> retVal = [];

    String url = _userCred["url"].toString();
    String apiToken = _userCred["redmine_token"].toString();

    if (url.isNotEmpty && apiToken.isNotEmpty) {
      List<Map<String, dynamic>> projects =
          await NetworkHelper.getUserProjects(url, apiToken);

      if (projects.isNotEmpty) {
        for (var p in projects) {
          int id = p["id"];
          String projName = p["name"].toString();

          retVal.add(ListTile(
            title: Text(projName),
            subtitle: Text(p["description"].toString()),
            isThreeLine: true,
            leading: const Icon(Icons.wallet_travel),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return ProjectPage(id, projName);
              }),
            ),
          ));
        }
      }
    }
    return retVal;
  }

  buildMainWidget() async {
    switch (_bottomBarSel) {
      case 0:
        _mainWidget = Container();
        break;
      case 1:
        List<Widget> arr = await buildProjects();
        _mainWidget = SingleChildScrollView(
          child: Column(
            children: arr,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        );
        break;
      case 2:
        _mainWidget = Container();
        break;
      default:
        _mainWidget = Container();
        break;
    }
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
      body: Scaffold(
        body: !_isLoaded ? waiting : _mainWidget,
        appBar: AppBar(
          //centerTitle: true,
          title: const Text("Easy Redmine Copy"),
          //leading: const Icon(Icons.eleven_mp),
          //primary: false,
          actions: [
            const Icon(Icons.favorite),
            const SizedBox(
              width: 8.0,
            ),
            const Icon(Icons.search),
            const SizedBox(
              width: 8.0,
            ),
            const Icon(Icons.filter_alt),
            const SizedBox(
              width: 8.0,
            ),
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text("Log out"),
                  value: 1,
                ),
              ],
              icon: const Icon(Icons.more_vert),
              onSelected: (i) => handleMenu(i),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white70,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: _bottomBarSel,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: "My Tasks",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_travel),
              label: "Projects",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm),
              label: "Timer",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: "Profile",
            ),
          ],
          onTap: (i) async {
            _bottomBarSel = i;
/*
            DialogUtil.showOnSendDialog(context, "Processing");
            await buildMainWidget();
            Navigator.pop(context);
*/
            _isLoaded = false;
            setState(() {});
            await buildMainWidget();
            _isLoaded = true;
            setState(() {});
          },
        ),
      ),
    );
  }
}
