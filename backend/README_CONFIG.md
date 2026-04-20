# Guía de Configuración Local y Resoluciones de Compatibilidad

Este documento resume los cambios realizados en el proyecto y los pasos necesarios para arrancar el backend en local sin problemas, especialmente en entornos más recientes (como Java 25 y MySQL 9.x).

## Cambios realizados

### 1. Actualización en `pom.xml` (Compatibilidad de Versiones Java)
El proyecto inicialmente estaba configurado para **Java 17**, pero generaba un error `java.lang.ExceptionInInitializerError: com.sun.tools.javac.code.TypeTag` al intentar compilar en un entorno local con **Java 25**.
Para solucionarlo, se actualizaron las dependencias y la configuración de los plugins:
*   Se actualizó la propiedad `<java.version>` a `21` y `<lombok.version>` a `1.18.38` (compatible con versiones recientes de Java).
*   Se subió la versión padre de Spring Boot a `3.4.4`.
*   Se especificó la clase principal (`<mainClass>com.sportaccess.backend.BackendApplication</mainClass>`) en el `spring-boot-maven-plugin` para que el compilador sepa de dónde arrancar.

### 2. Actualización de Base de Datos (`application.properties`)
El servidor fue interrumpido porque recibía una excepción de **"Access denied"** tras un arranque exitoso de Hibernate debido a credenciales inválidas y porque se requirió compatibilidad extra para la base de datos:
*   **Contraseña de MySQL:** Actualizada a la contraseña correcta local.
*   **Dialecto de Hibernate:** Se cambió `org.hibernate.dialect.MySQL8Dialect` por el más genérico `org.hibernate.dialect.MySQLDialect` para asegurar la retrocompatibilidad con las distintas versiones (como MySQL 9.5).

### 3. Arranque del Servidor (Backend)
Debido a que el comando de Maven original no estaba en el entorno configurado, **descargamos directamente los binarios de Apache Maven 3.9.15** y compilamos/arrancamos la aplicación desde allí directamente.

---

## Cómo levantar este proyecto en adelante

Una vez con los cambios subidos:

1.  Abre el servicio **MySQL** (Puerto 3306) en background.
2.  No utilices la terminal directamente si te da error el comando "mvn". La forma más recomendable a partir de ahora es utilizar Visual Studio Code:
    *   Ir a `backend/src/main/java/com/sportaccess/backend/BackendApplication.java`.
    *   Hacer clic en el pequeño botón de "Run" en la cabecera del método `main`.
    *   *Nota: VS Code utiliza su propio motor de Maven incluido en la extensión para saltarse el problema de la instalación global.*
3.  Ingresa a [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) para visualizar y testear la API integrada mediante Swagger UI sin necesidad de Postman.
