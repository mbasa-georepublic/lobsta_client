import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lobsta_client/db/db_utils.dart';
import 'package:lobsta_client/net/net_utils.dart';
import 'package:lobsta_client/utils/dialog_utils.dart';

class ImageViewPage extends StatefulWidget {
  final String _imgId;
  final String _imgUrl;
  final String _imgName;

  const ImageViewPage(this._imgId, this._imgUrl, this._imgName, {Key? key})
      : super(key: key);

  @override
  State<ImageViewPage> createState() => ImageViewPageState();
}

class ImageViewPageState extends State<ImageViewPage> {
  final DatabaseHelper _dbh = DatabaseHelper();

  bool _isLoaded = false;
  String _token = "";
  String _mUrl = "";
  String _imgUrl = "";
  String _imgName = "";
  int _imgId = 0;

  @override
  void initState() {
    super.initState();

    _imgUrl = widget._imgUrl;
    _imgName = widget._imgName;
    _imgId = int.parse(widget._imgId);

    setToken();
  }

  setToken() async {
    var userCred = await _dbh.getUserCredential();

    _mUrl = userCred["url"].toString();
    _token = userCred["redmine_token"].toString();

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
              actions: [
                IconButton(
                  onPressed: () async {
                    bool del = await DialogUtil.showConfirmDialog(
                        context, "Delete", "Delete Photo?", "Cancel", "Delete");

                    if (del) {
                      DialogUtil.showOnSendDialog(context, "Deleting Photo");

                      bool ret = await NetworkHelper.deleteImage(
                          _mUrl, _token, _imgId);

                      Navigator.pop(context);

                      if (ret) {
                        Navigator.pop(context, true);
                      } else {
                        DialogUtil.showCustomDialog(
                            context, "Error", "An Error Occurred", "Close");
                      }
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
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
