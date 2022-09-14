import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lobsta_client/utils/color_utils.dart';

import '../utils/layer_control_utils.dart';
import '../utils/material_icon_utils.dart';
import 'map_layer_control_page.dart';

class IssueMapViewPagePt extends StatefulWidget {
  final LatLng _latLng;
  final bool forEdit;
  final String iconName;
  final String iconColor;

  const IssueMapViewPagePt(this._latLng,
      {this.forEdit = true, this.iconName = "", this.iconColor = "", Key? key})
      : super(key: key);

  @override
  IssueMapViewPagePtState createState() => IssueMapViewPagePtState();
}

class IssueMapViewPagePtState extends State<IssueMapViewPagePt> {
  final MapController _mapController = MapController();
  MapOptions _mapOptions = MapOptions();
  final List<Marker> _markers = [];
  LatLng _initialPoint = LatLng(35.6592979, 139.7005656);
  LatLng _presentPoint = LatLng(0, 0);
  bool _isFirst = true;
  bool _forEdit = true;

  String _iconColor = "#000000";
  String _iconName = "location_on";
  IconData _selIcon = Icons.location_on;
  List<MapLayer> _mapLayers = LayerControlUtils.createMapLayerList();

  @override
  void initState() {
    super.initState();

    if (widget.iconColor.isNotEmpty) {
      _iconColor = widget.iconColor;
    }
    if (widget.iconName.isNotEmpty) {
      _iconName = widget.iconName;
    }

    _initialPoint = widget._latLng;
    _forEdit = widget.forEdit;

    _selIcon = getMaterialIcon(name: _iconName) ?? Icons.location_on;

    _markers.add(
      Marker(
        point: _initialPoint,
        height: 80.0,
        width: 70.0,
        builder: (ctx) => Stack(
          alignment: Alignment.topCenter,
          children: [
            Icon(
              Icons.chat_bubble_rounded,
              size: 42,
              color: HexColor(_iconColor), //Colors.deepPurple,
            ),
            Container(
              padding: const EdgeInsets.only(top: 7.0),
              //alignment: Alignment.center,
              child: Icon(
                _selIcon,
                size: 20,
                color: Colors.white,
              ),
            )
          ],
        ),
        anchorPos: AnchorPos.exactly(Anchor(35.0, 20.0)),
      ),
    );
    _mapOptions = MapOptions(
        center: _initialPoint,
        maxZoom: 18.0,
        minZoom: 9.0,
        zoom: 16.0,
        onPositionChanged: _forEdit ? (pos, y) => _moveMap(pos) : (pos, y) {});
  }

  _moveMap(MapPosition pos) {
    _presentPoint = LatLng(pos.center!.latitude, pos.center!.longitude);

    if (!_isFirst) {
      _markers.clear();
      _markers.add(
        Marker(
          point: _presentPoint,
          height: 80.0,
          width: 70.0,
          anchorPos: AnchorPos.exactly(Anchor(35.0, 20.0)),
          builder: (ctx) => Stack(
            alignment: Alignment.topCenter,
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                size: 42,
                color: HexColor(_iconColor), //Colors.deepPurple,
              ),
              Container(
                padding: const EdgeInsets.only(top: 7.0),
                //alignment: Alignment.center,
                child: Icon(
                  _selIcon,
                  size: 20,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
      setState(() {});
    } else {
      _isFirst = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<LayerOptions> layers =
        LayerControlUtils.createLayerOptionsList(_mapLayers);

    if (LayerControlUtils.gttBndPoly.points.isNotEmpty) {
      layers.add(PolygonLayerOptions(polygons: [LayerControlUtils.gttBndPoly]));
    }

    layers.add(
      MarkerLayerOptions(
        markers: _markers,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_forEdit ? "Choose Position" : "Map"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                FlutterMap(
                  options: _mapOptions,
                  mapController: _mapController,
                  layers: layers,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(30.0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        var l = await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MapLayerControlPage(_mapLayers);
                        }));
                        if (l != null) {
                          setState(() {
                            _mapLayers = l;
                            LayerControlUtils.modifiedMapLayerList = l;
                          });
                        }
                      },
                      elevation: 10,
                      mini: true,
                      tooltip: "Layer Control",
                      child: const Icon(Icons.layers),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                child: Text(_forEdit ? "Set Position" : "Return"),
                onPressed: () => Navigator.pop(context, _presentPoint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
