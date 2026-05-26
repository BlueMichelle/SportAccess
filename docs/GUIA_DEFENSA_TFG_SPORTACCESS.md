# Guia de explicacion y defensa del proyecto SportAccess

## Documento de estudio para la exposicion del TFG

| Dato | Contenido |
|---|---|
| Proyecto | SportAccess |
| Ciclo | CFGS Desarrollo de Aplicaciones Multiplataforma |
| Centro | CIFP Politecnico de Cartagena |
| Localidad | Cartagena, Region de Murcia |
| Curso | 2025-2026 |
| Tipo de proyecto | Aplicacion movil multiplataforma + backend REST + base de datos |
| Backend | Spring Boot, Java, Spring Data JPA, Spring Security |
| Frontend | Flutter, Dart |
| Base de datos | MySQL, base de datos relacional |
| Documentacion API | Swagger / OpenAPI |

## 1. Explicacion corta para empezar la defensa

SportAccess es una aplicacion multiplataforma para gestionar reservas de instalaciones deportivas. El usuario puede registrarse, iniciar sesion, consultar pistas disponibles, seleccionar una fecha y horario, crear una reserva, obtener un codigo QR, consultar su historial y registrar incidencias.

El proyecto esta formado por dos partes principales. Por un lado, una aplicacion movil desarrollada con Flutter, que actua como interfaz de usuario. Por otro lado, un backend desarrollado con Spring Boot, que expone una API REST, valida las operaciones y guarda la informacion en una base de datos MySQL.

La idea principal es sustituir una gestion manual de reservas por un sistema digital que centraliza datos, evita solapes de horarios y permite tener trazabilidad de reservas e incidencias.

## 2. Que problema resuelve

El problema que resuelve SportAccess es la organizacion de reservas deportivas. En muchos centros deportivos o instalaciones compartidas se pueden producir problemas como:

- Reservas duplicadas en la misma pista y franja horaria.
- Falta de historial de reservas por usuario.
- Dificultad para saber que pistas estan disponibles.
- Falta de control para validar el acceso.
- Incidencias comunicadas sin seguimiento claro.
- Datos repartidos en papel, hojas de calculo o conversaciones.

SportAccess resuelve estas necesidades mediante una app movil conectada a un servidor. La reserva no se guarda directamente en el movil, sino que se envia al backend, donde se comprueba la disponibilidad y se almacena en la base de datos.

## 3. Como se ha hecho el proyecto desde cero

### 3.1 Analisis de la idea

El primer paso fue definir la necesidad: crear una aplicacion para reservar pistas deportivas. A partir de esa idea se identificaron los usuarios principales:

- Usuario final que reserva una pista.
- Administrador o responsable que puede revisar datos.
- Personal que puede consultar incidencias.

Tambien se definieron las funcionalidades principales:

- Registro e inicio de sesion.
- Listado de pistas.
- Seleccion de fecha y hora.
- Creacion de reservas.
- Control de solapes.
- Generacion de QR.
- Escaneo de QR.
- Historial.
- Incidencias.

### 3.2 Diseno de la arquitectura

Despues se decidio usar una arquitectura cliente-servidor:

```text
App Flutter -> API REST Spring Boot -> Repositorios JPA -> Base de datos MySQL
```

La app movil no accede directamente a la base de datos. Siempre se comunica con el backend mediante peticiones HTTP. Esto es importante porque centraliza la seguridad y la logica de negocio en el servidor.

### 3.3 Creacion del backend

El backend se creo con Spring Boot. Se organizaron las clases por capas:

```text
controller/   # Recibe peticiones HTTP
service/      # Logica de negocio
repository/   # Acceso a base de datos
model/        # Entidades JPA
dto/          # Datos de entrada y salida
config/       # Configuracion del proyecto
security/     # Seguridad y filtros
exception/    # Gestion de errores
```

Las entidades principales son:

- `User`: usuarios.
- `SportsCenter`: centros deportivos.
- `Court`: pistas deportivas.
- `Reservation`: reservas usadas por la app movil.
- `Booking`: modelo adicional de reserva.
- `Payment`: pagos preparados.
- `Incident`: incidencias.

### 3.4 Creacion de la base de datos

Se uso MySQL como sistema gestor de base de datos. MySQL es una base de datos relacional, lo que significa que la informacion se organiza en tablas relacionadas entre si mediante claves primarias y claves foraneas.

Ejemplo de relaciones:

- Un usuario puede tener muchas reservas.
- Una pista puede tener muchas reservas.
- Una pista pertenece a un centro deportivo.
- Una incidencia pertenece a un usuario y a una pista.
- Una incidencia puede estar asociada a una reserva.

El backend usa Spring Data JPA e Hibernate para mapear las clases Java a tablas de MySQL. Por ejemplo, la clase `Reservation` representa la tabla `reservations`.

