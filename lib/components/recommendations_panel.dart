import 'package:flutter/material.dart';
import '../utils/recommendations.dart';

class RecommendationsPanel extends StatefulWidget {
  final String weatherMain;
  final List<Map<String, dynamic>>? hourlyData;
  final Color textColor;
  final Color cardColor;
  const RecommendationsPanel({super.key, required this.weatherMain, this.hourlyData, this.textColor = Colors.white, this.cardColor = Colors.white});

  @override
  State<RecommendationsPanel> createState() => _RecommendationsPanelState();
}

class _RecommendationsPanelState extends State<RecommendationsPanel> {
  bool expanded = false;

  IconData _iconForRecommendation(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('paraguas') || msg.contains('impermeable') || msg.contains('lluvia')) {
      return Icons.umbrella;
    } else if (msg.contains('gafas de sol') || msg.contains('protector solar') || msg.contains('sombrero')) {
      return Icons.wb_sunny;
    } else if (msg.contains('abrigo') || msg.contains('bufanda') || msg.contains('guantes') || msg.contains('manta')) {
      return Icons.ac_unit;
    } else if (msg.contains('chaqueta') || msg.contains('cortaviento')) {
      return Icons.wind_power;
    } else if (msg.contains('evita salir') || msg.contains('tormenta')) {
      return Icons.flash_on;
    } else if (msg.contains('ropa cómoda') || msg.contains('camiseta')) {
      return Icons.checkroom;
    } else if (msg.contains('bebe agua') || msg.contains('hidratación')) {
      return Icons.local_drink;
    } else if (msg.contains('calzado')) {
      return Icons.directions_walk;
    } else if (msg.contains('revisa pronóstico')) {
      return Icons.info_outline;
    }
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = getRecommendations(widget.weatherMain);
    // Asociar temperatura a cada franja horaria
    List<Widget> recWidgets = recommendations.map((rec) {
      String? tempText;
      final icon = _iconForRecommendation(rec.message);
      Color color = Colors.blueAccent;
      // Buscar temperatura aproximada para la franja horaria
      if (widget.hourlyData != null) {
        final hourStart = int.tryParse(rec.hourRange.split(':')[0]);
        if (hourStart != null) {
          final hourMatch = widget.hourlyData!.firstWhere(
            (h) => int.tryParse(h['hour'].split(':')[0]) == hourStart,
            orElse: () => {},
          );
          if (hourMatch.isNotEmpty && hourMatch['temp'] != null) {
            tempText = '${hourMatch['temp'].toStringAsFixed(0)}°C';
          }
        }
      }
      // Íconos y colores llamativos según clima
      if (widget.weatherMain.toLowerCase().contains('rain')) {
        color = Colors.blue;
      } else if (widget.weatherMain.toLowerCase().contains('clear')) {
        color = Colors.orangeAccent;
      } else if (widget.weatherMain.toLowerCase().contains('cloud')) {
        color = Colors.grey;
      } else if (widget.weatherMain.toLowerCase().contains('snow')) {
        color = Colors.lightBlueAccent;
      } else if (widget.weatherMain.toLowerCase().contains('thunderstorm')) {
        color = Colors.deepPurpleAccent;
      } else if (widget.weatherMain.toLowerCase().contains('wind')) {
        color = Colors.teal;
      }
      return Card(
        color: color.withOpacity(0.13),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: Icon(icon, color: color, size: 32),
          title: Text(rec.message, style: TextStyle(color: widget.textColor)),
          subtitle: rec.hourRange.isNotEmpty ? Text(rec.hourRange, style: TextStyle(color: widget.textColor.withOpacity(0.7))) : null,
          trailing: tempText != null ? Text(tempText, style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold)) : null,
        ),
      );
    }).toList();
    return Card(
      color: widget.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text('Recomendaciones del día', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold)),
        children: recWidgets,
        iconColor: widget.textColor,
        collapsedIconColor: widget.textColor,
      ),
    );
  }
}
