# 🏁 PoliRent (SportAccess) - Panel de Administración Web

![Flutter Web](https://img.shields.io/badge/Frontend-Flutter_Web-02569B?style=flat&logo=flutter)
![Spring Boot](https://img.shields.io/badge/Backend-Spring_Boot-6DB33F?style=flat&logo=spring)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=flat&logo=mysql)

Este repositorio contiene el **Panel de Administración Web** del ecosistema PoliRent / SportAccess. Es una herramienta diseñada para que los gestores del centro deportivo puedan administrar pistas, supervisar reservas, controlar el directorio de clientes y resolver incidencias en tiempo real.

Este panel se conecta a una API RESTful desarrollada en **Java (Spring Boot)** y comparte la misma base de datos **MySQL** que la aplicación móvil de los clientes.

---

## 🚀 Características Principales

### 🔒 Autenticación y Acceso
* Pantalla de Login moderna con validación de credenciales.
* Interfaz de usuario responsiva (adaptada a navegadores web de escritorio).

### 🎾 Gestión de Pistas (Courts)
* **CRUD Completo:** Creación, lectura, actualización y borrado de pistas deportivas.
* **Control de Estado:** Activación y desactivación rápida de pistas mediante la interfaz.
* **Integridad de Datos:** Uso de listas desplegables cerradas mapeadas a Enums en el backend (`PADEL`, `TENIS`, `FUTBOL_SALA`, `BALONCESTO`) para evitar errores de servidor (HTTP 400).

### 📅 Control de Reservas
* **Sincronización Multiplataforma:** Vinculación estricta de las reservas con el `firebase_uid` del cliente para garantizar la coherencia con la App Móvil.
* **Gestión de Zonas Horarias:** Conversión automática de las fechas (almacenadas en formato UTC en la base de datos) a la hora local del dispositivo del administrador.
* Gestión de reservas pasadas para cuadres de caja y soporte técnico.

### 👥 Directorio de Usuarios
* Visualización detallada de los clientes registrados.
* Mapeo de la estructura relacional de la tabla `users` (`id`, `email`, `firebase_uid`, `nombre`, `telefono`, `rol`).

### ⚠️ Panel de Incidencias (En desarrollo)
* Visualización de reportes enviados por los usuarios desde la app móvil.
* Decodificación y renderizado de imágenes procesadas in `Base64` directamente desde el backend.

---

#### 18/05/2026

* Modificación de admin_dashboard_screen.dart y login_screen.dart con una interfaz más profesional.
* Creación de la carpeta widgets con sus respectivos archivos.
* Falta por arreglar las reservas, incidencias, CRUD de usuarios...


## 📂 Estructura del Proyecto

El código fuente sigue una arquitectura modular y limpia para separar las vistas completas de los componentes reutilizables:

```text
lib/
├── screens/
│   ├── admin_dashboard_screen.dart   # Estructura principal con menú lateral
│   └── login_screen.dart             # Pantalla de acceso corporativa
├── widgets/
│   ├── courts_view.dart              # Lógica y tabla del CRUD de Pistas
│   ├── home_view.dart                # Vista general / Resumen
│   ├── incidents_view.dart           # Gestión de reportes
│   ├── reservations_view.dart        # Gestión del calendario de reservas
│   └── users_view.dart               # Directorio y listado de clientes
└── main.dart                         # Punto de entrada de la aplicación
