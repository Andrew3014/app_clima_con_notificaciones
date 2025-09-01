class Recommendation {
  final String hourRange;
  final String message;
  Recommendation(this.hourRange, this.message);
}

Map<String, List<Recommendation>> recommendationsByWeather = {
  'clear': [
    Recommendation('08:00–11:00', 'Gafas de sol, camiseta ligera, protector solar FPS 30+'),
    Recommendation('11:00–15:00', 'Sombrero de ala ancha, ropa transpirable, evitar colores oscuros, hidratación constante'),
    Recommendation('15:00–18:00', 'Camisa de manga larga ligera para proteger del sol, sombra si es posible'),
    Recommendation('18:00–21:00', 'Chaqueta ligera si baja la temperatura, mantener hidratación'),
  ],
  'rain': [
    Recommendation('08:00–11:00', 'Paraguas compacto, chaqueta impermeable, calzado cerrado'),
    Recommendation('11:00–15:00', 'Impermeable completo, mochila con cubierta, evitar telas absorbentes'),
    Recommendation('15:00–18:00', 'Botas de lluvia, pantalón impermeable si hay tormenta'),
    Recommendation('18:00–21:00', 'Ropa seca de repuesto, cuidado con charcos y visibilidad baja'),
  ],
  'snow': [
    Recommendation('08:00–11:00', 'Abrigo térmico, guantes, bufanda, gorro'),
    Recommendation('11:00–15:00', 'Capas de ropa, calzado térmico, protector labial'),
    Recommendation('15:00–18:00', 'Manta ligera si estás en exteriores, bebidas calientes'),
    Recommendation('18:00–21:00', 'Ropa reflectante si hay poca luz, calefacción portátil si es necesario'),
  ],
  'clouds': [
    Recommendation('08:00–11:00', 'Ropa cómoda, capas ligeras'),
    Recommendation('11:00–15:00', 'Camiseta y pantalón de tela fresca, calzado cómodo'),
    Recommendation('15:00–18:00', 'Gafas de sol opcionales, chaqueta ligera si hay brisa'),
    Recommendation('18:00–21:00', 'Ropa casual, revisar pronóstico nocturno por si baja la temperatura'),
  ],
  'thunderstorm': [
    Recommendation('08:00–21:00', 'Evita salir si no es necesario, mantente seguro en interiores'),
  ],
  'wind': [
    Recommendation('08:00–11:00', 'Chaqueta cortaviento, gafas protectoras si hay polvo'),
    Recommendation('11:00–15:00', 'Evitar sombreros sueltos, ropa ajustada'),
    Recommendation('15:00–18:00', 'Protección auditiva si el viento es fuerte'),
    Recommendation('18:00–21:00', 'Evitar zonas abiertas, asegurar objetos personales'),
  ],
  'default': [
    Recommendation('08:00–21:00', 'Consulta el clima antes de salir.'),
  ],
};

List<Recommendation> getRecommendations(String main) {
  final key = main.toLowerCase();
  return recommendationsByWeather[key] ?? recommendationsByWeather['default']!;
}
