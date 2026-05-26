# Estructura organizada del proyecto SportAccess

Este documento resume la organizacion recomendada del proyecto para presentarla en la memoria del TFG y ante el jurado. La idea es mostrar una estructura clara, similar a un arbol de carpetas comentado, donde cada parte tenga una responsabilidad concreta.

## Vision general

```text
ProyectoFinal_PoliRect/
|-- backend/                         # API REST, seguridad, logica de negocio y acceso a datos
|-- mobile/                          # Aplicacion movil Flutter para usuarios
|-- docs/                            # Memoria, anexos, RA, estructura y documentacion tecnica
|-- sql/                             # Scripts de base de datos, datos de prueba y consultas
|-- Diagramas/                       # Diagramas y bocetos de arquitectura
|-- .github/                         # Configuracion de GitHub
|-- README.md                        # Descripcion principal del proyecto
|-- .gitignore                       # Exclusiones: secretos, IDE, builds y generados
```

## Backend

```text
backend/
|-- pom.xml                          # Dependencias Maven y configuracion Java/Spring Boot
|-- Dockerfile                       # Imagen Docker del backend
|-- docker-compose.yml               # Servicios app + MySQL
|-- README_CONFIG.md                 # Guia de configuracion local
|-- src/
|   |-- main/
|   |   |-- java/com/sportaccess/backend/
|   |   |   |-- BackendApplication.java       # Punto de entrada principal
|   |   |   |-- SportAccessApplication.java   # Punto alternativo/compatibilidad
|   |   |   |
|   |   |   |-- config/                       # Configuracion general
|   |   |   |   |-- DataInitializer.java        # Datos iniciales/demo
|   |   |   |   |-- FirebaseConfig.java         # Inicializacion Firebase Admin SDK
|   |   |   |   |-- SecurityConfig.java         # Seguridad, CORS y filtros
|   |   |   |
|   |   |   |-- controller/                   # Endpoints REST
|   |   |   |   |-- HomeController.java         # Endpoint raiz de comprobacion
|   |   |   |   |-- UserController.java         # Usuarios y registro/sincronizacion
|   |   |   |   |-- SportsCenterController.java # Centros deportivos
|   |   |   |   |-- CourtController.java        # Pistas deportivas
|   |   |   |   |-- ReservationController.java  # Reservas usadas por la app movil
|   |   |   |   |-- BookingController.java      # Reservas/booking historico o alternativo
|   |   |   |   |-- IncidentController.java     # Incidencias y cambios de estado
|   |   |   |
|   |   |   |-- dto/                          # Objetos de entrada/salida
|   |   |   |   |-- UserResponse.java           # Respuesta de usuario
|   |   |   |   |-- UserUpdateRequest.java      # Actualizacion de usuario
|   |   |   |   |-- IncidentRequest.java        # Peticion de incidencia
|   |   |   |   |-- IncidentRequestDTO.java     # DTO de incidencia usado por Flutter
|   |   |   |
|   |   |   |-- exception/                    # Gestion de errores
|   |   |   |   |-- ErrorResponse.java          # Modelo de error
|   |   |   |   |-- GlobalExceptionHandler.java # Manejador global
|   |   |   |   |-- UserNotFoundException.java  # Error especifico de usuario
|   |   |   |
|   |   |   |-- model/                        # Entidades JPA
|   |   |   |   |-- User.java                   # Usuarios, roles y estado activo
|   |   |   |   |-- SportsCenter.java           # Centros deportivos
|   |   |   |   |-- Court.java                  # Pistas, tipo, precio e imagen
|   |   |   |   |-- Reservation.java            # Reserva con fechas, estado y QR
|   |   |   |   |-- Booking.java                # Modelo adicional de reserva
|   |   |   |   |-- Payment.java                # Pagos preparados
|   |   |   |   |-- Incident.java               # Incidencias de pistas/reservas
|   |   |   |
|   |   |   |-- repository/                   # Acceso a datos Spring Data JPA
|   |   |   |   |-- UserRepository.java         # Consultas de usuarios
|   |   |   |   |-- SportsCenterRepository.java # Consultas de centros
|   |   |   |   |-- CourtRepository.java        # Consultas de pistas
|   |   |   |   |-- ReservationRepository.java  # Reservas y consulta de solapes
|   |   |   |   |-- BookingRepository.java      # Bookings
|   |   |   |   |-- PaymentRepository.java      # Pagos
|   |   |   |   |-- IncidentRepository.java     # Incidencias
|   |   |   |
|   |   |   |-- security/                     # Seguridad de peticiones
|   |   |   |   |-- FirebaseTokenFilter.java    # Verificacion de tokens Firebase
|   |   |   |
|   |   |   |-- service/                      # Logica de negocio
|   |   |       |-- UserService.java            # Usuarios y sincronizacion
|   |   |       |-- BookingService.java         # Creacion y consulta de bookings
|   |   |       |-- IncidentService.java        # Logica de incidencias
|   |   |       |-- PaymentService.java         # Logica de pagos
|   |   |       |-- AccessControlService.java   # Control de acceso
|   |   |
|   |   |-- resources/
|   |       |-- application.properties        # Configuracion local
|   |       |-- application-docker.properties # Configuracion Docker
```

### Responsabilidad del backend

- Exponer la API REST.
- Validar operaciones de negocio.
- Gestionar usuarios, pistas, centros, reservas, pagos e incidencias.
- Comprobar solapes de reservas.
- Conectarse con MySQL mediante JPA.
- Preparar seguridad y autenticacion con Firebase.
- Documentar endpoints con Swagger/OpenAPI.

