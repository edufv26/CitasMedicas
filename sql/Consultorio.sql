CREATE DATABASE Consultorio
GO
USE Consultorio
GO
-- =========================================================
-- 1. CREACIÓN DE TABLAS
-- =========================================================

-- Tabla unificada de Usuarios (Admin: 1, Dentistas: 2, Secretarias: 3)
CREATE TABLE Usuarios(
    usuario CHAR(12) PRIMARY KEY NOT NULL,
    password CHAR(32), -- Hash o texto plano para la práctica
    nombre VARCHAR(30),
    APaterno VARCHAR(30),
    AMaterno VARCHAR(30),
    tipo INT CHECK(tipo >= 1 AND tipo <= 3) DEFAULT 3,--1 = ADMIN, 2 = SECRETARIA, 3 = DENTISTA
    estatus CHAR(1) CHECK(estatus IN ('A','D')) DEFAULT 'A' -- A = Activo, D = Dado de baja (Inactivo)
);
GO
-- 2. Dentistas
CREATE TABLE Dentistas(
    id_dentista INT IDENTITY(1,1) PRIMARY KEY,
    usuario CHAR(12) NOT NULL,
    especialidad VARCHAR(50),
    CONSTRAINT FK_Dentista_Usuario FOREIGN KEY (usuario) REFERENCES Usuarios(usuario)
);
GO
-- 3. Secretarias
CREATE TABLE Secretarias(
    id_secretaria INT IDENTITY(1,1) PRIMARY KEY,
    usuario CHAR(12) NOT NULL,
    CONSTRAINT FK_Secretaria_Usuario FOREIGN KEY (usuario) REFERENCES Usuarios(usuario)
);
GO
-- 4. Pacientes (Con médico de preferencia)
CREATE TABLE Pacientes (
    id_paciente INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    APaterno VARCHAR(30) NOT NULL,
    AMaterno VARCHAR(30) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(50),
    id_dentista_preferencia INT NULL,
    estatus CHAR(1) CHECK(estatus IN ('A','D')) DEFAULT 'A',
    CONSTRAINT FK_Paciente_DentistaPref FOREIGN KEY (id_dentista_preferencia) REFERENCES Dentistas(id_dentista)
);
GO
-- 5. Citas
CREATE TABLE Citas (
    id_cita INT IDENTITY(1,1) PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_dentista INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(20) DEFAULT 'PROGRAMADA', -- PROGRAMADA, CANCELADA, REAGENDADA, ATENDIDA
    CONSTRAINT FK_Cita_Paciente FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    CONSTRAINT FK_Cita_Dentista FOREIGN KEY (id_dentista) REFERENCES Dentistas(id_dentista)
);
GO
-- 6. Historial (Simplificado con Fecha, Hora implícita por la cita, Paciente y Diagnóstico)
CREATE TABLE Historial (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    id_cita INT NOT NULL,
    diagnostico VARCHAR(MAX) NOT NULL, -- Aquí entra diagnóstico, notas y tratamiento/receta
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Historial_Cita FOREIGN KEY (id_cita) REFERENCES Citas(id_cita)
);
GO
--inserciones previas (usuarios) 1 admin, 2 dentistas, 2 secretarias
INSERT INTO Usuarios (usuario, password, nombre, APaterno, AMaterno, tipo, estatus) VALUES
('admin01', '26062004', 'Eduardo', 'Flores', 'Velazquez', 1, 'A'),
('dentista01', '1234', 'Laura', 'Martínez', 'Sánchez', 2, 'A'),
('dentista02', '3456', 'Roberto', 'López', 'Ramírez', 2, 'A'),
('sec01', '676767', 'Ana', 'Torres', 'Cruz', 3, 'A'),
('sec02', '676767', 'Sofía', 'Jiménez', 'Ruiz', 3, 'A');

--inserciones previas (Dentistas)
INSERT INTO Dentistas (usuario, especialidad) VALUES
('dentista01', 'Ortodoncia'),
('dentista02', 'Endodoncia');

-- inserciones previas (Secretarias)
-- Ligar Secretarias
INSERT INTO Secretarias (usuario) VALUES
('sec01'),
('sec02');

--inserciones previas (Pacientes)
-- Pacientes de prueba
INSERT INTO Pacientes (nombre, APaterno, AMaterno, telefono, correo, id_dentista_preferencia, estatus) VALUES
('Juan', 'Hernández', 'Pérez', '5512345678', 'juan@mail.com', NULL, 'A'), -- Paciente nuevo (sin preferencia)
('María', 'García', 'López', '5587654321', 'maria@mail.com', NULL, 'A');   -- Paciente antiguo (preferencia al dentista 1)
GO
--PARA ADMIN
--procedure paciente nuevo, nuevo medico ... paciente antiguo medico  de preferencia (el mas frecuente)
CREATE PROCEDURE sp_RegistrarPaciente
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30),
    @telefono VARCHAR(15),
    @correo VARCHAR(50),
    @id_dentista_preferencia INT = NULL -- Si viene NULL, el sistema asume que es paciente nuevo
