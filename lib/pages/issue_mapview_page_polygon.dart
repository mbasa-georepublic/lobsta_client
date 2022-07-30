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

  const IssueMapViewPagePolygon(this._polygon, this.centerPt,
      {this.forEdit = true, Key? key})
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
  List<MapLayer> _mapLayers = [];

  @override
  void initState() {
    super.initState();

    MapLayer mapLayer = MapLayer.xyz(
        "OSM Standard",
        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "xyz",
        1.0,
        true,
        false,
        ['a', 'b', 'c']);

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI標準地図",
        "https://maps.gsi.go.jp/xyz/std/{z}/{x}/{y}.png?_=20210915a",
        "xyz",
        1.0,
        true,
        true, []);

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI淡色地図",
        "https://maps.gsi.go.jp/xyz/pale/{z}/{x}/{y}.png?_=20210915a",
        "xyz",
        1.0,
        true,
        false, []);

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI白地図",
        "https://maps.gsi.go.jp/xyz/blank/{z}/{x}/{y}.png?_=20210915a",
        "xyz",
        1.0,
        true,
        false, []);

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI写真地図",
        "https://maps.gsi.go.jp/xyz/seamlessphoto/{z}/{x}/{y}.jpg",
        "xyz",
        1.0,
        true,
        false, []);

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.wms(
        "日本語版(基本版)",
        "https://gbank.gsj.jp/ows/seamlessgeology200k_b?",
        "WMS",
        0.6,
        false,
        true,
        ["Basic_Version_Japanese"],
        {"tiled": "true"});

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.wms(
      "重力図（ブーゲー異常）",
      "https://gbank.gsj.jp/ows/gravdb?",
      "WMS",
      1.0,
      false,
      false,
      ["BouguerAnomaly"],
      {"tiled": "true"},
    );

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.wms(
      "Geochemical Map",
      "https://gbank.gsj.jp/ows/geochemmap_en?",
      "WMS",
      1.0,
      false,
      false,
      ["GeochemicalMap"],
      {"tiled": "true"},
    );

    debugPrint("Layer Name: ${mapLayer.layerName} ID: ${mapLayer.id}");
    _mapLayers.add(mapLayer);

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
        minZoom: 10.0,
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
