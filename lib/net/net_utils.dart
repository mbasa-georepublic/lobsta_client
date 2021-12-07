import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NetworkHelper {
  static Future<String> getApiKey(
      String user, String password, String url) async {
    Dio dio = Dio();
    String retVal = "";
    String mUrl = "$url/my/account.json";

    try {
      Response response = await dio.get(
        mUrl,
        options: Options(
          headers: {
            "Authorization": "Basic " +
                const Base64Encoder().convert("$user:$password".codeUnits),
            "Content-Type": "application/json",
          },
        ),
      );

      debugPrint(
          "Code: ${response.statusCode} Response: ${response.data.toString()}");

      if (response.statusCode == 200) {
        Map<String, dynamic> r = response.data;
        retVal = r["user"]["api_key"];
      }
    } on DioError catch (e) {
      debugPrint("getApiKey Network Error: ${e.message}");
    }

    return retVal;
  }

  static Future<Map<String, dynamic>> getProject(
      String mUrl, String apiKey, int projectId) async {
    Map<String, dynamic> retVal = {};

    String url = "$mUrl/projects/$projectId.json?include="
        "trackers,issue_categories,enabled_modules";

    try {
      Dio dio = Dio();

      Response response = await dio.get(
        url,
        options: Options(
          headers: {
            "X-Redmine-API-Key": apiKey,
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint("Msg: ${response.statusMessage} Response Records: "
            "${response.data["total_count"]}");

        retVal = response.data["project"];
      }
    } on DioError catch (exception) {
      debugPrint("User Projects Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<List<Map<String, dynamic>>> getUserProjects(
      String mUrl, String apiKey) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/projects.json?limit=100000000&include=enabled_modules";

    try {
      Dio dio = Dio();

      Response response = await dio.get(
        url,
        options: Options(
          headers: {
            "X-Redmine-API-Key": apiKey,
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint("Msg: ${response.statusMessage} Response Records: "
            "${response.data["total_count"]}");

        //retVal = response.data["projects"] as List<Map<String, dynamic>>;
        for (Map<String, dynamic> ret in response.data["projects"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("User Projects Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<List<Map<String, dynamic>>> getProjectIssues(
      String mUrl, String apiKey, int projectId, String issueStatus) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/issues.json?limit=100000000&project_id=$projectId"
        "&status_id=$issueStatus";

    try {
      Dio dio = Dio();

      Response response = await dio.get(
        url,
        options: Options(
          headers: {
            "X-Redmine-API-Key": apiKey,
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint("Msg: ${response.statusMessage} Response Records: "
            "${response.data["total_count"]}");

        //retVal = response.data["projects"] as List<Map<String, dynamic>>;
        for (Map<String, dynamic> ret in response.data["issues"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("User Projects Error: ${exception.message}");
    }
    return retVal;
  }
}
