import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

///collection of static methods to make http requests
class Http {
  ///translate text by making a post request to API
  ///
  ///if theres an error but the response can still be decoded,
  ///makes a snackbar with error information
  static Future<String> translationRequest(BuildContext context, String str,
      String srclang, String destlang) async {
    if (kDebugMode) {
      print("User requested to translate $str from $srclang to $destlang");
    }
    Uri url = Uri.parse(
        'https://bk6l12pe03.execute-api.us-east-2.amazonaws.com/default/main');
    Map jsonData = {
      "resource": "translate",
      "body": str,
      "pathParameters": {
        "srclang": srclang,
        "destlang": destlang
      }
    };
    var body = json.encode(jsonData);
    http.Response response;
    try {
      response = await http.post(url, body: body);
    }on Exception catch(e){
      final snackbar = SnackBar(content: Text("Unable to access server"));
      try {
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      finally {
        if (kDebugMode) print("Unable to access server, ${e.toString()}");

      }
      return "";
    }
    Map map = json.decode(response.body);
    if (map.containsKey("data") && response.statusCode == 200) {
      return map["data"];
    } else {
      final snackbar = SnackBar(content: Text("An error occurred! ${map.toString()}"));
      try {
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      finally {
        if (kDebugMode) print("The http request response was ${map.toString()}");
      }


      return "";
    }
  }
  ///not yet implemented
  static Future<String> transcriptionRequest(String str, String lang) {
    throw UnimplementedError();
  }
}