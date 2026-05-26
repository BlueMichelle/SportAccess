# RAS del TFG - SportAccess

Este documento relaciona SportAccess con los resultados de aprendizaje del modulo `0492. Proyecto de Desarrollo de Aplicaciones Multiplataforma`, correspondiente al CFGS de Desarrollo de Aplicaciones Multiplataforma.

Fuentes de referencia:

- Real Decreto 450/2010, de 16 de abril: https://www.boe.es/eli/es/rd/2010/04/16/450
- Real Decreto 405/2023, de 29 de mayo: https://www.boe.es/eli/es/rd/2023/05/29/405
- Programacion del modulo de Proyecto DAM en la Region de Murcia: modulo de 30 horas y 5 ECTS.

## RA1 - Identificacion de necesidades del sector productivo

**Resultado de aprendizaje:** identifica necesidades del sector productivo, relacionandolas con proyectos tipo que puedan satisfacerlas.

| Criterio | Aplicacion en SportAccess | Evidencia prevista |
|---|---|---|
| Clasificacion de empresas del sector | Se analiza el sector de instalaciones deportivas, centros educativos, gimnasios, clubes y entidades con reserva de espacios. | Apartado de contexto y justificacion |
| Caracterizacion de empresas tipo | Se describen roles: usuarios, administradores, responsables de instalaciones y personal de mantenimiento. | Analisis de usuarios y actores |
| Necesidades demandadas | Digitalizacion de reservas, control de disponibilidad, acceso por QR, seguimiento de incidencias. | Requisitos funcionales |
| Oportunidades de negocio | Plataforma reutilizable para centros deportivos o educativos con instalaciones compartidas. | Estudio de viabilidad |
| Tipo de proyecto requerido | Aplicacion multiplataforma con backend REST, base de datos y cliente movil. | Arquitectura tecnica |
| Caracteristicas especificas | Reservas por pista y franja horaria, gestion de usuarios, incidencias y validacion de accesos. | Modelo de datos y endpoints |
| Obligaciones y condiciones | Proteccion de datos, seguridad de acceso, trazabilidad de operaciones y prevencion de riesgos digitales. | Apartado legal y seguridad |
| Ayudas o incorporacion tecnologica | Uso de tecnologias actuales: Flutter, Spring Boot, Firebase, MySQL, Docker y Swagger. | Stack tecnologico |
| Guion de trabajo | Planificacion por fases: analisis, diseño, implementacion, validacion y entrega. | Cronograma y tareas |

## RA2 - Diseño del proyecto

**Resultado de aprendizaje:** diseña proyectos relacionados con las competencias expresadas en el titulo, incluyendo y desarrollando las fases que lo componen.

| Criterio | Aplicacion en SportAccess | Evidencia prevista |
|---|---|---|
| Recopilacion de informacion | Se documentan necesidades, tecnologias, arquitectura y requisitos. | Memoria y bibliografia |
| Viabilidad tecnica | El proyecto usa tecnologias disponibles y compatibles con el ciclo DAM. | Estudio de viabilidad |
| Fases del proyecto | Se separan analisis, diseño, backend, movil, pruebas y documentacion. | Planificacion |
| Objetivos y alcance | Se define una plataforma funcional de reservas e incidencias. | Objetivos generales y especificos |
| Recursos materiales y personales | Equipo de desarrollo, ordenador, Android Studio/IDE, JDK, Flutter, MySQL, Docker. | Recursos del proyecto |
| Presupuesto | Coste principalmente formativo, con herramientas gratuitas o de uso academico. | Presupuesto |
| Financiacion | No se requiere financiacion externa para prototipo academico; posible coste futuro de hosting. | Viabilidad economica |
| Documentacion de diseño | Diagramas, arquitectura, endpoints, modelo de datos, README y anexos. | `docs/`, `README.md`, Swagger |
| Control de calidad | Revisiones, pruebas manuales, validacion de solapes, control de errores y limpieza del repositorio. | Checklist de pruebas |

## RA3 - Planificacion de la ejecucion

**Resultado de aprendizaje:** planifica la ejecucion del proyecto, determinando el plan de intervencion y la documentacion asociada.

