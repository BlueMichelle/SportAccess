import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersView extends StatefulWidget {
  const UsersView({Key? key}) : super(key: key);

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/users'));
    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception('Fallo al cargar usuarios');
  }

  Future<void> _eliminarUsuario(int id) async {
    // Diálogo de confirmación profesional antes de borrar
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')
          ),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    final response = await http.delete(Uri.parse('http://localhost:8080/api/users/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('👤 Usuario eliminado')));
    }
  }

  // 🛠️ MAGIA AQUÍ: Formulario unificado para Crear y Editar
  void _mostrarFormularioUsuario({Map<String, dynamic>? usuarioExistente}) {
    final isEditing = usuarioExistente != null;
    final nombreCtrl = TextEditingController(text: isEditing ? usuarioExistente['nombre'] : '');
    final emailCtrl = TextEditingController(text: isEditing ? usuarioExistente['email'] : '');
    final passwordCtrl = TextEditingController(); // La contraseña suele ir vacía al editar por seguridad
    String rolSeleccionado = isEditing ? (usuarioExistente['rol'] ?? 'USER') : 'USER';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Usuario #${usuarioExistente['id']}' : 'Añadir Nuevo Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                if (!isEditing) // Solo pedimos contraseña obligatoria al crear
                  TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: rolSeleccionado,
                  decoration: const InputDecoration(labelText: 'Rol del Sistema'),
                  items: ['USER', 'ADMIN'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => rolSeleccionado = v!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final Map<String, dynamic> body = {
                  "nombre": nombreCtrl.text,
                  "email": emailCtrl.text,
                  "rol": rolSeleccionado,
                };
                if (passwordCtrl.text.isNotEmpty) body["password"] = passwordCtrl.text; // Ojo, tu backend debe encriptarla

                http.Response response;
                if (isEditing) {
                  // Actualizar existente (PUT)
                  response = await http.put(
                    Uri.parse('http://localhost:8080/api/users/${usuarioExistente['id']}'),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(body),
                  );
                } else {
                  // Crear nuevo (POST)
                  response = await http.post(
                    Uri.parse('http://localhost:8080/api/users'),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(body),
                  );
                }

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  setState(() {}); // Refrescamos la tabla
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? '✅ Usuario actualizado' : '✅ Usuario creado')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.statusCode}')));
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<dynamic>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Aún no hay conexión con Usuarios.'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay usuarios registrados'));

          return ListView(
            padding: const EdgeInsets.all(32.0),
            children: [
              Card(
                elevation: 4,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: snapshot.data!.map((u) {
                    return DataRow(cells: [
                      DataCell(Text(u['id'].toString())),
                      DataCell(Text(u['nombre'] ?? 'Sin nombre')),
                      DataCell(Text(u['email'] ?? '')),
                      DataCell(Chip(label: Text(u['rol'] ?? 'USER'), backgroundColor: Colors.blueGrey[100])),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✏️ Botón de Editar
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar',
                              onPressed: () => _mostrarFormularioUsuario(usuarioExistente: u),
                            ),
                            // 🗑️ Botón de Borrar
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Eliminar',
                              onPressed: () => _eliminarUsuario(u['id']),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      // ➕ Botón Flotante para crear usuario
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioUsuario(), // Sin parámetros = Modo Crear
        label: const Text('Nuevo Usuario'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
    );
  }
}