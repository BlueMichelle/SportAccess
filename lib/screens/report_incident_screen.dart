import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

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

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/incidents'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "courtId": selectedCourtId,
          "reportedById": 1,
          "descripcion": description,
          "imagenBase64": base64Image,
        }),
      );

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
      print("❌ ERROR DETALLADO: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Error al enviar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Atrás', style: TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TÍTULO
                Text(
                  'REPORTAR',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Text(
                  'Incidencia técnica',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // CONTENEDOR DE LA FOTO
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceVariant : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.4),
                      ),
                    ),
                    child: _selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 48,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Añadir foto',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // DESPLEGABLE DE PISTAS
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Selecciona la instalación afectada',
                    border: const OutlineInputBorder(),
                    filled: isDark,
                    fillColor: isDark ? colorScheme.surfaceVariant : null,
                  ),
                  dropdownColor: isDark ? colorScheme.surfaceVariant : null,
                  value: selectedCourtId,
                  items: _courts.map((court) {
                    return DropdownMenuItem<int>(
                      value: court['id'],
                      child: Text(court['nombre']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() => selectedCourtId = newValue);
                  },
                ),
                const SizedBox(height: 16),

                // CAMPO DE DESCRIPCIÓN
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Descripción del problema',
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                    filled: isDark,
                    fillColor: isDark ? colorScheme.surfaceVariant : null,
                  ),
                ),
                const SizedBox(height: 24),

                // BOTÓN DE ENVÍO
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