<%-- 
    Document   : Pacientes (SECRETARIAS)
    Created on : 13 nov 2026, 10:38:27 a.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="bean.Pacientes"%>
<%@page import="bean.Dentistas"%>
<%
    // Verificamos si el servlet mandó un paciente para editar
    Pacientes pacEdit = (Pacientes) request.getAttribute("pacienteEdit");
    boolean esEdicion = (pacEdit != null);
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
    </head>
    <body>
        <form action="Control" method="post">
            <!-- Barra de navegación -->
            <%@ include file="navbarSecretaria.jsp" %>

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
                            <%
                                // Recibimos la lista enviada desde el Servlet
                                List<Pacientes> listaPacientes = (List<Pacientes>) request.getAttribute("listaPacientes");
                                if (listaPacientes != null && !listaPacientes.isEmpty()) {
                                    for (Pacientes p : listaPacientes) {
                            %>
                            <tr>
                                <td><%= p.getIdP()%></td>
                                <td><%= p.getNombre()%> <%= p.getaPaterno()%> <%= p.getaMaterno()%></td>
                                <td><%= p.getTelefono()%></td>
                                <td><%= p.getCorreo()%></td>
                                <td><%= p.getDireccion()%></td>
                                <td>
                                    <% if (p.getIdDenP() > 0) { %>
                                        <b>Dr(a). <%= p.getNombreDentista() %></b>
                                    <% } else { %>
                                        <i>No asignado</i>
                                    <% } %>
                                </td>
                                <td class="text-center">
                                    <a href="Control?accion=editar&id=<%= p.getIdP()%>" class="btn-icon-tabla editar" title="Editar"><span class="fa fa-pencil"></span></a>
                                    <!-- Botón de eliminar conectado al modal personalizado -->
                                    <a href="#" onclick="abrirModalEliminar('<%= p.getIdP()%>')" class="btn-icon-tabla eliminar" title="Eliminar"><span class="fa fa-trash"></span></a>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr>
                                <td colspan="7" class="text-center" style="padding: 20px; color: #666;">No hay pacientes registrados en el sistema.</td>
                            </tr>
                            <%
                                }
                            %>
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
                <input type="hidden" name="idP" value="<%= pacEdit.getIdP()%>">
                <% }%>

                <div class="campo-grupo">
                    <label>Nombre:</label>
                    <input type="text" name="nombre" value="<%= esEdicion ? pacEdit.getNombre() : ""%>" required>
                </div>
                <div class="campo-grupo">
                    <label>Apellido paterno:</label>
                    <input type="text" name="paterno" value="<%= esEdicion ? pacEdit.getaPaterno() : ""%>" required>
                </div>
                <div class="campo-grupo">
                    <label>Apellido materno:</label>
                    <input type="text" name="materno" value="<%= esEdicion ? pacEdit.getaMaterno() : ""%>" required>
                </div>
                <div class="campo-grupo">
                    <label>Teléfono:</label>
                    <input type="tel" name="tel" value="<%= esEdicion ? pacEdit.getTelefono() : ""%>" required>
                </div>
                <div class="campo-grupo">
                    <label>Correo:</label>
                    <input type="email" name="correo" value="<%= esEdicion ? pacEdit.getCorreo() : ""%>" required>
                </div>
                <div class="campo-grupo">
                    <label>Dirección:</label>
                    <input type="text" name="direccion" value="<%= esEdicion ? pacEdit.getDireccion() : ""%>" required>
                </div>

                <!-- Selector de Doctor de Preferencia (Visible SOLO en modo Edición) -->
                <% if (esEdicion) { %>
                <div class="campo-grupo select-doctor">
                    <label>Doctor de Preferencia:</label>
                    <select name="idDenP">
                        <option value="0" <%= (pacEdit.getIdDenP() == 0) ? "selected" : "" %>>-- No asignado --</option>
                        <%
                            List<Dentistas> listaDentistas = (List<Dentistas>) request.getAttribute("listaDentistas");
                            if (listaDentistas != null && !listaDentistas.isEmpty()) {
                                for (Dentistas d : listaDentistas) {
                                    boolean seleccionado = (pacEdit.getIdDenP() == d.getIdDentista());
                        %>
                        <option value="<%= d.getIdDentista() %>" <%= seleccionado ? "selected" : "" %>>
                            Dr(a). <%= d.getNombre() %> - <%= d.getEspecialidad() %>
                        </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                <% } %>

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