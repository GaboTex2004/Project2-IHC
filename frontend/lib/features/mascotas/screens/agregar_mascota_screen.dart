import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants.dart';

class AgregarMascotaScreen extends StatefulWidget {
  @override
  _AgregarMascotaScreenState createState() => _AgregarMascotaScreenState();
}

class _AgregarMascotaScreenState extends State<AgregarMascotaScreen> {
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _cuidadoController = TextEditingController();
  final _fechaController = TextEditingController();

  bool _guardando = false;

  Future<void> _guardarMascota() async {
    // Validación súper básica para que no envíen datos vacíos
    if (_nombreController.text.isEmpty || _fechaController.text.isEmpty) {
      print("Por favor, llena los datos");
      return;
    }

    setState(() {
      _guardando = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      // CORRECCIÓN DEL 404: Quitamos la barra final después de mascotas
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/mascotas/crear'),
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        print("Error al guardar: ${response.body}");
        setState(() {
          _guardando = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _guardando = false;
      });
    }
  }

  // --- FUNCIÓN PARA MOSTRAR EL CALENDARIO ---
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), // Fecha mínima
      lastDate: DateTime(2030), // Fecha máxima
      builder: (context, child) {
        // Le damos tu estilo blanco/negro al calendario
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue, // Color del encabezado
              onPrimary: Colors.white, // Texto del encabezado
              onSurface: Colors.black, // Color de los días
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      // Si eligen una fecha, la formateamos a YYYY-MM-DD sin usar librerías extra
      String anio = fechaSeleccionada.year.toString();
      String mes = fechaSeleccionada.month.toString().padLeft(2, '0');
      String dia = fechaSeleccionada.day.toString().padLeft(2, '0');

      setState(() {
        _fechaController.text = "$anio-$mes-$dia";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Nueva Mascota"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Llena los datos:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: "Nombre (ej. Luna)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _tipoController,
              decoration: InputDecoration(
                labelText: "Tipo (ej. perro)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _cuidadoController,
              decoration: InputDecoration(
                labelText: "Cuidado (ej. vacuna)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // --- CAMPO DE FECHA CON CALENDARIO ---
            TextField(
              controller: _fechaController,
              readOnly: true, // Evita que se abra el teclado
              onTap: () =>
                  _seleccionarFecha(context), // Abre el calendario al tocar
              decoration: InputDecoration(
                labelText: "Fecha de cuidado",
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
                onPressed: _guardando ? null : _guardarMascota,
                child: _guardando
                    ? Text("Guardando...")
                    : Text("Guardar Mascota"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
