import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/pages/img_view_page.dart';
import 'package:lobsta_client/pages/issue_edit_page.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';

import 'issue_mapview_page.dart';

class IssueInfoPage extends StatefulWidget {
  final int _issueId;
  const IssueInfoPage(this._issueId, {Key? key}) : super(key: key);

  @override
  State<IssueInfoPage> createState() => IssueInfoPageState();
}

class IssueInfoPageState extends State<IssueInfoPage> {
  Map<String, dynamic> _issue = {};
  Map<String, Object?> _userCred = {};

  String _url = "";
  String _apiToken = "";
  int _issueId = -1;

  LatLng _latLng = LatLng(0, 0);

  final DatabaseHelper _dbh = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _issueId = widget._issueId;

    getIssue();
  }

  getIssue() async {
    if (_userCred.isEmpty) {
      _userCred = await _dbh.getUserCredential();

      _url = _userCred["url"].toString();
      _apiToken = _userCred["redmine_token"].toString();
    }

    _issue = await NetworkHelper.getIssue(_url, _apiToken, _issueId);
    debugPrint("ISSUE: ${_issue.toString()}");
    if (_issue["geojson"] != null && _issue["geojson"].toString().isNotEmpty) {
      try {
        Map<String, dynamic> geom = _issue["geojson"]["geometry"];

        if (geom.isNotEmpty && geom["type"] == "Point") {
          _latLng = LatLng(geom["coordinates"][1], geom["coordinates"][0]);
          debugPrint("LatLng: ${_latLng.toString()}");
        }
      } catch (e) {
        debugPrint("GeoJSON Error: ${e.toString()}");
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget waiting = const Center(
      child: CircularProgressIndicator(
        semanticsLabel: "Waiting",
        semanticsValue: "Waiting",
      ),
    );

    List<Widget> imgAttachments = [];
    List<Widget> noteJournals = [];
    List<Widget> mapLocation = [];

    if (_latLng.longitude != 0 && _latLng.latitude != 0) {
      mapLocation.add(
        const Text(
          "Location",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      mapLocation.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return IssueMapViewPage(
                      _latLng,
                      forEdit: false,
                    );
                  }),
                );
              },
              label: const Text("Open Map"),
              icon: const Icon(
                Icons.add_location_alt_outlined,
                size: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_issue.isNotEmpty && _issue["journals"] != null) {
      bool isFirst = true;

      for (var j in _issue["journals"]) {
        if (j["notes"] != null && j["notes"].toString().isNotEmpty) {
          if (isFirst) {
            isFirst = false;
            noteJournals.add(const Text(
              "Notes",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ));
          }
          noteJournals.add(Card(
            elevation: 1.5,
            color: const Color.fromRGBO(238, 238, 232, 1),
            child: ListTile(
              isThreeLine: false,
              title: Text(j["notes"].toString()),
              subtitle: Text(
                "by ${j["user"]["name"].toString()} on "
                "${j["created_on"]}",
                style: const TextStyle(color: Colors.deepOrangeAccent),
              ),
            ),
          ));
        }
      }
    }

    if (_issue.isNotEmpty && _issue["attachments"] != null) {
      bool isFirst = true;

      for (var a in _issue["attachments"]) {
        if (a["content_type"].toString().contains("image")) {
          if (isFirst) {
            imgAttachments.add(const Text(
              "Attachments",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ));
            isFirst = false;
          }

          Widget w = TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              padding: MaterialStateProperty.all(const EdgeInsets.all(0.0)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ImageViewPage(
                    a["content_url"].toString(), a["filename"].toString());
              }));
            },
            child: Text(
              a["filename"].toString(),
              style: const TextStyle(color: Colors.blue),
            ),
          );
          imgAttachments.add(w);
        }
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Issue #$_issueId"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                if (_issue.isNotEmpty) {
                  var s = await Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return IssueEditPage(_issue);
                    },
                  ));

                  if (s != null) {
                    setState(() {
                      _issue = {};
                      getIssue();
                    });
                  }
                }
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: () async {
                bool del = await DialogUtil.showConfirmDialog(context, "Delete",
                    "Delete Issue #$_issueId?", "Cancel", "Delete");

                if (del) {
                  DialogUtil.showOnSendDialog(context, "Deleting Issue");

                  bool ret = await NetworkHelper.deleteIssue(
                      _url, _apiToken, _issueId);
                  debugPrint("Delete: ${ret.toString()}");

                  if (ret) {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  } else {
                    DialogUtil.showCustomDialog(
                        context, "Error", "An Error Occurred", "Close");
                  }
                }
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: _issue.isEmpty
            ? waiting
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(3),
                      },
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Subject",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: Text(_issue["subject"].toString()),
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
                            child: Text(_issue["description"].toString()),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Author",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: Text(_issue["author"]["name"].toString()),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Assigned To",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: _issue["assigned_to"] != null
                                ? Text(_issue["assigned_to"]["name"].toString())
                                : const Text(""),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Start Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: _issue["start_date"].toString() != 'null'
                                ? Text(_issue["start_date"].toString())
                                : const Text(""),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Due Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: _issue["due_date"].toString() != 'null'
                                ? Text(_issue["due_date"].toString())
                                : const Text(""),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Done Ratio",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: Text("${_issue["done_ratio"].toString()}%"),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Spent Hours",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: Text(
                                "${numFormat(_issue["total_spent_hours"] ?? 0.0)} h"),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Tracker",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: Text(_issue["tracker"]["name"].toString()),
                          ),
                        ]),
                        TableRow(children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: const Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            child: Text(_issue["status"]["name"].toString()),
                          ),
                        ]),
                      ],
                    ),
                    SizedBox(
                      height: imgAttachments.isEmpty ? 0.0 : 16.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: imgAttachments,
                    ),
                    SizedBox(
                      height: mapLocation.isEmpty ? 0.0 : 16.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: mapLocation,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: noteJournals,
                    )
                  ],
                ),
              ));
  }

  String numFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