AS
BEGIN
    DECLARE @id_dentista_final INT;
    
    SET @id_dentista_final = @id_dentista_preferencia;

    -- Si no mandaron preferencia (es paciente nuevo), le asignamos uno al azar de los dentistas activos
    IF @id_dentista_final IS NULL
    BEGIN
        SELECT TOP 1 @id_dentista_final = d.id_dentista 
        FROM Dentistas d
        INNER JOIN Usuarios u ON d.usuario = u.usuario
        WHERE u.estatus = 'A'
        ORDER BY NEWID(); -- Aquí hace la magia de asignarle un doctor al azar de los disponibles
    END

    -- Insertar al paciente ya con su médico asignado (ya sea el preferido o el que le tocó por el volado)
    INSERT INTO Pacientes (nombre, APaterno, AMaterno, telefono, correo, id_dentista_preferencia, estatus)
    VALUES (@nombre, @APaterno, @AMaterno, @telefono, @correo, @id_dentista_final, 'A');
END
GO
--procedure nuev@ admin, dentista, secretaria + usuario
-- SP: Registrar personal (Admin, Dentista o Secretaria + su usuario)
CREATE PROCEDURE sp_RegistrarPersonal
    @usuario CHAR(12),
    @password CHAR(32),
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30),
    @tipo INT, -- 1: Administrador, 2: Dentista, 3: Secretaria
    @especialidad VARCHAR(50) = NULL -- Solo aplica si es dentista
AS
BEGIN
    -- 1. Insertar el registro principal en la tabla de Usuarios (aplica para los tres roles)
    INSERT INTO Usuarios (usuario, password, nombre, APaterno, AMaterno, tipo, estatus)
    VALUES (@usuario, @password, @nombre, @APaterno, @AMaterno, @tipo, 'A');

    -- 2. Dependiendo del rol, insertar en su tabla correspondiente si la requiere
    IF @tipo = 2
    BEGIN
        INSERT INTO Dentistas (usuario, especialidad) VALUES (@usuario, @especialidad);
    END
    ELSE IF @tipo = 3
    BEGIN
        INSERT INTO Secretarias (usuario) VALUES (@usuario);
    END
    -- Si el tipo es 1 (Admin), no hace falta insertar en otra tabla 
    -- porque el administrador vive exclusivamente en la tabla Usuarios.
END
GO
--procedure dar de baja paciente (cambiar a INACTIVO) con UPDATE
-- SP: Dar de baja lógica a Paciente
CREATE PROCEDURE sp_BajaPaciente
    @id_paciente INT
AS
BEGIN
    UPDATE Pacientes SET estatus = 'D' WHERE id_paciente = @id_paciente;
END
GO

-- SP: Dar de baja lógica a Dentista
CREATE PROCEDURE sp_BajaDentista
    @id_dentista INT
AS
BEGIN
    UPDATE u SET u.estatus = 'D'
    FROM Usuarios u
    INNER JOIN Dentistas d ON u.usuario = d.usuario
    WHERE d.id_dentista = @id_dentista;
END
GO
--procedure dar de baja a dentista (cambiar a INACTIVO) con UPDATE
-- SP: Dar de baja lógica a Dentista
CREATE PROCEDURE sp_BajaDentista
    @id_dentista INT
AS
BEGIN
    UPDATE u SET u.estatus = 'D'
    FROM Usuarios u
    INNER JOIN Dentistas d ON u.usuario = d.usuario
    WHERE d.id_dentista = @id_dentista;
END
GO
--procedure dar de baja a secretaria (cambiar a INACTIVO con UPDATE)
-- SP: Dar de baja lógica a Secretaria
CREATE PROCEDURE sp_BajaSecretaria
    @id_secretaria INT
AS
BEGIN
    UPDATE u SET u.estatus = 'D'
    FROM Usuarios u
    INNER JOIN Secretarias s ON u.usuario = s.usuario
    WHERE s.id_secretaria = @id_secretaria;
END
GO

--PARA SECRETARIAS Y ADMIN

--procedure agendar citas (verificar si fecha-hora y medico esta disponible(logica de paciente antiguo o nuevo))
-- SP: Agendar cita (Verifica disponibilidad de fecha/hora/médico y maneja médico preferido o nuevo)
CREATE PROCEDURE sp_AgendarCita
    @id_paciente INT,
    @id_dentista_forzado INT = NULL, 
    @fecha DATE,
    @hora TIME
