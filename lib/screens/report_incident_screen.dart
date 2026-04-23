import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  // Lógica de envío (Firebase + Spring Boot)
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

    String fileName = "incident_${DateTime.now().millisecondsSinceEpoch}.jpg";

    print("🚀 1. Botón pulsado. Empezando...");
    print("🚀 Intentando subir a Firebase: incidents/$fileName");//nuevo

    try {

      //❌❌❌❌❌❌❌ESTO ES LO QUE NO FUNCIONA

      String downloadUrl = "";
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://sportaccess-76235.firebasestorage.app');
      Reference ref = storage.ref().child("incidents/$fileName");

      print("📡 Intentando conectar con Firebase Storage...");

      // 1. SUBIDA CON TIEMPO LÍMITE (Esto evitará que gire siempre)
      await ref.putFile(_selectedImage!).timeout(const Duration(seconds: 20), onTimeout: () {
        throw 'TIEMPO_AGOTADO: Firebase no responde. Revisa el archivo google-services.json o tu conexión.';
      });

      print("📸 2. Foto subida con éxito");
      downloadUrl = await ref.getDownloadURL();

      downloadUrl = await ref.getDownloadURL();
      print("🔗 3. URL obtenida de Firebase: $downloadUrl");


      // 2. ENVIAR A SPRING BOOT (MySQL)
      print("📡 4. Enviando datos al servidor Java...");
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/incidents'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "courtId": selectedCourtId,
          "reportedById": 1,
          "descripcion": description,
          "imagenUrl": downloadUrl
        }),
      );

      print("🌍 5. Respuesta del servidor Java: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Incidencia enviada correctamente')),
          );
          Navigator.pop(context);
        }
      } else {
        throw 'Error en el servidor Java (Código: ${response.statusCode})';
      }

    } catch (e) {
      print("❌ ERROR DETALLADO: $e"); // ESTO ES LO QUE TIENES QUE MIRAR
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
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

                // Contenedor de la Foto (Estilo de vuestras Cards)
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

                // Desplegable pintado en pantalla
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

                // Campo de descripción (Estilo igual a vuestro Login)
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

                // Botón de Envío (Igual que vuestro botón ENTRAR)
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