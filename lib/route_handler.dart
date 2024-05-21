import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final key = Platform.environment['KEY'];

final router = Router()
  ..get('/random_activity/all', _getAllActivities)
  ..get('/random_activity/filter/<category>', _filterActivities);

Future<Response> _filterActivities(Request request) async {
  final query = request.params["category"]!;
  final decodeQuery = Uri.decodeComponent(query);
  final url = Uri.parse(key ?? '');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body) as List;

    final filter = decoded.where((e) {
      return e["type"]!.contains(decodeQuery);
    }).toList();
    final encode = jsonEncode(filter);

    return Response.ok(encode, headers: {'Content-Type': 'text/plain'});
  } else {
    return Response.internalServerError(
      body: 'Sorry! An Error Occured: ${response.body}',
    );
  }
}

Future<Response> _getAllActivities(Request request) async {
  final url = Uri.parse(key ?? "");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    // final responseBody = jsonDecode(response.body);
    return Response.ok(
      response.body,
      headers: {'Content-Type': 'text/plain'},
    );
  } else {
    return Response.internalServerError(
      body: 'Sorry! An Error Occured: ${response.body}',
    );
  }
}
