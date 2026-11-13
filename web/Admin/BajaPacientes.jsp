<%-- 
    Document   : BajaPacientes
    Created on : 12 nov 2026, 2:10:40 p.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="bean.Pacientes"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Baja Pacientes</title>
        <link rel="stylesheet" href="../css/bajas.css">
    </head>
    <body>
    <div class="form-container">
        <!-- Botón de Regresar arriba, pero dentro de la misma tarjeta -->
        <form action="Menu1.html" method="get" style="margin-bottom: 15px;">
            <button type="submit" class="btn-regresar" title="Volver al menú">
                &#8592; Volver al Menú
            </button>
        </form>

        <!-- Formulario principal de Baja -->
        <form action="Control" method="post">
            <h2>Baja de Pacientes</h2>

            <div class="campo">
                <label for="id_paciente">Seleccione el Paciente:</label>

                <%
                    Pacientes p = new Pacientes();
                    p.llenarSelectorPacientes();
                    out.print(p.getRespuesta());
                %>

            </div>

            <input type="submit" class="btn-baja" value="Dar de Baja Paciente" name="bajaPacientes">
        </form>
    </div>
</body>
</html>
