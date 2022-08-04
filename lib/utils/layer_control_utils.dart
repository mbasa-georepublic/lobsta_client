import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapLayer {
  int _id = DateTime.now().microsecondsSinceEpoch;
  String _layerName = "";
  String _url = "";
  String _layerType = "";
  double _opacity = 1.0;
  bool _isBaseLayer = true;
  bool _isVisible = true;
  List<String> _xyzSubdomains = [];
  List<String> _wmsLayers = [];
  Map<String, String> _wmsOtherParams = {};

  int get id => _id;
  String get layerName => _layerName;
  String get url => _url;
  String get layerType => _layerType;
  double get opacity => _opacity;
  bool get isBaseLayer => _isBaseLayer;
  bool get isVisible => _isVisible;
  List<String> get xyzSubdomains => _xyzSubdomains;
  List<String> get wmsLayers => _wmsLayers;
  Map<String, String> get wmsOtherParams => _wmsOtherParams;

  set setId(int val) => _id = val;
  set setLayerName(String val) => _layerName = val;
  set setUrl(String val) => _url = val;
  set setLayerType(String val) => _layerType = val;
  set setOpacity(double val) => _opacity = val;
  set setIsBaseLayer(bool val) => _isBaseLayer = val;
  set setIsVisible(bool val) => _isVisible = val;
  set setXyzSubdomains(List<String> val) => _xyzSubdomains = val;
  set setWmsLayers(List<String> val) => _wmsLayers = val;
  set setWmsOtherParams(Map<String, String> val) => _wmsOtherParams;

  MapLayer(this._layerName, this._url, this._layerType, this._opacity,
      this._isBaseLayer, this._isVisible);

  MapLayer.xyz(this._layerName, this._url, this._layerType, this._opacity,
      this._isBaseLayer, this._isVisible, this._xyzSubdomains);

  MapLayer.wms(
      this._layerName,
      this._url,
      this._layerType,
      this._opacity,
      this._isBaseLayer,
      this._isVisible,
      this._wmsLayers,
      this._wmsOtherParams);

  MapLayer.empty();
}

class LayerControlUtils {
  static Polygon _gttBndPoly = Polygon(points: []);
  static List<MapLayer> _modifiedMapLayerList = [];

  static Polygon get gttBndPoly => _gttBndPoly;
  static set gttBndPoly(val) => _gttBndPoly = val;

  static List<MapLayer> get modifiedMapLayerList => _modifiedMapLayerList;
  static set modifiedMapLayerList(List<MapLayer> val) =>
      _modifiedMapLayerList = val;
/*
  static void setModifiedLayerList(List<MapLayer> val) {
    _modifiedMapLayerList = val;
  }
*/

  static void createGttBndPoly(List<LatLng> pts) {
    Polygon polygon = Polygon(
        points: [
          LatLng(90, -180),
          LatLng(-90, -180),
          LatLng(-90, 180),
          LatLng(90, 180),
          LatLng(90, -180)
        ],
        holePointsList: [
          pts
        ],
        color: Colors.grey.withOpacity(0.3),
        borderStrokeWidth: 4.0,
        borderColor: Colors.deepPurple);

    LayerControlUtils.gttBndPoly = polygon;
  }

  static void configureGttLayers(List<dynamic> gttLayers) {
    if (gttLayers.isNotEmpty) {
      modifiedMapLayerList = [];
      List<MapLayer> mapLayers = [];
      bool isVisible = false;
      bool isFirstBaseLayer = true;

      for (Map<String, dynamic> gtt in gttLayers) {
        String layerType = gtt["type"];

        if (gtt["baselayer"] && isFirstBaseLayer) {
          isVisible = true;
          isFirstBaseLayer = false;
        } else {
          isVisible = false;
        }

        if (layerType.toUpperCase().contains("WMS")) {
          List<String> wmsLayers = [];

          Map<String, dynamic> s = gtt["options"]["params"];
          Map<String, dynamic> t = {};
          t = s.map((key, value) => MapEntry(key.toLowerCase(), value));

          if (t["layers"] is String) {
            wmsLayers.add(t["layers"]);
          } else {
            for (var str in t["layers"]) {
              wmsLayers.add(str.toString());
            }
          }

          MapLayer ml = MapLayer.wms(
              gtt["name"],
              gtt["options"]["url"],
              "WMS",
              0.5,
              gtt["baselayer"],
              isVisible,
              wmsLayers, {}); //gtt["options"]["params"]);

          mapLayers.add(ml);
        } else if (layerType.toUpperCase().contains("XYZ") ||
            layerType.toUpperCase().contains("OSM")) {
          MapLayer ml = MapLayer.xyz(gtt["name"], gtt["options"]["url"], "XYZ",
              0.5, gtt["baselayer"], isVisible, []);

          mapLayers.add(ml);
        } else {
          debugPrint("GTTLayers: un-handled Layer Type $layerType");
        }
      }

      if (mapLayers.isNotEmpty) {
        modifiedMapLayerList = mapLayers;
      }
    }
  }

  static List<MapLayer> createMapLayerList() {
    if (modifiedMapLayerList.isNotEmpty) {
      return (modifiedMapLayerList);
    }

    List<MapLayer> _mapLayers = [];
    MapLayer mapLayer = MapLayer.xyz(
        "OSM Standard",
        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "xyz",
        1.0,
        true,
        true,
        ['a', 'b', 'c']);

    _mapLayers.add(mapLayer);
    return _mapLayers;
  }

  static List<LayerOptions> createLayerOptionsList(List<MapLayer> mapLayers) {
    List<LayerOptions> layerOptions = [];
    /**
     * Base Layers
     */
    for (MapLayer mapLayer in mapLayers) {
      if (mapLayer.isBaseLayer && mapLayer.isVisible) {
        if (mapLayer.layerType.toUpperCase().contains("XYZ")) {
          layerOptions.add(TileLayerOptions(
            urlTemplate: mapLayer.url,
            subdomains: mapLayer.xyzSubdomains,
          ));
          break;
        } else if (mapLayer.layerType.toUpperCase().contains("WMS")) {
          layerOptions.add(TileLayerOptions(
            wmsOptions: WMSTileLayerOptions(
              baseUrl: mapLayer.url,
              layers: mapLayer.wmsLayers,
              otherParameters: mapLayer.wmsOtherParams,
            ),
          ));
          break;
        }
      }
    }

    /**
     * Oeverlay Layers
     */
    for (MapLayer mapLayer in mapLayers) {
      if (!mapLayer.isBaseLayer && mapLayer.isVisible) {
        if (mapLayer.layerType.toUpperCase().contains("XYZ")) {
          layerOptions.add(TileLayerOptions(
            urlTemplate: mapLayer.url,
            subdomains: mapLayer.xyzSubdomains,
            opacity: mapLayer.opacity,
          ));
        } else if (mapLayer.layerType.toUpperCase().contains("WMS")) {
          layerOptions.add(TileLayerOptions(
            wmsOptions: WMSTileLayerOptions(
              baseUrl: mapLayer.url,
              layers: mapLayer.wmsLayers,
              otherParameters: mapLayer.wmsOtherParams,
            ),
            opacity: mapLayer.opacity,
          ));
        }
      }
    }

    return layerOptions;
  }
}
