import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/pages/issue_info_page.dart';
import 'package:lobsta_client/pages/login_page.dart';
import 'package:lobsta_client/pages/profile_page.dart';
import 'package:lobsta_client/pages/project_page.dart';
import 'package:lobsta_client/pages/switch_account_page.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';
import 'package:lobsta_client/utils/layer_control_utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool _isLoaded = false;
  bool _diableNavBar = false;

  int _bottomBarSel = 0;
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

  void handleMenu(int code) async {
    switch (code) {
      case 1: //logout
        await _dbh.deleteUserCredential();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return const LoginPage();
          },
        ), (route) => false);
        break;
      case 2:
        bool? retVal = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return const SwitchAccountPage();
          }),
        );
        if (retVal != null && retVal) {
          setState(() {
            _isLoaded = false;
            _bottomBarSel = 0;
            initScreen();
          });
        }
        break;
      case 3:
        DialogUtil.showCustomDialog(
            context,
            "About",
            "Location Based Tracker (LOBSTA) Client\n"
                "for the LOBSTA Project Management System",
            "Close");
        break;
    }
  }

  Future<List<Widget>> buildMyTasks() async {
    List<Widget> retVal = [];
    LayerControlUtils.modifiedMapLayerList = [];

    String url = _userCred["url"].toString();
    String apiToken = _userCred["redmine_token"].toString();

    if (url.isNotEmpty && apiToken.isNotEmpty) {
      List<Map<String, dynamic>> issues =
          await NetworkHelper.getMyTasks(url, apiToken);

      if (issues.isNotEmpty) {
        for (var p in issues) {
          int id = p["id"];
          String subject = p["subject"].toString();
          String desc = p["project"]?["name"];

          retVal.add(
            ListTile(
              title: Text(subject),
              subtitle: Text(desc),
              isThreeLine: false,
              leading: const Icon(Icons.list_alt),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return IssueInfoPage(id);
                  }),
                );
                await redraw();
              },
            ),
          );
        }
      }
    }
    return retVal;
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
        List<Widget> arr = await buildMyTasks();
        if (arr.isEmpty) {
          _mainWidget = Container(
            alignment: Alignment.center,
            child: const Text("No Tasks Assigned To Me"),
          );
        } else {
          _mainWidget = RefreshIndicator(
            onRefresh: () async {
              await redraw();
            },
            child: ListView(
              children: arr,
            ),
          );
        }
        break;
      case 1:
        List<Widget> arr = await buildProjects();
        _mainWidget = RefreshIndicator(
          onRefresh: () async {
            await redraw();
          },
          child: ListView(
            children: arr,
          ),
        );
        break;
      case 2:
        _mainWidget = ProfilePage(_userCred);
        break;
      default:
        _mainWidget = Container();
        break;
    }
  }

  redraw() async {
    setState(() {
      _isLoaded = false;
      _diableNavBar = true;
    });

    await buildMainWidget();
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoaded = true;
      _diableNavBar = false;
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
      body: Scaffold(
        body: !_isLoaded ? waiting : _mainWidget,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("LOBSTA Client"),
          //leading: const Icon(Icons.eleven_mp),
          //primary: false,
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text("About"),
                  value: 3,
                ),
                const PopupMenuDivider(
                  height: 4.0,
                ),
                const PopupMenuItem(
                  child: Text("Switch Account"),
                  value: 2,
                ),
                const PopupMenuDivider(
                  height: 4.0,
                ),
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
            /*
            BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm),
              label: "Timer",
            ),
             */
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: "Profile",
            ),
          ],
          onTap: _diableNavBar
              ? null
              : (i) async {
                  _bottomBarSel = i;
                  await redraw();
                },
        ),
      ),
    );
  }
}
