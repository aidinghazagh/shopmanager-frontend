import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shop_manager/helpers/shared_prefs_helper.dart';
import 'api_response.dart';

class ApiHelper {
  static const String _baseUrl = 'http://shopmanager.ir/api';

  // Default headers for all requests
  static Map<String, String> get _defaultHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  static Future<Map<String, String>> _getTokenMap() async{
    return  {
      'Authorization': "Bearer ${await SharedPrefsHelper.getUserToken()}",
    };
  }

  // Helper method to make POST requests
  static Future<ApiResponse> post(String endpoint,
      {bool token = false, dynamic body = const {}}) async {
    try {
      Map<String, String> headers = _defaultHeaders;
      if(token){
        headers = {..._defaultHeaders, ... await _getTokenMap()};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
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
  static Future<ApiResponse> get(String endpoint, {bool token = false}) async {
    try {
      Map<String, String> headers = _defaultHeaders;
      if(token){
        headers = {..._defaultHeaders, ... await _getTokenMap()};
      }
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
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
  static Future<ApiResponse> put(String endpoint, {bool token = false, dynamic body = const {}}) async {
    try {
      Map<String, String> headers = _defaultHeaders;
      if(token){
        headers = {..._defaultHeaders, ... await _getTokenMap()};
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
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
  static Future<ApiResponse> delete(String endpoint, {bool token = false}) async {
    try {
      Map<String, String> headers = _defaultHeaders;
      if(token){
        headers = {..._defaultHeaders, ... await _getTokenMap()};
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
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
    if (kDebugMode) {
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      // Parse the response body
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      print('Response status: ${responseBody['status']}');

      // Convert the response to an ApiResponse object
      return ApiResponse.fromJson(responseBody);
    } else {
      // Throw an exception with the error message
      throw Exception('Failed to load data: ${response.statusCode}, body: ${response.body}');
    }
  }
}