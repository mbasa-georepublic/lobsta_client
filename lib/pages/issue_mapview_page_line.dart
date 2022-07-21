import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import 'package:latlong2/latlong.dart';

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
        minZoom: 10.0,
        zoom: 16.0,
        allowPanningOnScrollingParent: false,
        onPositionChanged: _forEdit ? (pos, y) => _moveMap(pos) : (pos, y) {},
      );
    }
    _polyEditor = PolyEditor(
      addClosePathMarker: false,
      points: _polyline.points,
      pointIcon: const Icon(Icons.crop_square, size: 25),
      intermediateIcon: const Icon(Icons.lens, size: 15, color: Colors.grey),
      callbackRefresh: () => {setState(() {})},
    );
  }

  _moveMap(MapPosition pos) {
    //_presentPoint = LatLng(pos.center!.latitude, pos.center!.longitude);
  }

  @override
  Widget build(BuildContext context) {
    List<LayerOptions> layers = [
      TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c'],
        //attributionBuilder: (_) {
        //  return const Text("© OpenStreetMap contributors");
        //},
      ),
      PolylineLayerOptions(
        polylineCulling: false,
        polylines: [_polyline],
      ),
      //DragMarkerPluginOptions(markers: _polyEditor.edit()),
    ];

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
            child: FlutterMap(
              options: _mapOptions,
              mapController: _mapController,
              layers: layers,
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
