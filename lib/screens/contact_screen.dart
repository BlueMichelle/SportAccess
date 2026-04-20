import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  // Lista de preguntas frecuentes
  final List<Map<String, String>> faqs = const [
    {
      'question': '¿Cómo accedo a la instalación?',
      'answer': 'Una vez realizada tu reserva, recibirás un código QR. Solo tienes que ir a la pestaña "Escanear Acceso" en la app y leer el código del torno de entrada cuando estés a menos de 500 metros de la pista.'
    },
    {
      'question': '¿Puedo cancelar mi reserva?',
      'answer': 'Sí, puedes cancelar desde la sección "Mis Reservas". El horario quedará liberado automáticamente para otros usuarios.'
    },
    {
      'question': '¿Qué ocurre si llueve?',
      'answer': 'Si las condiciones meteorológicas impiden el juego en pistas exteriores, contacta con nuestro soporte mediante teléfono o correo para reprogramar tu reserva sin coste adicional.'
    },
    {
      'question': '¿Cómo añado material a mi reserva?',
      'answer': 'Justo antes de pagar tu reserva, verás un desplegable llamado "Añadir Material" donde puedes incluir palas, raquetas, balones o petos dependiendo del deporte de la pista.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        title: const Text('Contacto y Ayuda', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B263B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contacta con nosotros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
            const SizedBox(height: 16),

            // Tarjetas de contacto
            _buildContactCard(Icons.phone, 'Teléfono Soporte', '+34 900 123 456', 'Lunes a Domingo, 9:00 - 22:00'),
            const SizedBox(height: 12),
            _buildContactCard(Icons.email, 'Correo Electrónico', 'soporte@sportaccess.com', 'Te respondemos en menos de 24h'),
            const SizedBox(height: 12),
            _buildContactCard(Icons.location_on, 'Oficina Central', 'Campus Universitario', 'Murcia, España'),

            const SizedBox(height: 32),
            const Text('Preguntas Frecuentes (FAQ)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
            const SizedBox(height: 16),

            // Generador de Acordeones para las FAQ
            ...faqs.map((faq) => _buildFaqTile(faq['question']!, faq['answer']!)).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Diseño de la tarjeta de contacto
  Widget _buildContactCard(IconData icon, String title, String subtitle, String extra) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF05B3A).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFFF05B3A)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B263B))),
            const SizedBox(height: 2),
            Text(extra, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Diseño del Acordeón (Pregunta/Respuesta)
  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent), // Quita las líneas feas de Flutter por defecto
        child: ExpansionTile(
          iconColor: const Color(0xFFF05B3A),
          collapsedIconColor: Colors.grey,
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B263B), fontSize: 14)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}