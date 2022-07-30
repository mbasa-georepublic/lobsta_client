import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import 'package:latlong2/latlong.dart';
import 'package:lobsta_client/pages/map_layer_control.dart';

import '../utils/layer_control_utils.dart';

class IssueMapViewPagePolygon extends StatefulWidget {
  final Polygon _polygon;
  final LatLng centerPt;
  final bool forEdit;
  final List<MapLayer> mapLayers;

  const IssueMapViewPagePolygon(this._polygon, this.centerPt,
      {this.mapLayers = const [], this.forEdit = true, Key? key})
      : super(key: key);

  @override
  IssueMapViewPagePolygonState createState() => IssueMapViewPagePolygonState();
}

class IssueMapViewPagePolygonState extends State<IssueMapViewPagePolygon> {
  final MapController _mapController = MapController();
  MapOptions _mapOptions = MapOptions();
  Polygon _polygon = Polygon(points: []);
  bool _forEdit = true;

  late PolyEditor _polyEditor;
  List<MapLayer> _mapLayers = LayerControlUtils.createMapLayerList();

  @override
  void initState() {
    super.initState();

    _polygon = widget._polygon;
    _forEdit = widget.forEdit;

    LatLngBounds bnd = LatLngBounds();

    if (_polygon.points.isNotEmpty) {
      bnd = LatLngBounds.fromPoints(_polygon.points);
      bnd.pad(0.1);
    } else {
      List<LatLng> l = [widget.centerPt];
      bnd = LatLngBounds.fromPoints(l);
    }

    if (_forEdit) {
      _mapOptions = MapOptions(
        bounds: bnd,
        maxZoom: 18.0,
        minZoom: 9.0,
        zoom: 16.0,
        allowPanningOnScrollingParent: false,
        plugins: [
          DragMarkerPlugin(),
        ],
        onTap: (_, ll) {
          _polyEditor.add(_polygon.points, ll);
        },
        //onPositionChanged: _forEdit ? (pos, y) => _moveMap(pos) : (pos, y) {},
      );
    } else {
      _mapOptions = MapOptions(
        bounds: bnd,
        maxZoom: 18.0,
        minZoom: 10.0,
        zoom: 16.0,
        allowPanningOnScrollingParent: false,
        onTap: (_, ll) {
          //_polyEditor.add(_polygon.points, ll);
        },
        //onPositionChanged: _forEdit ? (pos, y) => _moveMap(pos) : (pos, y) {},
      );
    }
    _polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: _polygon.points,
      pointIcon: const Icon(Icons.crop_square, size: 30),
      intermediateIcon: const Icon(Icons.lens, size: 30, color: Colors.grey),
      callbackRefresh: () => {setState(() {})},
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    List<LayerOptions> layers =
        LayerControlUtils.createLayerOptionsList(_mapLayers);

    layers.add(PolygonLayerOptions(
      polygonCulling: false,
      polygons: [_polygon],
    ));

    if (_forEdit) {
      layers.add(DragMarkerPluginOptions(markers: _polyEditor.edit()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_forEdit ? "Edit Polygon" : "Map"),
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
                          return MapLayerControl(_mapLayers);
                        }));
                        if (l != null) {
                          setState(() {
                            _mapLayers = l;
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
                onPressed: () => Navigator.pop(context, _polygon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
