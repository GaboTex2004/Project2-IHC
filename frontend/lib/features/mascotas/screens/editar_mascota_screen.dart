import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants.dart';

class EditarMascotaScreen extends StatefulWidget {
  final Map<String, dynamic> mascota;
  EditarMascotaScreen({required this.mascota});
  @override
  _EditarMascotaScreenState createState() => _EditarMascotaScreenState();
}

class _EditarMascotaScreenState extends State<EditarMascotaScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _tipoController;
  late TextEditingController _cuidadoController;
  late TextEditingController _fechaController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.mascota['nombre']);
    _tipoController = TextEditingController(text: widget.mascota['tipo']);
    _cuidadoController = TextEditingController(text: widget.mascota['cuidado']);
    _fechaController = TextEditingController(text: widget.mascota['fecha']);
  }

  Future<void> _actualizarMascota() async {
    if (_nombreController.text.isEmpty || _fechaController.text.isEmpty) return;

    setState(() => _guardando = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final idMascota = widget.mascota['id'];

    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/mascotas/editar/$idMascota'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "nombre": _nombreController.text,
          "tipo": _tipoController.text,
          "cuidado": _cuidadoController.text,
          "fecha": _fechaController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Retornamos true indicando éxito
      } else {
        setState(() => _guardando = false);
      }
    } catch (e) {
      setState(() => _guardando = false);
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.mascota['fecha']),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (fecha != null) {
      setState(() {
        _fechaController.text =
            "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Editar Mascota"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _tipoController,
              decoration: InputDecoration(
                labelText: "Tipo",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _cuidadoController,
              decoration: InputDecoration(
                labelText: "Cuidado",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _fechaController,
              readOnly: true,
              onTap: () => _seleccionarFecha(context),
              decoration: InputDecoration(
                labelText: "Fecha",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _guardando ? null : _actualizarMascota,
                child: Text(_guardando ? "Actualizando..." : "Guardar Cambios"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