## Aplicacion movil

```text
mobile/
|-- pubspec.yaml                     # Dependencias Flutter/Dart
|-- analysis_options.yaml            # Reglas de analisis estatico
|-- google-services.json             # Configuracion Firebase Android
|-- lib/
|   |-- main.dart                    # Entrada de la app
|   |
|   |-- models/
|   |   |-- models.dart              # Modelos, mocks y persistencia local
|   |
|   |-- services/
|   |   |-- api_service.dart         # Cliente HTTP hacia Spring Boot
|   |
|   |-- screens/
|       |-- login_screen.dart        # Inicio de sesion
|       |-- register_screen.dart     # Registro de usuario
|       |-- home_screen.dart         # Listado de pistas y menu principal
|       |-- booking_screen.dart      # Seleccion de fecha/hora
|       |-- payment_screen.dart      # Confirmacion o simulacion de pago
|       |-- qr_screen.dart           # QR de la reserva
|       |-- scanner_screen.dart      # Escaneo y validacion de QR
|       |-- history_screen.dart      # Historial de reservas
|
|-- android/                         # Proyecto Android generado por Flutter
|-- ios/                             # Proyecto iOS generado por Flutter
|-- web/                             # Soporte web generado por Flutter
|-- windows/                         # Soporte escritorio Windows
|-- linux/                           # Soporte escritorio Linux
|-- macos/                           # Soporte escritorio macOS
|-- test/                            # Pruebas Flutter
```

### Responsabilidad de la app movil

- Mostrar la interfaz al usuario.
- Consumir la API REST mediante `ApiService`.
- Gestionar login y registro.
- Listar pistas deportivas.
- Permitir seleccion de fecha y horario.
- Enviar reservas al backend.
- Mostrar QR de acceso.
- Escanear QR y validar reserva.
- Mostrar historial.

## Documentacion

```text
docs/
|-- TFG_MEMORIA_FINAL_DAM_SPORTACCESS.md     # Memoria principal para el jurado
|-- ESTRUCTURA_PROYECTO_SPORTACCESS.md       # Arbol comentado del proyecto
|-- TFG_CARTAGENA_MURCIA.md                  # Base inicial del TFG
|-- ENTREGA_PDF_TFG_SPORTACCESS.md           # Version orientada a entrega
|-- RAS_TFG_CARTAGENA_MURCIA.md              # Relacion con resultados de aprendizaje
|-- ANEXO_IV_ACTIVIDADES_DAM.md              # Actividades semanales de practicas
|-- SPRING_BOOT_CLEANUP.md                   # Limpieza y organizacion backend
```

### Responsabilidad de la documentacion

- Facilitar la defensa del proyecto.
- Relacionar el trabajo con los RA de DAM.
- Explicar instalacion, ejecucion y pruebas.
- Dejar evidencias tecnicas para el jurado.
- Servir como base para pasar a Google Docs o PDF.

## SQL

```text
sql/
|-- 01_schema.sql                    # Creacion de base de datos y tablas
|-- 02_data_test.sql                 # Datos de prueba
|-- 03_queries_utiles.sql            # Consultas de verificacion
```

### Responsabilidad de SQL

- Crear el esquema relacional.
- Cargar datos iniciales de prueba.
- Verificar usuarios, pistas, reservas e incidencias.
- Apoyar la defensa con capturas de MySQL.

## Diagramas

```text
Diagramas/
|-- area1-bocetos-arquitectura.html  # Bocetos y diagramas de arquitectura
```

### Diagramas recomendados para la memoria

- Arquitectura cliente-servidor.
- Flujo de reserva.
- Diagrama entidad-relacion.
- Flujo de validacion QR.
- Estructura por capas del backend.

## Limpieza recomendada para entrega

Antes de entregar el repositorio o generar ZIP/PDF final, conviene comprobar:

- No incluir `.env`.
- No incluir claves privadas ni credenciales Firebase privadas.
- No incluir `mobile/build/`.
- No incluir `mobile/.dart_tool/`.
- No incluir carpetas `.gradle/`.
- No incluir configuraciones personales de IDE.
- Mantener solo documentacion, codigo fuente, SQL y archivos necesarios.

## Imagenes concretas que deberian aparecer en la memoria

1. Captura del arbol general del proyecto.
2. Captura del arbol `backend/src/main/java/com/sportaccess/backend`.
3. Captura del arbol `mobile/lib`.
4. Captura del Swagger UI con endpoints.
5. Captura del endpoint de pistas.
6. Captura del endpoint de reservas.
7. Captura del error de solape `409`.
8. Captura de MySQL con tablas.
9. Captura de la pantalla de login.
10. Captura de la pantalla principal con pistas.
11. Captura del calendario de reserva.
12. Captura del QR.
13. Captura del escaner.
14. Captura del historial.
15. Captura de incidencias.

## Como explicarlo ante el jurado

La estructura se ha organizado separando responsabilidades. El backend concentra la API, la seguridad, la logica de negocio y el acceso a datos. La carpeta `mobile` contiene la aplicacion Flutter y separa pantallas, modelos y servicios. La carpeta `sql` conserva los scripts de base de datos y la carpeta `docs` reune la documentacion de entrega. Esta organizacion facilita el mantenimiento, la localizacion de errores y la ampliacion futura del sistema.
