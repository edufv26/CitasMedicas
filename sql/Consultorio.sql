CREATE DATABASE Consultorio
GO
USE Consultorio
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
    tipo INT CHECK(tipo >= 1 AND tipo <= 3) DEFAULT 3, -- 1 = ADMIN, 2 = SECRETARIA, 3 = DENTISTA
    estatus CHAR(1) CHECK(estatus IN ('A','D')) DEFAULT 'A'
);
GO
SELECT * FROM Personal
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
    direccion VARCHAR(100),
    id_dentista_preferencia INT NULL,
    estatus CHAR(1) CHECK(estatus IN ('A','D')) DEFAULT 'A',
    CONSTRAINT FK_Paciente_DentistaPref FOREIGN KEY (id_dentista_preferencia) REFERENCES Dentistas(id_dentista)
);
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
-- 6. Historial (Simplificado con Fecha, Hora implícita por la cita, Paciente y Diagnóstico) -- citas ya realizadas
CREATE TABLE Historial (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    id_cita INT NOT NULL,
    diagnostico VARCHAR(MAX) NOT NULL, -- Aquí entra diagnóstico, notas y tratamiento/receta
    fecha_registro DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Historial_Cita FOREIGN KEY (id_cita) REFERENCES Citas(id_cita)
);
GO

SELECT * FROM Citas
SELECT * FROM Historial
USE Consultorio
GO
-- =========================================================
-- PROCEDURES
-- =========================================================
-- =========================================================
-- ALTAS
-- =========================================================
--PARA ADMIN
--procedure nuev@ admin, dentista, secretaria + usuario
-- SP: Registrar personal (Admin, Dentista o Secretaria + su usuario
USE Consultorio
GO
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarPersonal
    @usuario CHAR(12),
    @password CHAR(32),
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30) = NULL,
    @telefono VARCHAR(15) = NULL,
    @correo VARCHAR(50) = NULL,
    @tipo INT, -- 1: Administrador, 2: Secretaria, 3: Dentista
    @especialidad VARCHAR(50) = NULL,
    @cedula_profesional VARCHAR(20) = NULL,
    @turno VARCHAR(20) = NULL,
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@usuario, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@password, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@nombre, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@APaterno, ''))) = ''
        OR @tipo NOT IN (1, 2, 3)
    BEGIN
        SET @mensaje = 'Faltan campos obligatorios para registrar al personal.';
        RETURN;
    END;

    IF @tipo = 3 AND (
        LTRIM(RTRIM(ISNULL(@especialidad, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@cedula_profesional, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@turno, ''))) = ''
    )
    BEGIN
        SET @mensaje = 'Faltan especialidad, cédula profesional o turno para el dentista.';
        RETURN;
    END;

    IF @tipo = 2 AND LTRIM(RTRIM(ISNULL(@turno, ''))) = ''
    BEGIN
        SET @mensaje = 'Falta el turno para la secretaria.';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM Personal WHERE usuario = @usuario)
    BEGIN
        SET @mensaje = 'El usuario ya se encuentra registrado: ' + LTRIM(RTRIM(@usuario));
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Personal (usuario, password, nombre, APaterno, AMaterno, telefono, correo, tipo, estatus)
        VALUES (@usuario, @password, @nombre, @APaterno, @AMaterno, @telefono, @correo, @tipo, 'A');

        IF @tipo = 3
        BEGIN
            INSERT INTO Dentistas (usuario, especialidad, cedula_profesional, turno, telefono, correo)
            VALUES (@usuario, @especialidad, @cedula_profesional, @turno, @telefono, @correo);
        END
        ELSE IF @tipo = 2
        BEGIN
            INSERT INTO Secretarias (usuario, turno, telefono, correo)
            VALUES (@usuario, @turno, @telefono, @correo);
        END;

        COMMIT TRANSACTION;
        SET @mensaje = 'Personal registrado correctamente. Usuario: ' + LTRIM(RTRIM(@usuario));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @mensaje = 'Error en transacción: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
