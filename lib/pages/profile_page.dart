import 'package:flutter/material.dart';
import 'package:lobsta_client/net/net_utils.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> _userCred;
  const ProfilePage(this._userCred, {Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final List<Widget> _widgets = [];
  bool _isLoaded = false;

  DateTime getFirstDate() {
    DateTime now = DateTime.now();
    return (DateTime(now.year, now.month, 1));
  }

  DateTime getLastDate() {
    DateTime now = DateTime.now();
    return (DateTime(now.year, now.month + 1, 1).subtract(
      const Duration(
        days: 1,
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    setPage();
  }

  setPage() async {
    String mUrl = widget._userCred["url"].toString();
    String apiKey = widget._userCred["redmine_token"].toString();
    String fromDate = getFirstDate().toIso8601String().split("T")[0];
    String toDate = getLastDate().toIso8601String().split("T")[0];

    List<Map<String, dynamic>> ret =
        await NetworkHelper.getTimeEntries(mUrl, apiKey, fromDate, toDate);

    Map<String, double> summary = {};
    double totalHours = 0.0;
    String userName = ret.isNotEmpty ? ret[0]["user"]["name"] : "";

    for (Map<String, dynamic> r in ret) {
      String key = "${r["project"]["name"]} : ${r["activity"]["name"]}";
      double value = r["hours"];

      totalHours += value;

      if (summary.isNotEmpty && summary.containsKey(key)) {
        summary.update(key, (v) => value + v);
      } else {
        summary[key] = value;
      }
    }

    if (summary.isNotEmpty) {
      List sorted = summary.keys.toList()..sort();

      _widgets.clear();

      _widgets.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              child: Text("A"),
              radius: 26,
            ),
            Text("$userName's Activities"),
          ],
        ),
      );
      _widgets.add(
        const SizedBox(
          height: 22,
        ),
      );
      _widgets.add(Card(
        child: ListTile(
          leading: const Icon(Icons.work),
          title: const Text("Total Hours Worked"),
          subtitle: Text("$fromDate ~ "),
          trailing: Text("${totalHours.toStringAsFixed(2)} H"),
        ),
      ));

      _widgets.add(
        const SizedBox(
          height: 22,
        ),
      );
      _widgets.add(
        const Text(
          "Activity Summary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      _widgets.add(
        const SizedBox(
          height: 22,
        ),
      );
      for (String s in sorted) {
        debugPrint("Summary: $s: ${summary[s]!.toStringAsFixed(2)}");
        _widgets.add(Card(
          child: ListTile(
            leading: const Icon(Icons.timer),
            title: Text(s.split(" : ")[0]),
            subtitle: Text(s.split(" : ")[1]),
            trailing: Text("${summary[s]!.toStringAsFixed(2)} H"),
          ),
        ));
      }
    }
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

    return !_isLoaded
        ? waiting
        : _widgets.isEmpty
            ? const Center(
                child: Text("No Recorded Activities for This Month"),
              )
            : ListView(
                padding: const EdgeInsets.all(20.0),
                children: _widgets,
              );
  }
}
