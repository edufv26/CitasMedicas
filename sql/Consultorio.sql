CREATE DATABASE Consultorio
GO
USE Consultorio
GO
-- =========================================================
-- 1. CREACIÓN DE TABLAS
-- =========================================================

-- Tabla unificada de Personal (Usuarios) (Admin: 1, Dentistas: 2, Secretarias: 3)
CREATE TABLE Personal(
    usuario CHAR(12) PRIMARY KEY NOT NULL,
    password CHAR(32),
    nombre VARCHAR(30),
    APaterno VARCHAR(30),
    AMaterno VARCHAR(30),
    telefono VARCHAR(15), -- Teléfono de contacto para el personal
    correo VARCHAR(50),   -- Correo electrónico institucional o personal
    tipo INT CHECK(tipo >= 1 AND tipo <= 3) DEFAULT 3, -- 1 = ADMIN, 2 = DENTISTA, 3 = SECRETARIA
    estatus CHAR(1) CHECK(estatus IN ('A','D')) DEFAULT 'A'
);
GO
GO
-- 2. Dentistas 
CREATE TABLE Dentistas(
    id_dentista INT IDENTITY(1,1) PRIMARY KEY,
    usuario CHAR(12) NOT NULL,
    especialidad VARCHAR(50) NOT NULL,
    cedula_profesional VARCHAR(20) NOT NULL,
    turno VARCHAR(20) CHECK(turno IN ('Matutino','Vespertino')) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(50),
    CONSTRAINT FK_Dentista_Usuario FOREIGN KEY (usuario) REFERENCES Personal(usuario)
);
GO
GO
-- 3. Secretarias
CREATE TABLE Secretarias(
    id_secretaria INT IDENTITY(1,1) PRIMARY KEY,
    usuario CHAR(12) NOT NULL,
    turno VARCHAR(20) CHECK(turno IN ('Matutino','Vespertino')) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(50),
    CONSTRAINT FK_Secretaria_Usuario FOREIGN KEY (usuario) REFERENCES Personal(usuario)
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
-- =========================================================
-- INSERCIONES PREVIAS
-- =========================================================
--inserciones previas (usuarios) 3 admin, 2 dentistas, 2 secretarias
INSERT INTO Personal (usuario, password, nombre, APaterno, AMaterno, telefono, correo, tipo, estatus) VALUES
('admin01', '26062004', 'Eduardo', 'Flores', 'Velazquez', '5511111111', 'admin1@mail.com', 1, 'A'),
('admin02', '123456', 'Oswaldo Yael', 'Alonso', 'Guarneros', '5522222222', 'admin2@mail.com', 1, 'A'),
('admin03', '098765', 'Paul Isaac', 'Mendoza', 'Lopez', '5533333333', 'admin3@mail.com', 1, 'A'),
('dentista01', '1234', 'Laura', 'Martínez', 'Sánchez', '5544444444', 'laura@mail.com', 2, 'A'),
('dentista02', '3456', 'Roberto', 'López', 'Ramírez', '5555555555', 'roberto@mail.com', 2, 'A'),
('sec01', '676767', 'Ana', 'Torres', 'Cruz', '5566666666', 'ana@mail.com', 3, 'A'),
('sec02', '696969', 'Sofía', 'Jiménez', 'Ruiz', '5577777777', 'sofia@mail.com', 3, 'A');
GO
-- SE ASIGNA usuario-NUMERO EL PASSWORD SI ESTA ENCRIPTADO

--inserciones previas (Dentistas)
-- Inserciones de Dentistas (Con todos sus campos obligatorios)
INSERT INTO Dentistas (usuario, especialidad, cedula_profesional, turno, telefono, correo) VALUES
('dentista01', 'Ortodoncia', 'CED12345', 'Matutino', '5544444444', 'laura@mail.com'),
('dentista02', 'Endodoncia', 'CED67890', 'Vespertino', '5555555555', 'roberto@mail.com');
GO
-- inserciones previas (Secretarias)
-- Ligar Secretarias
I-- Inserciones de Secretarias (Con todos sus campos obligatorios)
INSERT INTO Secretarias (usuario, turno, telefono, correo) VALUES
('sec01', 'Matutino', '5566666666', 'ana@mail.com'),
('sec02', 'Vespertino', '5577777777', 'sofia@mail.com');
GO
--inserciones previas (Pacientes)
-- Pacientes de prueba
-- Pacientes de prueba
INSERT INTO Pacientes (nombre, APaterno, AMaterno, telefono, correo, direccion, id_dentista_preferencia, estatus) VALUES
('Juan', 'Hernández', 'Pérez', '5512345678', 'juan@mail.com', 'Av. Central #123', NULL, 'A'),
('María', 'García', 'López', '5587654321', 'maria@mail.com', 'Calle Mexiquense #45', 1, 'A');
GO
-- =========================================================
-- PROCEDURES
-- =========================================================
-- =========================================================
-- ALTAS
-- =========================================================
--PARA ADMIN
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
    INSERT INTO Personal (usuario, password, nombre, APaterno, AMaterno, tipo, estatus)
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
    -- porque el administrador vive exclusivamente en la tabla Personal.
END
GO
--procedure paciente nuevo, nuevo medico ... paciente antiguo medico  de preferencia (el mas frecuente)
CREATE PROCEDURE sp_RegistrarPaciente
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30),
    @telefono VARCHAR(15),
    @correo VARCHAR(50),
    @direccion VARCHAR(150), -- Nuevo campo
    @id_dentista_preferencia INT = NULL
