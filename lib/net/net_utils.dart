import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NetworkHelper {
  static Future<Map<String, dynamic>> getApiKey(
      String user, String password, String url) async {
    Dio dio = Dio();
    Map<String, dynamic> retVal = {};
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
        retVal = r["user"];
      }
    } on DioError catch (e) {
      debugPrint("getApiKey Network Error: ${e.message}");
    }

    return retVal;
  }

  static Future<Map<String, dynamic>> getTrackerIcons(
      String mUrl, String apiKey) async {
    Map<String, dynamic> retVal = {};

    String url = "$mUrl/gtt/settings.json";

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
        debugPrint("Msg: ${response.statusMessage} ");

        retVal = response.data["gttDefaultSetting"];
      }
    } on DioError catch (exception) {
      debugPrint("GTT Settings Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<Map<String, dynamic>> getProject(
      String mUrl, String apiKey, int projectId) async {
    Map<String, dynamic> retVal = {};

    String url = "$mUrl/projects/$projectId.json?include="
        "trackers,issue_categories,enabled_modules,layers";

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

  static Future<List<Map<String, dynamic>>> getIssueStatus(
      String mUrl, String apiKey) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/issue_statuses.json";

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
        debugPrint("IssueStatus Msg: ${response.statusMessage}");

        //retVal = response.data["projects"] as List<Map<String, dynamic>>;
        for (Map<String, dynamic> ret in response.data["issue_statuses"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("IssueStatus Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<List<Map<String, dynamic>>> getTrackers(
      String mUrl, String apiKey) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/trackers.json";

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
        debugPrint("Tracker Msg: ${response.statusMessage}");

        //retVal = response.data["projects"] as List<Map<String, dynamic>>;
        for (Map<String, dynamic> ret in response.data["trackers"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("Trackers Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<List<Map<String, dynamic>>> getTimeEntries(
      String mUrl, String apiKey, String fromDate, String toDate) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/time_entries.json?limit=100000&user_id=me"
        "&from=$fromDate&to=$toDate";

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
        for (Map<String, dynamic> ret in response.data["time_entries"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("TimeEntries Error: ${exception.message}");
    }

    return retVal;
  }

  static Future<List<Map<String, dynamic>>> getTimeEntryActivities(
      String mUrl, String apiKey) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/enumerations/time_entry_activities.json";

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
        debugPrint("TimeEntryActivities Msg: ${response.statusMessage}");

        //retVal = response.data["projects"] as List<Map<String, dynamic>>;
        for (Map<String, dynamic> ret
            in response.data["time_entry_activities"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("TimeEntryActivities Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<List<Map<String, dynamic>>> getMemberships(
      String mUrl, String apiKey, int projectId) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/projects/$projectId/memberships.json";

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
        debugPrint("Membership Msg: ${response.statusMessage}");

        //retVal = response.data["projects"] as List<Map<String, dynamic>>;
        for (Map<String, dynamic> ret in response.data["memberships"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("Memberships Error: ${exception.message}");
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

  static Future<List<Map<String, dynamic>>> getMyTasks(
      String mUrl, String apiKey) async {
    List<Map<String, dynamic>> retVal = [];

    String url = "$mUrl/issues.json?assigned_to_id=me";

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
        debugPrint("Msg: ${response.statusMessage} Status Code: "
            "${response.statusCode}");

        for (Map<String, dynamic> ret in response.data["issues"]) {
          retVal.add(ret);
        }
      }
    } on DioError catch (exception) {
      debugPrint("My Tasks Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<Map<String, dynamic>> getIssue(
      String mUrl, String apiKey, int issueId) async {
    Map<String, dynamic> retVal = {};

    String url = "$mUrl/issues/$issueId.json?include=attachments,journals";

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
        debugPrint("Msg: ${response.statusMessage} Status Code: "
            "${response.statusCode}");

        retVal = response.data["issue"];
      }
    } on DioError catch (exception) {
      debugPrint("User Projects Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<bool> deleteIssue(
      String mUrl, String apiKey, int issueId) async {
    bool retVal = false;

    String url = "$mUrl/issues/$issueId.json";

    try {
      Dio dio = Dio();

      await dio.delete(
        url,
        options: Options(
          headers: {
            "X-Redmine-API-Key": apiKey,
            "Content-Type": "application/json",
          },
        ),
      );

      retVal = true;
    } on DioError catch (exception) {
      debugPrint("Delete Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<Map<String, dynamic>> postImage(Uint8List imageBytes,
      String imageName, String mUrl, String apiKey) async {
    Map<String, dynamic> retVal = {};

    String url = "$mUrl/uploads.json?filename=$imageName";

    try {
      Dio dio = Dio();

      Response response = await dio.post(
        url,
        options: Options(
          headers: {
            "X-Redmine-API-Key": apiKey,
            "Content-Type": "application/octet-stream",
          },
        ),
        data: Stream.fromIterable(imageBytes.map((e) => [e])),
      );

      retVal = {
        "status_code": response.statusCode,
        "status_message": response.statusMessage,
        "status_data": response.data,
      };
    } catch (exception) {
      debugPrint("Image Error: $exception");
    }
    return retVal;
  }

  static Future<bool> deleteImage(
      String mUrl, String apiKey, int imageId) async {
    bool retVal = false;

    String url = "$mUrl/attachments/$imageId.json";

    try {
      Dio dio = Dio();

      await dio.delete(
        url,
        options: Options(
          headers: {
            "X-Redmine-API-Key": apiKey,
            "Content-Type": "application/json",
          },
        ),
      );

      retVal = true;
    } on DioError catch (exception) {
      debugPrint("Delete Error: ${exception.message}");
    }
    return retVal;
  }

  static Future<Map<String, dynamic>> postSpentHours(
      url, apiKey, Map<String, dynamic> params) async {
    Map<String, dynamic> retVal = {};

    String iUrl = "$url/time_entries.json";
    try {
      Dio dio = Dio();
      Response response;

      response = await dio.post(
        iUrl,
        options: Options(
          headers: {
            "X-Redmine-API-Key": apiKey,
            "Content-Type": "application/json",
          },
        ),
        data: params,
      );
      retVal = {
        "status_code": response.statusCode,
        "status_message": response.statusMessage,
        "status_data": response.data,
      };
    } catch (e) {
      debugPrint("SetHours Error: ${params.toString()}");
    }

    return retVal;
  }

  static Future<Map<String, dynamic>> postIssue(
      url, apiKey, Map<String, dynamic> params) async {
    Map<String, dynamic> retVal = {};

    String iUrl = params["issue"]["issue_id"] < 0
        ? "$url/issues.json"
        : "$url/issues/${params["issue"]["issue_id"]}.json";

    debugPrint("POST: $iUrl");
    debugPrint("Params: ${params.toString()}");

    try {
      Dio dio = Dio();
      Response response;

      if (params["issue"]["issue_id"] < 0) {
        response = await dio.post(
          iUrl,
          options: Options(
            headers: {
              "X-Redmine-API-Key": apiKey,
              "Content-Type": "application/json",
            },
          ),
          data: params,
        );
      } else {
        response = await dio.put(
          iUrl,
          options: Options(
            headers: {
              "X-Redmine-API-Key": apiKey,
              "Content-Type": "application/json",
            },
          ),
          data: params,
        );
      }

      retVal = {
        "status_code": response.statusCode,
        "status_message": response.statusMessage,
        "status_data": response.data,
      };

      debugPrint("Status Code: ${response.statusCode}, "
          "Status Message: ${response.statusMessage},"
          "Status Data: ${response.data.toString()}");
    } catch (exception) {
      debugPrint("Issue Error: $exception");
    }
    return retVal;
  }
}
