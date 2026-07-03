# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Proyecto

App móvil Flutter ("Xtreme Performance", nombre de paquete `xtreme_performance`) para un sistema de
gestión de taller mecánico. Es un cliente de un backend PHP en
`https://www.xtremeperformancepe.com/public/api` — no hay código de backend en este repo.

## Comandos

```bash
flutter pub get                  # instalar dependencias
flutter run                      # ejecutar en modo debug en un dispositivo/emulador conectado
flutter run -d <device_id>       # ejecutar en un dispositivo específico (ver `flutter devices`)
flutter analyze                  # lint/análisis estático (usa analysis_options.yaml)
flutter test                     # ejecutar tests (aún no existe carpeta test/)
flutter build apk --release      # build de release para Android
flutter build ios --release      # build de release para iOS
```

No hay generación de código en este proyecto (no hay archivos `.g.dart`/`.freezed.dart`, ni dependencia
de `build_runner`) — ignora el paso `build_runner build` mencionado en README.md/QUICKSTART.md, está
desactualizado.

## Arquitectura

Estructura estándar en capas de Flutter/Provider bajo `lib/`:

- **`services/api_service.dart`** — el único cliente HTTP de toda la app. Cada llamada al backend pasa
  por aquí como un método que devuelve `Future<Map<String, dynamic>>` con forma
  `{'success': bool, ...data|'error'}`. El backend es un único router PHP: las peticiones son
  `GET/POST $baseUrl/?resource=<resource>&action=<action>&...`, no rutas REST (por ejemplo
  `?resource=clientes&action=list`, `?resource=ordenes&action=get&id=5`). Algunos endpoints en cambio
  golpean scripts PHP independientes directamente (p. ej. `/endpoints/mis_vehiculos.php`,
  `/endpoints/editar_perfil.php`, `/endpoints/chatbot_pro.php`) — revisa los métodos existentes para ver
  el patrón antes de agregar uno nuevo. La autenticación es un JWT tipo bearer leído vía `getToken()`/
  guardado vía `SharedPreferences` (claves `auth_token`, `user_data`); la mayoría de los métodos
  retornan temprano con `{'success': false, 'error': 'No token disponible'}` si no hay token presente.
- **`providers/`** — un `ChangeNotifier` por recurso (`AuthProvider`, `ClientesProvider`,
  `VehiculosProvider`, `OrdenesProvider`, `MecanicosProvider`, `SeguimientosProvider`), cada uno envuelve
  llamadas a `ApiService` y expone estado de loading/error/data a los widgets. Todos están registrados
  como `ChangeNotifierProvider`s en el `MultiProvider` de `main.dart`; las pantallas los leen vía
  `context.read/watch`. Importa el archivo barril `providers/index.dart` (y `models/index.dart`,
  `screens/index.dart`) en lugar de archivos individuales — esa es la convención usada en todo el
  proyecto.
- **`models/`** — clases Dart planas con `fromJson`/`toJson`, sin generación de código.
- **`screens/`** — un archivo por pantalla/ruta. `main.dart` conecta rutas con nombre para la mayoría de
  las pantallas; la pantalla de seguimiento (tracking de órdenes) se registra vía `onGenerateRoute`
  porque necesita que se le pase un objeto `Orden` como `settings.arguments`.
- **`services/pusher_config.dart`** — envuelve `pusher_channels_flutter` para eventos en tiempo real
  (usado para actualizaciones en vivo de órdenes/seguimiento); tiene hardcodeados el `apiKey`/`cluster`
  de Pusher.

### Acceso basado en roles

El backend devuelve un `tipo` (rol) entero en el objeto de usuario, definido en
`constants/app_constants.dart` (`UserRole`: 1=admin, 2=operador, 3=mecanico, 4=cliente).
`constants/role_permissions.dart` (`RolePermissions`) mapea cada rol a un mapa de permisos
(`ver_clientes`, `crear_orden`, etc.) y a una lista de rutas accesibles — consúltalo antes de agregar UI
que deba estar restringida por rol, aunque según `ROLES_PERMISOS.md` este mapa de permisos todavía no
se aplica de forma consistente en todas las pantallas/UI (ver su checklist de qué está implementado y
qué falta, p. ej. validaciones de permisos en la UI y guardas de ruta).

Rol → ruta de inicio se decide en dos lugares que deben mantenerse sincronizados: la pantalla splash en
`main.dart` (restauración de sesión) y `login_screen.dart` (redirección post-login):
- admin/operador → `/home` (`HomeScreen`)
- mecanico → `/mecanicoHome` (`MecanicoScreen`)
- cliente → `/clienteHome` (`ClienteScreen`)

`ROLES_PERMISOS.md` tiene la matriz completa de roles/permisos/navegación y vale la pena leerlo antes de
tocar lógica de autenticación, ruteo o permisos.

## Notas

- `android_respaldo/` es una copia de respaldo del directorio `android/`, no es un target de build
  activo.
- Las credenciales de prueba y más detalles de endpoints/permisos están documentados en `README.md`,
  `QUICKSTART.md` y `ROLES_PERMISOS.md`.