AS
BEGIN
    DECLARE @id_dentista_final INT;
    SET @id_dentista_final = @id_dentista_preferencia;

    IF @id_dentista_final IS NULL
    BEGIN
        SELECT TOP 1 @id_dentista_final = d.id_dentista 
        FROM Dentistas d
        INNER JOIN Personal u ON d.usuario = u.usuario
        WHERE u.estatus = 'A'
        ORDER BY NEWID();
    END

    INSERT INTO Pacientes (nombre, APaterno, AMaterno, telefono, correo, direccion, id_dentista_preferencia, estatus)
    VALUES (@nombre, @APaterno, @AMaterno, @telefono, @correo, @direccion, @id_dentista_final, 'A');
END
GO
-- SP: Registrar Secretaria
CREATE PROCEDURE sp_RegistrarSecretaria
    @usuario CHAR(12),
    @password CHAR(32),
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30),
    @turno VARCHAR(20),
    @extension VARCHAR(10)
AS
BEGIN
    -- 1. Insertar usuario base (Tipo 3 = Secretaria)
    INSERT INTO Personal (usuario, password, nombre, APaterno, AMaterno, tipo, estatus)
    VALUES (@usuario, @password, @nombre, @APaterno, @AMaterno, 3, 'A');

    -- 2. Insertar los datos específicos de secretaria
    INSERT INTO Secretarias (usuario, turno, extension) 
    VALUES (@usuario, @turno, @extension);
END
GO
-- SP: Alta Dentista
CREATE PROCEDURE sp_RegistrarDentista
    @usuario CHAR(12),
    @password CHAR(32),
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30),
    @telefono VARCHAR(15),
    @correo VARCHAR(50),
    @especialidad VARCHAR(50),
    @cedula_profesional VARCHAR(20)
AS
BEGIN
    -- 1. Insertar en Personal incluyendo teléfono y correo
    INSERT INTO Personal (usuario, password, nombre, APaterno, AMaterno, telefono, correo, tipo, estatus)
    VALUES (@usuario, @password, @nombre, @APaterno, @AMaterno, @telefono, @correo, 2, 'A');

    -- 2. Insertar en Dentistas con su especialidad y cédula
    INSERT INTO Dentistas (usuario, especialidad, cedula_profesional) 
    VALUES (@usuario, @especialidad, @cedula_profesional);
END
GO
-- ==============================================================
--  BAJAS (cambiar a INACTIVO) con UPDATE
-- ===============================================================
-- SP: Dar de baja lógica a cualquier Usuario del personal (Admin, Dentista o Secretaria)
--PARA ADMIN
CREATE PROCEDURE sp_BajaUsuario
    @usuario CHAR(12)
AS
BEGIN
    UPDATE Personal 
    SET estatus = 'D' 
    WHERE usuario = @usuario;
END
GO
-- SP: Dar de baja lógica a Paciente
CREATE PROCEDURE sp_BajaPacientecc
    @id_paciente INT
AS
BEGIN
    UPDATE Pacientes SET estatus = 'D' WHERE id_paciente = @id_paciente;
END
GO
-- =========================================================
-- CAMBIO
-- =========================================================
--- SP: Actualizar datos de Personal (Admin, Dentista o Secretaria)
-- PARA ADMIN
CREATE PROCEDURE sp_ActualizarPersonal
    @usuario CHAR(12),
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30),
    @tipo INT, -- 1: Admin, 2: Dentista, 3: Secretaria
    @especialidad VARCHAR(50) = NULL -- Solo aplica si es dentista
AS
BEGIN
    -- 1. Actualizar los datos generales en la tabla Personal
    UPDATE Personal 
    SET nombre = @nombre,
        APaterno = @APaterno,
        AMaterno = @AMaterno,
        tipo = @tipo
    WHERE usuario = @usuario;

    -- 2. Si el rol es Dentista, actualizar su especialidad (o insertarla por si acaso)
    IF @tipo = 2
    BEGIN
        IF EXISTS (SELECT 1 FROM Dentistas WHERE usuario = @usuario)
        BEGIN
            UPDATE Dentistas 
            SET especialidad = @especialidad 
            WHERE usuario = @usuario;
        END
        ELSE
        BEGIN
            INSERT INTO Dentistas (usuario, especialidad) VALUES (@usuario, @especialidad);
        END
    END
    -- Si es Secretaria o Admin, se actualiza su base en Personal y listo.
