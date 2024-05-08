import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_assistant/misc/base_item.dart';
import 'package:inventory_assistant/misc/api/api_url.dart' as api;
import 'package:inventory_assistant/misc/api/api_token.dart' as api_token;
import 'dart:developer';
import 'package:flutter/foundation.dart';

/// Fetch all locations from the database
Future<List<BaseItem>> fetchLocations() async {
  List<BaseItem> location = [];

  try {
    await http.get(
      Uri.parse('${api.getApiBaseUrl()}/locations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        for (var i = 0; i < data.length; i++) {
          location.add(BaseItem(
            id: data[i]['id'],
            name: data[i]['address'],
          ));
        }
      } else {
        if (kDebugMode) {
          debugPrint('Request failed with status: ${response.statusCode}');
          log('Request failed with status: ${response.statusCode}');
        }
      }
    });
  } catch (e) {
    // Handle any exceptions that occur
    if (kDebugMode) {
      debugPrint('Error: $e');
      log('Error: $e');
    }
  }

  return location;
}

/// Get current user information
Future getCurrentUser() async {
  Map<String, dynamic> user = {};
  final token = await api_token.getToken();

  try {
    await http.get(
      Uri.parse('${api.getApiBaseUrl()}/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user = {
          'id': data['id'],
          'first_name': data['first_name'],
          'last_name': data['last_name'],
          'email': data['email'],
          'phone': data['phone_number'],
          'location': data['location_id'],
        };
      } else {
        if (kDebugMode) {
          debugPrint('Request failed with status: ${response.statusCode}');
        }
      }
    });
  } catch (e) {
    // Handle any exceptions that occur
    if (kDebugMode) {
      debugPrint('Error: $e');
    }
  }

  return user;
}

/// Update user information
Future<bool> updateUser({
  required int userId,
  required String firstName,
  required String lastName,
  required String email,
  required String phoneNumber,
  required String locatioId,
  required String password,
}) async {
  final token = await api_token.getToken();

  try {
    return await http
        .put(
      Uri.parse('${api.getApiBaseUrl()}/user/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'location_id': locatioId,
        'password': password,
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('User updated');
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('Request failed with status: ${response.statusCode}');
        }
        return false;
      }
    });
  } catch (e) {
    // Handle any exceptions that occur
    if (kDebugMode) {
      debugPrint('Error: $e');
    }
    return false;
  }
}
