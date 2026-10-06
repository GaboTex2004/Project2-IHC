import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants.dart';
import '../../auth/screens/login_screen.dart';

// IMPORTAMOS LA NUEVA PANTALLA
import 'agregar_mascota_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nombreUsuario = "Cargando...";
  List<dynamic> _mascotas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarMascotas();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreUsuario = prefs.getString('usuario_nombre') ?? 'Usuario';
    });
  }

  Future<void> _cargarMascotas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/mascotas/lista'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _mascotas = json.decode(response.body);
          _cargando = false;
        });
      } else {
        print("Error al cargar mascotas");
        setState(() => _cargando = false);
      }
    } catch (e) {
      print("Error de conexión: $e");
      setState(() => _cargando = false);
    }
  }

  Future<void> _marcarComoRealizado(int idMascota) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/mascotas/$idMascota/completar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _cargarMascotas();
      } else {
        print("Error al actualizar");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('usuario_nombre');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Mascota al Día - Panel"),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              "Hola, $_nombreUsuario",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Divider(color: Colors.grey),
          Expanded(
            child: _cargando
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : _mascotas.isEmpty
                ? Center(
                    child: Text(
                      "No tienes mascotas registradas.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _mascotas.length,
                    itemBuilder: (context, index) {
                      final mascota = _mascotas[index];
                      final bool estaRealizado = mascota['estado'];

                      return Card(
                        color: Colors.grey[200],
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey, width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"${mascota['nombre']}" · ${mascota['tipo']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${mascota['cuidado']} · ${mascota['fecha']}',
                                style: TextStyle(color: Colors.black87),
                              ),
                              SizedBox(height: 12),
                              if (!estaRealizado)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      _marcarComoRealizado(mascota['id']);
                                    },
                                    child: Text("Marcar como realizado"),
                                  ),
                                )
                              else
                                Text(
                                  "✓ Realizado",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // --- BOTÓN PARA IR A LA NUEVA PANTALLA ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegamos a la pantalla y esperamos a ver si devuelve "true"
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarMascotaScreen()),
          );

          // Si el resultado es true, significa que el usuario guardó algo y recargamos
          if (resultado == true) {
            setState(() {
              _cargando = true;
            });
            _cargarMascotas();
          }
        },
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
