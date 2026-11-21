<%-- 
    Document   : Pacientes (DENTISTAS)
    Created on : 21 nov 2026
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="bean.Pacientes"%>

<jsp:useBean id="pacienteVista" class="bean.Pacientes" scope="request"/>
<jsp:useBean id="tablaPacientes" class="bean.Pacientes" scope="page"/>
<jsp:setProperty name="tablaPacientes" property="respuesta" value="${requestScope.tablaPacientesHtml}"/>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mis Pacientes - Clínica Dental</title>

        <!-- icono svg + css -->
        <link rel="icon" type="image/svg+xml" href="<%= request.getContextPath()%>/icons/favicon.svg">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/menu.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/font-awesome.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/pacientes.css">

        <!-- Scripts -->
        <script src="<%= request.getContextPath()%>/js/modoOscuro.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/modal-global.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/menu.js" defer></script>
    </head>
    <body>
        <!-- Barra de navegación -->
        <%@ include file="navbarDentista.jsp" %>
        <div id="loading-overlay">
            <div class="spinner"></div>
            <div class="loading-text">Cargando...</div>
        </div>

        <!-- Contenedor Principal Unificado -->
        <div class="container-contenido">

            <!-- Cabecera: Botón Volver + Título -->
            <div class="header-seccion">
                <div class="header-left">
                    <a href="<%= request.getContextPath()%>/Control?accion=menu" class="btn-regresar">
                        <span class="fa fa-chevron-left"></span> Volver
                    </a>
                    <h2><span class="fa fa-users"></span> Mis Pacientes</h2>
                </div>
            </div>

            <!-- Filtros directos con selector (estilo Citas) -->
            <form action="Control" method="get" class="filtros">
                <input type="hidden" name="accion" value="pacientes">

                <div class="campo-grupo">
                    <label for="fPacSelector">Paciente:</label>
                    <select id="fPacSelector" name="idPaciente">
                        <option value="">Todos</option>
                        <jsp:getProperty name="pacienteVista" property="opcionesPacientesFiltro"/>
                    </select>
                </div>

                <div class="filtros-acciones">
                    <button type="submit" class="btn-accion-principal">
                        <span class="fa fa-filter"></span> Filtrar
                    </button>
                    <a href="<%= request.getContextPath()%>/Control?accion=pacientes" class="btn-limpiar">
                        <span class="fa fa-eraser"></span> Limpiar
                    </a>
                </div>
            </form>

            <!-- Tabla de Pacientes -->
            <div class="table-responsive">
                <table class="tabla-clinica">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre Completo</th>
                            <th>Teléfono</th>
                            <th>Correo</th>
                            <th>Último Diagnóstico</th>
                        </tr>
                    </thead>
                    <tbody>
                        <jsp:getProperty name="tablaPacientes" property="respuesta"/>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>