USE Consultorio
GO
CREATE PROCEDURE dbo.sp_RegistrarPaciente
    @nombre        VARCHAR(30),
    @a_paterno     VARCHAR(30),
    @a_materno     VARCHAR(30),
    @telefono      VARCHAR(15),
    @correo        VARCHAR(50),
    @direccion     VARCHAR(100),
    @id_den_p      INT = NULL,
    @respuesta     VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_medico_asignado INT = NULL;
    DECLARE @nombre_medico VARCHAR(120) = 'No asignado';

    -- 1. Si viene preferencia (> 0), validamos que exista y esté activo; si no, elegimos uno aleatorio activo
    IF @id_den_p IS NOT NULL AND @id_den_p > 0
    BEGIN
        SELECT TOP 1
            @id_medico_asignado = d.id_dentista,
            @nombre_medico = LTRIM(RTRIM(
                COALESCE(per.nombre, '') + ' ' + COALESCE(per.APaterno, '') + ' ' + COALESCE(per.AMaterno, '')
            ))
        FROM Dentistas d
        INNER JOIN Personal per ON d.usuario = per.usuario
        WHERE d.id_dentista = @id_den_p
          AND per.estatus = 'A';

        IF @id_medico_asignado IS NULL
        BEGIN
            SET @respuesta = 'El médico de preferencia seleccionado no existe o está inactivo';
            RETURN;
        END
    END
    ELSE
    BEGIN
        SELECT TOP 1
            @id_medico_asignado = d.id_dentista,
            @nombre_medico = LTRIM(RTRIM(
                COALESCE(per.nombre, '') + ' ' + COALESCE(per.APaterno, '') + ' ' + COALESCE(per.AMaterno, '')
            ))
        FROM Dentistas d
        INNER JOIN Personal per ON d.usuario = per.usuario
        WHERE per.estatus = 'A'
        ORDER BY NEWID();

        IF @id_medico_asignado IS NULL
        BEGIN
            SET @respuesta = 'No hay médicos activos disponibles para asignar';
            RETURN;
        END
    END

    -- 2. Insertar paciente con el médico asignado
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Pacientes (
            nombre,
            APaterno,
            AMaterno,
            telefono,
            correo,
            direccion,
            id_dentista_preferencia,
            estatus
        )
        VALUES (
            @nombre,
            @a_paterno,
            @a_materno,
            @telefono,
            @correo,
            @direccion,
            @id_medico_asignado,
            'A'
        );

        COMMIT TRANSACTION;
        SET @respuesta = 'Paciente registrado, médico asignado: Dr(a). ' + @nombre_medico;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @respuesta = 'Error al registrar paciente: ' + ERROR_MESSAGE();
    END CATCH
END
GO
-- ==============================================================
--  BAJAS (cambiar a INACTIVO) con UPDATE
-- ===============================================================
-- SP: Dar de baja lógica a cualquier Usuario del personal (Admin, Dentista o Secretaria)
--PARA ADMIN
USE Consultorio
GO
CREATE OR ALTER PROCEDURE dbo.sp_BajaUsuario
    @usuario CHAR(12),
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@usuario, ''))) = ''
    BEGIN
        SET @mensaje = 'Falta el usuario para dar de baja.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Personal WHERE usuario = @usuario)
    BEGIN
        SET @mensaje = 'No existe el usuario indicado: ' + LTRIM(RTRIM(@usuario));
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Personal
        SET estatus = 'D'
        WHERE usuario = @usuario;

        COMMIT TRANSACTION;
        SET @mensaje = 'Personal dado de baja correctamente: ' + LTRIM(RTRIM(@usuario));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @mensaje = 'Error en transacción: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
-- PROCEDURE - BAJA PACIENTES
CREATE PROCEDURE sp_BajaPaciente
    @id_paciente INT,
    @respuesta VARCHAR(150) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE id_paciente = @id_paciente)
    BEGIN
        SET @respuesta = 'El paciente no existe';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Pacientes WHERE id_paciente = @id_paciente AND estatus = 'D')
    BEGIN
        SET @respuesta = 'El paciente ya estaba dado de baja';
        RETURN;
    END

    BEGIN TRANSACTION;

    UPDATE Pacientes
    SET estatus = 'D'
    WHERE id_paciente = @id_paciente;

    IF (@@ERROR > 0)
    BEGIN
        ROLLBACK TRANSACTION;
        SET @respuesta = 'Error al dar de baja al paciente';
        RETURN;
    END

    COMMIT TRANSACTION;
    SET @respuesta = 'Paciente dado de baja correctamente';
