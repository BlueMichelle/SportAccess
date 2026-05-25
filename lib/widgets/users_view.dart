import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersView extends StatefulWidget {
  const UsersView({Key? key}) : super(key: key);

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  // Estado de carga para que el botón muestre un spinner al guardar
  bool _isSaving = false;

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/users'));
    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception('Fallo al cargar usuarios');
  }

  Future<void> _eliminarUsuario(int id) async {
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

  void _mostrarFormularioUsuario({Map<String, dynamic>? usuarioExistente}) {
    final isEditing = usuarioExistente != null;
    final nombreCtrl = TextEditingController(text: isEditing ? usuarioExistente['nombre'] : '');
    final emailCtrl = TextEditingController(text: isEditing ? usuarioExistente['email'] : '');
    final telefonoCtrl = TextEditingController(text: isEditing ? usuarioExistente['telefono'] : '');
    String rolSeleccionado = isEditing ? (usuarioExistente['rol'] ?? 'USER') : 'USER';

    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre tocando fuera mientras carga
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                title: Text(isEditing ? 'Editar Usuario #${usuarioExistente['id']}' : 'Añadir Nuevo Usuario'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                      TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono')), // ✨ NUEVO
                      TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        enabled: !isEditing, // Evitamos cambiar el email al editar para no romper Firebase
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: rolSeleccionado,
                        decoration: const InputDecoration(labelText: 'Rol del Sistema'),
                        items: ['USER', 'ADMIN'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                        onChanged: (v) => setModalState(() => rolSeleccionado = v!),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar')
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : () async {
                      if (emailCtrl.text.isEmpty || nombreCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rellena todos los campos')));
                        return;
                      }

                      setModalState(() => _isSaving = true);

                      try {
                        http.Response response;

                        if (isEditing) {
                          // ✏️ MODO EDICIÓN
                          final Map<String, dynamic> body = {
                            "nombre": nombreCtrl.text,
                            "rol": rolSeleccionado,
                            "telefono": telefonoCtrl.text,
                          };
                          response = await http.put(
                            Uri.parse('http://localhost:8080/api/users/${usuarioExistente['id']}'),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode(body),
                          );
                        } else {
                          // ➕ MODO CREACIÓN MÁGICA
                          // 1. Generamos contraseña temporal súper segura (nunca se usará)
                          String tempPassword = "Temp${DateTime.now().millisecondsSinceEpoch}#@!";

                          // 2. Truco pro: Creamos App temporal para que no nos cierre la sesión del admin
                          FirebaseApp tempApp = await Firebase.initializeApp(
                            name: 'tempUserCreation',
                            options: Firebase.app().options,
                          );

                          UserCredential userCred = await FirebaseAuth.instanceFor(app: tempApp)
                              .createUserWithEmailAndPassword(email: emailCtrl.text.trim(), password: tempPassword);

                          String newUid = userCred.user!.uid;
                          await tempApp.delete(); // Destruimos la app temporal, la sesión original sigue intacta

                          // 3. Enviamos los datos a tu UserController (MySQL)
                          final Map<String, dynamic> body = {
                            "firebaseUid": newUid,
                            "nombre": nombreCtrl.text,
                            "email": emailCtrl.text.trim(),
                            "rol": rolSeleccionado,
                          };

                          response = await http.post(
                            // Usamos tu ruta /register que ya procesa el firebaseUid
                            Uri.parse('http://localhost:8080/api/users/register'),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode(body),
                          );

                          // 4. Enviamos el correo de reseteo real
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: emailCtrl.text.trim());
                          }
                        }

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          Navigator.pop(context);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEditing ? '✅ Actualizado' : '✅ Creado. Se ha enviado un email al usuario.'))
                          );
                        } else {
                          throw Exception('Error del servidor: ${response.statusCode}');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        setModalState(() => _isSaving = false);
                      }
                    },
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isEditing ? 'Actualizar' : 'Guardar y Enviar Email'),
                  ),
                ],
              );
            }
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
          if (snapshot.hasError) return Center(child: Text('Error al conectar: ${snapshot.error}'));
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
                    DataColumn(label: Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: snapshot.data!.map((u) {
                    return DataRow(cells: [
                      DataCell(Text(u['id'].toString())),
                      DataCell(Text(u['nombre'] ?? 'Sin nombre')),
                      DataCell(Text(u['email'] ?? '')),
                      DataCell(Text(u['telefono'] ?? '-')), // Si es null, muestra un guion
                      DataCell(Chip(label: Text(u['rol'] ?? 'USER'), backgroundColor: Colors.blueGrey[100])),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar',
                              onPressed: () => _mostrarFormularioUsuario(usuarioExistente: u),
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioUsuario(),
        label: const Text('Nuevo Usuario'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
    );
  }
}