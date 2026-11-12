<%-- 
    Document   : BajaPacientes
    Created on : 12 nov 2026, 2:10:40 p.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="objBaja" class="bean.Pacientes" scope="page" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Baja Pacientes</title>
        <link rel="stylesheet" href="bajas.css">
    </head>
    <body>
        <div class="form-container">
        <!-- Apuntas al Servlet que va a procesar la baja con tu SP sp_BajaPacientecc -->
        <form action="Control" method="post">
            <h2>Baja de Pacientes</h2>

            <div class="campo">
                <label for="id_paciente">Seleccione el Paciente:</label>
                
                <%
                    objBaja.llenarSelectorPacientes();
                    out.print(objBaja.getRespuesta());
                %>
            </div>

            <input type="submit" class="btn-enviar" value="Dar de Baja Paciente" name="accion" style="background-color: #e74c3c;">
        </form>
    </div>
    </body>
</html>
