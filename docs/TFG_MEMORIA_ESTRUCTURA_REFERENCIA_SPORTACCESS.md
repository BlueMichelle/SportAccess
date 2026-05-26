# CIFP Politecnico de Cartagena

## Trabajo de Fin de Ciclo

## CFGS Desarrollo de Aplicaciones Multiplataforma

# SportAccess

## Plataforma multiplataforma para reservas y gestion de instalaciones deportivas

**Realizado por**  
Alumno/a pendiente de completar

**Dirigido por**  
Tutor/a pendiente de completar

**Departamento / Familia profesional**  
Informatica y Comunicaciones

**Cartagena, Region de Murcia**  
Curso 2025-2026

## Licencia y datos del documento

Documento elaborado para la defensa del modulo `0492. Proyecto de Desarrollo de Aplicaciones Multiplataforma`.

Repositorio del proyecto:

```text
https://github.com/BlueMichelle/SportAccess
```

Este documento se ha redactado como memoria academica del proyecto SportAccess. La estructura se inspira en memorias tecnicas universitarias con separacion clara entre introduccion, metodologia, analisis, diseno, implementacion, manuales, conclusiones y anexos.

## Declaracion de autoria

Yo, alumno/a del CFGS de Desarrollo de Aplicaciones Multiplataforma, declaro que la presente memoria corresponde al proyecto SportAccess, desarrollado como Trabajo de Fin de Ciclo durante el curso 2025-2026.

El proyecto consiste en una aplicacion multiplataforma para la gestion de reservas de instalaciones deportivas, compuesta por una aplicacion movil en Flutter, un backend REST en Spring Boot y una base de datos MySQL.

Firma:

```text
Alumno/a: ______________________________
Fecha:    ______________________________
```

## Dedicatoria

A todas las personas que han apoyado el proceso de aprendizaje durante el ciclo, especialmente a quienes han ayudado en la revision, pruebas y mejora del proyecto.

## Agradecimientos

Quiero agradecer al profesorado del ciclo de Desarrollo de Aplicaciones Multiplataforma la orientacion recibida en las areas de programacion, bases de datos, acceso a datos, desarrollo de interfaces, seguridad y documentacion tecnica.

Tambien agradezco el apoyo recibido durante el desarrollo y prueba de SportAccess, especialmente en la revision de funcionalidades, deteccion de errores y preparacion de la defensa final.

## Resumen

### Contexto

La gestion de reservas de instalaciones deportivas suele realizarse mediante procesos manuales, llamadas, hojas de calculo o sistemas poco integrados. Esto puede provocar reservas duplicadas, falta de trazabilidad, errores en horarios y dificultad para registrar incidencias.

### Objetivos

El objetivo del proyecto es desarrollar una aplicacion multiplataforma que permita consultar pistas deportivas, crear reservas, evitar solapes, generar codigos QR, consultar historial y registrar incidencias. Para ello se implementa una app movil conectada a una API REST y una base de datos relacional.

### Resultados

El resultado es un sistema compuesto por:

- Aplicacion movil desarrollada con Flutter y Dart.
- Backend REST desarrollado con Spring Boot y Java.
- Base de datos MySQL gestionada mediante Spring Data JPA.
- Endpoints documentados con Swagger/OpenAPI.
- Funcionalidades de reservas, usuarios, pistas, incidencias, QR e historial.
- Configuracion local y Docker Compose.
- Documentacion tecnica y guia de defensa.

### Conclusiones

SportAccess demuestra la integracion de varias competencias del ciclo DAM: programacion, bases de datos, acceso a datos, interfaces, aplicaciones moviles, seguridad, pruebas, documentacion y uso de herramientas informaticas. El proyecto queda preparado para evolucionar con autenticacion completa, pagos reales, panel administrador y despliegue en produccion.

## Indice general

I. Introduccion  
1. Introduccion  
1.1 Contexto  
1.2 Objetivos  
1.3 Estructura del documento  

II. Metodologia  
2. Planificacion  
2.1 Metodologia de desarrollo  
2.2 Resumen temporal del proyecto  
2.3 Informe de tareas  
3. Estimacion de costes  
3.1 Costes de personal  
3.2 Costes materiales  
3.3 Costes indirectos  
3.4 Resumen de costes  

III. Analisis  
4. Estado del arte  
4.1 Gestion de reservas deportivas  
4.2 Aplicaciones moviles de gestion  
4.3 APIs REST y arquitectura cliente-servidor  
4.4 Comparativa de soluciones  
5. Estudio tecnologico  
5.1 Flutter  
5.2 Spring Boot  
5.3 MySQL  
5.4 Firebase, Swagger y Docker  

