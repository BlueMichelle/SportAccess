import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/models/models.dart';
import 'package:app/services/api_service.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({Key? key}) : super(key: key);

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _descriptionCtrl = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  bool _isLoadingCourts = true;
  // ✨ CORRECCIÓN 1: Ahora espera un String en lugar de un int
  String? selectedCourtId;
  List<Court> _courts = [];

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    try {
      final apiCourts = await ApiService().getCourts();
      if (mounted) {
        setState(() {
          _courts = apiCourts;
          _isLoadingCourts = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar las pistas para el reporte: $e');
      if (mounted) {
        setState(() => _isLoadingCourts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar la lista de instalaciones')),
        );
      }
    }
  }

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
          // ✨ CORRECCIÓN 4: Convertimos el String a número para Java
          "courtId": int.parse(selectedCourtId!),
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

                // ✨ CORRECCIÓN 2: El Dropdown ahora usa <String>
                _isLoadingCourts
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(color: Color(0xFFF05B3A)),
                )
                    : DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Selecciona la instalación afectada',
                    border: const OutlineInputBorder(),
                    filled: isDark,
                    fillColor: isDark ? colorScheme.surfaceVariant : null,
                  ),
                  dropdownColor: isDark ? colorScheme.surfaceVariant : null,
                  value: selectedCourtId,
                  items: _courts.map((Court court) {
                    // ✨ CORRECCIÓN 3: Los items también usan <String> y se les pasa el ID tal cual
                    return DropdownMenuItem<String>(
                      value: court.id,
                      child: Text(court.name),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => selectedCourtId = newValue);
                  },
                ),
                const SizedBox(height: 16),

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