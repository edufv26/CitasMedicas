<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Consultar Citas</title>
</head>
<body>
    <h2>Filtro y Consulta de Citas</h2>
    <form action="#" method="get">
        <label for="filtro">Filtrar consultas por:</label>
        <select name="filtro" id="filtro">
            <option value="dia">Por Día</option>
            <option value="semana">Por Semana</option>
            <option value="mes">Por Mes</option>
        </select>
        <button type="submit">Consultar</button>
    </form>
    <br>
    <table border="1">
        <tr>
            <th>ID Cita</th>
            <th>Paciente</th>
            <th>Fecha</th>
            <th>Hora</th>
            <th>Médico</th>
        </tr>
    </table>
    <br>
    <a href="Menu1.html">Volver al Menú Principal</a>
</body>
</html>