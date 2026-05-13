import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ¡Adiós a la importación de firebase_storage!

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({Key? key}) : super(key: key);

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _descriptionCtrl = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  int? selectedCourtId;
  final List<Map<String, dynamic>> _courts = [
    {"id": 1, "nombre": "Pista 1 (Fútbol)"},
    {"id": 2, "nombre": "Pista 2 (Pádel)"},
    {"id": 3, "nombre": "Pista 3 (Tenis)"},
    {"id": 4, "nombre": "Pista 4 (Baloncesto)"},
  ];

  // Seleccionar foto (Galería)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Bajamos un poco la calidad para que el texto Base64 no sea colosal y MySQL lo trague rápido
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  // Lógica de envío (Directo a Spring Boot)
  Future<void> _submitIncident() async {
    final description = _descriptionCtrl.text.trim();

    if (_selectedImage == null || description.isEmpty || selectedCourtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falta la foto, la pista o la descripción'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    print("🚀 1. Botón pulsado. Empezando...");

    try {
      // 1. CONVERTIR LA FOTO A TEXTO (Base64)
      print("📸 2. Convirtiendo foto a Base64...");
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      print("✅ Foto convertida correctamente.");

      // 2. ENVIAR A SPRING BOOT (MySQL)
      print("📡 3. Enviando datos al servidor Java...");
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/incidents'), // 10.0.2.2 es el localhost del emulador de Android
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "courtId": selectedCourtId,
          "reportedById": 1, // Esto lo cambiarás más adelante por el ID del usuario logueado
          "descripcion": description,
          "imagenBase64": base64Image // ¡Aquí mandamos el texto kilométrico!
        }),
      );

      print("🌍 4. Respuesta del servidor Java: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Incidencia enviada correctamente')),
          );
          Navigator.pop(context); // Vuelve a la pantalla anterior
        }
      } else {
        throw 'Error en el servidor Java (Código: ${response.statusCode})';
      }

    } catch (e) {
      print("❌ ERROR DETALLADO: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al enviar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, title: const Text('Atrás', style: TextStyle(fontSize: 16))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('REPORTAR',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))
                ),
                const Text('Incidencia técnica', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 48),

                // Contenedor de la Foto
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Añadir foto', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Desplegable de Pistas
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Selecciona la instalación afectada',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCourtId,
                  items: _courts.map((court) {
                    return DropdownMenuItem<int>(
                      value: court['id'],
                      child: Text(court['nombre']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedCourtId = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Campo de descripción
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del problema',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de Envío
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _submitIncident,
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ENVIAR REPORTE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}