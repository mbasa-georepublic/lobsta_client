import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';
import 'package:location/location.dart';

class IssueEditPage extends StatefulWidget {
  final Map<String, dynamic> _issue;

  const IssueEditPage(this._issue, {Key? key}) : super(key: key);

  @override
  IssueEditPageState createState() => IssueEditPageState();
}

class IssueEditPageState extends State<IssueEditPage> {
  final DatabaseHelper _dbh = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  String _mUrl = "";
  String _apiKey = "";
  String _subject = "";
  String _description = "";
  String _newNote = "";
  String _startDate = DateTime.now().toIso8601String().split("T")[0];
  String _dueDate = DateTime.now().toIso8601String().split("T")[0];

  final List<DropdownMenuItem<int>> _trackers = [];
  final List<DropdownMenuItem<int>> _users = [];
  final List<DropdownMenuItem<int>> _doneRatio = [];
  final List<DropdownMenuItem<int>> _issueStatus = [];

  bool _isLoaded = false;
  bool _isPrivate = true;
  bool _isPriority = false;
  bool _useLocation = false;

  int _assignedTo = 0;
  int _trackerId = 0;
  int _projectId = 0;
  int _doneRatioId = 0;
  int _issueStatusId = 0;

  Map<String, dynamic> _issue = {};

  @override
  void initState() {
    super.initState();
    _issue = widget._issue;
    _projectId = _issue["project"]["id"] as int;
    _subject = _issue["subject"] ?? "";
    _description = _issue["description"] ?? "";
    _startDate = _issue["start_date"] ?? "--";
    _dueDate = _issue["due_date"] ?? "--";
    _assignedTo = _issue["assigned_to"]?["id"] ?? 0;
    _issueStatusId = _issue["status"]?["id"] ?? 0;

    //debugPrint("Issue: ${_issue.toString()}");

    _isPrivate = _issue["is_private"] ?? false;
    _trackerId = _issue["tracker"]["id"] ?? 0;
    _doneRatioId = _issue["done_ratio"] ?? 0;

    initScreen();
  }

  initScreen() async {
    if (_mUrl.isEmpty && _apiKey.isEmpty) {
      var r = await _dbh.getUserCredential();

      _mUrl = r["url"].toString();
      _apiKey = r["redmine_token"].toString();
    }

    var trackers = await NetworkHelper.getTrackers(_mUrl, _apiKey);
    var issueStatus = await NetworkHelper.getIssueStatus(_mUrl, _apiKey);
    var members =
        await NetworkHelper.getMemberships(_mUrl, _apiKey, _projectId);

    _issueStatus.clear();
    _trackers.clear();
    _users.clear();
    _doneRatio.clear();

    for (int c = 0; c < 110; c += 10) {
      _doneRatio.add(
        DropdownMenuItem(
          child: Text(" $c% "),
          value: c,
        ),
      );
    }

    for (Map<String, dynamic> s in issueStatus) {
      _issueStatus.add(
        DropdownMenuItem(
          child: Text(s["name"].toString()),
          value: s["id"],
        ),
      );
    }

    for (Map<String, dynamic> t in trackers) {
      _trackers.add(
        DropdownMenuItem(
          child: Text(t["name"].toString()),
          value: t["id"],
        ),
      );
    }

    //_assignedTo = 0; //members[0]["user"]["id"];
    _users.add(const DropdownMenuItem(
      child: Text(""),
      value: 0,
    ));

    if (members.isNotEmpty) {
      for (Map<String, dynamic> u in members) {
        if (u["user"] == null) {
          continue;
        }
        _users.add(DropdownMenuItem(
          child: Text("${u["user"]["name"]}"),
          value: u["user"]["id"],
        ));
      }
    } else {
      _assignedTo = 0;
    }

    setState(() {
      _isLoaded = true;
    });
  }

