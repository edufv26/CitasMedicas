# Sistema de Gestión de Consultorio Dental (Java Web / MVC + SQL Server)

Sistema web integral para la gestión administrativa y médica de un consultorio dental. Desarrollado bajo el patrón de arquitectura **MVC (Model-View-Controller)** en Java Web (Servlets/JDBC) y respaldado por una base de datos relacional en **SQL Server** con procedimientos almacenados (Stored Procedures).

---

## 📌 Tabla de Contenidos
- [Características Principales](#-características-principales)
- [Arquitectura y Roles de Usuario](#-arquitectura-y-roles-de-usuario)
- [Reglas de Negocio Implementadas](#-reglas-de-negocio-implementadas)
- [Estructura de la Base de Datos](#-estructura-de-la-base-de-datos)
- [Procedimientos Almacenados (Stored Procedures)](#-procedimientos-almacenados-stored-procedures)
- [Tecnologías Utilizadas](#-tecnologías-utilizadas)
- [Instalación y Configuración](#-instalación-y-configuración)

---

## 🚀 Características Principales

* **Autenticación y Seguridad:** Control de acceso basado en roles con tres niveles de privilegio (Administrador, Dentista, Secretaria).
* **Asignación Inteligente de Pacientes:** Clasificación de pacientes (nuevos vs. frecuentes) con asignación automatizada o por preferencia.
* **Gestión Flexible de Citas:** Agendamiento con validación de disponibilidad en tiempo real, reagendamiento y cancelación.
* **Bajas Lógicas:** Mantenimiento de integridad referencial mediante estatus activo/inactivo (`'A'` / `'D'`).
* **Historial Clínico Unificado:** Consulta de historial general para secretaría/administración o filtrado por médico/paciente para atención dental.
* **Generación de Reportes:** Módulo preparado para exportación a PDF y visualización de datos estadísticos.

---

## 👥 Arquitectura y Roles de Usuario

| Rol | Tipo | Descripción y Permisos |
|---|:---:|---|
| **Administrador** | `1` | Gestión total de usuarios (Alta de Admins, Dentistas y Secretarias), gestión de pacientes, seguimiento general de citas y reportes del sistema. |
| **Dentista** | `2` | Consulta de agenda propia del día/fecha seleccionada, atención de citas asignadas con registro de diagnóstico e historial clínico. |
| **Secretaria** | `3` | Alta de pacientes, agendamiento, reagendamiento y cancelación de citas, consulta de disponibilidad de médicos e historial general. |

---

## ⚙️ Reglas de Negocio Implementadas

1. **Pacientes Nuevos vs. Frecuentes:**
   * **Paciente Nuevo:** Al registrarse por primera vez sin médico asignado (`id_dentista_preferencia IS NULL`), el sistema le asigna un dentista activo al azar mediante la función `ORDER BY NEWID()` en SQL.
   * **Paciente Frecuente:** Si ya cuenta con un dentista asignado, el sistema respeta obligatoriamente su médico de preferencia al agendar.
2. **Disponibilidad de Horarios:**
   * No se permite agendar dos citas para el mismo dentista en el mismo bloque de fecha y hora. Se valida contra citas activas (excluyendo estado `'CANCELADA'`).
3. **Persistencia e Integridad:**
   * Ningún usuario o paciente se elimina físicamente de la base de datos (`DELETE`). Se implementa baja lógica actualizando el atributo `estatus = 'D'`.

---

## 🗄️ Estructura de la Base de Datos

La base de datos `Consultorio` cuenta con las siguientes tablas principales:

* `Usuarios`: Tabla maestra de credenciales y datos personales (`tipo`: 1 Admin, 2 Dentista, 3 Secretaria; `estatus`: 'A'/'D').
* `Dentistas`: Extensión de usuarios tipo 2 con información de especialidad.
* `Secretarias`: Extensión de usuarios tipo 3.
* `Pacientes`: Datos de contacto y llave foránea opcional a `Dentistas` (`id_dentista_preferencia`).
* `Citas`: Registro de agendas (Paciente, Dentista, Fecha, Hora y Estado: PROGRAMADA, CANCELADA, REAGENDADA, ATENDIDA).
* `Historial`: Registros médicos ligados a las citas atendidas con diagnóstico y timestamp de atención.

---

## 🛠️ Procedimientos Almacenados (Stored Procedures)

### Módulo de Personal y Usuarios
* `sp_RegistrarPersonal`: Da de alta Admins, Dentistas o Secretarias creando el registro general en `Usuarios` y su correspondiente detalle si aplica.
* `sp_BajaDentista` / `sp_BajaSecretaria`: Ejecutan la baja lógica cambiando el estatus a `'D'`.

### Módulo de Pacientes
* `sp_RegistrarPaciente`: Registra al paciente. Si es nuevo, ejecuta la selección aleatoria con `NEWID()` entre los dentistas activos y lo vincula como preferencia inicial.
* `sp_BajaPaciente`: Ejecuta la baja lógica del paciente.

### Módulo de Citas y Atención
* `sp_AgendarCita`: Valida la preferencia del paciente o asignación aleatoria, comprueba choque de horarios y agenda la cita.
* `sp_CancelarCita` / `sp_ReagendarCita`: Gestión del estado de la cita con re-validación de choque de agenda.
* `sp_VerCitasDentista`: Muestra la agenda de un médico específico filtrada por fecha.
* `sp_AtenderCita`: Registra el diagnóstico en `Historial` y actualiza la cita a estado `'ATENDIDA'`.

### Módulo de Reportes e Historial
* `sp_FiltrarHistorial`: Procedimiento polimórfico flexible. Si los parámetros (`@id_dentista`, `@id_paciente`) se envían como `NULL`, devuelve el **historial general** del consultorio; si recibe un ID, devuelve el **historial específico**.

---

## 💻 Tecnologías Utilizadas

* **Backend DB:** SQL Server (T-SQL, Stored Procedures, Triggers/Indexes).
* **Capa Web (Java):** Java EE, Servlets, JSP, JDBC, JSTL.
* **Patrón de Diseño:** MVC (Model-View-Controller) + DAO (Data Access Object).
* **Frontend UI:** HTML5, CSS3, Bootstrap 5, SweetAlert2 (Notificaciones avanzadas).
* **Librerías de Exportación:** itextpdf (para generación de reportes PDF), jxl (exportacion de xml), sqljdbc4 (conexion de java a sql server), jfrechart & jcommon (creacion de graficas de barras y pie).

---

## 📋 Instalación y Configuración

1. **Base de Datos:**
   * Abrir SQL Server Management Studio (SSMS).
   * Ejecutar el script `Consultorio.sql` para crear la base de datos, tablas, datos iniciales (semilla) y Stored Procedures.
2. **Conexión JDBC:**
   * Configurar las credenciales de conexión en la clase `Conexion.java` o `DBConnection.java` en la capa Model (bean) del proyecto Java.
   * Asegurar que el driver JDBC de Microsoft SQL Server (`mssql-jdbc`) esté presente en las dependencias del proyecto.
3. **Despliegue:**
   * Importar el proyecto en Apache NetBeans / Eclipse / IntelliJ.
   * Desplegar en un servidor de aplicaciones compatible (Apache Tomcat 9.0+ o GlassFish).
```
eof

Este README es temporal y se cambiara conforme a la rubrica y con el paso del proyecto...
