<%--
    Document   : Citas (DENTISTAS)
    Created on : 19 nov 2026
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="bean.Citas"%>

<jsp:useBean id="citasVista" class="bean.Citas" scope="request"/>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mi Agenda de Citas - Clínica Dental</title>

        <!-- icono svg + css -->
        <link rel="icon" type="image/svg+xml" href="<%= request.getContextPath()%>/icons/favicon.svg">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/menu.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/font-awesome.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/citas.css">

        <!-- Scripts  -->
        <script src="<%= request.getContextPath()%>/js/modoOscuro.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/modal-global.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/menu.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/citas.js" defer></script>
    </head>
    <body data-mensaje-respuesta="<jsp:getProperty name="citasVista" property="mensajeAttr"/>">
        <!-- Barra de navegación -->
        <%@ include file="navbarDentista.jsp" %>
        <div id="loading-overlay">
            <div class="spinner"></div>
            <div class="loading-text">Cargando...</div>
        </div>

        <!-- Contenedor Principal Unificado -->
        <div class="container-contenido">

            <!-- Cabecera: Botón Volver + Título (Izquierda) -->
            <div class="header-seccion">
                <div class="header-left">
                    <a href="<%= request.getContextPath()%>/Control?accion=menu" class="btn-regresar">
                        <span class="fa fa-chevron-left"></span> Volver
                    </a>
                    <h2><span class="fa fa-calendar"></span> Mi Agenda de Citas</h2>
                </div>
            </div>

            <!-- Pestañas: citas pendientes / historial -->
            <jsp:getProperty name="citasVista" property="pestanasHtml"/>

            <!-- Filtros por fecha y paciente -->
            <form action="Control" method="get" class="filtros-citas" data-seccion-cita="filtros">
                <input type="hidden" name="accion" value="citas">
                <input type="hidden" name="vista" value="<jsp:getProperty name="citasVista" property="vista"/>">

                <div class="campo-grupo">
                    <label for="fFecha">Fecha:</label>
                    <input type="date" id="fFecha" name="fecha" value="<jsp:getProperty name="citasVista" property="filtroFecha"/>">
                </div>
                <div class="campo-grupo">
                    <label for="fPaciente">Paciente:</label>
                    <select id="fPaciente" name="idPaciente">
                        <option value="">Todos</option>
                        <jsp:getProperty name="citasVista" property="opcionesPacientesFiltro"/>
                    </select>
                </div>

                <div class="filtros-acciones">
                    <button type="submit" class="btn-accion-principal">
                        <span class="fa fa-filter"></span> Filtrar
                    </button>
                    <a href="<%= request.getContextPath()%>/Control?accion=citas&vista=<jsp:getProperty name="citasVista" property="vista"/>" class="btn-limpiar">
                        <span class="fa fa-eraser"></span> Limpiar
                    </a>
                    <jsp:getProperty name="citasVista" property="botonPdfDentistaHtml"/>
                </div>
            </form>

            <!-- Tabla de Citas -->
            <div class="table-responsive" data-seccion-cita="tabla">
                <table class="tabla-clinica">
                    <thead>
                        <tr>
                            <th>Folio</th>
                            <th>Paciente</th>
                            <th>Doctor</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Estado</th>
                            <jsp:getProperty name="citasVista" property="encabezadoDinamicoHtml"/>
                        </tr>
                    </thead>
                    <tbody>
                        <jsp:getProperty name="citasVista" property="tablaHtml"/>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Ventana Flotante (Modal) para Atender la cita -->
        <dialog id="modalAtender" class="modal-citas">
            <form action="Control" method="post">
                <div class="modal-header-registro">
                    <h3><span class="fa fa-stethoscope"></span> Atender cita #<span id="atIdTexto"></span></h3>
                    <button type="button" data-cerrar class="modal-btn-x">&times;</button>
                </div>

                <input type="hidden" name="accion" value="atender">
                <input type="hidden" id="atIdCita" name="idCita">

                <div class="campo-grupo">
                    <label for="atDiagnostico">Diagnóstico / tratamiento:</label>
                    <textarea id="atDiagnostico" name="diagnostico" rows="5" placeholder="Escribe el diagnóstico, notas y tratamiento o receta..." required></textarea>
                </div>

                <button type="submit" class="btn-submit-modal">Guardar y marcar como atendida</button>
            </form>
        </dialog>
    </body>
</html>