  Future<void> _selectDate(BuildContext context,
      {bool isStartDate = true}) async {
    DateTime dateTime = DateTime.now();

    if (isStartDate) {
      if (_startDate.isNotEmpty && _startDate.length > 2) {
        dateTime = DateTime.parse(_startDate);
      }
    } else {
      if (_dueDate.isNotEmpty && _dueDate.length > 2) {
        dateTime = DateTime.parse(_dueDate);
      }
    }

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: dateTime,
      lastDate: DateTime(2080),
    );
    if (selected != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selected.toIso8601String().split("T")[0];
        } else {
          _dueDate = selected.toIso8601String().split("T")[0];
        }
      });
    }
  }

  postIssue() async {
    Map<String, dynamic> issueParams = {
      "issue_id": _issue["id"],
      "subject": _subject,
      "description": _description,
      "tracker_id": _trackerId,
      "status_id": _issueStatusId,
      "done_ratio": _doneRatioId,
    };

    if (_newNote.isNotEmpty) {
      issueParams["notes"] = _newNote;
    }

    if (_assignedTo > 0) {
      issueParams["assigned_to_id"] = _assignedTo;
    }

    if (_startDate.length > 2) {
      issueParams["start_date"] = _startDate;
    }

    if (_dueDate.length > 2) {
      issueParams["due_date"] = _dueDate;
    }

    DialogUtil.showOnSendDialog(context, "Submitting Issue");

    if (_useLocation) {
      try {
        Location location = Location();
        var l = await location.getLocation();
        debugPrint("Location: ${l.toString()}");

        issueParams["geojson"] = "{\"type\": \"Feature\",\"properties\": {},"
            "\"geometry\": {\"type\": \"Point\",\"coordinates\": "
            "[${l.longitude},${l.latitude}]}}";
      } catch (e) {
        debugPrint("Location Error: ${e.toString()}");
      }
    }

    Map<String, dynamic> issue = {"issue": issueParams};

    var r = await NetworkHelper.postIssue(_mUrl, _apiKey, issue);
    Navigator.pop(context);

    if (r["status_code"] != 204) {
      DialogUtil.showCustomDialog(context, "Error",
          "An Error has Occurred. \nCheck entered parameters.", "Close");
    } else {
      Navigator.pop(context, true);
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
        title: Text("Update Issue #${_issue["id"]}"),
      ),
      body: !_isLoaded
          ? waiting
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("Subject"),
                      ),
                      title: TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        initialValue: _subject,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Field can not be empty";
                          }
                          _subject = v;
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("Description"),
                      ),
                      title: TextFormField(
                        maxLines: 2,
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        initialValue: _description,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Field can not be empty";
                          }
                          _description = v;
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("Assigned To"),
                      ),
                      title: DropdownButtonFormField(
                        items: _users,
                        value: _assignedTo,
                        onChanged: (i) {
                          _assignedTo = i as int;
                          debugPrint("User: $_assignedTo");
                        },
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("Done Ratio"),
                      ),
                      title: DropdownButtonFormField(
                        items: _doneRatio,
                        value: _doneRatioId,
                        onChanged: (i) {
                          _doneRatioId = i as int;
                        },
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("Status"),
                      ),
                      title: DropdownButtonFormField(
                        items: _issueStatus,
                        value: _issueStatusId,
                        onChanged: (i) {
                          _issueStatusId = i as int;
                        },
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("Tracker"),
                      ),
                      title: DropdownButtonFormField(
                        items: _trackers,
                        value: _trackerId,
                        onChanged: (i) {
                          _trackerId = i as int;
                          debugPrint("Tracker: $_trackerId");
                        },
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("StartDate"),
                      ),
                      title: OutlinedButton(
                        onPressed: () => _selectDate(context),
                        child: Text(_startDate),
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                        child: Text("DueDate"),
                      ),
                      title: OutlinedButton(
                        onPressed: () =>
                            _selectDate(context, isStartDate: false),
                        child: Text(_dueDate),
                      ),
                    ),
                    ListTile(
                      leading: const SizedBox(
                        width: 110,
                      ),
                      title: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        value: _useLocation,
                        onChanged: (v) {
                          _useLocation = v!;
                          setState(() {});
                        },
                        title: const Text(
                          "Update Location Information\nTo Present Position",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "New Issue Note",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            _newNote = v;
                          }
                          return null;
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          postIssue();
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
