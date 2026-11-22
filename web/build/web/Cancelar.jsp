<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Cancelar o Reagendar Cita</title>
</head>
<body>
    <h2>Cancelar o Reagendar Cita Médica</h2>
    <form action="#" method="post">
        <label for="idCita">ID de Cita:</label>
        <input type="text" id="idCita" name="idCita" required>
        <br><br>
        <button type="submit" name="accion" value="cancelar">Cancelar Cita</button>
        <button type="submit" name="accion" value="reagendar">Reagendar Cita</button>
    </form>
    <br>
    <a href="Menu1.html">Volver al Menú Principal</a>
</body>
</html>