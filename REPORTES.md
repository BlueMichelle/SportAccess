# Reporte de Progreso - Miembro 4 (Gestión de Incidencias)
**Fecha:** 23 de Abril de 2026
**Rama actual:** `mobile-flutter` / Backend

---

## 🛠️ 1. Cambios en el Backend (Spring Boot)
Se ha implementado la estructura base para recibir y gestionar los reportes de incidencias desde la aplicación móvil:
* **Controllers:** Creación del archivo `IncidentController.java` dentro de la carpeta `controller` para exponer la API.
* **DTOs:** Creación de una nueva carpeta `dto` y del archivo `IncidentRequestDTO.java` para tipar y recibir correctamente el cuerpo de las peticiones (JSON) desde el frontend.
* **Persistencia:** Modificación del archivo `DataInitializer.java` para eliminar la instrucción que borraba los usuarios al reiniciar el servidor, garantizando así la persistencia de datos durante las pruebas.

## 📱 2. Cambios en el Frontend (Flutter / App Móvil)
Se ha desarrollado la interfaz de usuario para la creación de reportes y se ha integrado en la navegación principal:
* **Pantallas:** Creación del archivo `report_incident_screen.dart` en la carpeta `screens` con la lógica de UI y el formulario de envío (incluyendo selección de pista y captura de imagen).
* **Navegación:** Modificación del archivo `home_screen.dart`. Se ha añadido el botón de acceso directo a "Incidencias" tanto en el menú desplegable (Drawer) como en el menú fijo inferior.

## ⚙️ 3. Configuración e Integración (Firebase & Android)
Se ha preparado el entorno de la aplicación para soportar la subida de imágenes a la nube:
* **Credenciales:** Integración del archivo `google-services.json` en las rutas clave del proyecto (`android/` y `android/app/`).
* **Dependencias Flutter:** Actualización del archivo `pubspec.yaml` para incluir los paquetes necesarios de Firebase (`firebase_core`, `firebase_storage`).
* **Gradle (Kotlin DSL):** * Modificación de `android/build.gradle.kts` para agregar la dependencia global de Google Services.
  * Modificación de `android/app/build.gradle.kts` para aplicar el plugin específico de Google Services necesario para la compilación de Android.

---
