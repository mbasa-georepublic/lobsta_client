import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';

class ImageViewPage extends StatefulWidget {
  final String _imgUrl;
  final String _imgName;

  const ImageViewPage(this._imgUrl, this._imgName, {Key? key})
      : super(key: key);

  @override
  State<ImageViewPage> createState() => ImageViewPageState();
}

class ImageViewPageState extends State<ImageViewPage> {
  final DatabaseHelper _dbh = DatabaseHelper();
  bool _isLoaded = false;
  String _token = "";
  String _imgUrl = "";
  String _imgName = "";

  @override
  void initState() {
    super.initState();

    _imgUrl = widget._imgUrl;
    _imgName = widget._imgName;

    setToken();
  }

  setToken() async {
    _token = await _dbh.getUserToken();
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoaded
        ? Container()
        : Scaffold(
            appBar: AppBar(
              title: Text(_imgName),
            ),
            body: Center(
              child: CachedNetworkImage(
                  imageUrl: _imgUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  httpHeaders: {
                    "X-Redmine-API-Key": _token,
                  }),
            ),
          );
  }
}
