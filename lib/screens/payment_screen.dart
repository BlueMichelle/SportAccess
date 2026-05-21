import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/screens/qr_screen.dart';
import 'package:app/models/models.dart';
import 'package:app/services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final Court court;
  final DateTime date;
  final String time;
  final int duration;
  final double total;
  final String materialDetails;

  const PaymentScreen({
    Key? key,
    required this.court,
    required this.date,
    required this.time,
    required this.duration,
    required this.total,
    required this.materialDetails,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = loggedUserName.isNotEmpty ? loggedUserName : '';
    _emailCtrl.text = loggedUserEmail.isNotEmpty ? loggedUserEmail : '';
  }

  Future<void> _processPayment() async {
    if (_cardCtrl.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Número de tarjeta incompleto')));
      return;
    }
    if (_expiryCtrl.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fecha de caducidad no válida')));
      return;
    }
    if (_cvvCtrl.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CVV incompleto')));
      return;
    }

    setState(() => _isLoading = true);

    final timeList = widget.time.split(':');
    final startDt = DateTime(widget.date.year, widget.date.month, widget.date.day,
        int.parse(timeList[0]), int.parse(timeList[1]));
    final endDt = startDt.add(Duration(hours: widget.duration));

    final Map<String, dynamic> payload = {
      "user": {
        "firebaseUid": loggedUserUid,
        "email": loggedUserEmail,
        "nombre": loggedUserName
      },
      "court": {"id": int.tryParse(widget.court.id) ?? 1},
      "fechaInicio": startDt.toIso8601String(),
      "fechaFin": endDt.toIso8601String(),
      "detallesMaterial": widget.materialDetails,
    };

    final result = await ApiService().createReservation(payload);

    if (result != null && result['qrToken'] != null) {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => QRScreen(
                  court: widget.court,
                  date: widget.date,
                  time: widget.time,
                  total: widget.total,
                  uuid: result['qrToken'],
                )));
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al conectar con la pasarela del Servidor. Verifica conexión.'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PASARELA DE PAGO',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // PASOS DEL PROCESO
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep('1', 'Summary', true, isDark),
                  _buildLine(true),
                  _buildStep('2', 'Payment', true, isDark),
                  _buildLine(false),
                  _buildStep('3', 'Confirmed', false, isDark),
                ],
              ),
            ),

            // BANNER DE MATERIAL
            if (widget.materialDetails != "Sin material")
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Incluye: ${widget.materialDetails}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // TARJETA DE PAGO
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Container(height: 6, width: double.infinity, color: const Color(0xFFF05B3A)),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tarjeta Bancaria',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.credit_card,
                                      color: colorScheme.onSurface, size: 30),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: colorScheme.outline.withOpacity(0.4)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('VISA',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: colorScheme.outline.withOpacity(0.4)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('MC',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            context,
                            'Número de Tarjeta',
                            _cardCtrl,
                            '0000 0000 0000 0000',
                            [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16)
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  context,
                                  'Caducidad',
                                  _expiryCtrl,
                                  'MM/YY',
                                  [
                                    _ExpiryDateFormatter(),
                                    LengthLimitingTextInputFormatter(5)
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildField(
                                  context,
                                  'CVV',
                                  _cvvCtrl,
                                  '123',
                                  [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // DATOS DE FACTURACIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos de Facturación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Divider(),
                  _buildField(context, 'Nombre', _nameCtrl, 'Nombre', []),
                  const SizedBox(height: 16),
                  _buildField(context, 'Email', _emailCtrl, 'Email', []),
                  const SizedBox(height: 16),
                  _buildField(context, 'Dirección', _addressCtrl, 'Dirección Completa', []),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF05B3A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : Text(
                        'PAGAR ${widget.total.toStringAsFixed(2)}€',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ahora recibe context para acceder al tema
  Widget _buildField(
      BuildContext context,
      String label,
      TextEditingController ctrl,
      String hint,
      List<TextInputFormatter> formatters,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          inputFormatters: formatters,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: isDark ? colorScheme.surfaceVariant : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String label, bool isActive, bool isDark) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xFFF05B3A) : Colors.grey.shade400,
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive
                ? (isDark ? Colors.white : Colors.black)
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool active) {
    return Container(
      width: 40,
      height: 2,
      color: active ? const Color(0xFFF05B3A) : Colors.grey.shade400,
      margin: const EdgeInsets.only(bottom: 12),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (oldValue.text.length > newValue.text.length) return newValue;
    var selectionIndex = newValue.selection.end;
    if (newText.length == 2) {
      newText += '/';
      selectionIndex++;
    } else if (newText.length == 3 && !newText.contains('/')) {
      newText = newText.substring(0, 2) + '/' + newText.substring(2);
      selectionIndex++;
    }
    return TextEditingValue(
        text: newText, selection: TextSelection.collapsed(offset: selectionIndex));
  }
}