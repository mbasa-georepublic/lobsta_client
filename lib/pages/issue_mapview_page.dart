import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class IssueMapViewPage extends StatefulWidget {
  final LatLng _latLng;
  final bool forEdit;

  const IssueMapViewPage(this._latLng, {this.forEdit = true, Key? key})
      : super(key: key);

  @override
  IssueMapViewPageState createState() => IssueMapViewPageState();
}

class IssueMapViewPageState extends State<IssueMapViewPage> {
  final MapController _mapController = MapController();
  MapOptions _mapOptions = MapOptions();
  final List<Marker> _markers = [];
  LatLng _initialPoint = LatLng(35.6592979, 139.7005656);
  LatLng _presentPoint = LatLng(0, 0);
  bool _isFirst = true;
  bool _forEdit = true;

  @override
  void initState() {
    super.initState();

    _initialPoint = widget._latLng;
    _forEdit = widget.forEdit;

    _markers.add(
      Marker(
        point: _initialPoint,
        height: 80.0,
        width: 70.0,
        anchorPos: AnchorPos.exactly(Anchor(35.0, 20.0)),
        builder: (ctx) => const Icon(
          Icons.location_on,
          size: 42,
          color: Colors.deepOrange,
        ),
      ),
    );
    _mapOptions = MapOptions(
        center: _initialPoint,
        maxZoom: 18.0,
        minZoom: 13.0,
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
          builder: (ctx) => const Icon(
            Icons.location_on,
            size: 42,
            color: Colors.deepOrange,
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_forEdit ? "Choose Position" : "Map"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: FlutterMap(
              options: _mapOptions,
              mapController: _mapController,
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  attributionBuilder: (_) {
                    return const Text("© OpenStreetMap contributors");
                  },
                ),
                MarkerLayerOptions(
                  markers: _markers,
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
