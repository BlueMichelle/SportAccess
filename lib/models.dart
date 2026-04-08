class Court {
  final String id;
  final String name;
  final List<String> sports;
  final String imageUrl;
  final double pricePerHour;
  final String location;

  Court({
    required this.id,
    required this.name,
    required this.sports,
    required this.imageUrl,
    required this.pricePerHour,
    required this.location,
  });
}

// Datos falsos (MOCK) imitando la Región de Murcia
List<Court> mockCourts = [
  Court(
    id: '1',
    name: 'Pabellón Príncipe de Asturias',
    sports: ['Fútbol Sala', 'Baloncesto', 'Voleibol'],
    imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&q=80&w=800',
    pricePerHour: 15.0,
    location: 'Murcia Centro',
  ),
  Court(
    id: '2',
    name: 'Polideportivo San Javier',
    sports: ['Tenis', 'Pádel'],
    imageUrl: 'https://images.unsplash.com/photo-1622279457486-640ca4a4bc6b?auto=format&fit=crop&q=80&w=800',
    pricePerHour: 12.50,
    location: 'San Javier',
  ),
  Court(
    id: '3',
    name: 'Palacio de Deportes',
    sports: ['Baloncesto'],
    imageUrl: 'https://images.unsplash.com/photo-1504450758481-7338eba7524a?auto=format&fit=crop&q=80&w=800',
    pricePerHour: 20.0,
    location: 'Cartagena',
  ),
];
