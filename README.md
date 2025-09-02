# App Clima Flutter

Aplicación móvil desarrollada en Flutter para consultar el clima actual, pronóstico por hora y semanal de cualquier ciudad, guardar ciudades favoritas y recibir notificaciones. Utiliza la API de OpenWeatherMap y animaciones Lottie para una experiencia visual atractiva.

#LINK YOUTUBE DEMOSTRACION
https://youtu.be/NcAdXic6jYU

## Capturas de pantalla

### Pantalla de inicio
![Pantalla de inicio](screenshots/pagina%20de%20inicio%20.png)
Muestra el clima actual, pronóstico por hora y semanal.

### Favoritos
![Favoritos](screenshots/pagina%20de%20favoritos.png)
Lista de ciudades favoritas guardadas por el usuario.

### Centro de búsqueda
![Centro de búsqueda](screenshots/centro%20de%20busqueda.png)
Permite buscar y seleccionar ciudades para consultar el clima.

### Notificación de la app
![Notificación de la app](screenshots/notificacion%20de%20la%20app.png)
Ejemplo de notificación enviada por la app.

---

## Herramientas y librerías utilizadas
- **Flutter**: Framework principal para desarrollo multiplataforma.
- **OpenWeatherMap API**: Fuente de datos meteorológicos.
- **Lottie**: Animaciones de clima (sol, nubes, lluvia, etc.).
- **http**: Peticiones a la API.
- **shared_preferences**: Guardado de favoritos localmente.
- **flutter_local_notifications**: Notificaciones locales.
- **geolocator**: Ubicación del usuario (si se usa).
- **intl**: Formateo de fechas y horas.

## Estructura del proyecto
- `lib/main.dart`: Punto de entrada, lógica principal y navegación.
- `lib/components/`: Widgets reutilizables (tarjetas de clima, pronóstico, paneles, etc.).
- `lib/services/`: Servicios para consumir la API y manejar notificaciones.
- `lib/screens/`: Pantallas principales (inicio, favoritos, búsqueda).
- `lib/utils/`: Utilidades (helpers de color, formateo, etc.).
- `assets/lottie/`: Animaciones Lottie para los diferentes estados del clima.
- `screenshots/`: Imágenes de ejemplo de la app.

## Instalación y ejecución local

1. **Clona el repositorio**
   ```sh
   git clone <URL_DE_TU_NUEVO_REPO>
   cd app_clima
   ```
2. **Instala las dependencias**
   ```sh
   flutter pub get
   ```
3. **Configura tu API Key de OpenWeatherMap**
   - Abre el archivo donde se define la API key (usualmente en `lib/services/weather_service.dart` o similar).
   - Sustituye la clave por la tuya.
4. **Ejecuta la app**
   ```sh
   flutter run
   ```

## Funcionalidades principales
- Búsqueda de clima por ciudad con autocompletado.
- Visualización de temperatura, descripción, ícono, humedad, viento, etc.
- Pronóstico por horas y semanal.
- Guardado de ciudades favoritas.
- Notificaciones locales del clima.
- Animaciones dinámicas según el estado del clima.

## Notas técnicas
- El código es robusto ante datos numéricos que pueden venir como int, double o String desde la API.
- Las animaciones de clima se seleccionan dinámicamente según la probabilidad de lluvia y el estado del clima.
- El archivo `.gitignore` está configurado para no subir archivos temporales ni de build.
- El proyecto es fácilmente portable a otros repositorios y sistemas.

---


