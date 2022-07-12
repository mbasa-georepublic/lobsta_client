import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lobsta_client/net/net_utils.dart';

class IssueUtils {
  static Future<Map<String, dynamic>> uploadImageFile(
      String imgFileName, String mUrl, String apiKey) async {
    Map<String, dynamic> retVal = {};

    File imageFile = File(imgFileName);
    Uint8List uInt8list = await imageFile.readAsBytes();
    String fileName = "image_${Random().nextInt(20000000)}.jpg";

    try {
      Map<String, dynamic> r =
          await NetworkHelper.postImage(uInt8list, fileName, mUrl, apiKey);

      if (r.isNotEmpty && r["status_code"] == 201) {
        Map<String, dynamic> retData = r["status_data"];
        String token = retData["upload"]["token"];

        retVal = {
          "token": token,
          "filename": fileName,
          "content_type": "image/jpg",
        };
      }
    } catch (e) {
      debugPrint("Image Upload Error: ${e.toString()}");
    }

    return retVal;
  }
}
