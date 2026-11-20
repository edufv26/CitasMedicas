USE Consultorio;
GO

-- =========================================================
-- 1. NUEVOS DENTISTAS (Primero en Personal con tipo = 2, luego en Dentistas)
-- =========================================================
INSERT INTO Personal (usuario, password, nombre, APaterno, AMaterno, telefono, correo, tipo, estatus) VALUES
('dentista03', 'dent03pass', 'Carlos', 'Mendoza', 'Silva', '5511002233', 'carlos.mendoza@mail.com', 2, 'A'),
('dentista04', 'dent04pass', 'Valeria', 'Reyes', 'Ortiz', '5544998877', 'valeria.reyes@mail.com', 2, 'A');
GO

-- Recuperamos los id_dentista generados automáticamente (asumiendo que ya existían 1 y 2, estos serán 3 y 4)
DECLARE @id_dent3 INT = (SELECT id_dentista FROM Dentistas WHERE usuario = 'dentista03');
DECLARE @id_dent4 INT = (SELECT id_dentista FROM Dentistas WHERE usuario = 'dentista04');

INSERT INTO Dentistas (usuario, especialidad, cedula_profesional, turno, telefono, correo) VALUES
('dentista03', 'Odontopediatría', 'CED98123', 'Matutino', '5511002233', 'carlos.mendoza@mail.com'),
('dentista04', 'Cirugía Maxilofacial', 'CED45612', 'Vespertino', '5544998877', 'valeria.reyes@mail.com');
GO

-- =========================================================
-- 2. NUEVOS PACIENTES
-- =========================================================
INSERT INTO Pacientes (nombre, APaterno, AMaterno, telefono, correo, direccion, id_dentista_preferencia, estatus) VALUES
('Sofía', 'Castillo', 'Vargas', '5523456789', 'sofia.castillo@mail.com', 'Av. López Mateos #210', 1, 'A'),
('Diego', 'Morales', 'Nava', '5534567890', 'diego.morales@mail.com', 'Calle Juárez #88', 2, 'A'),
('Camila', 'Ríos', 'Domínguez', '5545678901', 'camila.rios@mail.com', 'Privada del Parque #14', NULL, 'A'),
('Alejandro', 'Gutiérrez', 'Luna', '5556789012', 'ale.gutierrez@mail.com', 'Blvd. Insurgentes #502', NULL, 'A'),
('Fernanda', 'Sánchez', 'Paz', '5567890123', 'fer.sanchez@mail.com', 'Calle 5 de Mayo #77', 1, 'A');
GO

-- =========================================================
-- 3. CITAS VARIADAS (ATENDIDA, PROGRAMADA [pendiente], REAGENDADA, CANCELADA)
-- =========================================================
-- Obtenemos IDs de forma dinámica para evitar errores si tu tabla ya tenía otros registros
DECLARE @p1 INT = (SELECT TOP 1 id_paciente FROM Pacientes WHERE correo = 'juan@mail.com');
DECLARE @p2 INT = (SELECT TOP 1 id_paciente FROM Pacientes WHERE correo = 'maria@mail.com');
DECLARE @p3 INT = (SELECT TOP 1 id_paciente FROM Pacientes WHERE correo = 'sofia.castillo@mail.com');
DECLARE @p4 INT = (SELECT TOP 1 id_paciente FROM Pacientes WHERE correo = 'diego.morales@mail.com');
DECLARE @p5 INT = (SELECT TOP 1 id_paciente FROM Pacientes WHERE correo = 'camila.rios@mail.com');
DECLARE @p6 INT = (SELECT TOP 1 id_paciente FROM Pacientes WHERE correo = 'ale.gutierrez@mail.com');
DECLARE @p7 INT = (SELECT TOP 1 id_paciente FROM Pacientes WHERE correo = 'fer.sanchez@mail.com');