IV. Diseno  
6. Requisitos  
6.1 Requisitos funcionales  
6.2 Requisitos no funcionales  
6.3 Casos de uso  
7. Arquitectura  
7.1 Arquitectura de la solucion  
7.2 Arquitectura del backend  
7.3 Arquitectura de la app movil  
7.4 Modelo de datos  

V. Implementacion  
8. Implementacion de SportAccess  
8.1 Stack tecnologico  
8.2 Backend  
8.3 Aplicacion movil  
8.4 Base de datos  
8.5 Conexion front-back  
8.6 Seguridad  
9. Validacion  
9.1 Pruebas funcionales  
9.2 Pruebas de API  
9.3 Pruebas de app movil  
9.4 Resultados de validacion  

VI. Manuales  
10. Manual de uso  
10.1 Situacion inicial  
10.2 Instalacion del backend  
10.3 Instalacion de la app movil  
10.4 Uso de la aplicacion  
10.5 Prueba del sistema  

VII. Conclusiones  
11. Conclusiones  
11.1 Evaluacion final del proyecto  
11.2 Trabajo futuro  

Anexos  
A. Relacion con resultados de aprendizaje DAM  
B. Preguntas frecuentes de defensa  
C. Estructura de directorios  
D. Capturas recomendadas  
Bibliografia

## Indice de figuras

| Figura | Titulo recomendado |
|---|---|
| Figura 1 | Arquitectura general de SportAccess |
| Figura 2 | Flujo de creacion de reserva |
| Figura 3 | Estructura del backend Spring Boot |
| Figura 4 | Estructura de la app Flutter |
| Figura 5 | Modelo entidad-relacion de la base de datos |
| Figura 6 | Swagger UI con endpoints |
| Figura 7 | Pantalla de login |
| Figura 8 | Pantalla principal con pistas |
| Figura 9 | Pantalla de seleccion de fecha y horario |
| Figura 10 | QR generado para una reserva |
| Figura 11 | Escaner QR |
| Figura 12 | Historial de reservas |

## Indice de cuadros

| Cuadro | Titulo recomendado |
|---|---|
| Cuadro 1 | Resumen de tecnologias utilizadas |
| Cuadro 2 | Planificacion temporal |
| Cuadro 3 | Estimacion de costes |
| Cuadro 4 | Requisitos funcionales |
| Cuadro 5 | Requisitos no funcionales |
| Cuadro 6 | Endpoints principales |
| Cuadro 7 | Entidades de base de datos |
| Cuadro 8 | Pruebas funcionales |
| Cuadro 9 | Relacion con RA de DAM |

# I. Introduccion

## 1. Introduccion

SportAccess es una aplicacion multiplataforma para la gestion de reservas de instalaciones deportivas. El sistema permite a un usuario consultar pistas, reservar una franja horaria, obtener un codigo QR, revisar su historial y registrar incidencias.

El proyecto se compone de una aplicacion movil Flutter, un backend REST Spring Boot y una base de datos MySQL. Esta separacion permite que la interfaz de usuario, la logica de negocio y la persistencia de datos esten organizadas en capas independientes.

### 1.1 Contexto

En instalaciones deportivas, centros educativos o polideportivos municipales, la reserva de pistas requiere controlar disponibilidad, usuarios, horarios, incidencias y accesos. Si estos procesos se gestionan manualmente, pueden aparecer errores como duplicidad de reservas o perdida de informacion.

SportAccess digitaliza este proceso y lo convierte en un flujo controlado por una API. La app movil permite al usuario interactuar con el sistema y el backend asegura que los datos se validen antes de guardarse.

### 1.2 Objetivos

#### 1.2.1 Objetivos tecnicos

- Desarrollar una aplicacion movil multiplataforma con Flutter.
- Implementar un backend REST con Spring Boot.
- Usar MySQL como base de datos relacional.
- Conectar app y backend mediante HTTP y JSON.
- Validar reservas para evitar solapes.
- Generar y leer codigos QR.
- Registrar incidencias asociadas a pistas o reservas.
- Documentar endpoints mediante Swagger.
- Preparar configuracion local y Docker.

#### 1.2.2 Objetivos academicos