END
GO
-- =========================================================
-- CAMBIO
-- =========================================================
-- SP - ACTUALIZAR INFO DEL PACIENTE
CREATE OR ALTER PROCEDURE dbo.sp_ActualizarPersonal
    @usuario CHAR(12),
    @nombre VARCHAR(30),
    @APaterno VARCHAR(30),
    @AMaterno VARCHAR(30) = NULL,
    @telefono VARCHAR(15) = NULL,
    @correo VARCHAR(50) = NULL,
    @tipo INT, -- 1: Administrador, 2: Secretaria, 3: Dentista
    @especialidad VARCHAR(50) = NULL,
    @cedula_profesional VARCHAR(20) = NULL,
    @turno VARCHAR(20) = NULL,
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@usuario, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@nombre, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@APaterno, ''))) = ''
        OR @tipo NOT IN (1, 2, 3)
    BEGIN
        SET @mensaje = 'Faltan campos obligatorios para actualizar al personal.';
        RETURN;
    END;

    IF @tipo = 3 AND (
        LTRIM(RTRIM(ISNULL(@especialidad, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@cedula_profesional, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@turno, ''))) = ''
    )
    BEGIN
        SET @mensaje = 'Faltan especialidad, cédula profesional o turno para el dentista.';
        RETURN;
    END;

    IF @tipo = 2 AND LTRIM(RTRIM(ISNULL(@turno, ''))) = ''
    BEGIN
        SET @mensaje = 'Falta el turno para la secretaria.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Personal WHERE usuario = @usuario)
    BEGIN
        SET @mensaje = 'No existe el usuario indicado: ' + LTRIM(RTRIM(@usuario));
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Personal
        SET nombre = @nombre,
            APaterno = @APaterno,
            AMaterno = @AMaterno,
            telefono = @telefono,
            correo = @correo,
            tipo = @tipo
        WHERE usuario = @usuario;

        IF @tipo = 3
        BEGIN
            IF EXISTS (SELECT 1 FROM Dentistas WHERE usuario = @usuario)
            BEGIN
                UPDATE Dentistas
                SET especialidad = @especialidad,
                    cedula_profesional = @cedula_profesional,
                    turno = @turno,
                    telefono = @telefono,
                    correo = @correo
                WHERE usuario = @usuario;
            END
            ELSE
            BEGIN
                INSERT INTO Dentistas (usuario, especialidad, cedula_profesional, turno, telefono, correo)
                VALUES (@usuario, @especialidad, @cedula_profesional, @turno, @telefono, @correo);
            END;
        END
        ELSE IF @tipo = 2
        BEGIN
            IF EXISTS (SELECT 1 FROM Secretarias WHERE usuario = @usuario)
            BEGIN
                UPDATE Secretarias
                SET turno = @turno,
                    telefono = @telefono,
                    correo = @correo
                WHERE usuario = @usuario;
            END
            ELSE
            BEGIN
                INSERT INTO Secretarias (usuario, turno, telefono, correo)
                VALUES (@usuario, @turno, @telefono, @correo);
            END;
        END;

        COMMIT TRANSACTION;
        SET @mensaje = 'Personal actualizado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @mensaje = 'Error en transacción: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
USE Consultorio
SELECT * FROM Personal
GO
-- PARA ADMIN
CREATE OR ALTER PROCEDURE dbo.sp_CambiarPasswordUsuario
    @usuario CHAR(12),
    @nuevo_password CHAR(32),
    @mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@usuario, ''))) = ''
        OR LTRIM(RTRIM(ISNULL(@nuevo_password, ''))) = ''
    BEGIN
        SET @mensaje = 'Faltan datos para actualizar la contraseña.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Personal WHERE usuario = @usuario)
    BEGIN
        SET @mensaje = 'No existe el usuario indicado: ' + LTRIM(RTRIM(@usuario));
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Personal
        SET password = @nuevo_password
        WHERE usuario = @usuario;

        COMMIT TRANSACTION;
        SET @mensaje = 'Contraseña actualizada correctamente para ' + LTRIM(RTRIM(@usuario));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @mensaje = 'Error en transacción: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
