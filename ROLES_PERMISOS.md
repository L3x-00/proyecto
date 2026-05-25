## 📊 ESTRUCTURA DE ROLES Y PERMISOS - XTREME PERFORMANCE

### 🔑 Valores de Rol (del Backend):
```
1 = ADMIN (Administrador)
2 = OPERADOR (Operador)
3 = MECANICO (Mecánico)
4 = CLIENTE (Cliente)
```

---

## 🏠 NAVEGACIÓN POR ROL

### 1️⃣ ADMINISTRADOR (Rol ID: 1)
```
LOGIN ➜ /home (HomeScreen)
         ├── Dashboard (KPIs, gráficos)
         ├── Clientes (CRUD completo)
         ├── Vehículos (CRUD completo)
         ├── Órdenes (CRUD completo)
         ├── Mecánicos (CRUD completo)
         └── Configuración (editar)

PERMISOS: ✅ TODOS
```

### 2️⃣ OPERADOR (Rol ID: 2)
```
LOGIN ➜ /home (HomeScreen)
         ├── Dashboard (KPIs, gráficos)
         ├── Clientes (crear, editar)
         ├── Vehículos (crear, editar)
         ├── Órdenes (crear, editar)
         └── Configuración (ver solo)

PERMISOS: ✅ Crear/Editar | ❌ Eliminar | ❌ Gestión mecánicos
```

### 3️⃣ MECÁNICO (Rol ID: 3)
```
LOGIN ➜ /mecanicoHome (MecanicoScreen)
         ├── Dashboard (mis órdenes, estado)
         ├── Equipo (otros mecánicos)
         └── Configuración (perfil)

VISTAS ADICIONALES:
├── Mis Órdenes (solo asignadas)
├── Crear Seguimientos (en sus órdenes)
└── Mis Datos (nombre, especialidad, estado)

PERMISOS: ✅ Ver/Editar órdenes asignadas | ✅ Crear seguimientos
          ❌ Gestión de clientes/vehículos | ❌ Crear órdenes
```

### 4️⃣ CLIENTE (Rol ID: 4)
```
LOGIN ➜ /clienteHome (ClienteScreen)
         ├── Dashboard (mis datos)
         ├── Mis Vehículos (ver, crear, editar)
         ├── Mis Órdenes (solo mis órdenes)
         ├── Seguimientos (de mis órdenes)
         └── Configuración (perfil)

PERMISOS: ✅ Ver/Editar perfil | ✅ Gestionar mis vehículos
          ❌ Ver otros clientes | ❌ Eliminar vehículos
          ❌ Crear órdenes | ❌ Ver mecánicos
```

---

## 📋 MATRIZ DE PERMISOS

| Funcionalidad | Admin | Operador | Mecánico | Cliente |
|---|---|---|---|---|
| **Clientes** | CRUD | CR- | - | Perfil |
| **Vehículos** | CRUD | CR- | - | Propios |
| **Órdenes** | CRUD | CR- | Asignadas | Propias |
| **Mecánicos** | CRUD | - | - | - |
| **Seguimientos** | CRUD | CR- | Crear* | Ver* |
| **Dashboard** | ✅ KPIs | ✅ KPIs | ✅ Mis órdenes | ✅ Mis datos |
| **Reportes** | ✅ | ✅ | ❌ | ❌ |
| **Configuración** | Editar | Ver | Ver | Ver |

*Solo en órdenes relacionadas

---

## 🔄 FLUJO DE AUTENTICACIÓN

```
Credenciales ➜ Backend ➜ Valida Correo/Contraseña
                ↓
        Retorna tipoUsuario (1-4)
                ↓
        ┌───────┼───────┬────────┐
        ↓       ↓       ↓        ↓
       Admin  Operador Mecánico Cliente
        ↓       ↓       ↓        ↓
      /home   /home  /mecánico /cliente
                        Home     Home
```

---

## 💾 ALMACENAMIENTO LOCAL

**SharedPreferences:**
- `auth_token` → JWT Token
- `user_data` → Usuario (JSON)
  - id, nombres, apellidos, correo, tipo, telefono, token

**SplashScreen detecta:**
1. ¿Hay token guardado?
2. ¿Cuál es el `tipo` del usuario?
3. Redirecciona según rol

---

## 🛡️ VALIDACIONES EN FLUTTER

### Login Screen (`login_screen.dart`)
```dart
if (rolUsuario == UserRole.admin)      → /home
if (rolUsuario == UserRole.mecanico)   → /mecanicoHome
if (rolUsuario == UserRole.cliente)    → /clienteHome
if (rolUsuario == UserRole.operador)   → /home
```

### SplashScreen (`main.dart`)
```dart
if (authProvider.isLogged):
  - Lee rol del usuario guardado
  - Redirecciona según rol
else:
  - Va a /login
```

---

## 📁 NUEVOS ARCHIVOS CREADOS

1. `lib/constants/app_constants.dart` - Constantes de roles
2. `lib/constants/role_permissions.dart` - Matriz de permisos
3. `lib/models/mecanico.dart` - Modelo de mecánico
4. `lib/providers/mecanicos_provider.dart` - Provider CRUD mecánicos
5. `lib/screens/mecanico_screen.dart` - Panel de mecánico

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [x] Constantes de roles actualizadas
- [x] Modelo Usuario actualizado (tipo como int)
- [x] Modelo Mecánico creado
- [x] Provider de Mecánicos creado
- [x] API Service con endpoints de mecánicos
- [x] MecanicoScreen creada
- [x] Login Screen con ruteo por rol
- [x] SplashScreen redirecciona según rol
- [x] Matriz de permisos definida
- [x] Routes en main.dart actualizadas
- [ ] Implementar verificación de permisos en UI
- [ ] Agregar guards/middleware para rutas
- [ ] Filtrar datos en API según rol

