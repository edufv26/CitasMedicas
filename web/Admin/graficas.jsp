<%-- 
    Document   : Graficas (ADMINS)
    Created on : 12 nov 2026, 10:45:34 p.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Gráficas de Pacientes por Médico</title>
        <!-- Favicon e Iconos -->
        <link rel="icon" type="image/svg+xml" href="<%= request.getContextPath()%>/icons/favicon.svg">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/font-awesome.css">
        
        <!-- estilos -->
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/menu.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/graficas.css">

        <!-- Scripts Globales -->
        <script src="<%= request.getContextPath()%>/js/modoOscuro.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/menu.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/graficas.js" defer></script>
    </head>
    <body>
        <!-- Barra de navegación -->
        <%@ include file="navbarAdmin.jsp" %>

        <jsp:useBean id="datosGraficas" class="bean.Datos" scope="request"/>
        <!-- Pantalla de carga (Loader) -->
        <div id="loading-overlay">
            <div class="spinner"></div>
            <div class="loading-text">Cargando...</div>
        </div>
        <!-- Pantalla de carga para las graficas/pdf -->
        <div id="overlayGraficas" class="cargando-overlay" aria-live="polite" aria-hidden="true">
            <div class="spinner-graficas"></div>
            <div id="textoCargaGraficas" class="cargando-texto">Generando gráficas...</div>
            <div id="subtextoCargaGraficas" class="cargando-subtexto">Consultando datos y renderizando visualizaciones</div>
        </div>

        <div class="contenedor">
            <!-- Cabecera: Botón Volver + Título (Izquierda) -->
            <div class="header-seccion">
                <div class="header-left">
                    <a href="<%= request.getContextPath()%>/Control?accion=pacientes" class="btn btn-secundario">
                        <span class="fa fa-chevron-left"></span> Volver a Pacientes
                    </a>
                    <h2><span class="fa fa-calendar"></span> Gráficas de Pacientes por Médico</h2>
                </div>
            </div>

            <form class="panel-controles" action="<%= request.getContextPath()%>/Control" method="get">
                <input type="hidden" name="accion" value="graficas">
                <input type="hidden" name="generar" value="1">

                <label for="idDentista">Doctor:</label>
                <jsp:getProperty name="datosGraficas" property="selectDoctores"/>

                <label for="periodo">Periodo:</label>
                <jsp:getProperty name="datosGraficas" property="selectPeriodo"/>

                <button type="submit" class="btn">Crear Gráficas</button>
            </form>

            <jsp:getProperty name="datosGraficas" property="bloqueGraficas"/>

            <form class="panel-controles" action="<%= request.getContextPath()%>/Control" method="get" style="margin-top: 12px;">
                <input type="hidden" name="accion" value="pdfGraficas">
                <input type="hidden" name="idDentista" value="<jsp:getProperty name="datosGraficas" property="idDentistaSeleccionado"/>">
                <input type="hidden" name="periodo" value="<jsp:getProperty name="datosGraficas" property="periodo"/>">

                <jsp:getProperty name="datosGraficas" property="bloquePdf"/>
            </form>
        </div>
    </body>
</html>