- Aplicar conocimientos de programacion, bases de datos y acceso a datos.
- Desarrollar interfaces moviles funcionales.
- Practicar pruebas, depuracion y control de versiones.
- Relacionar el proyecto con los resultados de aprendizaje de DAM.
- Elaborar una memoria tecnica defendible ante un jurado.

### 1.3 Estructura del documento

El documento se organiza en siete partes. La primera introduce el proyecto. La segunda explica metodologia, planificacion y costes. La tercera analiza el contexto y las tecnologias. La cuarta presenta requisitos, arquitectura y modelo de datos. La quinta describe la implementacion y validacion. La sexta contiene manuales de instalacion y uso. La septima recoge conclusiones y trabajo futuro. Finalmente se incluyen anexos, preguntas de defensa y bibliografia.

# II. Metodologia

## 2. Planificacion

### 2.1 Metodologia de desarrollo

El proyecto se ha desarrollado de forma incremental. Primero se definio el problema y el alcance. Despues se preparo el backend, la base de datos y la app movil. Posteriormente se conectaron ambas partes mediante HTTP y se realizaron pruebas de reserva, QR e incidencias.

La metodologia seguida combina analisis, diseno, implementacion, validacion y documentacion. Cada funcionalidad se ha construido de forma progresiva para poder probarla antes de continuar con la siguiente.

### 2.2 Resumen temporal del proyecto

| Fase | Actividades principales | Evidencias |
|---|---|---|
| Analisis | Necesidades, usuarios, alcance y requisitos | Memoria y requisitos |
| Diseno | Arquitectura, entidades, pantallas y endpoints | Diagramas y estructura |
| Backend | Controladores, entidades, repositorios y servicios | Codigo en `backend/` |
| Base de datos | Tablas, relaciones, SQL y JPA | `sql/` y modelos JPA |
| Movil | Pantallas, navegacion, QR y escaner | Codigo en `mobile/` |
| Integracion | Conexion Flutter-Spring Boot | `ApiService` y endpoints |
| Validacion | Pruebas funcionales y depuracion | Swagger, consola y checklist |
| Documentacion | Memoria, anexos y guia de defensa | `docs/` |

### 2.3 Informe de tareas

| Tarea | Descripcion | Resultado |
|---|---|---|
| T01 | Configuracion inicial del backend | Proyecto Spring Boot operativo |
| T02 | Configuracion de dependencias | Maven, JPA, Security, Swagger |
| T03 | Modelo de usuarios y pistas | Entidades y repositorios |
| T04 | Reservas y control de disponibilidad | Validacion de solapes |
| T05 | App movil y navegacion | Pantallas principales |
| T06 | Conexion HTTP | Flutter conectado a API |
| T07 | QR y escaner | Acceso identificable por token |
| T08 | Incidencias | Registro y cambio de estado |
| T09 | Pruebas | Verificacion funcional |
| T10 | Documentacion | Memoria y defensa |

## 3. Estimacion de costes

### 3.1 Costes de personal

| Perfil | Horas estimadas | Coste/hora estimado | Coste |
|---|---:|---:|---:|
| Analista/desarrollador junior | 120 | 12 EUR | 1.440 EUR |
| Tester/documentador | 30 | 10 EUR | 300 EUR |
| Total | 150 |  | 1.740 EUR |

### 3.2 Costes materiales

#### 3.2.1 Hardware

| Recurso | Coste estimado |
|---|---:|
| Ordenador de desarrollo | 0 EUR, equipo propio |
| Dispositivo/emulador Android | 0 EUR, entorno local |
| Conexion a internet | 0 EUR, uso academico |

#### 3.2.2 Software

| Software | Licencia / coste |
|---|---|
| Java | Gratuito |
| Spring Boot | Gratuito |
| Flutter | Gratuito |
| MySQL | Gratuito |
| Docker | Gratuito para uso academico/local |
| Git/GitHub | Gratuito |
| Swagger/OpenAPI | Gratuito |

### 3.3 Costes indirectos

Los costes indirectos incluyen electricidad, conexion a internet, tiempo de configuracion del entorno y mantenimiento del equipo. Para un prototipo academico se consideran asumidos dentro del entorno formativo.

### 3.4 Resumen de costes del proyecto

| Concepto | Coste |
|---|---:|
| Personal estimado | 1.740 EUR |
| Hardware adicional | 0 EUR |
| Software adicional | 0 EUR |
| Costes indirectos estimados | 50 EUR |
| Total estimado | 1.790 EUR |

# III. Analisis

## 4. Estado del arte

### 4.1 Gestion de reservas deportivas

