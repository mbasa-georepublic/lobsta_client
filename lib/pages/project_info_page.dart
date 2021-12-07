import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';

class ProjectInfoPage extends StatefulWidget {
  final String _projectName;
  final int _projectId;

  const ProjectInfoPage(this._projectName, this._projectId, {Key? key})
      : super(key: key);

  @override
  State<ProjectInfoPage> createState() => ProjectInfoPageState();
}

class ProjectInfoPageState extends State<ProjectInfoPage> {
  final DatabaseHelper _dbh = DatabaseHelper();

  int _projectId = 0;
  String _projectTitle = "";

  bool _isLoaded = false;
  Map<String, Object?> _userCred = {};
  Map<String, dynamic> _projectInfo = {};

  @override
  void initState() {
    super.initState();
    _projectId = widget._projectId;
    _projectTitle = widget._projectName;

    initScreen();
  }

  void initScreen() async {
    if (_userCred.isEmpty) {
      _userCred = await _dbh.getUserCredential();
    }

    String url = _userCred["url"].toString();
    String apiToken = _userCred["redmine_token"].toString();

    _projectInfo = await NetworkHelper.getProject(url, apiToken, _projectId);
    debugPrint(_projectInfo.toString());

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

    List<Widget> issueCategories = [];

    if (_projectInfo.isNotEmpty && _projectInfo["issue_categories"] != null) {
      for (var c in _projectInfo["issue_categories"]) {
        issueCategories.add(Text("- ${c["name"].toString()}"));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_projectTitle),
      ),
      body: !_isLoaded
          ? waiting
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                border: TableBorder.all(color: Colors.grey),
                children: [
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Text(_projectInfo["name"].toString()),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Description",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Text(_projectInfo["description"].toString()),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Parent",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: _projectInfo["parent"] != null
                          ? Text(_projectInfo["parent"]["name"].toString())
                          : const Text(""),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Homepage",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Text(_projectInfo["homepage"].toString()),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Issue Categories",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(7),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: issueCategories,
                        )),
                  ]),
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Public Project",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Text(_projectInfo["is_public"].toString()),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Created On",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Text(_projectInfo["created_on"].toString()),
                    ),
                  ]),
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Text(
                        "Updated On",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Text(_projectInfo["updated_on"].toString()),
                    ),
                  ]),
                ],
              ),
            ),
    );
  }
}
