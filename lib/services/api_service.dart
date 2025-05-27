import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final baseUrl = dotenv.env['BASE_URL'];

  static Future<String?> _getToken() async {
    return Supabase.instance.client.auth.currentSession?.accessToken;
  }

  static Future<List<dynamic>> getTransactions() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  static Future<void> createTransaction({
    required String description,
    required double amount,
    required String categoryId,
    required DateTime date,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'description': description,
        'amount': amount,
        'category_id': categoryId,
        'transaction_date': date.toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create transaction');
    }
  }
}