Las reservas deportivas pueden gestionarse manualmente, mediante llamadas, hojas de calculo o aplicaciones especificas. Las soluciones manuales son sencillas, pero tienen problemas de trazabilidad, disponibilidad en tiempo real y control de incidencias.

SportAccess se situa como una solucion academica que centraliza la reserva y permite comprobar disponibilidad desde una app movil.

### 4.2 Aplicaciones moviles de gestion

Las aplicaciones moviles ofrecen acceso rapido al usuario final. En este proyecto se elige Flutter porque permite construir una app con multiples pantallas, navegacion, calendario, QR y escaner usando una sola base de codigo.

### 4.3 APIs REST y arquitectura cliente-servidor

Una API REST permite que el cliente movil se comunique con el servidor mediante HTTP. La app no accede directamente a MySQL, sino que envia peticiones al backend. Esto mejora seguridad, mantenibilidad y separacion de responsabilidades.

### 4.4 Comparativa de soluciones

| Opcion | Ventajas | Inconvenientes |
|---|---|---|
| Gestion manual | Simple y barata | Errores, solapes, poca trazabilidad |
| Hoja de calculo | Facil de editar | Sin validacion fuerte ni app movil |
| App sin backend | Rapida para prototipo | Datos poco centralizados |
| App + API + BD | Escalable y mantenible | Requiere mas desarrollo |

## 5. Estudio tecnologico

### 5.1 Flutter

Flutter se usa para construir la app movil. Permite crear interfaces con widgets y ofrece buen rendimiento. En SportAccess se usa para login, registro, listado de pistas, reservas, QR, escaner e historial.

### 5.2 Spring Boot

Spring Boot se usa para construir el backend REST. Permite crear controladores, servicios, repositorios y configuraciones de seguridad. Tambien facilita documentar la API con Swagger.

### 5.3 MySQL

MySQL es la base de datos usada. Es relacional y SQL. Almacena usuarios, pistas, centros deportivos, reservas, pagos e incidencias. Se conecta con el backend mediante Spring Data JPA e Hibernate.

### 5.4 Firebase, Swagger y Docker

Firebase queda preparado para autenticacion mediante tokens. Swagger permite probar y documentar endpoints. Docker Compose permite levantar backend y MySQL en un entorno controlado.

# IV. Diseno

## 6. Requisitos

### 6.1 Requisitos funcionales

| Codigo | Requisito |
|---|---|
| RF01 | Registrar usuarios |
| RF02 | Iniciar sesion |
| RF03 | Consultar pistas |
| RF04 | Seleccionar fecha y horario |
| RF05 | Crear reserva |
| RF06 | Evitar reservas solapadas |
| RF07 | Generar QR |
| RF08 | Escanear QR |
| RF09 | Consultar historial |
| RF10 | Registrar incidencias |
| RF11 | Cambiar estado de incidencia |

### 6.2 Requisitos no funcionales

| Codigo | Requisito |
|---|---|
| RNF01 | Separacion por capas |
| RNF02 | Persistencia en base de datos |
| RNF03 | Comunicacion mediante API REST |
| RNF04 | Configuracion sensible fuera del repositorio |
| RNF05 | Documentacion tecnica suficiente |
| RNF06 | Posibilidad de ejecucion local |
| RNF07 | Codigo organizado para mantenimiento |

### 6.3 Casos de uso

| Caso de uso | Actor | Descripcion |
|---|---|---|
| Registrarse | Usuario | Crea una cuenta en el sistema |
| Iniciar sesion | Usuario | Accede a la aplicacion |
| Consultar pistas | Usuario | Ve las pistas disponibles |
| Crear reserva | Usuario | Reserva una pista en fecha y hora |
| Validar QR | Responsable | Escanea el QR de una reserva |
| Registrar incidencia | Usuario | Comunica un problema |
| Revisar incidencias | Administrador | Consulta o cambia estados |

## 7. Arquitectura

### 7.1 Arquitectura de la solucion

```text
Usuario -> App Flutter -> ApiService -> API REST Spring Boot -> JPA/Hibernate -> MySQL
```

La app movil actua como cliente. El backend centraliza la logica. La base de datos almacena la informacion persistente.

### 7.2 Arquitectura del backend

```text
backend/src/main/java/com/sportaccess/backend/
|-- config/
|-- controller/
|-- dto/
|-- exception/
|-- model/
|-- repository/
|-- security/
|-- service/
```

### 7.3 Arquitectura de la app movil

```text
mobile/lib/
|-- main.dart
|-- models/
|-- services/
|-- screens/
```

