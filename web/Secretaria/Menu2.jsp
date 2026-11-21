<%-- 
    Document   : Menu2 (SECRETARIAS)
    Created on : 12 nov 2026, 10:45:34 p.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Menú Principal - Secretaria</title>

        <!-- Favicon e Iconos -->
        <link rel="icon" type="image/svg+xml" href="<%= request.getContextPath()%>/icons/favicon.svg">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/font-awesome.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/menu.css">

        <!-- Scripts Globales -->
        <script src="<%= request.getContextPath()%>/js/modoOscuro.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/menu.js" defer></script>
    </head>
    <body>
        <!-- Pantalla de carga (Loader) -->
        <div id="loading-overlay">
            <div class="spinner"></div>
            <div class="loading-text">Cargando...</div>
        </div>

        <!-- Barra de navegación de la secretaria -->
        <%@ include file="navbarSecretaria.jsp" %>

        <!-- Contenido del Dashboard -->
        <div class="container-contenido" style="padding: 40px; font-family: system-ui, sans-serif;">
            <h1>Dashboard</h1>
            <p>Selecciona una opción en el menú superior para administrar pacientes o citas.</p>
            <h2> Citas del día de hoy</h2>
            <jsp:useBean id="citasHoy" class="bean.Citas" scope="page"/>
            <jsp:setProperty name="citasHoy" property="usuarioLogin" value="${sessionScope.usuarioLogin}"/>
            <jsp:setProperty name="citasHoy" property="tipoRol" value="${sessionScope.tipo != null ? sessionScope.tipo : 1}"/>

            <div class="contenedor-citashoy">
                <table class="tabla-citashoy">
                    <thead>
                        <tr>
                            <th>Hora</th>
                            <th>Paciente</th>
                            <th>Teléfono</th>
                            <th>Doctor</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <jsp:getProperty name="citasHoy" property="miniTablaCitasHoy"/>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>