DECLARE @d1 INT = (SELECT TOP 1 id_dentista FROM Dentistas WHERE usuario = 'dentista01');
DECLARE @d2 INT = (SELECT TOP 1 id_dentista FROM Dentistas WHERE usuario = 'dentista02');
DECLARE @d3 INT = (SELECT TOP 1 id_dentista FROM Dentistas WHERE usuario = 'dentista03');
DECLARE @d4 INT = (SELECT TOP 1 id_dentista FROM Dentistas WHERE usuario = 'dentista04');

INSERT INTO Citas (id_paciente, id_dentista, fecha, hora, estado) VALUES
-- Atendidas (fechas pasadas)
(@p1, @d1, DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), '09:30:00', 'ATENDIDA'),
(@p2, @d2, DATEADD(DAY, -7,  CAST(GETDATE() AS DATE)), '16:00:00', 'ATENDIDA'),
(@p3, @d1, DATEADD(DAY, -3,  CAST(GETDATE() AS DATE)), '10:30:00', 'ATENDIDA'),
(@p4, @d3, DATEADD(DAY, -1,  CAST(GETDATE() AS DATE)), '11:00:00', 'ATENDIDA'),

-- Citas de HOY (útiles para probar sp_ListarCitasDelDia)
(@p5, @d1, CAST(GETDATE() AS DATE), '10:00:00', 'PROGRAMADA'),
(@p6, @d4, CAST(GETDATE() AS DATE), '17:00:00', 'ATENDIDA'),

-- Pendientes / Futuras (PROGRAMADA y REAGENDADA)
(@p1, @d1, DATEADD(DAY, 2,  CAST(GETDATE() AS DATE)), '09:00:00', 'PROGRAMADA'),
(@p7, @d3, DATEADD(DAY, 4,  CAST(GETDATE() AS DATE)), '12:00:00', 'PROGRAMADA'),
(@p2, @d2, DATEADD(DAY, 5,  CAST(GETDATE() AS DATE)), '15:30:00', 'REAGENDADA'),

-- Canceladas
(@p3, @d1, DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), '11:30:00', 'CANCELADA'),
(@p4, @d4, DATEADD(DAY, 3,  CAST(GETDATE() AS DATE)), '18:00:00', 'CANCELADA');
GO

-- =========================================================
-- 4. HISTORIAL PARA LAS CITAS MARCADAS COMO 'ATENDIDA'
-- =========================================================
INSERT INTO Historial (id_cita, diagnostico)
SELECT 
    c.id_cita,
    CASE 
        WHEN p.correo = 'juan@mail.com' THEN 'Limpieza dental profunda y profilaxis. Sin caries activas. Revisión en 6 meses.'
        WHEN p.correo = 'maria@mail.com' THEN 'Pulpitis reversible en pieza 36. Se realiza tratamiento de conductos y colocación de obturación temporal.'
        WHEN p.correo = 'sofia.castillo@mail.com' THEN 'Ajuste de arco y revisión de brackets en arcada superior e inferior. Higiene adecuada.'
        WHEN p.correo = 'diego.morales@mail.com' THEN 'Revisión dental preventiva en paciente pediátrico y aplicación tópica de flúor.'
        WHEN p.correo = 'ale.gutierrez@mail.com' THEN 'Valoración de tercer molar inferior derecho retenido; se solicita radiografía panorámica y analgésico.'
        ELSE 'Consulta odontológica completada satisfactoriamente.'
    END
FROM Citas c
INNER JOIN Pacientes p ON c.id_paciente = p.id_paciente
WHERE c.estado = 'ATENDIDA'
  AND NOT EXISTS (SELECT 1 FROM Historial h WHERE h.id_cita = c.id_cita);
GO

-- Verificación rápida
SELECT * FROM Dentistas;
SELECT * FROM Pacientes;
SELECT * FROM Citas ORDER BY fecha DESC, hora DESC;
SELECT * FROM Historial;
GO