### 7.4 Modelo de datos

| Entidad | Finalidad |
|---|---|
| User | Usuarios |
| SportsCenter | Centros deportivos |
| Court | Pistas |
| Reservation | Reservas principales |
| Booking | Modelo adicional de reserva |
| Payment | Pagos |
| Incident | Incidencias |

# V. Implementacion

## 8. Implementacion de SportAccess

### 8.1 Stack tecnologico

| Capa | Tecnologia |
|---|---|
| Movil | Flutter, Dart |
| HTTP | Dio / http |
| Backend | Java, Spring Boot |
| Persistencia | Spring Data JPA, Hibernate |
| Base de datos | MySQL |
| Seguridad | Spring Security, Firebase Admin SDK |
| API Docs | Swagger / OpenAPI |
| Despliegue local | Docker Compose |

### 8.2 Backend

El backend expone endpoints REST para usuarios, pistas, centros, reservas, bookings e incidencias. Los controladores reciben peticiones, los repositorios acceden a datos y los modelos representan tablas de base de datos.

Endpoints principales:

| Metodo | Ruta | Uso |
|---|---|---|
| GET | `/api/courts` | Listar pistas |
| POST | `/api/users` | Crear usuario |
| POST | `/api/users/register` | Registrar/sincronizar usuario |
| GET | `/api/reservations` | Listar reservas |
| POST | `/api/reservations` | Crear reserva |
| PUT | `/api/reservations/{id}/cancel` | Cancelar reserva |
| POST | `/api/incidents` | Crear incidencia |
| GET | `/api/incidents` | Listar incidencias |

### 8.3 Aplicacion movil

La app movil contiene pantallas para login, registro, inicio, reservas, pago, QR, escaner e historial. La clase `ApiService` centraliza la comunicacion con el backend.

Pantallas principales:

| Pantalla | Funcion |
|---|---|
| Login | Acceso de usuario |
| Registro | Alta de usuario |
| Home | Listado de pistas |
| Booking | Seleccion de fecha/hora |
| Payment | Confirmacion |
| QR | Codigo de reserva |
| Scanner | Lectura de QR |
| History | Historial |

### 8.4 Base de datos

La base de datos es MySQL, de tipo relacional. El acceso se realiza mediante JPA. Las clases anotadas con `@Entity` se corresponden con tablas. Las relaciones se representan mediante anotaciones como `@ManyToOne` y `@OneToMany`.

### 8.5 Conexion front-back

Flutter se conecta al backend mediante HTTP. En Android Emulator se usa:

```text
http://10.0.2.2:8080/api
```

Ejemplo de flujo para listar pistas:

```text
Flutter -> GET /api/courts -> Spring Boot -> MySQL -> JSON -> Flutter
```

Ejemplo de flujo para crear reserva:

```text
Flutter -> POST /api/reservations -> Validacion de solape -> Guardado en MySQL -> Respuesta JSON
```

### 8.6 Seguridad

La seguridad se basa en Spring Security y configuracion preparada para Firebase. Las credenciales sensibles se excluyen del repositorio. El backend valida la existencia de usuario, pista y reserva antes de guardar informacion.

## 9. Validacion

### 9.1 Pruebas funcionales

| Prueba | Resultado esperado |
|---|---|
| Arrancar backend | API disponible |
| Abrir Swagger | Endpoints visibles |
| Listar pistas | Respuesta JSON |
| Crear usuario | Usuario guardado |
| Crear reserva valida | Reserva confirmada |
| Crear reserva solapada | Error 409 |
| Mostrar QR | QR visible |
| Escanear QR | Reserva localizada |
| Crear incidencia | Incidencia registrada |

### 9.2 Pruebas de API

Swagger permite probar la API desde el navegador. Es una evidencia importante para la defensa porque muestra los endpoints reales y sus respuestas.

### 9.3 Pruebas de app movil

Se prueban pantallas, navegacion, calendario, seleccion de horario, confirmacion, QR, escaner e historial.

### 9.4 Resultados de validacion

El sistema permite completar el flujo principal de reserva. La validacion de solapes se realiza en backend, lo que evita depender solamente de la interfaz movil.

# VI. Manuales

## 10. Manual de uso

### 10.1 Situacion inicial

Para probar el sistema se necesita tener backend, base de datos y app movil preparados. El backend escucha en el puerto 8080 y la app consume la API desde el emulador Android.

### 10.2 Instalacion del backend

```bash
cd backend
mvn spring-boot:run
```

