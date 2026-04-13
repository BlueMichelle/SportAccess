# 📘 Documentación Técnica y Resolución de Errores

Este documento detalla exhaustivamente el esfuerzo técnico llevado a cabo para integrar la aplicación móvil de **SportAccess** (desarrollada en Flutter) con nuestro backend (construido con Spring Boot y base de datos relacional MySQL). Aquí explicamos qué metas arquitectónicas hemos alcanzado, qué paradigmas de código hemos aplicado, y proporciona una bitácora pormenorizada de los errores técnicos superados durante el ciclo de vida del proyecto.

---

## ¿Qué hemos hecho?

Hemos conseguido enlazar el Frontend (App Flutter) y el Backend (Spring Boot) para que operen como un sistema unificado y en tiempo real, garantizando la persistencia estricta en la base de datos MySQL. Las implementaciones abarcan:

1. **Gestión Integral de Usuarios**: Flujos completos de autenticación (Login y Registro) interceptando las credenciales y garantizando su existencia real en la tabla `users` mediante peticiones seguras.
2. **Catálogo Dinámico de Instalaciones**: Visualización renderizada desde el backend de las instalaciones y pistas deportivas repartidas por la Región de Murcia (traídas vía peticiones `GET`).
3. **Motor de Reservaciones Híbrido**: Sistema de calendario (usando `table_calendar`) capaz de bloquear horas ocupadas en tiempo real para evitar solapamientos.
4. **Módulo de Transacciones Económicas**: Simulación de pasarela de pago (`payment_screen.dart`) que consolida la reserva enviando un *payload* de confirmación al servidor.
5. **Generador de Accesos y Seguridad Física (`QR`)**: Creación de tokens temporales de acceso mediante códigos QR, generados con la información de la reserva validada.
6. **Autenticación Biométrica/Geolocalizada de Accesos**: Pantalla de escáner en tiempo real (`mobile_scanner` + `geolocator`) para permitir el acceso a pistas validando tanto que el QR sea legítimo como que el usuario se encuentre en las coordenadas de la instalación.

---

## Arquitectura de Comunicación: ¿Cómo lo hemos logrado?

El core de nuestra infraestructura recae en una arquitectura HTTP RESTful, centralizada en la capa de servicios de Dart.

- **Conectividad a Entornos de Desarrollo (`10.0.2.2:8080`)**:
  Dado que los emuladores Android (como AVD) ejecutan una red virtualizada aislada, hacer peticiones a `localhost` intentaría conectar al propio teléfono simulado en lugar del ordenador anfitrión. Para sortear esto —y prescindir temporalmente de túneles como Ngrok—, enrutamos nuestro cliente HTTP en `lib/services/api_service.dart` apuntando estáticamente a la Magic IP de loopback del emulador: `static const String baseUrl = 'http://10.0.2.2:8080/api';`.
- **Cliente y Consumo REST (`Dio`)**:
  Sustituimos el paquete HTTP estándar por `Dio` para gestionar con mayor versatilidad tiempos de espera, decodificación de JSON y encabezados. Mapeamos las rutas principales:
  - `GET /api/courts` (Carga la infraestructura del complejo deportivo).
  - `POST /api/users` & `GET /api/users/{uid}` (Control de identidades).
  - `POST /api/reservations` (Confirmación final de agenda).
- **Gestión de Identidad mediante Firebase UUID**:
  A falta de una integración nativa completa en Flutter con `firebase_auth` (por restricciones de configuración), hemos replicado una arquitectura segura utilizando el esquema de base de datos del backend. Hemos conservado la columna `@Column(name="firebase_uid")` en el modelo MySQL (`User.java`) como llave primaria virtual. Este UID se transporta en las peticiones de Flutter como un identificador de sesión a lo largo del proceso del login (`userMap['firebaseUid']`) y del pago.

---

## Errores Críticos

A lo largo del proyecto, la integración de ambas ramas requirió un arduo trabajo de refactorización y depuración de concurrencias. A continuación el detalle técnico:

### 1. Integridad Referencial y Tablas "Zombies" en la Base de Datos
- **Contexto del Problema**: Durante la evolución del modelo de datos de Spring Boot, necesitábamos renombrar y alterar restricciones (e.g., pasar el atributo *name* a *nombre*). Al ejecutar un `ALTER TABLE users`, el motor de InnoDB de MySQL bloqueaba la orden disparando excepciones de integridad (`Cannot delete or update a parent row: a foreign key constraint fails`). 
- **Causa Raíz y Solución**: Tablas originadas en compilaciones antiguas llamadas `bookings` y `payments` seguían vivas en el esquema, entrelazando claves foráneas con `users`. Al ser imperceptibles desde algunas vistas, paralizaban cualquier migración de atributos. Resolvemos esto deteniendo el servicio y forzando scripts manuales directos a la consola SQL: `DROP TABLE payments; DROP TABLE bookings;`, liberando a la entidad `users` de cualquier deuda técnica.

