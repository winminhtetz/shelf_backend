import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// final apiKey = Platform.environment['OPENAI_API_KEY'];
final apiKey = 'sk-proj-cRBetP0lCy7EpzQuKaf9T3BlbkFJuJ0KJXijxVzAdJSTGG0a';
final link =
    'https://raw.githubusercontent.com/winminhtetz/JsonFiles/main/pyin_nay_b_lar.json';

final router = Router()
  ..get('/random_activity/all', _getAllActivities)
  ..get('/random_activity/filter/<category>', _filterActivities);

Future<Response> _filterActivities(Request request) async {
  final query = request.params["category"]!;
  final decodeQuery = Uri.decodeComponent(query);
  final url = Uri.parse(link);
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
  final url = Uri.parse(link);
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

Future<Response> _tipHandler(Request request) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };
  final data = {
    'model': 'gpt-3.5-turbo',
    'messages': [
      {
        'role': 'user',
        'content': 'Give me a random tip about using Flutter and Dart. '
            'Keep it to one sentence.',
      }
    ],
    'temperature': 1.0,
  };

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    final messageContent = responseBody['choices'][0]['message']['content'];
    return Response.ok(messageContent);
  } else {
    return Response.internalServerError(
      body: 'OpenAI request failed: ${response.body}',
    );
  }
}
