import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shop_manager/helpers/shared_prefs_helper.dart';
import 'api_response.dart';

class ApiHelper {
  static const String _baseUrl = 'http://shopmanager.ir/api';

  // Default headers for all requests
  static Future<Map<String, String>> get _defaultHeaders async {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'Authorization': "Bearer ${await SharedPrefsHelper.getUserToken()}",
    };
  }

  // Helper method to make POST requests
  static Future<ApiResponse> post(String endpoint,
      {dynamic body = const {}}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _defaultHeaders,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('POST request failed: $e');
      }
      rethrow;
    }
  }

  // Helper method to make GET requests
  static Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _defaultHeaders,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('GET request failed: $e');
      }
      rethrow;
    }
  }

  // Helper method to make PUT requests
  static Future<ApiResponse> put(String endpoint, {dynamic body = const {}}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _defaultHeaders,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('PUT request failed: $e');
      }
      rethrow;
    }
  }

  // Helper method to make DELETE requests
  static Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _defaultHeaders,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('DELETE request failed: $e');
      }
      rethrow;
    }
  }

  // Handle the API response
  static ApiResponse _handleResponse(http.Response response) {
    var decodedData = utf8.decode(response.bodyBytes); // Decode bytes as UTF-8
    final Map<String, dynamic> responseBody = jsonDecode(decodedData);

    if (kDebugMode) {
      print('Response status code: ${response.statusCode}');
      print('Response body: $responseBody');
    }

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(responseBody);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}, body: ${response.body}');
    }
  }
}