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

  static String createCoordString(List inCoords) {
    int len = inCoords.length;

    String coords = "[[${inCoords[0].longitude},"
        "${inCoords[0].latitude}],";

    for (int i = 1; i < len - 1; i++) {
      coords += "[${inCoords[i].longitude},"
          "${inCoords[i].latitude}],";
    }

    coords += "[${inCoords[len - 1].longitude},"
        "${inCoords[len - 1].latitude}]]";

    return coords;
  }
}
