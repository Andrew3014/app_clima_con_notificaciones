import 'package:flutter/material.dart';

class WeatherDetailsPanel extends StatelessWidget {
  final Map<String, dynamic> details;
  final Color cardColor;
  final Color textColor;
  const WeatherDetailsPanel({super.key, required this.details, this.cardColor = Colors.white, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    final List<_DetailItem> items = [];
    if (details['location'] != null) items.add(_DetailItem(icon: Icons.location_on, label: 'Ubicación', value: details['location']));
    if (details['coords'] != null) items.add(_DetailItem(icon: Icons.gps_fixed, label: 'Coordenadas', value: details['coords']));
    if (details['temp'] != null) items.add(_DetailItem(icon: Icons.thermostat, label: 'Temperatura', value: details['temp']));
    if (details['feels_like'] != null) items.add(_DetailItem(icon: Icons.thermostat_auto, label: 'Sensación térmica', value: details['feels_like']));
    if (details['humidity'] != null) items.add(_DetailItem(icon: Icons.water_drop, label: 'Humedad', value: details['humidity']));
    if (details['pressure'] != null) items.add(_DetailItem(icon: Icons.speed, label: 'Presión', value: details['pressure']));
    if (details['visibility'] != null) items.add(_DetailItem(icon: Icons.remove_red_eye, label: 'Visibilidad', value: details['visibility']));
    if (details['dew_point'] != null) items.add(_DetailItem(icon: Icons.grain, label: 'Punto de rocío', value: details['dew_point']));
    if (details['wind'] != null) items.add(_DetailItem(icon: Icons.air, label: 'Viento', value: details['wind']));
    if (details['wind_dir'] != null) items.add(_DetailItem(icon: Icons.explore, label: 'Dirección viento', value: details['wind_dir']));
    if (details['wind_gust'] != null) items.add(_DetailItem(icon: Icons.flash_on, label: 'Ráfagas', value: details['wind_gust']));
    if (details['uv'] != null) items.add(_DetailItem(icon: Icons.wb_sunny, label: 'Índice UV', value: details['uv']));
    if (details['sunrise'] != null) items.add(_DetailItem(icon: Icons.wb_twighlight, label: 'Amanecer', value: details['sunrise']));
    if (details['sunset'] != null) items.add(_DetailItem(icon: Icons.nights_stay, label: 'Atardecer', value: details['sunset']));
    if (details['moon_phase'] != null) items.add(_DetailItem(icon: Icons.nightlight_round, label: 'Fase lunar', value: details['moon_phase']));
    if (details['alert'] != null) items.add(_DetailItem(icon: Icons.warning, label: 'Alerta', value: details['alert']));
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.8,
        children: items.map((item) => _DetailCard(item: item, cardColor: cardColor, textColor: textColor)).toList(),
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final dynamic value;
  _DetailItem({required this.icon, required this.label, required this.value});
}

class _DetailCard extends StatelessWidget {
  final _DetailItem item;
  final Color cardColor;
  final Color textColor;
  const _DetailCard({required this.item, this.cardColor = Colors.white, this.textColor = Colors.black});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(item.icon, color: textColor.withOpacity(0.8), size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.label, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
                  Text(item.value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
