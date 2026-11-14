<%-- 
    Document   : Pacientes
    Created on : 13 nov 2026, 10:38:27 a.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="bean.Pacientes"%>
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
            <%@ include file="Menu1.jsp" %>

            <!-- Contenedor Principal Unificado -->
            <div class="container-contenido" style="padding: 30px;">

                <!-- Cabecera: Botón Volver + Título (Izquierda) | Botón Alta (Derecha) -->
                <div class="header-seccion" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">

                    <div style="display: flex; align-items: center; gap: 15px;">
                        <!-- Botón de Volver -->
                        <a href="<%= request.getContextPath()%>/Admin/Menu1.jsp" class="btn-regresar">
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
                <div class="table-responsive" style="background: var(--bg-card, #ffffff); border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden;">
                    <table class="tabla-clinica" style="width: 100%; border-collapse: collapse; text-align: left;">
                        <thead>
                            <tr style="background-color: #542b83; color: white;">
                                <th style="padding: 12px 15px;">ID</th>
                                <th style="padding: 12px 15px;">Nombre Completo</th>
                                <th style="padding: 12px 15px;">Teléfono</th>
                                <th style="padding: 12px 15px;">Correo</th>
                                <th style="padding: 12px 15px;">Dirección</th>
                                <th style="padding: 12px 15px; text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                // Recibimos la lista enviada desde el Servlet
                                List<Pacientes> listaPacientes = (List<Pacientes>) request.getAttribute("listaPacientes");
                                if (listaPacientes != null && !listaPacientes.isEmpty()) {
                                    for (Pacientes p : listaPacientes) {
                            %>
                            <tr style="border-bottom: 1px solid var(--border-color, #e5e7eb); color: var(--text-color, #333);">
                                <td style="padding: 12px 15px;"><%= p.getIdP()%></td>
                                <td style="padding: 12px 15px;"><%= p.getNombre()%> <%= p.getaPaterno()%> <%= p.getaMaterno()%></td>
                                <td style="padding: 12px 15px;"><%= p.getTelefono()%></td>
                                <td style="padding: 12px 15px;"><%= p.getCorreo()%></td>
                                <td style="padding: 12px 15px;"><%= p.getDireccion()%></td>
                                <td style="padding: 12px 15px; text-align: center;">
                                    <a href="Control?accion=editar&id=<%= p.getIdP()%>" class="btn-icon-tabla editar" title="Editar" style="color: #3b82f6; margin-right: 10px; font-size: 16px;"><span class="fa fa-pencil"></span></a>
                                    <a href="Control?accion=eliminar&id=<%= p.getIdP()%>" class="btn-icon-tabla eliminar" title="Eliminar" style="color: #ef4444; font-size: 16px;" onclick="return confirm('¿Estás seguro de eliminar este paciente?');"><span class="fa fa-trash"></span></a>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr>
                                <td colspan="6" style="padding: 20px; text-align: center; color: #666;">No hay pacientes registrados en el sistema.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Ventana Flotante (Modal) con margin: auto para que salga perfectamente centrada -->
            <dialog id="modalRegistro" style="margin: auto; border: none; border-radius: 10px; padding: 25px; max-width: 500px; width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.3); background-color: var(--bg-card, #ffffff); color: var(--text-color, #333);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <h3 style="color: #542b83;">Nuevo Paciente</h3>
                    <button type="button" data-cerrar style="background: transparent; border: none; font-size: 20px; cursor: pointer; color: #666;">&times;</button>
                </div>

                <input type="hidden" name="accion" value="registrar">

                <div class="campo" style="margin-bottom: 12px;">
                    <label style="display:block; font-size: 13px; margin-bottom: 4px;">Nombre:</label>
                    <input type="text" name="nombre" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px;">
                </div>
                <div class="campo" style="margin-bottom: 12px;">
                    <label style="display:block; font-size: 13px; margin-bottom: 4px;">Apellido paterno:</label>
                    <input type="text" name="paterno" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px;">
                </div>
                <div class="campo" style="margin-bottom: 12px;">
                    <label style="display:block; font-size: 13px; margin-bottom: 4px;">Apellido materno:</label>
                    <input type="text" name="materno" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px;">
                </div>
                <div class="campo" style="margin-bottom: 12px;">
                    <label style="display:block; font-size: 13px; margin-bottom: 4px;">Teléfono:</label>
                    <input type="tel" name="tel" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px;">
                </div>
                <div class="campo" style="margin-bottom: 12px;">
                    <label style="display:block; font-size: 13px; margin-bottom: 4px;">Correo:</label>
                    <input type="email" name="correo" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px;">
                </div>
                <div class="campo" style="margin-bottom: 20px;">
                    <label style="display:block; font-size: 13px; margin-bottom: 4px;">Dirección:</label>
                    <input type="text" name="direccion" required style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px;">
                </div>

                <button type="submit" style="width: 100%; background: #542b83; color: white; padding: 10px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer;">Guardar Paciente</button>

            </dialog>
        </form> 
    </body>
</html>