END
GO
-- PARA ADMIN
-- SP: Cambiar contraseña de un usuario (Exclusivo para el Administrador)
CREATE PROCEDURE sp_CambiarPasswordUsuario
    @usuario CHAR(12),
    @nuevo_password CHAR(32)
AS
BEGIN
    UPDATE Personal 
    SET password = @nuevo_password 
    WHERE usuario = @usuario;
END
GO
--PARA SECRETARIAS Y ADMIN
-- SP: Actualizar datos de un paciente (para corregir nombres, teléfonos, correo o preferencia)
CREATE PROCEDURE sp_ActualizarPaciente
    @id_paciente INT,
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30),
    @telefono VARCHAR(15),
    @correo VARCHAR(50),
    @id_dentista_preferencia INT = NULL
AS
BEGIN
    UPDATE Pacientes 
    SET nombre = @nombre,
        APaterno = @APaterno,
        AMaterno = @AMaterno,
        telefono = @telefono,
        correo = @correo,
        id_dentista_preferencia = @id_dentista_preferencia
    WHERE id_paciente = @id_paciente;
END
GO
-- =========================================================
-- CONSULTAS
-- =========================================================
-- 1. Listar todo el personal para el Administrador
CREATE PROCEDURE sp_ListarPersonal
AS
BEGIN
    SELECT 
        u.usuario,
        u.nombre,
        u.APaterno,
        u.AMaterno,
        u.telefono,
        u.correo,
        u.tipo, -- 1: Admin, 2: Dentista, 3: Secretaria
        u.estatus,
        ISNULL(d.especialidad, 'N/A') AS especialidad,
        ISNULL(d.cedula_profesional, 'N/A') AS cedula_profesional,
        ISNULL(s.turno, 'N/A') AS turno,
        ISNULL(s.extension, 'N/A') AS extension
    FROM Personal u
    LEFT JOIN Dentistas d ON u.usuario = d.usuario
    LEFT JOIN Secretarias s ON u.usuario = s.usuario;
END
GO

-- 2. Listar todos los pacientes activos para la Secretaria / Admin
CREATE PROCEDURE sp_ListarPacientes
AS
BEGIN
    SELECT 
        p.id_paciente,
        p.nombre,
        p.APaterno,
        p.AMaterno,
        p.telefono,
        p.correo,
        p.direccion,
        p.estatus,
        ISNULL(u.nombre + ' ' + u.APaterno, 'Sin preferencia (Asignación aleatoria)') AS DentistaPreferencia
    FROM Pacientes p
    LEFT JOIN Dentistas d ON p.id_dentista_preferencia = d.id_dentista
    LEFT JOIN Personal u ON d.usuario = u.usuario;
END
GO

-- 3. Listar solo dentistas activos (útil para los select/combobox al agendar citas)
CREATE PROCEDURE sp_ListarDentistasActivos
AS
BEGIN
    SELECT 
        d.id_dentista,
        u.usuario,
        u.nombre + ' ' + u.APaterno + ' ' + u.AMaterno AS NombreCompleto,
        d.especialidad,
        d.cedulas_profesional -- o cedula_profesional según tu columna
    FROM Dentistas d
    INNER JOIN Personal u ON d.usuario = u.usuario
    WHERE u.estatus = 'A';
END
GO
-- =========================================================
-- CITAS
-- =========================================================
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
    INNER JOIN Personal u ON d.usuario = u.usuario
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
-- =========================================================
-- GRAFICAS
-- =========================================================
-- SP para la Gráfica de Barras: Citas por mes y por dentista en un año específico
CREATE PROCEDURE sp_EstadisticasBarrasAnual
    @anio INT
AS
BEGIN
    SELECT 
        MONTH(c.fecha) AS Mes,
        d.id_dentista,
        u.nombre + ' ' + u.APaterno AS Dentista,
        COUNT(c.id_cita) AS TotalCitas
    FROM Citas c
    INNER JOIN Dentistas d ON c.id_dentista = d.id_dentista
    INNER JOIN Personal u ON d.usuario = u.usuario
    WHERE YEAR(c.fecha) = @anio
    GROUP BY MONTH(c.fecha), d.id_dentista, u.nombre, u.APaterno
    ORDER BY Mes, d.id_dentista;
END
GO
-- SP para la Gráfica de Pastel: Distribución de citas por dentista en un mes y año dados
CREATE PROCEDURE sp_EstadisticasPastelMensual
    @mes INT,
    @anio INT
AS
BEGIN
    SELECT 
        d.id_dentista,
        u.nombre + ' ' + u.APaterno AS Dentista,
        COUNT(c.id_cita) AS TotalCitas
    FROM Citas c
    INNER JOIN Dentistas d ON c.id_dentista = d.id_dentista
    INNER JOIN Personal u ON d.usuario = u.usuario
    WHERE MONTH(c.fecha) = @mes AND YEAR(c.fecha) = @anio
    GROUP BY d.id_dentista, u.nombre, u.APaterno;
END
GO


