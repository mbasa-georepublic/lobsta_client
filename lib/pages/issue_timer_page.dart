import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';

class IssueTimerPage extends StatefulWidget {
  final int _issueId;
  const IssueTimerPage(this._issueId, {Key? key}) : super(key: key);

  @override
  IssueTimerPageState createState() => IssueTimerPageState();
}

class IssueTimerPageState extends State<IssueTimerPage> {
  bool _isLoaded = false;
  bool _isRunning = false;
  String _mUrl = "";
  String _apiKey = "";
  int _timeActivity = 0;
  double _timeDiff = 0.0;
  DateTime _startTime = DateTime.now();
  DateTime _stopTime = DateTime.now();

  final List<DropdownMenuItem<int>> _timeActivities = [];
  final DatabaseHelper _dbh = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    getTimeActivities();
  }

  getTimeActivities() async {
    if (_mUrl.isEmpty && _apiKey.isEmpty) {
      var r = await _dbh.getUserCredential();

      _mUrl = r["url"].toString();
      _apiKey = r["redmine_token"].toString();
    }

    var timeActivities =
        await NetworkHelper.getTimeEntryActivities(_mUrl, _apiKey);

    for (Map<String, dynamic> ta in timeActivities) {
      if (ta["active"] == true) {
        _timeActivity = ta["id"];
        _timeActivities.add(
          DropdownMenuItem(
            child: Text(ta["name"].toString()),
            value: ta["id"],
          ),
        );
      }
    }

    setState(() {
      _isLoaded = true;
    });
  }

  updateSpentTime() async {
    DialogUtil.showOnSendDialog(context, "Submitting Issue");

    Map<String, dynamic> params = {
      "time_entry": {
        "issue_id": widget._issueId,
        "hours": _timeDiff,
        "activity_id": _timeActivity,
      }
    };

    Map<String, dynamic> retVal =
        await NetworkHelper.postSpentHours(_mUrl, _apiKey, params);

    Navigator.pop(context);

    if (retVal["status_code"] != 201) {
      DialogUtil.showCustomDialog(
          context, "Error", "An Error has Occurred.", "Close");
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
        title: Text(
          "Issue #${widget._issueId} Timer",
        ),
      ),
      body: !_isLoaded
          ? waiting
          : _timeActivities.isEmpty
              ? const Center(
                  child: Text("No Time Activity Set. "
                      "Please Contact your Administrator."),
                )
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          if (!_isRunning) {
                            _startTime = DateTime.now();
                            _isRunning = true;
                          } else {
                            _stopTime = DateTime.now();
                            _timeDiff +=
                                _stopTime.difference(_startTime).inSeconds /
                                    3600;
                            _startTime = DateTime.now();
                            _isRunning = false;
                          }
                        }),
                        child: Text(
                          _isRunning
                              ? "Stop"
                              : _timeDiff == 0
                                  ? "Start"
                                  : "Continue",
                          style: const TextStyle(fontSize: 36),
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26.0),
                              //side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                              _isRunning ? Colors.red : Colors.green),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 240,
                        //height: 12,
                        child: _isRunning
                            ? const LinearProgressIndicator()
                            : Center(
                                child: Text(_timeDiff == 0
                                    ? ""
                                    : "Elapsed Time: ${_timeDiff.toStringAsFixed(2)} hours "),
                              ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 380,
                        height: 40,
                        child: ListTile(
                          leading: const SizedBox(
                            width: 110,
                            child: Text("Select Activity: "),
                          ),
                          title: DropdownButtonFormField(
                            isExpanded: true,
                            //isDense: true,
                            items: _timeActivities,
                            value: _timeActivity,
                            onChanged: (i) {
                              _timeActivity = i as int;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                          onPressed: _timeDiff < 0.009 || _isRunning
                              ? null
                              : () async {
                                  await updateSpentTime();
                                },
                          child: const Text(
                            "Save",
                            style: TextStyle(fontSize: 20),
                          )),
                    ],
                  ),
                ),
    );
  }
}
