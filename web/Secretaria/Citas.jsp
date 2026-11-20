<%--
    Document   : Citas (SECRETARIAS)
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
        <title>Gestión de Citas - Clínica Dental</title>

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
        <%@ include file="navbarSecretaria.jsp" %>
        <div id="loading-overlay">
            <div class="spinner"></div>
            <div class="loading-text">Cargando...</div>
        </div>

        <!-- Contenedor Principal Unificado -->
        <div class="container-contenido">

            <!-- Cabecera: Botón Volver + Título (Izquierda) | Botón Agendar (Derecha) -->
            <div class="header-seccion">
                <div class="header-left">
                    <!-- Botón de Volver -->
                    <a href="<%= request.getContextPath()%>/Control?accion=menu" class="btn-regresar">
                        <span class="fa fa-chevron-left"></span> Volver
                    </a>
                    <h2><span class="fa fa-calendar"></span> Gestión de Citas</h2>
                </div>

                <!-- Botón de Agendar -->
                <button type="button" data-abrir="modalAgendar" class="btn-accion-principal">
                    <span class="fa fa-calendar-plus-o"></span> Agendar cita
                </button>
            </div>

            <!-- Pestañas: citas pendientes / historial -->
            <div class="tabs-citas">
                <a href="<%= request.getContextPath()%>/Control?accion=citas&vista=pendientes" class="tab-cita <%= citasVista.isHistorial() ? "" : "activo"%>">
                    <span class="fa fa-clock-o"></span> Pendientes
                </a>
                <a href="<%= request.getContextPath()%>/Control?accion=citas&vista=historial" class="tab-cita <%= citasVista.isHistorial() ? "activo" : ""%>">
                    <span class="fa fa-history"></span> Historial
                </a>
            </div>

            <!-- Filtros por fecha, doctor y paciente -->
            <form action="Control" method="get" class="filtros-citas">
                <input type="hidden" name="accion" value="citas">
                <input type="hidden" name="vista" value="<jsp:getProperty name="citasVista" property="vista"/>">

                <div class="campo-grupo">
                    <label for="fFecha">Fecha:</label>
                    <input type="date" id="fFecha" name="fecha" value="<jsp:getProperty name="citasVista" property="filtroFecha"/>">
                </div>

                <div class="campo-grupo">
                    <label for="fDoctor">Doctor:</label>
                    <select id="fDoctor" name="idDentista">
                        <option value="">Todos</option>
                        <jsp:getProperty name="citasVista" property="opcionesDentistasFiltro"/>
                    </select>
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
                    <% if (citasVista.isHistorial()) {%>
                    <a href="<%= request.getContextPath()%>/Control?accion=pdfCitas<jsp:getProperty name="citasVista" property="queryFiltros"/>" target="_blank" class="btn-pdf">
                        <span class="fa fa-file-pdf-o"></span> Exportar PDF
                    </a>
                    <% }%>
                </div>
            </form>

            <!-- Tabla de Citas -->
            <div class="table-responsive">
                <table class="tabla-clinica">
                    <thead>
                        <tr>
                            <th>Folio</th>
                            <th>Paciente</th>
                            <th>Doctor</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Estado</th>
                            <% if (citasVista.isHistorial()) { %>
                            <th>Diagnóstico</th>
                            <% } else { %>
                            <th class="text-center">Acciones</th>
                            <% }%>
                        </tr>
                    </thead>
                    <tbody>
                        <jsp:getProperty name="citasVista" property="tablaHtml"/>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Ventana Flotante (Modal) para Agendar -->
        <dialog id="modalAgendar" class="modal-citas">
            <form action="Control" method="post">
                <div class="modal-header-registro">
                    <h3><span class="fa fa-calendar-plus-o"></span> Agendar cita</h3>
                    <button type="button" data-cerrar class="modal-btn-x">&times;</button>
                </div>

                <input type="hidden" name="accion" value="agendar">

                <div class="campo-grupo">
                    <label for="agPaciente">Paciente:</label>
                    <select id="agPaciente" name="paciente" required>
                        <option value="">-- Selecciona un paciente --</option>
                        <jsp:getProperty name="citasVista" property="opcionesPacientes"/>
                    </select>
                </div>
                <div class="campo-grupo">
                    <label for="agMedico">Doctor:</label>
                    <select id="agMedico" name="medico">
                        <option value="AUTO">Automático (doctor de preferencia)</option>
                        <jsp:getProperty name="citasVista" property="opcionesDentistas"/>
                    </select>
                </div>
                <div class="campo-grupo">
                    <label for="agFecha">Fecha:</label>
                    <input type="date" id="agFecha" name="fecha" data-fecha-min required>
                </div>
                <div class="campo-grupo">
                    <label for="agHora">Hora:</label>
                    <input type="time" id="agHora" name="hora" required>
                </div>

                <button type="submit" class="btn-submit-modal">Guardar cita</button>
            </form>
        </dialog>

        <!-- Ventana Flotante (Modal) para Reagendar -->
        <dialog id="modalReagendar" class="modal-citas">
            <form action="Control" method="post">
                <div class="modal-header-registro">
                    <h3><span class="fa fa-calendar-check-o"></span> Reagendar cita #<span id="reIdTexto"></span></h3>
                    <button type="button" data-cerrar class="modal-btn-x">&times;</button>
                </div>

                <input type="hidden" name="accion" value="reagendar">
                <input type="hidden" id="reIdCita" name="idCita">

                <div class="campo-grupo">
                    <label for="reFecha">Nueva fecha:</label>
                    <input type="date" id="reFecha" name="nuevaFecha" data-fecha-min required>
                </div>
                <div class="campo-grupo">
                    <label for="reHora">Nueva hora:</label>
                    <input type="time" id="reHora" name="nuevaHora" required>
                </div>

                <button type="submit" class="btn-submit-modal">Confirmar reagendado</button>
            </form>
        </dialog>

        <!-- Modal de Advertencia / Confirmación de Cancelación -->
        <dialog id="modalCancelar" class="modal-citas">
            <form action="Control" method="post">
                <div class="modal-header">
                    <h3 class="modal-titulo-peligro"><span class="fa fa-exclamation-triangle"></span> Cancelar cita</h3>
                    <button type="button" data-cerrar class="modal-btn-cerrar">&times;</button>
                </div>

                <input type="hidden" name="accion" value="cancelar">
                <input type="hidden" id="caIdCita" name="idCita">

                <p class="modal-texto">
                    ¿Estás seguro de cancelar la cita #<span id="caIdTexto"></span>? Esta acción libera el horario del doctor.
                </p>

                <div class="modal-acciones">
                    <button type="button" data-cerrar class="btn-modal-cancelar">Volver</button>
                    <button type="submit" class="btn-modal-peligro">Sí, cancelar cita</button>
                </div>
            </form>
        </dialog>
    </body>
</html>
