import 'package:flutter/material.dart';

class MapLayerControl extends StatefulWidget {
  const MapLayerControl({Key? key}) : super(key: key);

  @override
  MapLayerControlState createState() => MapLayerControlState();
}

class MapLayerControlState extends State<MapLayerControl> {
  double _i = 1.0;
  final List<bool> _chkBox = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Layer Control"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              "Overlay Layers",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _chkBox[0],
              onChanged: (val) {
                setState(() {
                  _chkBox[0] = val!;
                });
              },
              title: const Text("Layer1"),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Opacity"),
                  Slider(
                    label: "$_i",
                    thumbColor: Colors.red,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    value: _i,
                    onChanged: (newValue) {
                      setState(() => _i = newValue);
                    },
                  ),
                ],
              ),
              dense: true,
            ),
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _chkBox[1],
              onChanged: (val) {
                setState(() {
                  _chkBox[1] = val!;
                });
              },
              title: const Text("Layer1"),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Opacity"),
                  Slider(
                    label: "$_i",
                    thumbColor: Colors.red,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    value: _i,
                    onChanged: (newValue) {
                      setState(() => _i = newValue);
                    },
                  ),
                ],
              ),
              dense: true,
            ),
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _chkBox[2],
              onChanged: (val) {
                setState(() {
                  _chkBox[2] = val!;
                });
              },
              title: const Text("Layer1"),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Opacity"),
                  Slider(
                    label: "$_i",
                    thumbColor: Colors.red,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    value: _i,
                    onChanged: (newValue) {
                      setState(() => _i = newValue);
                    },
                  ),
                ],
              ),
              dense: true,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Base Layers",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            RadioListTile(
              title: const Text("Layer 1"),
              value: 1,
              groupValue: 2,
              onChanged: (val) {
                debugPrint("Val: $val");
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            RadioListTile(
              title: const Text("Layer 1"),
              value: 2,
              groupValue: 2,
              onChanged: (val) {
                debugPrint("Val: $val");
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Set Layers"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
