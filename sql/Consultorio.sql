CREATE DATABASE Consultorio
GO
USE Consultorio
GO
-- dar de alta a admins, dentistas, secretarias
CREATE TABLE Usuarios(
    usuario CHAR(12) PRIMARY KEY NOT NULL,
    password char(32),
    nombre VARCHAR(30),
    APaterno VARCHAR(30),
    AMaterno VARCHAR(30),
    tipo int CHECK(tipo >=1 AND tipo <=3) DEFAULT 3, 
    estatus CHAR(1) CHECK(estatus IN ('A','D')) DEFAULT 'A' -- ACTIVO = A | INACTIVO = D
)
GO

CREATE TABLE Pacientes (

)
GO
CREATE TABLE Dentistas(

)
GO
CREATE TABLE Secretarias(

)
GO
--historiales
CREATE TABLE Citas (

)
GO
CREATE TABLE Historial(

)
GO

--inserciones previas (usuarios) 1 admin, 2 dentistas, 2 secretarias

--inserciones previas (Pacientes)

--inserciones previas (Dentistas)

--PARA ADMIN
--procedure paciente nuevo, nuevo medico ... paciente antiguo medico  de preferencia (el mas frecuente)

--procedure nuevo dentista, nueva secretaria + usuario

--procedure dar de baja paciente (cambiar a INACTIVO) con UPDATE

--procedure dar de baja a dentista (cambiar a INACTIVO) con UPDATE

--procedure dar de baja a secretaria (cambiar a INACTIVO con UPDATE)


--PARA SECRETARIAS Y ADMIN

--procedure agendar citas (verificar si fecha-hora y medico esta disponible(logica de paciente antiguo o nuevo))

--procedure cancelar citas

--procedure reagendar citas

--procedure historial de citas (general y dentista especifico)


--PARA DENTISTAS

-- procedure Ver citas

-- procedure Historico de citas

-- procedure atender cita x paciente (para ambos)