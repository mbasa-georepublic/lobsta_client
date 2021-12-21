import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';
import 'package:location/location.dart';

class IssueEntryPage extends StatefulWidget {
  final int _projectId;

  const IssueEntryPage(this._projectId, {Key? key}) : super(key: key);

  @override
  IssueEntryPageState createState() => IssueEntryPageState();
}

class IssueEntryPageState extends State<IssueEntryPage> {
  final DatabaseHelper _dbh = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  final List<DropdownMenuItem<int>> _trackers = [];
  final List<DropdownMenuItem<int>> _users = [];
  bool _isLoaded = false;
  bool _isPrivate = true;
  bool _isPriority = false;
  bool _useLocation = true;

  int _userId = 0;
  int _trackerId = 0;
  int _projectId = 0;

  String _mUrl = "";
  String _apiKey = "";
  String _subject = "";
  String _description = "";
  String _startDate = DateTime.now().toIso8601String().split("T")[0];
  String _dueDate = DateTime.now().toIso8601String().split("T")[0];

  @override
  void initState() {
    super.initState();
    _projectId = widget._projectId;
    initScreen();
  }

  initScreen() async {
    if (_mUrl.isEmpty && _apiKey.isEmpty) {
      var r = await _dbh.getUserCredential();

      _mUrl = r["url"].toString();
      _apiKey = r["redmine_token"].toString();
    }

    var trackers = await NetworkHelper.getTrackers(_mUrl, _apiKey);
    var members =
        await NetworkHelper.getMemberships(_mUrl, _apiKey, _projectId);

    _trackers.clear();
    _users.clear();

    if (trackers.isNotEmpty) {
      _trackerId = trackers[0]["id"];
    }
    for (Map<String, dynamic> t in trackers) {
      _trackers.add(
        DropdownMenuItem(
          child: Text(t["name"].toString()),
          value: t["id"],
        ),
      );
    }

    if (members.isNotEmpty) {
      _userId = 0; //members[0]["user"]["id"];
      _users.add(const DropdownMenuItem(
        child: Text(""),
        value: 0,
      ));

      for (Map<String, dynamic> u in members) {
        if (u["user"] == null) {
          continue;
        }
        _users.add(DropdownMenuItem(
          child: Text("${u["user"]["name"]}"),
          value: u["user"]["id"],
        ));
      }
    }

    setState(() {
      _isLoaded = true;
    });
  }

  Future<void> _selectDate(BuildContext context,
      {bool isStartDate = true}) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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

  _submitIssue() async {
    Map<String, dynamic> issueParams = {
      "issue_id": -999,
      "project_id": _projectId,
      "subject": _subject,
      "description": _description,
      "tracker_id": _trackerId,
      //"assigned_to_id": _userId,
      "is_private": _isPrivate,
      "priority_id": _isPriority ? 2 : 1,
      "start_date": _startDate,
      "due_date": _dueDate,
    };

    if (_userId > 0) {
      issueParams["assigned_to_id"] = _userId;
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

    if (r["status_code"] != 201) {
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
          title: const Text("New Issue"),
          centerTitle: true,
        ),
        body: !_isLoaded
            ? waiting
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const SizedBox(
                          width: 110,
                          child: Text("Subject"),
                        ),
                        title: TextFormField(
                          keyboardType: TextInputType.text,
                          obscureText: false,
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
                          value: _userId,
                          onChanged: (i) {
                            _userId = i as int;
                            debugPrint("User: $_userId");
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
                          value: _isPrivate,
                          onChanged: (v) {
                            _isPrivate = v!;
                            setState(() {});
                          },
                          title: const Text(
                            "Private",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const SizedBox(
                          width: 110,
                        ),
                        title: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          value: _isPriority,
                          onChanged: (v) {
                            _isPriority = v!;
                            setState(() {});
                          },
                          title: const Text(
                            "Priority",
                            style: TextStyle(fontSize: 15),
                          ),
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
                            "Use Present Location",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _submitIssue();
                            }
                          },
                          child: const Text("Submit Issue"),
                        ),
                      )
                    ],
                  ),
                ),
              ));
  }
}