| Criterio | Aplicacion en SportAccess | Evidencia prevista |
|---|---|---|
| Secuenciacion de tareas | Primero backend y modelo de datos, despues integracion movil y validacion. | Cronograma |
| Recursos y logistica | Repositorio GitHub, ramas por funcionalidad, entornos local y Docker. | Git, README, Docker Compose |
| Permisos y autorizaciones | Uso de APIs, Firebase, datos de prueba y credenciales no incluidas en el repo. | `.env.example`, documentacion config |
| Procedimientos de ejecucion | Instalacion, arranque de backend, ejecucion de app movil y pruebas de endpoints. | Guia de ejecucion |
| Riesgos de ejecucion | Conflictos de ramas, dependencias locales, solapes de reservas, configuracion Firebase. | Matriz de riesgos |
| Asignacion de recursos y tiempos | Reparto por areas: backend, movil, base de datos, QA/DevOps y documentacion. | Plan de trabajo |
| Valoracion economica | Herramientas libres, coste de desarrollo academico y posible despliegue futuro. | Presupuesto |
| Documentacion de ejecucion | Documentos de configuracion, memoria tecnica, RAS y limpieza del backend. | `docs/SPRING_BOOT_CLEANUP.md` y nuevos anexos |

## RA4 - Seguimiento y control del proyecto

**Resultado de aprendizaje:** define los procedimientos para el seguimiento y control en la ejecucion del proyecto, justificando la seleccion de variables e instrumentos empleados.

| Criterio | Aplicacion en SportAccess | Evidencia prevista |
|---|---|---|
| Evaluacion de actividades | Revision por funcionalidad: usuarios, reservas, incidencias, QR, API y app. | Checklist de validacion |
| Indicadores de calidad | Compilacion correcta, endpoints disponibles, no solapes, errores controlados, documentacion actualizada. | Informe de pruebas |
| Registro de incidencias | Incidencias del proyecto mediante GitHub issues o tabla de seguimiento. | Backlog o registro de incidencias |
| Solucion de incidencias | Priorizacion, correccion en rama, revision y cierre documentado. | Historial Git |
| Gestion de cambios | Cambios registrados en commits, ramas y documentos de decision. | Git log y changelog |
| Participacion de usuarios | Pruebas con usuarios o compañeros para reservar, cancelar, reportar incidencia y validar QR. | Encuesta o acta de pruebas |
| Cumplimiento de condiciones | Comparacion entre requisitos iniciales, alcance final y entregables del TFG. | Matriz de trazabilidad |

## Trazabilidad funcional inicial

| Funcionalidad | RA relacionado | Evidencia tecnica |
|---|---|---|
| Registro/login de usuario | RA1, RA2, RA3 | `mobile/lib/screens/login_screen.dart`, `register_screen.dart`, `backend/.../UserController.java` |
| Consulta de pistas | RA1, RA2 | `CourtController.java`, `ApiService.getCourts()` |
| Creacion de reservas | RA1, RA2, RA3 | `ReservationController.java`, `BookingController.java`, `booking_screen.dart` |
| Control de disponibilidad | RA2, RA4 | `ReservationRepository.existeSolape(...)`, validacion de conflicto HTTP 409 |
| Historial de usuario | RA2, RA4 | `history_screen.dart`, endpoints de reservas |
| QR de acceso | RA1, RA2, RA4 | `qr_screen.dart`, `scanner_screen.dart`, `qrToken` |
| Incidencias | RA1, RA2, RA4 | `IncidentController.java`, `Incident.java`, app movil |
| Configuracion y despliegue | RA3, RA4 | `docker-compose.yml`, `Dockerfile`, `README_CONFIG.md` |

## Evidencias pendientes

- Capturas de pantallas de Flutter.
- Capturas de Swagger UI.
- Diagrama entidad-relacion final.
- Tabla de endpoints finales con metodo, ruta, entrada, salida y permisos.
- Checklist de pruebas manuales.
- Registro de incidencias reales del proyecto.
- Presupuesto y valoracion economica final.