--PARA SECRETARIAS Y ADMIN
-- SP: Actualizar datos de un paciente (para corregir nombres, teléfonos, correo o preferencia)
CREATE PROCEDURE dbo.sp_ActualizarPaciente
    @id_paciente             INT,
    @nombre                  VARCHAR(30),
    @APaterno                VARCHAR(30),
    @AMaterno                VARCHAR(30),
    @telefono                VARCHAR(15),
    @correo                  VARCHAR(50),
    @direccion               VARCHAR(100),
    @id_dentista_preferencia INT = NULL,
    @respuesta               VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE id_paciente = @id_paciente)
    BEGIN
        SET @respuesta = 'El paciente no existe';
        RETURN;
    END

    IF @id_dentista_preferencia IS NOT NULL AND @id_dentista_preferencia > 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Dentistas WHERE id_dentista = @id_dentista_preferencia)
        BEGIN
            SET @respuesta = 'El médico de preferencia seleccionado no existe';
            RETURN;
        END
    END
    ELSE
    BEGIN
        SET @id_dentista_preferencia = NULL;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Pacientes
        SET nombre = @nombre,
            APaterno = @APaterno,
            AMaterno = @AMaterno,
            telefono = @telefono,
            correo = @correo,
            direccion = @direccion,
            id_dentista_preferencia = @id_dentista_preferencia
        WHERE id_paciente = @id_paciente;

        COMMIT TRANSACTION;
        SET @respuesta = 'Datos del paciente actualizados correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @respuesta = 'Error al actualizar paciente: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- =========================================================
