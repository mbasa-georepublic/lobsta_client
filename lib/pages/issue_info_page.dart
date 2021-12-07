import 'package:flutter/material.dart';

class IssueInfoPage extends StatefulWidget {
  final Map<String, dynamic> _issue;
  const IssueInfoPage(this._issue, {Key? key}) : super(key: key);

  @override
  State<IssueInfoPage> createState() => IssueInfoPageState();
}

class IssueInfoPageState extends State<IssueInfoPage> {
  Map<String, dynamic> _issue = {};

  @override
  void initState() {
    super.initState();
    _issue = widget._issue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Issue #${_issue["id"]}"),
        ),
        body: SingleChildScrollView(
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
                    "Percent Completed",
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
        ));
  }
}
