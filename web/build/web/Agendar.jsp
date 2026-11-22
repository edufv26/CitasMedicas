<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Agendar Cita</title>
</head>
<body>
    <h2>Agendar Nueva Cita Médica</h2>
    <form action="#" method="post">
        <label for="paciente">Nombre / ID Paciente:</label>
        <input type="text" id="paciente" name="paciente" required>
        <br><br>
        <label for="fecha">Fecha de Cita:</label>
        <input type="date" id="fecha" name="fecha" required>
        <br><br>
        <label for="hora">Hora:</label>
        <input type="time" id="hora" name="hora" required>
        <br><br>
        <label for="medico">Médico Asignado:</label>
        <select name="medico" id="medico">
            <option value="1">Médico 1 (Preferente)</option>
            <option value="2">Médico 2</option>
        </select>
        <br><br>
        <button type="submit">Verificar Disponibilidad y Agendar</button>
    </form>
    <br>
    <a href="Menu1.html">Volver al Menú Principal</a>
</body>
</html>