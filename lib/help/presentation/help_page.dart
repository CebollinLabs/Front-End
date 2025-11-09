import 'package:flutter/material.dart';
import 'package:flutter_frontend_app/utils/color_ext.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade700;
    final questions = [
      FAQ(
        question: "¿Cómo subo una imagen para diagnóstico?",
        answer:
        "En la pantalla principal, pulsa en 'Diagnóstico de cultivo'. Luego, selecciona o toma una foto de la planta o cultivo que deseas analizar y sigue las instrucciones.",
      ),
      FAQ(
        question: "¿Qué hago si mi parcela no aparece?",
        answer:
        "Ve a la sección de 'Cosechas / Parcelas' y revisa el listado. Si no aparece, puedes agregar una nueva parcela usando el botón '+'. Si el problema persiste, contacta soporte.",
      ),
      FAQ(
        question: "¿Cómo consulto diagnósticos anteriores?",
        answer:
        "En el menú principal, accede a 'Historial de diagnósticos' para ver los análisis previos realizados desde tu cuenta.",
      ),
      FAQ(
        question: "¿Dónde puedo cambiar mis datos personales?",
        answer:
        "Ingresa a 'Ver perfil' desde la pantalla principal. Allí puedes actualizar tu información personal y cambiar la contraseña.",
      ),
      FAQ(
        question: "Contacto de soporte",
        answer:
        "Si necesitas ayuda adicional, escríbenos a soporte@moventicorp.com o contáctanos por WhatsApp al +51 900 000 000. Nuestro equipo te responderá lo antes posible.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: green,
        elevation: 0,
        title: const Text("Ayuda", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final q = questions[index];
          return _FAQCard(faq: q, green: green);
        },
      ),
    );
  }
}

class FAQ {
  final String question;
  final String answer;
  FAQ({required this.question, required this.answer});
}

class _FAQCard extends StatefulWidget {
  final FAQ faq;
  final Color green;
  const _FAQCard({required this.faq, required this.green});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => expanded = !expanded),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: widget.green.withOpacitySafe(0.2), width: 1.2),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: widget.green, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.green,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: widget.green.withOpacitySafe(0.12)),
                const SizedBox(height: 6),
                Text(
                  widget.faq.answer,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