-- CITAS
-- =========================================================
--procedure agendar citas (verificar si fecha-hora y medico esta disponible(logica de paciente antiguo o nuevo))
-- SP: Agendar cita (Verifica disponibilidad de fecha/hora/médico y maneja médico preferido o nuevo)
USE Consultorio
GO
CREATE OR ALTER PROCEDURE sp_AgendarCita
    @id_paciente INT,
    @id_dentista_forzado INT = NULL,
    @fecha DATE,
    @hora TIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_dentista_final INT;
    DECLARE @turno_dentista VARCHAR(20);

    -- 1. Validar que la hora esté dentro de Matutino (08:00 - 14:00) o Vespertino (15:00 - 20:00)
    IF NOT (
        (@hora >= '08:00:00' AND @hora <= '14:00:00')
        OR
        (@hora >= '15:00:00' AND @hora <= '20:00:00')
    )
    BEGIN
        RAISERROR('La hora está fuera del horario de atención (Matutino 08:00-14:00 / Vespertino 15:00-20:00).', 16, 1);
        RETURN;
    END

    -- 2. Si se eligió un médico específico
    IF @id_dentista_forzado IS NOT NULL
    BEGIN
        SELECT @id_dentista_final = id_dentista,
               @turno_dentista = LTRIM(RTRIM(turno))
        FROM dbo.Dentistas
        WHERE id_dentista = @id_dentista_forzado;

        IF @id_dentista_final IS NULL
        BEGIN
            RAISERROR('El dentista seleccionado no existe.', 16, 1);
            RETURN;
        END

        -- Validar que el turno del dentista cubra la hora solicitada
        IF NOT (
            (@turno_dentista = 'Matutino' AND @hora >= '08:00:00' AND @hora <= '14:00:00')
            OR
            (@turno_dentista = 'Vespertino' AND @hora >= '15:00:00' AND @hora <= '20:00:00')
        )
        BEGIN
            RAISERROR('La hora seleccionada no corresponde al turno del dentista.', 16, 1);
            RETURN;
        END

        -- Validar disponibilidad en fecha y hora
        IF EXISTS (
            SELECT 1
            FROM dbo.Citas
            WHERE id_dentista = @id_dentista_final
              AND fecha = @fecha
              AND hora = @hora
              AND estado = 'PROGRAMADA'
        )
        BEGIN
            RAISERROR('El dentista ya tiene una cita programada en esa fecha y hora.', 16, 1);
            RETURN;
        END
    END
    ELSE
    BEGIN
        -- 3. Modo automático: revisar primero si el paciente tiene médico de preferencia
        DECLARE @id_pref INT;
        SELECT @id_pref = id_dentista_preferencia
        FROM dbo.Pacientes
        WHERE id_paciente = @id_paciente;

        IF @id_pref IS NOT NULL
        BEGIN
            SELECT @turno_dentista = LTRIM(RTRIM(turno))
            FROM dbo.Dentistas
            WHERE id_dentista = @id_pref;

            -- Si el médico de preferencia cumple el turno y está libre, se le asigna
            IF (
                (@turno_dentista = 'Matutino' AND @hora >= '08:00:00' AND @hora <= '14:00:00')
                OR
                (@turno_dentista = 'Vespertino' AND @hora >= '15:00:00' AND @hora <= '20:00:00')
            )
            AND NOT EXISTS (
                SELECT 1
                FROM dbo.Citas
                WHERE id_dentista = @id_pref
                  AND fecha = @fecha
                  AND hora = @hora
                  AND estado = 'PROGRAMADA'
            )
            BEGIN
                SET @id_dentista_final = @id_pref;
            END
        END

        -- 4. Si no tenía preferencia o su médico de preferencia no tenía ese turno / estaba ocupado,
        --    buscar un dentista que sí cubra el turno a esa hora y esté disponible
        IF @id_dentista_final IS NULL
        BEGIN
            SELECT TOP 1 @id_dentista_final = d.id_dentista
            FROM dbo.Dentistas d
            WHERE (
                (LTRIM(RTRIM(d.turno)) = 'Matutino' AND @hora >= '08:00:00' AND @hora <= '14:00:00')
                OR
                (LTRIM(RTRIM(d.turno)) = 'Vespertino' AND @hora >= '15:00:00' AND @hora <= '20:00:00')
            )
            AND NOT EXISTS (
                SELECT 1
                FROM dbo.Citas c
                WHERE c.id_dentista = d.id_dentista
                  AND c.fecha = @fecha
                  AND c.hora = @hora
                  AND c.estado = 'PROGRAMADA'
            )
            ORDER BY d.id_dentista;
        END

        IF @id_dentista_final IS NULL
        BEGIN
            RAISERROR('No hay dentistas disponibles en ese turno para la fecha y hora seleccionadas.', 16, 1);
            RETURN;
        END
    END

    -- 5. Insertar cita como PROGRAMADA
    INSERT INTO dbo.Citas (id_paciente, id_dentista, fecha, hora, estado)
    VALUES (@id_paciente, @id_dentista_final, @fecha, @hora, 'PROGRAMADA');
END
GO
-- ====================================================================
--procedure cancelar citas
-- ====================================================================
-- SP: Cancelar Citas
CREATE OR ALTER PROCEDURE sp_CancelarCita
    @id_cita INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Citas WHERE id_cita = @id_cita AND estado = 'PROGRAMADA')
    BEGIN
        RAISERROR('La cita no existe o ya no está programada.', 16, 1);
        RETURN;
    END

    UPDATE dbo.Citas
    SET estado = 'CANCELADA'
    WHERE id_cita = @id_cita;
