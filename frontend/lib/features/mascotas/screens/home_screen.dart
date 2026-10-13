import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants.dart';
import '../../auth/screens/login_screen.dart';

// IMPORTAMOS LA NUEVA PANTALLA
import 'agregar_mascota_screen.dart';
import 'editar_mascota_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nombreUsuario = "Cargando...";
  List<dynamic> _mascotas = [];
  bool _cargando = true;

  // Variables para los filtros
  String _filtroNombre = "";
  bool? _filtroEstado; // null: Todos, false: Pendientes, true: Realizados
  String? _filtroCuidado;
  DateTime? _filtroFechaInicio;
  DateTime? _filtroFechaFin;
  String? _filtroFechaLabel; // NUEVO: Para mostrar en el Chip

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

  // --- NUEVA FUNCIÓN PARA CALCULAR LAS FECHAS ---
  Future<void> _aplicarFiltroFecha(String? tipo) async {
    final hoy = DateTime.now();

    if (tipo == '7_dias') {
      _filtroFechaInicio = hoy;
      _filtroFechaFin = hoy.add(Duration(days: 7));
      _filtroFechaLabel = "Próximos 7 días";
    } else if (tipo == 'este_mes') {
      _filtroFechaInicio = DateTime(hoy.year, hoy.month, 1);
      _filtroFechaFin = DateTime(hoy.year, hoy.month + 1, 0);
      _filtroFechaLabel = "Este mes";
    } else if (tipo == 'personalizado') {
      final DateTimeRange? rango = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (rango != null) {
        _filtroFechaInicio = rango.start;
        _filtroFechaFin = rango.end;
        _filtroFechaLabel =
            "${rango.start.day}/${rango.start.month} - ${rango.end.day}/${rango.end.month}";
      } else {
        return; // Si cancela, no hacemos nada
      }
    } else {
      _filtroFechaInicio = null;
      _filtroFechaFin = null;
      _filtroFechaLabel = null;
    }

    setState(() {});
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    setState(() => _cargando = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    // Construimos los parámetros de la URL
    List<String> queryParams = [];
    if (_filtroNombre.isNotEmpty) queryParams.add("nombre=$_filtroNombre");
    if (_filtroEstado != null) queryParams.add("estado=$_filtroEstado");
    if (_filtroCuidado != null && _filtroCuidado!.isNotEmpty)
      queryParams.add("cuidado=$_filtroCuidado");
    if (_filtroFechaInicio != null)
      queryParams.add(
        "fecha_inicio=${_filtroFechaInicio!.toIso8601String().split('T')[0]}",
      );
    if (_filtroFechaFin != null)
      queryParams.add(
        "fecha_fin=${_filtroFechaFin!.toIso8601String().split('T')[0]}",
      );

    String queryString = queryParams.isNotEmpty
        ? "?${queryParams.join('&')}"
        : "";

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/mascotas/lista$queryString'),
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

  Future<void> _eliminarMascota(int idMascota) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/mascotas/eliminar/$idMascota'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro eliminado correctamente.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      _cargarMascotas();
    }
  }

  void _confirmarEliminar(int idMascota) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text("¿Eliminar registro?"),
        content: Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _eliminarMascota(idMascota);
            },
            child: Text("Eliminar"),
          ),
        ],
      ),
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

          // --- 1. BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) => _filtroNombre = value,
              onSubmitted: (_) => _cargarMascotas(),
              decoration: InputDecoration(
                labelText: 'Buscar mascota por nombre...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _cargarMascotas,
                ),
              ),
            ),
          ),

          // --- 2. CONTROLES DE FILTRO (Desplegables) ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<bool?>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    value: _filtroEstado,
                    hint: Text("Estado"),
                    items: [
                      DropdownMenuItem(value: null, child: Text("Todos")),
                      DropdownMenuItem(value: false, child: Text("Pendientes")),
                      DropdownMenuItem(value: true, child: Text("Realizados")),
                    ],
                    onChanged: (valor) {
                      setState(() => _filtroEstado = valor);
                      _cargarMascotas();
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    value: _filtroCuidado,
                    hint: Text("Tipo"),
                    items: [
                      DropdownMenuItem(value: null, child: Text("Cualquiera")),
                      DropdownMenuItem(value: "Vacuna", child: Text("Vacuna")),
                      DropdownMenuItem(
                        value: "Desparasitación",
                        child: Text("Desparasitación"),
                      ),
                      DropdownMenuItem(
                        value: "Control",
                        child: Text("Control"),
                      ),
                      DropdownMenuItem(value: "Baño", child: Text("Baño")),
                    ],
                    onChanged: (valor) {
                      setState(() => _filtroCuidado = valor);
                      _cargarMascotas();
                    },
                  ),
                ),
              ],
            ),
          ),

          // NUEVO: FILTRO DE FECHAS DEBAJO DE LOS OTROS DOS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String?>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              value: null,
              hint: Text("Filtrar por fecha..."),
              items: [
                DropdownMenuItem(value: null, child: Text("Cualquier fecha")),
                DropdownMenuItem(
                  value: "7_dias",
                  child: Text("Próximos 7 días"),
                ),
                DropdownMenuItem(value: "este_mes", child: Text("Este mes")),
                DropdownMenuItem(
                  value: "personalizado",
                  child: Text("Rango personalizado..."),
                ),
              ],
              onChanged: (valor) => _aplicarFiltroFecha(valor),
            ),
          ),
          SizedBox(height: 8),

          // --- 3. FILTROS ACTIVOS (Chips con la "X" para quitarlos) ---
          Wrap(
            spacing: 8.0,
            children: [
              if (_filtroNombre.isNotEmpty)
                Chip(
                  label: Text('Nombre: $_filtroNombre'),
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _filtroNombre = "");
                    _cargarMascotas();
                  },
                ),
              if (_filtroEstado != null)
                Chip(
                  label: Text(_filtroEstado! ? 'Realizados' : 'Pendientes'),
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _filtroEstado = null);
                    _cargarMascotas();
                  },
                ),
              if (_filtroCuidado != null && _filtroCuidado!.isNotEmpty)
                Chip(
                  label: Text('Tipo: $_filtroCuidado'),
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _filtroCuidado = null);
                    _cargarMascotas();
                  },
                ),
              if (_filtroFechaInicio != null)
                Chip(
                  label: Text(_filtroFechaLabel ?? 'Fechas específicas'),
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _filtroFechaInicio = null;
                      _filtroFechaFin = null;
                      _filtroFechaLabel = null;
                    });
                    _cargarMascotas();
                  },
                ),
            ],
          ),

          Divider(color: Colors.grey),

          // --- 4. LISTADO Y MENSAJE DE ESTADO VACÍO ---
          Expanded(
            child: _cargando
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : _mascotas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No se encontraron cuidados con estos filtros.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
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
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${mascota['cuidado']} · ${mascota['fecha']}',
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
                                    onPressed: () =>
                                        _marcarComoRealizado(mascota['id']),
                                    child: Text("Marcar como realizado"),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "✓ Realizado",
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              SizedBox(height: 8),

                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: estaRealizado
                                            ? Colors.grey[300]
                                            : Colors.white,
                                        foregroundColor: estaRealizado
                                            ? Colors.grey[600]
                                            : Colors.black,
                                        side: BorderSide(color: Colors.grey),
                                        elevation: 0,
                                      ),
                                      onPressed: () async {
                                        if (estaRealizado) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "No puedes editar un cuidado que ya fue realizado.",
                                                  ),
                                                ),
                                              );
                                        } else {
                                          final resultado =
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditarMascotaScreen(
                                                        mascota: mascota,
                                                      ),
                                                ),
                                              );
                                          if (resultado == true)
                                            _cargarMascotas();
                                        }
                                      },
                                      child: Text("Editar"),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[100],
                                        foregroundColor: Colors.red[900],
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                          _confirmarEliminar(mascota['id']),
                                      child: Text("Eliminar"),
                                    ),
                                  ),
                                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarMascotaScreen()),
          );
          if (resultado == true) {
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