### 3.5 Creacion de la app movil

La parte movil se hizo con Flutter y Dart. Flutter permite crear aplicaciones multiplataforma con una sola base de codigo.

La carpeta principal de la app es:

```text
mobile/lib/
|-- main.dart
|-- models/models.dart
|-- services/api_service.dart
|-- screens/
```

Las pantallas principales son:

- `login_screen.dart`: inicio de sesion.
- `register_screen.dart`: registro.
- `home_screen.dart`: listado de pistas.
- `booking_screen.dart`: seleccion de fecha y horario.
- `payment_screen.dart`: confirmacion o simulacion de pago.
- `qr_screen.dart`: visualizacion del QR.
- `scanner_screen.dart`: escaneo de QR.
- `history_screen.dart`: historial.

### 3.6 Conexion entre backend y frontend

La conexion entre front y back se realiza mediante HTTP. La app Flutter usa una clase llamada `ApiService`, que centraliza las llamadas al backend.

En el proyecto, la URL base usada por la app es:

```text
http://10.0.2.2:8080/api
```

Se usa `10.0.2.2` porque en el emulador Android esa direccion apunta al `localhost` del ordenador. El backend se ejecuta en el puerto `8080`.

Ejemplo del flujo:

1. El usuario abre la app.
2. La app pide pistas al backend con `GET /api/courts`.
3. El backend consulta la base de datos.
4. El backend devuelve JSON con las pistas.
5. Flutter convierte ese JSON en objetos `Court`.
6. La app muestra las pistas en pantalla.

Cuando se crea una reserva:

1. Flutter prepara un JSON con usuario, pista, fecha de inicio, fecha de fin y QR.
2. Envia una peticion `POST /api/reservations`.
3. Spring Boot recibe la peticion en `ReservationController`.
4. El backend comprueba si hay solape mediante `ReservationRepository`.
5. Si hay solape, devuelve error `409 CONFLICT`.
6. Si no hay solape, guarda la reserva en MySQL.
7. Devuelve la reserva creada a Flutter.
8. Flutter muestra la pantalla con el QR.

## 4. Herramientas utilizadas

| Herramienta | Uso |
|---|---|
| Java | Lenguaje del backend |
| Spring Boot | Framework para crear la API REST |
| Spring Web | Creacion de controladores REST |
| Spring Data JPA | Acceso a datos mediante repositorios |
| Hibernate | ORM que traduce entidades Java a tablas |
| Spring Security | Seguridad y control de acceso |
| Firebase Admin SDK | Preparacion para autenticacion con tokens Firebase |
| MySQL | Base de datos relacional |
| Maven | Gestion de dependencias del backend |
| Flutter | Framework de app movil multiplataforma |
| Dart | Lenguaje de programacion de Flutter |
| Dio | Cliente HTTP usado por Flutter |
| shared_preferences | Guardado local sencillo en la app |
| qr_flutter | Generacion de codigos QR |
| mobile_scanner | Escaneo de QR con la camara |
| table_calendar | Calendario para elegir fecha |
| Swagger / OpenAPI | Probar y documentar endpoints |
| Docker | Preparar entorno reproducible |
| Docker Compose | Levantar backend y MySQL juntos |
| Git | Control de versiones |
| GitHub | Repositorio remoto |

## 5. Que base de datos se usa y que tipo es

La base de datos usada es MySQL. Es una base de datos relacional SQL.

Esto significa que:

- Los datos se guardan en tablas.
- Cada tabla tiene columnas y registros.
- Las tablas se relacionan mediante claves.
- Se pueden hacer consultas SQL.
- Es adecuada para informacion estructurada como usuarios, reservas, pistas e incidencias.

En SportAccess se usa MySQL porque encaja bien con el modelo del proyecto. Las reservas, usuarios, pistas y centros tienen relaciones claras. Ademas, Spring Boot se integra muy bien con MySQL mediante Spring Data JPA.

## 6. Tablas o entidades principales

| Entidad | Que representa |
|---|---|
| `users` | Usuarios registrados |
| `sports_centers` | Centros deportivos |
| `courts` | Pistas deportivas |
| `reservations` | Reservas creadas desde la app movil |
| `bookings` | Modelo adicional de reservas |
| `payments` | Pagos preparados o simulados |
| `incidents` | Incidencias reportadas |

## 7. Como se evita que dos usuarios reserven lo mismo

La parte mas importante de la logica de reservas es evitar solapes. Esto se hace en el backend, no solo en la app. Es una decision correcta porque el backend es quien debe proteger la integridad de los datos.

La condicion usada es:

```text
Una reserva se solapa si:
nuevaFechaInicio < reservaExistente.fechaFin
y
nuevaFechaFin > reservaExistente.fechaInicio
```

