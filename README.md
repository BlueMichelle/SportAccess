# 🏟️ SportAccess — Aplicación de Reserva de Instalaciones Deportivas

Sistema de gestión y reserva de instalaciones deportivas, compuesto por una aplicación móvil en **Flutter** y un backend REST en **Spring Boot** con base de datos **MySQL**.

## 🚀 Cómo Arrancar el Proyecto

### 1. Base de datos MySQL
Asegúrate de tener MySQL corriendo con usuario `root` y contraseña `12345`. La base de datos `sportaccess` (y sus tablas) se crearán y configurarán automáticamente al arrancar el backend.

### 2. Backend Spring Boot
Abre una terminal y ejecuta:
```powershell
cd carpeta_backend_reservas\Spring\sportaccess-backend
.\mvnw.cmd clean package -DskipTests
.\mvnw.cmd spring-boot:run
```
El servidor arrancará en `http://localhost:8080`.

### 3. App Flutter
Abre una terminal en la carpeta principal del frontend y ejecuta:
```powershell
flutter pub get
flutter run
```
El emulador se conectará automáticamente a tu `localhost` a través de `10.0.2.2:8080`.

---
*Para ver información detallada sobre la integración y la resolución de problemas vividos durante el desarrollo del proyecto, consulta el archivo [DOCUMENTACION.md](DOCUMENTACION.md).*
