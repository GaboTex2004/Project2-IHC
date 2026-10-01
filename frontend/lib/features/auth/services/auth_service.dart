import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';

class AuthService {
  Future<bool> registrar(String nombre, String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/usuarios/registro'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "correo": correo,
          "password": password,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/usuarios/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access_token'];
        final String nombre = data['nombre'] ?? correo;

        // Guardar token y nombre de usuario localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('usuario_nombre', nombre);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> recuperarPassword(String correo) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${AppConstants.baseUrl}/usuarios/recuperar-password',
        ), // Ajusta la ruta si en tu FastAPI es distinta
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
