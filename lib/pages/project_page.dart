import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/pages/issue_entry_page.dart';
import 'package:lobsta_client/pages/issue_info_page.dart';
import 'package:lobsta_client/pages/project_info_page.dart';
import 'package:lobsta_client/utils/layer_control_utils.dart';

class ProjectPage extends StatefulWidget {
  final int projectId;
  final String projectTitle;

  const ProjectPage(this.projectId, this.projectTitle, {Key? key})
      : super(key: key);

  @override
  State<ProjectPage> createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {
  final DatabaseHelper _dbh = DatabaseHelper();

  int _projectId = 0;
  int _issueStat = 0;
  String _projectTitle = "";

  bool _isLoaded = false;
  Map<String, Object?> _userCred = {};
  final List<ListTile> _issueList = [];

  @override
  void initState() {
    super.initState();
    _projectId = widget.projectId;
    _projectTitle = widget.projectTitle;

    initScreen();
  }

  void initScreen() async {
    if (_userCred.isEmpty) {
      _userCred = await _dbh.getUserCredential();
    }

    _issueList.clear();
    await buildIssues();

    setState(() {
      _isLoaded = true;
    });
  }

  buildIssues() async {
    String url = _userCred["url"].toString();
    String apiToken = _userCred["redmine_token"].toString();
    String issueStatus = "*";

    switch (_issueStat) {
      case 0:
        issueStatus = "*";
        break;
      case 1:
        issueStatus = "open";
        break;
      case 2:
        issueStatus = "close";
        break;
    }

    if (url.isNotEmpty && apiToken.isNotEmpty) {
      List<Map<String, dynamic>> issues = await NetworkHelper.getProjectIssues(
          url, apiToken, _projectId, issueStatus);

      /**
       * Getting GTT Layer List and Polygon Outline
       */
      Map<String, dynamic> projectInfo =
          await NetworkHelper.getProject(url, apiToken, _projectId);

      if (projectInfo["layers"] != null) {
        List<dynamic> gttLayers = projectInfo["layers"];

        if (gttLayers.isNotEmpty) {
          LayerControlUtils.configureGttLayers(
              gttLayers.map((e) => e as Map<String, dynamic>).toList());
        } else {
          LayerControlUtils.modifiedMapLayerList = [];
          debugPrint("gttLayer is empty");
        }
      } else {
        debugPrint("gttLayer is null");
        LayerControlUtils.modifiedMapLayerList = [];
      }

      /**
       * Project Polygon Boundary
       */
      LayerControlUtils.gttBndPoly = Polygon(points: []);
      try {
        Map<String, dynamic>? geoJson = projectInfo["geojson"];

        if (geoJson != null) {
          Map<String, dynamic> geom = geoJson["geometry"];
          String geoType = geom["type"];
          List<LatLng> pts = [];

          if (geoType.toLowerCase().compareTo("multipolygon") == 0) {
            for (List pt in geom["coordinates"][0][0]) {
              pts.add(LatLng(pt[1], pt[0]));
            }
          } else if (geoType.toLowerCase().compareTo("polygon") == 0) {
            for (List pt in geom["coordinates"][0]) {
              pts.add(LatLng(pt[1], pt[0]));
            }
          }

          if (pts.isNotEmpty) {
            LayerControlUtils.createGttBndPoly(pts);
          }
        }
      } catch (e) {
        debugPrint("geoJson processing problem: ${e.toString()}");
      }

      /** x **/

      if (issues.isNotEmpty) {
        for (var issue in issues) {
          ListTile l = ListTile(
            trailing: Text(issue["status"]["name"]),
            leading: SizedBox(
              width: 70.0,
              child: Text(
                issue["priority"]["name"],
                style: TextStyle(
                    color: Colors.white,
                    backgroundColor: issue["priority"]["id"] == 2 ||
                            issue["priority"]["id"] == 5 ||
                            issue["priority"]["id"] == 6
                        ? Colors.red
                        : Colors.green),
              ),
            ),
            title: Text("${issue["subject"]} \nby ${issue["author"]["name"]}"),
            subtitle: Text("${issue["tracker"]["name"]}  "
                "${issue["done_ratio"]}% completed"),
            isThreeLine: true,
            onTap: () async {
              var ret = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return IssueInfoPage(issue["id"]);
                  },
                ),
              );

              if (ret != null) {
                setState(() {
                  _isLoaded = false;
                  initScreen();
                });
              }
            },
          );

          _issueList.add(l);
        }
      }
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
      appBar: AppBar(
        title: Text(_projectTitle),
        actions: [
          PopupMenuButton<int>(
              icon: const Icon(Icons.filter_alt),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text("All Issues"),
                      textStyle: TextStyle(
                          color: _issueStat == 0
                              ? Colors.deepOrange
                              : Colors.black),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: const Text("Open Issues"),
                      textStyle: TextStyle(
                          color: _issueStat == 1
                              ? Colors.deepOrange
                              : Colors.black),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: const Text("Closed Issues"),
                      textStyle: TextStyle(
                          color: _issueStat == 2
                              ? Colors.deepOrange
                              : Colors.black),
                      value: 2,
                    ),
                  ],
              onSelected: (i) => setState(() {
                    _issueStat = i;
                    _isLoaded = false;
                    initScreen();
                  })),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ProjectInfoPage(_projectTitle, _projectId);
                }));
              },
              icon: const Icon(Icons.info_outlined)),
          const SizedBox(
            width: 8.0,
          ),
        ],
      ),
      body: !_isLoaded
          ? waiting
          : RefreshIndicator(
              onRefresh: () async {
                _isLoaded = false;
                setState(() {});
                initScreen();
              },
              child: ListView(
                children: _issueList,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var ret = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return IssueEntryPage(_projectId);
              },
            ),
          );
          if (ret != null) {
            setState(() {
              _isLoaded = false;
              initScreen();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
