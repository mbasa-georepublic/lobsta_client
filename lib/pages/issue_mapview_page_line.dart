import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import 'package:latlong2/latlong.dart';

import '../utils/layer_control_utils.dart';
import 'map_layer_control_page.dart';

class IssueMapViewPageLine extends StatefulWidget {
  final Polyline _polyline;
  final bool forEdit;
  final LatLng centerPt;

  const IssueMapViewPageLine(this._polyline, this.centerPt,
      {this.forEdit = true, Key? key})
      : super(key: key);

  @override
  IssueMapViewPageLineState createState() => IssueMapViewPageLineState();
}

class IssueMapViewPageLineState extends State<IssueMapViewPageLine> {
  final MapController _mapController = MapController();
  MapOptions _mapOptions = MapOptions();
  Polyline _polyline = Polyline(points: []);
  //LatLng _presentPoint = LatLng(0, 0);
  bool _forEdit = true;

  late PolyEditor _polyEditor;
  List<MapLayer> _mapLayers = LayerControlUtils.createMapLayerList();

  @override
  void initState() {
    super.initState();
    _polyline = widget._polyline;
    _forEdit = widget.forEdit;

    LatLngBounds bnd = LatLngBounds();

    if (_polyline.points.isNotEmpty) {
      bnd = LatLngBounds.fromPoints(_polyline.points);
      bnd.pad(0.1);
    } else {
      List<LatLng> t = [widget.centerPt];
      bnd = LatLngBounds.fromPoints(t);
    }

    if (_forEdit) {
      _mapOptions = MapOptions(
        bounds: bnd,
        maxZoom: 22.0,
        minZoom: 10.0,
        zoom: 16.0,
        allowPanningOnScrollingParent: false,
        plugins: [
          DragMarkerPlugin(),
        ],
        onTap: (_, ll) {
          _polyEditor.add(_polyline.points, ll);
        },
        onPositionChanged: _forEdit ? (pos, y) => _moveMap(pos) : (pos, y) {},
      );
    } else {
      _mapOptions = MapOptions(
        bounds: bnd,
        maxZoom: 22.0,
        minZoom: 9.0,
        zoom: 16.0,
        allowPanningOnScrollingParent: false,
        onPositionChanged: _forEdit ? (pos, y) => _moveMap(pos) : (pos, y) {},
      );
    }
    _polyEditor = PolyEditor(
      addClosePathMarker: false,
      points: _polyline.points,
      pointIcon: const Icon(Icons.crop_square, size: 30),
      intermediateIcon: const Icon(Icons.lens, size: 30, color: Colors.grey),
      callbackRefresh: () => {setState(() {})},
    );
  }

  _moveMap(MapPosition pos) {
    //_presentPoint = LatLng(pos.center!.latitude, pos.center!.longitude);
  }

  @override
  Widget build(BuildContext context) {
    List<LayerOptions> layers =
        LayerControlUtils.createLayerOptionsList(_mapLayers);

    if (LayerControlUtils.gttBndPoly.points.isNotEmpty) {
      layers.add(PolygonLayerOptions(polygons: [LayerControlUtils.gttBndPoly]));
    }

    layers.add(
      PolylineLayerOptions(
        polylineCulling: false,
        polylines: [_polyline],
      ),
    );
    //DragMarkerPluginOptions(markers: _polyEditor.edit()),

    if (_forEdit) {
      layers.add(DragMarkerPluginOptions(markers: _polyEditor.edit()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_forEdit ? "Edit Line" : "Map"),
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
                child: Text(_forEdit ? "Save Edit" : "Return"),
                onPressed: () => Navigator.pop(context, _polyline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