AS
BEGIN
    DECLARE @id_dentista_final INT;

    -- Si no se fuerza un médico, evaluamos si el paciente es antiguo y tiene preferencia
    IF @id_dentista_forzado IS NULL
    BEGIN
        SELECT @id_dentista_final = id_dentista_preferencia 
        FROM Pacientes 
        WHERE id_paciente = @id_paciente;

        -- Si no tiene preferencia (paciente nuevo), asignamos el primer dentista disponible o por defecto
        IF @id_dentista_final IS NULL
        BEGIN
            SELECT TOP 1 @id_dentista_final = id_dentista FROM Dentistas;
        END
    END
    ELSE
    BEGIN
        SET @id_dentista_final = @id_dentista_forzado;
    END

    -- Validar disponibilidad (Fecha, Hora y Médico)
    IF EXISTS (SELECT 1 FROM Citas WHERE id_dentista = @id_dentista_final AND fecha = @fecha AND hora = @hora AND estado <> 'CANCELADA')
    BEGIN
        RAISERROR('El dentista ya tiene una cita ocupada en esa fecha y hora.', 16, 1);
        RETURN;
    END

    -- Insertar la cita
    INSERT INTO Citas (id_paciente, id_dentista, fecha, hora, estado)
    VALUES (@id_paciente, @id_dentista_final, @fecha, @hora, 'PROGRAMADA');
END
GO
--procedure cancelar citas
-- SP: Cancelar Citas
CREATE PROCEDURE sp_CancelarCita
    @id_cita INT
AS
BEGIN
    UPDATE Citas SET estado = 'CANCELADA' WHERE id_cita = @id_cita;
END
GO
--procedure reagendar citas
-- SP: Reagendar Citas (validando disponibilidad)
CREATE PROCEDURE sp_ReagendarCita
    @id_cita INT,
    @nueva_fecha DATE,
    @nueva_hora TIME
AS
BEGIN
    DECLARE @id_dentista INT;
    SELECT @id_dentista = id_dentista FROM Citas WHERE id_cita = @id_cita;

    -- Verificar disponibilidad excluyendo la propia cita actual
    IF EXISTS (SELECT 1 FROM Citas WHERE id_dentista = @id_dentista AND fecha = @nueva_fecha AND hora = @nueva_hora AND estado <> 'CANCELADA' AND id_cita <> @id_cita)
    BEGIN
        RAISERROR('El dentista no está disponible en el nuevo horario seleccionado.', 16, 1);
        RETURN;
    END

    UPDATE Citas 
    SET fecha = @nueva_fecha, hora = @nueva_hora, estado = 'REAGENDADA' 
    WHERE id_cita = @id_cita;
END
GO
--procedure historico de citas (general y dentista especifico)
-- SP: Historial de citas flexible (General, por Dentista, o por Paciente)
CREATE PROCEDURE sp_FiltrarHistorial
    @id_dentista INT = NULL,
    @id_paciente INT = NULL
AS
BEGIN
    SELECT 
        c.id_cita,
        p.nombre + ' ' + p.APaterno AS Paciente,
        u.nombre + ' ' + u.APaterno AS Dentista,
        c.fecha,
        c.hora,
        c.estado,
        ISNULL(h.diagnostico, 'Pendiente / Sin diagnóstico') AS diagnostico
    FROM Citas c
    INNER JOIN Pacientes p ON c.id_paciente = p.id_paciente
    INNER JOIN Dentistas d ON c.id_dentista = d.id_dentista
    INNER JOIN Usuarios u ON d.usuario = u.usuario
    LEFT JOIN Historial h ON c.id_cita = h.id_cita
    WHERE (@id_dentista IS NULL OR c.id_dentista = @id_dentista)
      AND (@id_paciente IS NULL OR c.id_paciente = @id_paciente)
    ORDER BY c.fecha DESC, c.hora DESC;
END
GO

--PARA DENTISTAS

-- procedure Ver citas
-- SP: Ver citas de un dentista específico
CREATE PROCEDURE sp_VerCitasDentista
    @id_dentista INT,
    @fecha DATE = NULL
AS
BEGIN
    SELECT 
        c.id_cita,
        p.id_paciente,
        p.nombre + ' ' + p.APaterno AS Paciente,
        c.fecha,
        c.hora,
        c.estado
    FROM Citas c
    INNER JOIN Pacientes p ON c.id_paciente = p.id_paciente
    WHERE c.id_dentista = @id_dentista 
      AND (@fecha IS NULL OR c.fecha = @fecha)
      AND c.estado IN ('PROGRAMADA', 'REAGENDADA');
END
GO
-- procedure atender cita x paciente (para ambos)
-- SP: Atender cita (Guarda diagnóstico y cambia estado a ATENDIDA)
CREATE PROCEDURE sp_AtenderCita
    @id_cita INT,
    @diagnostico VARCHAR(MAX)
AS
BEGIN
    INSERT INTO Historial (id_cita, diagnostico)
    VALUES (@id_cita, @diagnostico);

    UPDATE Citas SET estado = 'ATENDIDA' WHERE id_cita = @id_cita;
END
GO