END
GO
-- ====================================================================
--procedure reagendar citas
-- ====================================================================
-- SP: Cancelar Citas
CREATE OR ALTER PROCEDURE sp_ReagendarCita
    @id_cita INT,
    @nueva_fecha DATE,
    @nueva_hora TIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_dentista INT;
    DECLARE @turno_dentista VARCHAR(20);

    SELECT @id_dentista = c.id_dentista,
           @turno_dentista = LTRIM(RTRIM(d.turno))
    FROM dbo.Citas c
    INNER JOIN dbo.Dentistas d ON c.id_dentista = d.id_dentista
    WHERE c.id_cita = @id_cita
      AND c.estado = 'PROGRAMADA';

    IF @id_dentista IS NULL
    BEGIN
        RAISERROR('La cita no existe o no se puede reagendar.', 16, 1);
        RETURN;
    END

    -- Validar que la nueva hora corresponda al turno del dentista asignado
    IF NOT (
        (@turno_dentista = 'Matutino' AND @nueva_hora >= '08:00:00' AND @nueva_hora <= '14:00:00')
        OR
        (@turno_dentista = 'Vespertino' AND @nueva_hora >= '15:00:00' AND @nueva_hora <= '20:00:00')
    )
    BEGIN
        RAISERROR('La nueva hora no corresponde al turno del dentista asignado (Matutino 08:00-14:00 / Vespertino 14:00-20:00).', 16, 1);
        RETURN;
    END

    -- Verificar disponibilidad excluyendo la propia cita actual
    IF EXISTS (
        SELECT 1
        FROM dbo.Citas
        WHERE id_dentista = @id_dentista
          AND fecha = @nueva_fecha
          AND hora = @nueva_hora
          AND estado = 'PROGRAMADA'
          AND id_cita <> @id_cita
    )
    BEGIN
        RAISERROR('El dentista no está disponible en el nuevo horario seleccionado.', 16, 1);
        RETURN;
    END

    UPDATE dbo.Citas
    SET fecha = @nueva_fecha,
        hora = @nueva_hora,
        estado = 'PROGRAMADA'
    WHERE id_cita = @id_cita;
END
GO
--procedure historico de citas (general y dentista especifico)
CREATE OR ALTER PROCEDURE sp_FiltrarHistorial
    @id_dentista INT = NULL,
    @id_paciente INT = NULL,
    @fecha DATE = NULL,
    @solo_pendientes BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.id_cita,
        p.nombre + ' ' + p.APaterno AS Paciente,
        u.nombre + ' ' + u.APaterno AS Dentista,
        c.fecha,
        c.hora,
        c.estado,
        ISNULL(h.diagnostico, 'Pendiente / Sin diagnóstico') AS diagnostico
    FROM dbo.Citas c
    INNER JOIN dbo.Pacientes p ON c.id_paciente = p.id_paciente
    INNER JOIN dbo.Dentistas d ON c.id_dentista = d.id_dentista
    INNER JOIN dbo.Personal u ON d.usuario = u.usuario
    LEFT JOIN dbo.Historial h ON c.id_cita = h.id_cita
    WHERE (@id_dentista IS NULL OR c.id_dentista = @id_dentista)
      AND (@id_paciente IS NULL OR c.id_paciente = @id_paciente)
      AND (@fecha IS NULL OR c.fecha = @fecha)
      AND (
          (@solo_pendientes = 1 AND c.estado = 'PROGRAMADA')
          OR
          (@solo_pendientes = 0 AND c.estado IN ('ATENDIDA', 'CANCELADA'))
      )
    ORDER BY c.fecha DESC, c.hora DESC;
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
-- 1. DASHBOARD: Citas de Hoy (Reutilizable para Admin y Dentista)
-- =========================================================
-- Si @id_dentista es NULL, trae todas (para el Admin). 
-- Si se le pasa un ID, trae solo las de ese doctor (para su panel).
USE Consultorio
GO
CREATE OR ALTER PROCEDURE sp_ListarCitasDelDia
    @id_dentista INT = NULL
AS
BEGIN
    SELECT 
        c.id_cita,
        p.id_paciente,
        LTRIM(RTRIM(CONCAT(ISNULL(p.nombre, ''), ' ', ISNULL(p.APaterno, ''), ' ', ISNULL(p.AMaterno, '')))) AS Paciente,
        p.telefono,
        LTRIM(RTRIM(CONCAT(ISNULL(u.nombre, ''), ' ', ISNULL(u.APaterno, '')))) AS Dentista,
        c.fecha,
        c.hora,
        c.estado
    FROM Citas c
    INNER JOIN Pacientes p ON c.id_paciente = p.id_paciente
    INNER JOIN Dentistas d ON c.id_dentista = d.id_dentista
    INNER JOIN Personal u ON d.usuario = u.usuario
    WHERE c.fecha = CAST(GETDATE() AS DATE)
      AND (@id_dentista IS NULL OR c.id_dentista = @id_dentista)
      AND c.estado IN ('PROGRAMADA')
    ORDER BY c.hora ASC;
END
GO