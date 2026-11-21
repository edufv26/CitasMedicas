USE Consultorio;
GO

BEGIN TRANSACTION;

-- Deshabilitar FKs temporalmente para renumerar sin conflictos
ALTER TABLE dbo.Citas NOCHECK CONSTRAINT ALL;
ALTER TABLE dbo.Pacientes NOCHECK CONSTRAINT ALL;

-- =========================================================
-- 1. REORDENAR DENTISTAS (1..N) Y ACTUALIZAR REFERENCIAS
-- =========================================================
DECLARE @MapaDentistas TABLE (
    id_viejo INT PRIMARY KEY,
    id_nuevo INT NOT NULL
);

INSERT INTO @MapaDentistas (id_viejo, id_nuevo)
SELECT
    id_dentista,
    ROW_NUMBER() OVER (ORDER BY id_dentista)
FROM dbo.Dentistas;

SELECT
    m.id_nuevo AS id_dentista,
    d.usuario,
    d.especialidad,
    d.cedula_profesional,
    d.turno,
    d.telefono,
    d.correo
INTO #DentistasTemp
FROM dbo.Dentistas d
INNER JOIN @MapaDentistas m ON d.id_dentista = m.id_viejo;

UPDATE c
SET c.id_dentista = m.id_nuevo
FROM dbo.Citas c
INNER JOIN @MapaDentistas m ON c.id_dentista = m.id_viejo;

UPDATE p
SET p.id_dentista_preferencia = m.id_nuevo
FROM dbo.Pacientes p
INNER JOIN @MapaDentistas m ON p.id_dentista_preferencia = m.id_viejo;

DELETE FROM dbo.Dentistas;

SET IDENTITY_INSERT dbo.Dentistas ON;

INSERT INTO dbo.Dentistas (
    id_dentista, usuario, especialidad, cedula_profesional, turno, telefono, correo
)
SELECT
    id_dentista, usuario, especialidad, cedula_profesional, turno, telefono, correo
FROM #DentistasTemp
ORDER BY id_dentista;

SET IDENTITY_INSERT dbo.Dentistas OFF;

DROP TABLE #DentistasTemp;

DECLARE @MaxDent INT = ISNULL((SELECT MAX(id_dentista) FROM dbo.Dentistas), 0);
DBCC CHECKIDENT ('dbo.Dentistas', RESEED, @MaxDent);

-- =========================================================
-- 2. REORDENAR PACIENTES (1..N) Y ACTUALIZAR CITAS
-- =========================================================
DECLARE @MapaPacientes TABLE (
    id_viejo INT PRIMARY KEY,
    id_nuevo INT NOT NULL
);

INSERT INTO @MapaPacientes (id_viejo, id_nuevo)
SELECT
    id_paciente,
    ROW_NUMBER() OVER (ORDER BY id_paciente)
FROM dbo.Pacientes;

SELECT
    m.id_nuevo AS id_paciente,
    p.nombre,
    p.APaterno,
    p.AMaterno,
    p.telefono,
    p.correo,
    p.direccion,
    p.id_dentista_preferencia,
    p.estatus
INTO #PacientesTemp
FROM dbo.Pacientes p
INNER JOIN @MapaPacientes m ON p.id_paciente = m.id_viejo;

UPDATE c
SET c.id_paciente = m.id_nuevo
FROM dbo.Citas c
INNER JOIN @MapaPacientes m ON c.id_paciente = m.id_viejo;

DELETE FROM dbo.Pacientes;

SET IDENTITY_INSERT dbo.Pacientes ON;

INSERT INTO dbo.Pacientes (
    id_paciente, nombre, APaterno, AMaterno, telefono, correo, direccion, id_dentista_preferencia, estatus
)
SELECT
    id_paciente, nombre, APaterno, AMaterno, telefono, correo, direccion, id_dentista_preferencia, estatus
FROM #PacientesTemp
ORDER BY id_paciente;

SET IDENTITY_INSERT dbo.Pacientes OFF;

DROP TABLE #PacientesTemp;

DECLARE @MaxPac INT = ISNULL((SELECT MAX(id_paciente) FROM dbo.Pacientes), 0);
DBCC CHECKIDENT ('dbo.Pacientes', RESEED, @MaxPac);

-- Volver a habilitar y validar todas las FKs
ALTER TABLE dbo.Citas WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE dbo.Pacientes WITH CHECK CHECK CONSTRAINT ALL;

COMMIT TRANSACTION;
GO

-- Verificación
SELECT id_dentista, usuario, especialidad FROM dbo.Dentistas ORDER BY id_dentista;
SELECT id_paciente, nombre, APaterno, id_dentista_preferencia FROM dbo.Pacientes ORDER BY id_paciente;
SELECT id_cita, id_paciente, id_dentista, fecha, hora, estado FROM dbo.Citas ORDER BY id_cita;
GO

USE Consultorio
SELECT name FROM sys.procedures WHERE is_ms_shipped = 0 ORDER BY name;

SELECT * FROM Pacientes