Ademas, solo se tienen en cuenta reservas activas. Las reservas canceladas o completadas no bloquean necesariamente la pista.

Si se detecta un solape, el backend responde:

```text
409 CONFLICT
```

Esto indica que la peticion es valida, pero no puede completarse porque entra en conflicto con el estado actual del sistema.

## 8. Como funciona el QR

Cada reserva puede tener un `qrToken`. Ese token identifica la reserva. En la app, la pantalla `qr_screen.dart` muestra un codigo QR generado a partir de ese token.

Despues, con la pantalla `scanner_screen.dart`, se puede leer un QR. La app compara o busca ese token entre las reservas existentes para validar si corresponde a una reserva real.

En una version futura, esta validacion podria reforzarse haciendo que el backend tenga un endpoint especifico como:

```text
GET /api/reservations/qr/{token}
```

Asi la validacion dependeria siempre del servidor.

## 9. Seguridad del proyecto

El proyecto incluye varias medidas de seguridad:

- Uso de Spring Security en el backend.
- Preparacion para validar tokens Firebase.
- Configuracion CORS.
- Separacion de credenciales y codigo.
- Uso de `.gitignore` para evitar subir claves, `.env` o generados.
- Validacion de usuarios, pistas y reservas antes de guardar datos.
- Respuestas HTTP adecuadas ante errores.

Una mejora futura seria aplicar autenticacion obligatoria con Firebase en todos los endpoints privados y controlar los permisos por rol: usuario normal y administrador.

## 10. Pruebas realizadas

Las pruebas realizadas o recomendadas son:

- Arrancar backend en puerto 8080.
- Abrir Swagger.
- Probar `GET /api/courts`.
- Registrar usuario.
- Iniciar sesion.
- Crear reserva.
- Intentar crear reserva solapada.
- Comprobar respuesta `409`.
- Ver QR generado.
- Escanear QR.
- Consultar historial.
- Crear incidencia.
- Revisar datos guardados en MySQL.

## 11. Como explicarlo en una exposicion

Una forma clara de explicarlo seria:

"Primero hice el analisis de necesidades y defini que el sistema debia permitir gestionar reservas deportivas. Despues diseñe una arquitectura cliente-servidor, con una app movil en Flutter y un backend en Spring Boot. El backend se conecta a una base de datos MySQL mediante Spring Data JPA. La app se comunica con el backend usando peticiones HTTP y recibe datos en formato JSON. La funcionalidad principal es la reserva de pistas, donde el backend valida que no exista otra reserva en el mismo horario antes de guardar los datos. Ademas, el sistema incluye QR, historial, incidencias, Swagger, configuracion Docker y documentacion tecnica."

## 12. Preguntas tipicas de defensa y respuestas modelo

### 12.1 Por que elegiste Flutter

Flutter permite desarrollar aplicaciones multiplataforma con una sola base de codigo. Con Dart y Flutter puedo crear pantallas para Android, iOS, web o escritorio manteniendo una estructura comun. Para este proyecto era adecuado porque el objetivo era una aplicacion movil y se necesitaba rapidez para construir interfaz, navegacion y componentes como calendario, QR y escaner.

### 12.2 Por que elegiste Spring Boot

Spring Boot facilita crear APIs REST en Java de forma estructurada. Permite separar controladores, servicios, repositorios y entidades. Ademas, se integra bien con MySQL mediante Spring Data JPA, con seguridad mediante Spring Security y con documentacion mediante Swagger/OpenAPI.

### 12.3 Que tipo de base de datos usas

Uso MySQL, que es una base de datos relacional SQL. Es relacional porque organiza la informacion en tablas y permite relacionarlas mediante claves primarias y foraneas. Es adecuada para este proyecto porque usuarios, pistas, reservas e incidencias tienen relaciones claras.

### 12.4 Como se conecta el front con el back

La app Flutter se conecta con el backend mediante peticiones HTTP a la API REST. La clase `ApiService` usa la URL base `http://10.0.2.2:8080/api` en emulador Android. Por ejemplo, para obtener pistas llama a `GET /api/courts`, y para crear reservas llama a `POST /api/reservations`. El backend responde en JSON y Flutter transforma esos datos en modelos.

### 12.5 Por que no conectas Flutter directamente a MySQL

Porque no seria seguro ni mantenible. Si la app se conectara directamente a MySQL, habria que exponer credenciales y reglas de negocio en el cliente. Lo correcto es que la app hable con el backend y que el backend sea quien valide permisos, reglas, datos y acceso a la base de datos.

### 12.6 Como evitas reservas duplicadas

Lo evito en el backend mediante una consulta de solape. Antes de guardar una reserva, el servidor comprueba si ya existe una reserva activa para la misma pista cuyo intervalo horario se cruce con el nuevo. Si existe, devuelve `409 CONFLICT` y no guarda la reserva.

