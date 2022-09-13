import 'package:flutter/material.dart';

import '../db/db_utils.dart';
import '../net/net_utils.dart';

class TrackerIconsUtils {
  static getSaveTrackerIcons(String url, String userToken) async {
    DatabaseHelper dbh = DatabaseHelper();
    //Map<String, Object?> userAuth = await dbh.getUserCredential();
    //String userToken = userAuth["redmine_token"]?.toString() ?? "";

    if (userToken.isNotEmpty) {
      //String url = userAuth["url"]?.toString() ?? "";

      Map<String, dynamic> res =
          await NetworkHelper.getTrackerIcons(url, userToken);

      if (res.containsKey("defaultTrackerIcon")) {
        List<dynamic> tokens = res["defaultTrackerIcon"] ?? [];

        if (tokens.isNotEmpty) {
          await dbh.deleteTrackerIcons();

          for (Map<String, dynamic> token in tokens) {
            await dbh.insertTrackerIcon(
                token["trackerID"], token["icon"]?.toString() ?? "");

            debugPrint("TokenID: ${token["trackerID"]} icon: ${token["icon"]}");
          }
        }
      }
    }
  }
}
