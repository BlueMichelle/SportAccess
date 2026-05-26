🏁 PoliRent (SportAccess) - Panel de Administración Web
Este repositorio contiene el Panel de Administración Web del ecosistema PoliRent / SportAccess. Es una herramienta diseñada para que los gestores del centro deportivo puedan administrar pistas, supervisar reservas, controlar el directorio de clientes y resolver incidencias en tiempo real.

Este panel se conecta a una API RESTful desarrollada en Java (Spring Boot) y comparte la misma base de datos MySQL que la aplicación móvil de los clientes.

🚀 Características Principales
🔒 Autenticación y Acceso
Pantalla de Login moderna con validación real contra la base de datos MySQL.

Control de acceso basado en roles (RBAC): Verificación estricta del rol ADMIN mediante la API antes de permitir la entrada al sistema.

Interfaz de usuario responsiva (adaptada a navegadores web de escritorio).

🎾 Gestión de Pistas (Courts)
CRUD Completo: Creación, lectura, actualización y borrado de pistas deportivas.

Control de Estado: Activación y desactivación rápida de pistas mediante la interfaz.

Integridad de Datos: Uso de listas desplegables cerradas mapeadas a Enums en el backend (PADEL, TENIS, FUTBOL_SALA, BALONCESTO) para evitar errores de servidor (HTTP 400).

📅 Control de Reservas Avanzado
Sincronización Multiplataforma: Vinculación estricta de las reservas con el firebase_uid del cliente para garantizar la coherencia con la App Móvil.

Nuevos Atributos de Gestión: Soporte total para registrar jugadores invitados, control del método de pago (efectivo/tarjeta) y seguimiento del estado del pago.

Vistas Modulares: Gestión a través de un sistema de pestañas (Vista de Calendario, Tabla de Gestión CRUD y Próximas Reservas).

Gestión de Zonas Horarias: Conversión automática de las fechas (almacenadas en formato UTC en la base de datos) a la hora local del dispositivo del administrador.

👥 Directorio de Usuarios
Visualización detallada de los clientes registrados.

Mapeo de la estructura relacional de la tabla users (id, email, firebase_uid, nombre, telefono, rol).

⚠️ Panel de Incidencias
Visualización y gestión de reportes enviados por los usuarios desde la app móvil.

Decodificación y renderizado de imágenes procesadas en Base64 directamente desde el backend.

📅 Registro de Actualizaciones
26/05/2026 (Actualización Core & Módulo de Reservas)
Sustitución del login estático por autenticación real conectada al endpoint de Spring Boot, validando credenciales y exigiendo rol ADMIN.

Resolución de errores de interfaz (overflow) en las leyendas del gráfico analítico en home_view.dart.

Refactorización masiva del sistema de reservas:

Modularización de reservations_view.dart en pestañas independientes (calendar_tab.dart, crud_tab.dart, upcoming_tab.dart).

Creación del componente reservation_form.dart para soportar la actualización y edición de reservas con los nuevos campos de la base de datos (invitados, pago con tarjeta/efectivo, estado del pago).

Conexión de todas las vistas CRUD (users_view, courts_view, incidents_view) a la API real.

18/05/2026
Modificación de admin_dashboard_screen.dart y login_screen.dart con una interfaz más profesional.

Creación de la carpeta widgets con sus respectivos archivos.

Falta por arreglar las reservas, incidencias, CRUD de usuarios...

📂 Estructura del Proyecto
El código fuente sigue una arquitectura modular y limpia para separar las vistas completas de los componentes reutilizables:

```text
lib/
├── screens/
│   ├── admin_dashboard_screen.dart    # Estructura principal con menú lateral
│   └── login_screen.dart              # Pantalla de acceso corporativa y validación de rol
├── widgets/
│   ├── courts_view.dart               # Lógica y tabla del CRUD de Pistas
│   ├── home_view.dart                 # Vista general / Resumen estadístico
│   ├── incidents_view.dart            # Gestión de reportes
│   ├── users_view.dart                # Directorio y listado de clientes
│   └── reservations/                  # Módulo avanzado de reservas
│       ├── reservations_view.dart     # Contenedor principal de pestañas
│       ├── calendar_tab.dart          # Vista interactiva mensual/semanal
│       ├── crud_tab.dart              # Tabla de gestión general
│       ├── upcoming_tab.dart          # Listado de reservas inminentes
│       └── reservation_form.dart      # Formulario dinámico de creación/edición
└── main.dart                          # Punto de entrada de la app