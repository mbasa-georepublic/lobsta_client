import 'package:flutter_map/flutter_map.dart';

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
  static List<MapLayer> createMapLayerList() {
    List<MapLayer> _mapLayers = [];

    MapLayer mapLayer = MapLayer.xyz(
        "OSM Standard",
        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        "xyz",
        1.0,
        true,
        false,
        ['a', 'b', 'c']);

    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI標準地図",
        "https://maps.gsi.go.jp/xyz/std/{z}/{x}/{y}.png?_=20210915a",
        "xyz",
        1.0,
        true,
        true, []);

    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI淡色地図",
        "https://maps.gsi.go.jp/xyz/pale/{z}/{x}/{y}.png?_=20210915a",
        "xyz",
        1.0,
        true,
        false, []);

    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI白地図",
        "https://maps.gsi.go.jp/xyz/blank/{z}/{x}/{y}.png?_=20210915a",
        "xyz",
        1.0,
        true,
        false, []);

    _mapLayers.add(mapLayer);

    mapLayer = MapLayer.xyz(
        "GSI写真地図",
        "https://maps.gsi.go.jp/xyz/seamlessphoto/{z}/{x}/{y}.jpg",
        "xyz",
        1.0,
        true,
        false, []);

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
