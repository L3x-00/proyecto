# Xtreme Performance - Guía Rápida

## Instalación Rápida

### 1. Asegúrate de tener Flutter instalado

```bash
flutter --version
```

Si no está instalado, descárgalo desde [flutter.dev](https://flutter.dev/docs/get-started/install)

### 2. Clonar/Descargar el proyecto

```bash
cd Downloads/xtreme_mobile
```

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Limpiar (opcional pero recomendado)

```bash
flutter clean
```

### 5. Ejecutar en emulador o dispositivo

```bash
flutter run
```

O para especificar un dispositivo:

```bash
flutter devices  # Ver dispositivos disponibles
flutter run -d <id_dispositivo>
```

## Credenciales de Prueba

```
Correo: luccianobrzl@gmail.com
Contraseña: LUCCA2018
```

## Pantallas Disponibles

1. **Login** - Autenticación con correo y contraseña
2. **Home** - Menú principal con acceso rápido
3. **Clientes** - Listado de clientes registrados
4. **Vehículos** - Listado de vehículos
5. **Órdenes** - Listado de órdenes de reparación

## Problemas Comunes

### Error: "No application found"

```bash
flutter clean
flutter pub get
flutter run
```

### Error: "Waiting for another flutter command to release the startup lock"

```bash
# Matar procesos de Flutter
pkill -f flutter  # En Mac/Linux
taskkill /F /IM "dart.exe"  # En Windows
```

### Error de conexión a API

- Verificar que tienes conectividad de red
- Asegúrate que el servidor está disponible: https://www.xtremeperformancepe.com

## Contacto

Para soporte, contacta al equipo de desarrollo.
