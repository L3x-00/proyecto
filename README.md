# Xtreme Performance - App Móvil

Aplicación móvil Flutter para el sistema de gestión de reparación de vehículos Xtreme Performance.

## Características

- 🔐 Autenticación segura con JWT
- 👥 Gestión de clientes
- 🚗 Gestión de vehículos
- 🔧 Seguimiento de órdenes de reparación
- 📱 Interfaz moderna y responsiva

## Requisitos

- Flutter 3.0+
- Dart 3.0+
- Un dispositivo real o emulador

## Instalación

### 1. Clonar el repositorio

```bash
git clone <repo-url>
cd xtreme_mobile
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Generar código necesario (si es requerido)

```bash
flutter pub run build_runner build
```

## Ejecución

### Desarrollo

```bash
flutter run
```

### Versión Release

```bash
flutter run --release
```

### Build APK (Android)

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ios --release
```

## Estructura del Proyecto

```
lib/
├── main.dart              # Punto de entrada principal
├── models/                # Modelos de datos
│   ├── usuario.dart
│   ├── cliente.dart
│   ├── vehiculo.dart
│   ├── orden.dart
│   └── index.dart
├── services/              # Servicios
│   └── api_service.dart   # Cliente HTTP y gestión de API
├── providers/             # Gestión de estado (Provider)
│   ├── auth_provider.dart
│   ├── clientes_provider.dart
│   ├── vehiculos_provider.dart
│   ├── ordenes_provider.dart
│   └── index.dart
└── screens/               # Pantallas de la aplicación
    ├── login_screen.dart
    ├── home_screen.dart
    ├── clientes_screen.dart
    ├── vehiculos_screen.dart
    ├── ordenes_screen.dart
    └── index.dart
```

## Configuración de API

La aplicación se conecta al servidor en:
- **Base URL**: `https://www.xtremeperformancepe.com/public/api`
- **Authentication**: Bearer Token (JWT)

### Endpoints disponibles

#### Autenticación
- `POST /auth/login` - Iniciar sesión
- `GET /auth/verify` - Verificar token

#### Clientes
- `GET /clientes/list` - Listar clientes
- `GET /clientes/get/:id` - Obtener cliente

#### Vehículos
- `GET /vehiculos/list` - Listar vehículos
- `GET /vehiculos/list?idCliente=N` - Listar por cliente

#### Órdenes
- `GET /ordenes/list` - Listar órdenes
- `GET /ordenes/get/:id` - Obtener orden

## Credenciales de Prueba

```
Correo: luccianobrzl@gmail.com
Contraseña: LUCCA2018
```

## Gestión de Estado

La aplicación utiliza **Provider** para la gestión de estado:

- `AuthProvider` - Gestión de autenticación y usuario
- `ClientesProvider` - Datos de clientes
- `VehiculosProvider` - Datos de vehículos
- `OrdenesProvider` - Datos de órdenes

## Almacenamiento Local

Se utiliza `SharedPreferences` para almacenar:
- Token JWT después de login
- Datos del usuario logueado

## Seguridad

- Tokens JWT almacenados de forma segura
- HTTPS para todas las conexiones
- Headers de CORS configurados
- Sin credenciales almacenadas en texto plano

## Troubleshooting

### Error de conexión a la API

1. Verificar que la URL del servidor es correcta
2. Comprobar conectividad de red
3. Revisar los logs en la consola de Flutter

### Error de autenticación

1. Verificar credenciales
2. Ejecutar `flutter clean` y `flutter pub get`
3. Reiniciar la aplicación

## Contribución

Para contribuir al proyecto:

1. Crear una rama para la nueva feature
2. Hacer commit de los cambios
3. Hacer push a la rama
4. Crear un Pull Request

## Licencia

Todos los derechos reservados © Xtreme Performance 2024

## Contacto

Para preguntas o soporte, contactar al equipo de desarrollo.