### 2. El Conflicto de Marshalling JSON ("Los Getters Fantasmas")
- **Contexto del Problema**: Repentinamente, llamadas vitales a `/api/courts` devolvían códigos de éxito (HTTP 200) pero con cuerpos de respuesta incompletos o enteramente vacíos, causando Null Pointers en la UI de Flutter (`List.length was called on null`).
- **Causa Raíz y Solución**: La librería **Jackson** (utilizada por Spring Boot para empaquetar objetos de Java a JSON) requiere la existencia estricta de métodos `public... getVariable()` para inyectar su valor al payload de respuesta. El autor original de las entidades como `Court.java` omitió estos métodos, asumiendo que anotaciones de librerías externas (como Lombok `@Data`) harían el trabajo, pero el entorno de compilación carecía del plugin. 
- **Solución implementada**: Tuvimos que intervenir la estructura de los modelos POJO (`Plain Old Java Object`) del backend, inyectando iterativamente cada declarativa Getter y Setter de las propiedades para resucitar el enrutamiento bidireccional de datos.

### 3. Sincronicidad en la Pasarela de Pagos (Race Conditions)
- **Contexto del Problema**: Al presionar "Pagar y Finalizar" (`payment_screen.dart`), el log de Spring Boot vomitaba trazas de error `500 Internal Server Error` o `DataIntegrityViolationException`.
- **Causa Raíz y Solución**: El backend exigía asociar la nueva reserva a una ID de usuario foránea que obligatoriamente ya debía existir en su tabla de la BD. Si la App enviaba un `firebaseUid` sin que el backend hubiera previamente instanciado e indexado a ese usuario, MySQL abortaba la transacción por orfandad referencial.
- **Solución implementada**: Reemplazamos el guardado ciego por una función de acoplamiento seguro. Ahora, el Post de Reservas delega en el backend la búsqueda del usuario (haciendo un query a BD). Si el usuario asociado no se encuentra, el servicio intercepta el fallo, crea el usuario al vuelo inyectándole columnas obligatorias con default fallbacks (ej. rol = `USER`, telefono = `000000000`), y después procesa de forma segura el cobro de la reserva.

### 4. Geolocalización Asíncrona: El Escáner Atrapado en el Tiempo
- **Contexto del Problema**: En la validación táctica (`scanner_screen.dart`), pretendíamos verificar que la petición geospacial ocurriese "in situ". Al levantar la cámara en el emulador Android, el `Stream` de eventos de Flutter dejaba la pantalla bloqueada visualmente en un estado de carga infinita, finalizando en un `TimeoutException`.
- **Causa Raíz y Solución**: El *plugin* de geolocalización intentaba capturar satélites con la bandera `LocationAccuracy.high`. El GPS del ordenador emulado no emitía pulsos válidos a tiempo.
- **Solución implementada**: Evolucionamos el sistema a una arquitectura asíncrona tolerante a fallos. Introducimos una bifurcación de redondancia mediante un `try-catch` dotado de un centinela temporal (`.timeout((Duration(seconds: 5)))`). Si vencido el plazo el hardware del móvil no otorga una ubicación nativa, la App salta del hilo primario y le solicita al O.S. la última coordenada en caché con `Geolocator.getLastKnownPosition()`. Esto blinda la app frente a "Crashing", permitiendo continuar o denegar el acceso sin trabar el sistema de escaneo.

### 5. Bucles Infinitos de Serialización: "El Login Inmortal"
- **Contexto del Problema**: El peor fallo endémico lo encontramos en la autenticación. Omitir validaciones reales provocó sesiones de impostores, pero al fortificar el endpoint con comprobaciones de integridad, los terminales colapsaban tirando errores `StackOverflowError` traducido en un `Document nesting depth > 1000`.
- **Causa Raíz y Solución**: 
  1. *El Bucle*: Las entidades relacionales en Spring Boot sufrían redundancia circular cruzada. Una entidad `Court` poseía una `List<Reservation>`, y lógicamente cada `Reservation` tenía una FK apuntando a su `Court` matriz. Al invocar el JSON, Jackson entraba en una espiral infinita de serialización (Pista -> Reserva -> Pista -> Reserva...). Implementamos la etiqueta Jackson `@JsonIgnore` sobre estas ramas foráneas para seccionar la hiper-recursividad.
  2. *El Login Impostor*: Retocamos radicalmente la arquitectura de `login_screen.dart` pasando de un enfoque pasivo a uno validativo. Antes de emitir el token local, el cliente arroja un `dio.get('/users')`. Parsea la lista de bases de datos, verifica coincidencia de contraseñas u Oaths mapeados, y solo autoriza el progreso si el boolean interno `encontrado` retorna afirmativo. Fin de sesiones falsas en el emulador.