### 12.7 Que es una API REST

Una API REST es una forma de comunicar sistemas mediante HTTP. Usa rutas y metodos como `GET`, `POST`, `PUT` o `DELETE`. En este proyecto la app movil consume endpoints REST para obtener pistas, crear usuarios, crear reservas y gestionar incidencias.

### 12.8 Que es JPA

JPA es una especificacion de Java para trabajar con bases de datos usando objetos. En vez de escribir siempre SQL manualmente, se crean entidades Java y repositorios. Hibernate se encarga de traducir esas operaciones a consultas SQL.

### 12.9 Que es Swagger

Swagger es una herramienta para documentar y probar la API. En el proyecto permite ver los endpoints del backend desde el navegador y probar peticiones sin tener que usar Postman.

### 12.10 Que aporta Docker

Docker permite empaquetar servicios y ejecutarlos de forma reproducible. En el proyecto se usa Docker Compose para levantar el backend y una base de datos MySQL. Esto facilita que otra persona pueda probar el proyecto con una configuracion similar.

### 12.11 Que mejoras harias si tuvieras mas tiempo

Unificaria definitivamente `Booking` y `Reservation`, reforzaria la autenticacion real con Firebase, crearia un panel administrador, integraria pagos reales, añadiria notificaciones push, ampliaria tests automatizados y desplegaria el backend en un servidor cloud.

### 12.12 Que parte del proyecto es mas importante tecnicamente

Una de las partes mas importantes es la validacion de reservas en el backend, porque protege la coherencia de la base de datos. Tambien es importante la separacion por capas, ya que permite mantener el proyecto y localizar errores con mas facilidad.

### 12.13 Que diferencia hay entre frontend y backend en tu proyecto

El frontend es la aplicacion Flutter que ve el usuario. Se encarga de pantallas, formularios, navegacion, QR y llamadas HTTP. El backend es la API Spring Boot que recibe peticiones, valida datos, ejecuta logica de negocio y guarda informacion en MySQL.

### 12.14 Como se guarda una reserva

La app envia una peticion `POST /api/reservations` con los datos de usuario, pista y fechas. El backend recibe esos datos, busca o crea el usuario si procede, comprueba que la pista exista, valida que no haya solape y finalmente guarda la reserva con estado `CONFIRMADA` y un `qrToken`.

### 12.15 Que errores controlas

Se controlan errores como usuario o pista no encontrados, falta de credenciales, reservas solapadas, datos invalidos o errores internos del servidor. Se usan respuestas HTTP como `400`, `404`, `409` y `500`.

### 12.16 Que relacion tiene con DAM

El proyecto se relaciona con DAM porque integra programacion, bases de datos, acceso a datos, desarrollo de interfaces, aplicaciones moviles, seguridad, pruebas, documentacion tecnica y uso de herramientas informaticas. Es un proyecto completo de aplicacion multiplataforma.

## 13. Preguntas rapidas para practicar

| Pregunta | Respuesta corta |
|---|---|
| Que es SportAccess | Una app para reservar instalaciones deportivas |
| Que framework usa la app | Flutter |
| Que lenguaje usa Flutter | Dart |
| Que framework usa el backend | Spring Boot |
| Que lenguaje usa el backend | Java |
| Que base de datos usa | MySQL |
| Que tipo de BD es MySQL | Relacional SQL |
| Como se conectan app y backend | HTTP REST con JSON |
| Que puerto usa el backend | 8080 |
| Que URL usa Android para localhost | 10.0.2.2 |
| Como se prueban endpoints | Swagger |
| Como se evitan solapes | Consulta en backend antes de guardar |
| Que codigo HTTP indica solape | 409 CONFLICT |
| Para que sirve JPA | Mapear entidades Java a tablas |
| Para que sirve Docker Compose | Levantar app y base de datos juntas |

## 14. Guion recomendado para defenderlo

1. Presentacion del problema.
2. Objetivo general del proyecto.
3. Arquitectura: Flutter, Spring Boot y MySQL.
4. Explicacion de la app movil.
5. Explicacion del backend.
6. Explicacion de la base de datos.
7. Flujo de reserva.
8. Validacion de solapes.
9. QR y escaner.
10. Incidencias.
11. Seguridad.
12. Pruebas.
13. Relacion con DAM.
14. Mejoras futuras.
15. Cierre.

## 15. Cierre recomendado

Como conclusion, SportAccess demuestra la integracion de una aplicacion movil con un backend y una base de datos real. El proyecto aplica conocimientos de DAM en programacion, interfaces, acceso a datos, bases de datos, seguridad, pruebas y documentacion. Aunque todavia podria ampliarse con pagos reales, autenticacion completa y panel administrador, la base funcional esta preparada para evolucionar hacia una solucion real de gestion deportiva.
