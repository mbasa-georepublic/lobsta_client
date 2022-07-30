import 'package:flutter/material.dart';

import '../utils/layer_control_utils.dart';

class MapLayerControl extends StatefulWidget {
  final List<MapLayer> _mapLayers;

  const MapLayerControl(this._mapLayers, {Key? key}) : super(key: key);

  @override
  MapLayerControlState createState() => MapLayerControlState();
}

class MapLayerControlState extends State<MapLayerControl> {
  final List<bool> _visible = [];
  final List<double> _opacity = [];
  int _baseLayer = -1;

  List<MapLayer> _mapLayers = [];

  @override
  void initState() {
    super.initState();
    _mapLayers = widget._mapLayers;

    for (int i = 0; i < _mapLayers.length; i++) {
      MapLayer ml = _mapLayers[i];
      _opacity.add(ml.opacity);
      _visible.add(ml.isVisible);

      if (ml.isBaseLayer && ml.isVisible) {
        _baseLayer = i;
      }
    }
  }

  void returnMapLayers() {
    for (int i = 0; i < _mapLayers.length; i++) {
      if (_mapLayers[i].isBaseLayer) {
        if (_baseLayer == i) {
          _mapLayers[i].setIsVisible = true;
        } else {
          _mapLayers[i].setIsVisible = false;
        }
      } else {
        _mapLayers[i].setOpacity = _opacity[i];
        _mapLayers[i].setIsVisible = _visible[i];
      }
    }

    Navigator.pop(context, _mapLayers);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> baseLayerWidgets = [];
    List<Widget> overlayLayerWidgets = [];
    List<Widget> combinedWidgets = [];

    for (int i = 0; i < _mapLayers.length; i++) {
      MapLayer ml = _mapLayers[i];
      if (ml.isBaseLayer) {
        baseLayerWidgets.add(
          RadioListTile(
            title: Text(ml.layerName),
            value: i,
            groupValue: _baseLayer,
            onChanged: (val) {
              setState(() {
                _baseLayer = int.parse(val.toString());
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
        );
      } else {
        overlayLayerWidgets.add(
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            value: _visible[i],
            onChanged: (val) {
              setState(() {
                _visible[i] = val!;
              });
            },
            title: Text(ml.layerName),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Opacity"),
                Slider(
                  label: "${_opacity[i]}",
                  thumbColor: Colors.red,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  value: _opacity[i],
                  onChanged: (newValue) {
                    setState(() => _opacity[i] = newValue);
                  },
                ),
              ],
            ),
            dense: true,
          ),
        );
      }
    }

    combinedWidgets = [
          const Text(
            "Overlay Layers",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
        ] +
        overlayLayerWidgets +
        [
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
        ] +
        baseLayerWidgets +
        [
          const SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                returnMapLayers();
              },
              child: const Text("Set Layers"),
            ),
          )
        ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Layer Control"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: combinedWidgets,
        ),
      ),
    );
  }
}
