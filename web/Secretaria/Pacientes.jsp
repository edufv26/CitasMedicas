<%-- 
    Document   : Pacientes (SECRETARIAS)
    Created on : 13 nov 2026, 10:38:27 a.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="bean.Pacientes"%>
<%@page import="bean.Dentistas"%>
<%@page import="bean.Personal"%>

<jsp:useBean id="pacienteEdit" class="bean.Pacientes" scope="request"/>
<jsp:useBean id="mensajeBean" class="bean.Pacientes" scope="request"/>
<jsp:useBean id="tablaPacientes" class="bean.Pacientes" scope="page"/>
<jsp:setProperty name="tablaPacientes" property="respuesta" value="${requestScope.tablaPacientesHtml}"/>

<jsp:useBean id="selectorDoctor" class="bean.Dentistas" scope="page"/>
<jsp:setProperty name="selectorDoctor" property="respuesta" value="${requestScope.selectDoctorHtml}"/>

<%
    // Si el Servlet mandó un paciente para editar, vendrá con idP > 0
    boolean esEdicion = (pacienteEdit.getIdP() > 0);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Gestión de Pacientes - Clínica Dental</title>

        <!-- icono svg + css -->
        <link rel="icon" type="image/svg+xml" href="<%= request.getContextPath()%>/icons/favicon.svg">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/menu.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/font-awesome.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/pacientes.css">

        <!-- Scripts  -->
        <script src="<%= request.getContextPath()%>/js/modoOscuro.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/modal-global.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/menu.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/pacientes.js" defer></script>
    </head>
    <body data-mensaje-respuesta="<jsp:getProperty name="mensajeBean" property="mensajeAttr"/>">
        <!-- CONTROL DEL SERVLET -->
        <form action="Control" method="post">
            <!-- Barra de navegación -->
            <%@ include file="navbarSecretaria.jsp" %>
            <div id="loading-overlay">
                <div class="spinner"></div>
                <div class="loading-text">Cargando...</div>
            </div>

            <!-- Contenedor Principal Unificado -->
            <div class="container-contenido">

                <!-- Cabecera: Botón Volver + Título (Izquierda) | Botón Alta (Derecha) -->
                <div class="header-seccion">

                    <div class="header-left">
                        <!-- Botón de Volver -->
                        <a href="<%= request.getContextPath()%>/Control?accion=menu" class="btn-regresar">
                            <span class="fa fa-chevron-left"></span> Volver
                        </a>
                        <h2><span class="fa fa-users"></span> Lista de Pacientes</h2>
                    </div>

                    <!-- Botón de Alta -->
                    <button type="button" data-abrir="modalRegistro" class="btn-accion-principal">
                        <span class="fa fa-user-plus"></span> Dar de alta a paciente
                    </button>
                </div>

                <!-- Filtros de Pacientes (Búsqueda general + Doctor Asignado) -->
                <div id="filtrosPacientes" class="filtros">
                    <div class="campo-grupo">
                        <label for="fPacBuscar">Buscar (nombre, correo, teléfono o dirección):</label>
                        <input type="text" id="fPacBuscar" placeholder="Ej. Camila, @gmail.com, Ecatepec, 5512...">
                    </div>

                    <div class="campo-grupo">
                        <label for="fPacDoctor">Doctor asignado:</label>
                        <select id="fPacDoctor">
                            <option value="">Todos</option>
                        </select>
                    </div>

                    <div class="filtros-acciones">
                        <button type="button" id="btnFiltrarPacientes" class="btn-accion-principal">
                            <span class="fa fa-filter"></span> Filtrar
                        </button>
                        <button type="button" id="btnLimpiarPacientes" class="btn-limpiar">
                            <span class="fa fa-eraser"></span> Limpiar
                        </button>
                    </div>
                </div>

                <!-- Tabla de Pacientes -->
                <div class="table-responsive">
                    <table class="tabla-clinica">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre Completo</th>
                                <th>Teléfono</th>
                                <th>Correo</th>
                                <th>Dirección</th>
                                <th>Doctor Asignado</th>
                                <th class="text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <jsp:getProperty name="tablaPacientes" property="respuesta"/>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Ventana Flotante (Modal) unificada para Registro y Edición -->
            <dialog id="modalRegistro" <%= esEdicion ? "open" : ""%>>
                <div class="modal-header-registro">
                    <h3><%= esEdicion ? "Editar Paciente" : "Nuevo Paciente"%></h3>
                    <button type="button" data-cerrar class="modal-btn-x">&times;</button>
                </div>

                <!-- Acción dinámica para el Servlet ('actualizar' o 'registrar') -->
                <input type="hidden" name="accion" value="<%= esEdicion ? "actualizar" : "registrar"%>">

                <!-- ID oculto indispensable para saber qué registro actualizar -->
                <% if (esEdicion) {%>
                <input type="hidden" name="idP" value="<jsp:getProperty name="pacienteEdit" property="idP"/>">
                <% }%>

                <div class="campo-grupo">
                    <label>Nombre:</label>
                    <input type="text" name="nombre" value="<% if (esEdicion && pacienteEdit.getNombre() != null) { %><jsp:getProperty name="pacienteEdit" property="nombre"/><% } %>" required>
                </div>
                <div class="campo-grupo">
                    <label>Apellido paterno:</label>
                    <input type="text" name="paterno" value="<% if (esEdicion && pacienteEdit.getaPaterno() != null) { %><jsp:getProperty name="pacienteEdit" property="aPaterno"/><% } %>" required>
                </div>
                <div class="campo-grupo">
                    <label>Apellido materno:</label>
                    <input type="text" name="materno" value="<% if (esEdicion && pacienteEdit.getaMaterno() != null) { %><jsp:getProperty name="pacienteEdit" property="aMaterno"/><% } %>" required>
                </div>
                <div class="campo-grupo">
                    <label>Teléfono:</label>
                    <input type="tel" name="tel" value="<% if (esEdicion && pacienteEdit.getTelefono() != null) { %><jsp:getProperty name="pacienteEdit" property="telefono"/><% } %>" required>
                </div>
                <div class="campo-grupo">
                    <label>Correo:</label>
                    <input type="email" name="correo" value="<% if (esEdicion && pacienteEdit.getCorreo() != null) { %><jsp:getProperty name="pacienteEdit" property="correo"/><% } %>" required>
                </div>
                <div class="campo-grupo">
                    <label>Dirección:</label>
                    <input type="text" name="direccion" value="<% if (esEdicion && pacienteEdit.getDireccion() != null) { %><jsp:getProperty name="pacienteEdit" property="direccion"/><% }%>" required>
                </div>

                <!-- Selector de Doctor de Preferencia (Visible SOLO en modo Edición) -->
                <jsp:getProperty name="selectorDoctor" property="respuesta"/>

                <button type="submit" class="btn-submit-modal">
                    <%= esEdicion ? "Guardar Cambios" : "Guardar Paciente"%>
                </button>
            </dialog>

            <!-- Modal de Advertencia / Confirmación de Eliminación -->
            <dialog id="modalEliminar">
                <div class="modal-header">
                    <h3 class="modal-titulo-peligro"><span class="fa fa-exclamation-triangle"></span> Confirmar Eliminación</h3>
                    <button type="button" data-cerrar class="modal-btn-cerrar">&times;</button>
                </div>

                <p class="modal-texto">
                    ¿Estás seguro de eliminar este paciente del sistema?
                </p>

                <div class="modal-acciones">
                    <button type="button" data-cerrar class="btn-modal-cancelar">Cancelar</button>
                    <a id="btnConfirmarEliminar" href="#" class="btn-modal-peligro">Sí, Eliminar</a>
                </div>
            </dialog>
        </form> 
    </body>
</html>