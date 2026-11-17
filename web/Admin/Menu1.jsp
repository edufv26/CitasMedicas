<%-- 
    Document   : Menu1
    Descripción: Vista principal del Administrador
    Created:     edu
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Menú Principal - Administrador</title>
        
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
            <div class="loading-text">Cargando Sistema...</div>
        </div>

        <!-- Barra de navegación del Admin -->
        <%@ include file="navbarAdmin.jsp" %>

        <!-- Contenido del Dashboard -->
        <div class="container-contenido" style="padding: 40px; font-family: system-ui, sans-serif;">
            <h1>Dashboard</h1>
            <p>Selecciona una opción en el menú superior para administrar pacientes, personal o citas.</p>
        </div>
    </body>
</html>