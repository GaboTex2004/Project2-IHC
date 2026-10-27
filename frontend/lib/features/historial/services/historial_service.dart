import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';

class HistorialService {
  // Devuelve la lista de eventos o null si hubo un error
  Future<List<dynamic>?> obtenerHistorial(String? tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    String url = '${AppConstants.baseUrl}/historial/';
    if (tipo != null) url += '?tipo=$tipo';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
