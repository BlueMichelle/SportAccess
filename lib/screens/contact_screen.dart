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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ Fondo adaptado al tema (era Color(0xFFF7FAFD))
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Contacto y Ayuda', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        // ✅ AppBar adaptado al tema (era Colors.white / Color(0xFF1B263B))
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Título adaptado al tema (era Color(0xFF1B263B))
            Text(
              'Contacta con nosotros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),

            // Tarjetas de contacto
            _buildContactCard(context, Icons.phone, 'Teléfono Soporte', '+34 900 123 456', 'Lunes a Domingo, 9:00 - 22:00'),
            const SizedBox(height: 12),
            _buildContactCard(context, Icons.email, 'Correo Electrónico', 'soporte@sportaccess.com', 'Te respondemos en menos de 24h'),
            const SizedBox(height: 12),
            _buildContactCard(context, Icons.location_on, 'Oficina Central', 'Campus Universitario', 'Murcia, España'),

            const SizedBox(height: 32),
            // ✅ Título FAQ adaptado al tema (era Color(0xFF1B263B))
            Text(
              'Preguntas Frecuentes (FAQ)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),

            // Generador de Acordeones para las FAQ
            ...faqs.map((faq) => _buildFaqTile(context, faq['question']!, faq['answer']!)).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Diseño de la tarjeta de contacto
  Widget _buildContactCard(BuildContext context, IconData icon, String title, String subtitle, String extra) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        // ✅ Fondo de tarjeta adaptado al tema (era Colors.white)
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ✅ Sombra adaptada al tema (era Colors.black.withOpacity(0.04))
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF05B3A).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFFF05B3A)),
        ),
        title: Text(
          title,
          // ✅ Color etiqueta adaptado al tema (era Colors.grey)
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // ✅ Texto principal adaptado al tema (era Color(0xFF1B263B))
            Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
            const SizedBox(height: 2),
            // ✅ Texto extra adaptado al tema (era Colors.grey)
            Text(extra, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  // Diseño del Acordeón (Pregunta/Respuesta)
  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ✅ Fondo del acordeón adaptado al tema (era Colors.white)
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        // ✅ Borde adaptado al tema (era Colors.grey.shade200)
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Theme(
        // ✅ Hereda el tema actual en lugar de crear uno nuevo vacío con ThemeData()
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFFF05B3A),
          // ✅ Icono colapsado adaptado al tema (era Colors.grey)
          collapsedIconColor: colorScheme.onSurface.withOpacity(0.5),
          // ✅ Título de la pregunta adaptado al tema (era Color(0xFF1B263B))
          title: Text(
            question,
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 14),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              // ✅ Texto de la respuesta adaptado al tema (era Colors.grey)
              child: Text(answer, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}