Swagger:

```text
http://localhost:8080/swagger-ui.html
```

### 10.3 Instalacion de la app movil

```bash
cd mobile
flutter pub get
flutter run
```

### 10.4 Uso de la aplicacion

1. Abrir la app.
2. Registrarse o iniciar sesion.
3. Ver pistas.
4. Elegir una pista.
5. Seleccionar fecha y horario.
6. Confirmar reserva.
7. Ver QR.
8. Consultar historial.
9. Registrar incidencia si procede.

### 10.5 Prueba del sistema

Una prueba completa consiste en crear una reserva, intentar crear otra en el mismo horario para comprobar el error `409`, generar el QR y validarlo con el escaner.

# VII. Conclusiones

## 11. Conclusiones

### 11.1 Evaluacion final del proyecto

SportAccess cumple el objetivo de integrar una aplicacion movil, un backend REST y una base de datos relacional. El proyecto aplica competencias de DAM en programacion, bases de datos, acceso a datos, interfaces, aplicaciones moviles, seguridad, pruebas y documentacion.

La separacion por capas permite explicar claramente cada parte ante el jurado y facilita el mantenimiento futuro.

### 11.2 Trabajo futuro

- Unificar `Reservation` y `Booking`.
- Completar autenticacion real con Firebase.
- Crear panel administrador.
- Integrar pagos reales.
- Anadir notificaciones push.
- Implementar mas pruebas automatizadas.
- Desplegar backend en produccion.
- Publicar app en Android.

# Anexos

## A. Relacion con resultados de aprendizaje DAM

| Area | Evidencia en SportAccess |
|---|---|
| Sistemas Informaticos RA7 | Documentacion, herramientas, configuracion |
| Lenguajes de Marcas RA6 | JSON, XML, YAML/KTS, Markdown |
| Bases de Datos RA5 | MySQL, SQL, relaciones, entidades |
| Programacion RA3 | Java, Dart, controladores, pantallas |
| Entornos de Desarrollo RA3 | Git, IDE, Swagger, pruebas |
| Acceso a Datos RA6 | JPA, repositorios, consultas |
| Desarrollo de Interfaces RA8 | Pantallas Flutter |
| Multimedia y Moviles RA3 | QR, escaner, app movil |
| Seguridad RA5 | Spring Security, Firebase, CORS |
| Gestion Empresarial RA1 | Reservas, usuarios, incidencias, pagos |

## B. Preguntas frecuentes de defensa

| Pregunta | Respuesta breve |
|---|---|
| Que es SportAccess | Una app para gestionar reservas deportivas |
| Que tecnologia usa la app | Flutter y Dart |
| Que tecnologia usa el backend | Spring Boot y Java |
| Que base de datos usa | MySQL |
| Que tipo de BD es | Relacional SQL |
| Como se conectan front y back | API REST con JSON |
| Por que no conectar Flutter a MySQL | Por seguridad y mantenibilidad |
| Como se evitan solapes | Consulta en backend antes de guardar |
| Que es Swagger | Herramienta para probar/documentar la API |
| Que mejoras harias | Firebase completo, pagos reales, admin, despliegue |

## C. Estructura de directorios

```text
ProyectoFinal_PoliRect/
|-- backend/
|-- mobile/
|-- docs/
|-- sql/
|-- Diagramas/
|-- README.md
|-- .gitignore
```

## D. Capturas recomendadas

1. Arbol del proyecto.
2. Estructura del backend.
3. Estructura de `mobile/lib`.
4. Swagger.
5. Endpoint de pistas.
6. Creacion de reserva.
7. Error de solape.
8. Base de datos MySQL.
9. Login.
10. Home con pistas.
11. Reserva.
12. QR.
13. Escaner.
14. Historial.
15. Incidencias.

# Bibliografia

- Documentacion oficial de Spring Boot: https://spring.io/projects/spring-boot
- Documentacion oficial de Flutter: https://docs.flutter.dev/
- Documentacion oficial de MySQL: https://dev.mysql.com/doc/
- Documentacion oficial de Firebase: https://firebase.google.com/docs
- Documentacion oficial de Docker: https://docs.docker.com/
- Documentacion oficial de SpringDoc OpenAPI: https://springdoc.org/
- Repositorio del proyecto SportAccess: https://github.com/BlueMichelle/SportAccess
- Real Decreto 450/2010, de 16 de abril, por el que se establece el titulo de Tecnico Superior en Desarrollo de Aplicaciones Multiplataforma.
