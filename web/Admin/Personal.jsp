<%-- 
    Document   : Personal (ADMIN)
    Created on : 18 nov 2026
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="bean.Personal"%>
<%@page import="bean.Dentistas"%>
<%@page import="bean.Secretarias"%>
<%
    Personal perEdit = (Personal) request.getAttribute("personalEdit");
    boolean esEdicion = (perEdit != null);

    List<Personal> listaAdmins = (List<Personal>) request.getAttribute("listaAdmins");
    List<Dentistas> listaDentistas = (List<Dentistas>) request.getAttribute("listaDentistas");
    List<Secretarias> listaSecretarias = (List<Secretarias>) request.getAttribute("listaSecretarias");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Gestión de Personal - Clínica Dental</title>

        <!-- icono svg + css -->
        <link rel="icon" type="image/svg+xml" href="<%= request.getContextPath()%>/icons/favicon.svg">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/menu.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/font-awesome.css">
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/personal.css">

        <!-- Scripts -->
        <script src="<%= request.getContextPath()%>/js/modoOscuro.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/modal-global.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/menu.js" defer></script>
        <script src="<%= request.getContextPath()%>/js/personal.js" defer></script>
    </head>
    <body>
        <%@ include file="navbarAdmin.jsp" %>
        <div id="loading-overlay">
            <div class="spinner"></div>
            <div class="loading-text">Cargando...</div>
        </div>

        <div class="container-contenido">
            <!-- Cabecera: Botón Volver + Título (Izquierda) | Botón Alta General (Derecha) -->
            <div class="header-seccion">
                <div class="header-left">
                    <a href="<%= request.getContextPath()%>/Control?accion=menu" class="btn-regresar">
                        <span class="fa fa-chevron-left"></span> Volver
                    </a>
                    <h2><span class="fa fa-id-badge"></span> Gestión de Personal</h2>
                </div>

                <button type="button" data-abrir="modalRegistro" class="btn-accion-principal">
                    <span class="fa fa-user-plus"></span> Dar de alta personal
                </button>
            </div>

            <!-- 1. TABLA DE ADMINISTRADORES -->
            <h3 style="margin-top: 20px;"><span class="fa fa-shield"></span> Administradores</h3>
            <div class="table-responsive">
                <table class="tabla-clinica">
                    <thead>
                        <tr>
                            <th>Usuario</th>
                            <th>Nombre Completo</th>
                            <th>Teléfono</th>
                            <th>Correo</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (listaAdmins != null && !listaAdmins.isEmpty()) {
                                for (Personal a : listaAdmins) {
                        %>
                        <tr>
                            <td><b><%= a.getUsuario()%></b></td>
                            <td><%= a.getNombre()%> <%= a.getPaterno()%> <%= a.getMaterno() != null ? a.getMaterno() : ""%></td>
                            <td><%= a.getTelefono() != null ? a.getTelefono() : "-"%></td>
                            <td><%= a.getCorreo() != null ? a.getCorreo() : "-"%></td>
                            <td class="text-center">
                                <a href="Control?accion=editarPersonal&usuario=<%= a.getUsuario()%>&tipo=1" class="btn-icon-tabla editar" title="Editar"><span class="fa fa-pencil"></span></a>
                                <button type="button" class="btn-icon-tabla" title="Cambiar contraseña" onclick="abrirModalPassword('<%= a.getUsuario()%>')"><span class="fa fa-key"></span></button>
                                <a href="#" onclick="abrirModalEliminar('<%= a.getUsuario()%>')" class="btn-icon-tabla eliminar" title="Eliminar"><span class="fa fa-trash"></span></a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="text-center" style="padding: 16px; color: #666;">No hay administradores registrados.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- 2. TABLA DE DENTISTAS -->
            <h3 style="margin-top: 28px;"><span class="fa fa-user-md"></span> Dentistas</h3>
            <div class="table-responsive">
                <table class="tabla-clinica">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Nombre Completo</th>
                            <th>Especialidad</th>
                            <th>Cédula</th>
                            <th>Turno</th>
                            <th>Teléfono</th>
                            <th>Correo</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (listaDentistas != null && !listaDentistas.isEmpty()) {
                                for (Dentistas d : listaDentistas) {
                        %>
                        <tr>
                            <td><%= d.getIdDentista()%></td>
                            <td><b><%= d.getUsuario()%></b></td>
                            <td><%= d.getNombre()%> <%= d.getPaterno() != null ? d.getPaterno() : ""%> <%= d.getMaterno() != null ? d.getMaterno() : ""%></td>
                            <td><%= d.getEspecialidad()%></td>
                            <td><%= d.getCedula()%></td>
                            <td><%= d.getTurno()%></td>
                            <td><%= d.getTelefono() != null ? d.getTelefono() : "-"%></td>
                            <td><%= d.getCorreo() != null ? d.getCorreo() : "-"%></td>
                            <td class="text-center">
                                <a href="Control?accion=editarPersonal&usuario=<%= d.getUsuario()%>&tipo=2" class="btn-icon-tabla editar" title="Editar"><span class="fa fa-pencil"></span></a>
                                <button type="button" class="btn-icon-tabla" title="Cambiar contraseña" onclick="abrirModalPassword('<%= d.getUsuario()%>')"><span class="fa fa-key"></span></button>
                                <a href="#" onclick="abrirModalEliminar('<%= d.getUsuario()%>')" class="btn-icon-tabla eliminar" title="Eliminar"><span class="fa fa-trash"></span></a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" class="text-center" style="padding: 16px; color: #666;">No hay dentistas registrados.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- 3. TABLA DE SECRETARIAS -->
            <h3 style="margin-top: 28px;"><span class="fa fa-headphones"></span> Secretarias</h3>
            <div class="table-responsive">
                <table class="tabla-clinica">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Nombre Completo</th>
                            <th>Turno</th>
                            <th>Teléfono</th>
                            <th>Correo</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (listaSecretarias != null && !listaSecretarias.isEmpty()) {
                                for (Secretarias s : listaSecretarias) {
                        %>
                        <tr>
                            <td><%= s.getIdSec()%></td>
                            <td><b><%= s.getUsuario()%></b></td>
                            <td><%= s.getNombre()%> <%= s.getPaterno() != null ? s.getPaterno() : ""%> <%= s.getMaterno() != null ? s.getMaterno() : ""%></td>
                            <td><%= s.getTurno()%></td>
                            <td><%= s.getTelefono() != null ? s.getTelefono() : "-"%></td>
                            <td><%= s.getCorreo() != null ? s.getCorreo() : "-"%></td>
                            <td class="text-center">
                                <a href="Control?accion=editarPersonal&usuario=<%= s.getUsuario()%>&tipo=3" class="btn-icon-tabla editar" title="Editar"><span class="fa fa-pencil"></span></a>
                                <button type="button" class="btn-icon-tabla" title="Cambiar contraseña" onclick="abrirModalPassword('<%= s.getUsuario()%>')"><span class="fa fa-key"></span></button>
                                <a href="#" onclick="abrirModalEliminar('<%= s.getUsuario()%>')" class="btn-icon-tabla eliminar" title="Eliminar"><span class="fa fa-trash"></span></a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="7" class="text-center" style="padding: 16px; color: #666;">No hay secretarias registradas.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- MODAL ALTA / EDICIÓN DE PERSONAL -->
        <dialog id="modalRegistro" <%= esEdicion ? "open" : ""%>>
            <form action="Control" method="post">
                <div class="modal-header-registro">
                    <h3><%= esEdicion ? "Editar Personal" : "Nuevo Personal"%></h3>
                    <button type="button" data-cerrar class="modal-btn-x">&times;</button>
                </div>

                <input type="hidden" name="accion" value="<%= esEdicion ? "actualizarPersonal" : "registrarPersonal"%>">

                <div class="campo-grupo">
                    <label for="usuario">Usuario:</label>
                    <input type="text" id="usuario" name="usuario" maxlength="12" value="<%= esEdicion ? perEdit.getUsuario() : ""%>" <%= esEdicion ? "readonly" : "required"%>>
                </div>

                <% if (!esEdicion) { %>
                <div class="campo-grupo">
                    <label for="password">Contraseña:</label>
                    <input type="password" id="password" name="password" required>
                </div>
                <% } %>

                <div class="campo-grupo">
                    <label for="nombre">Nombre:</label>
                    <input type="text" id="nombre" name="nombre" value="<%= esEdicion ? perEdit.getNombre() : ""%>" required>
                </div>
                <div class="campo-grupo">
                    <label for="APaterno">Apellido paterno:</label>
                    <input type="text" id="APaterno" name="APaterno" value="<%= esEdicion ? perEdit.getPaterno() : ""%>" required>
                </div>
                <div class="campo-grupo">
                    <label for="AMaterno">Apellido materno:</label>
                    <input type="text" id="AMaterno" name="AMaterno" value="<%= esEdicion && perEdit.getMaterno() != null ? perEdit.getMaterno() : ""%>">
                </div>
                <div class="campo-grupo">
                    <label for="telefono">Teléfono:</label>
                    <input type="tel" id="telefono" name="telefono" maxlength="15" value="<%= esEdicion && perEdit.getTelefono() != null ? perEdit.getTelefono() : ""%>">
                </div>
                <div class="campo-grupo">
                    <label for="correo">Correo:</label>
                    <input type="email" id="correo" name="correo" maxlength="50" value="<%= esEdicion && perEdit.getCorreo() != null ? perEdit.getCorreo() : ""%>">
                </div>

                <div class="campo-grupo">
                    <label for="tipo">Tipo de Personal:</label>
                    <select id="tipo" name="tipo" onchange="mostrarCamposExtra()" required>
                        <option value="" disabled <%= !esEdicion ? "selected" : ""%>>Seleccione un rol...</option>
                        <option value="1" <%= (esEdicion && perEdit.getTipo() == 1) ? "selected" : ""%>>Administrador</option>
                        <option value="2" <%= (esEdicion && perEdit.getTipo() == 2) ? "selected" : ""%>>Secretaria</option>
                        <option value="3" <%= (esEdicion && perEdit.getTipo() == 3) ? "selected" : ""%>>Dentista</option>
                    </select>
                </div>

                <!-- Campos extra Dentista -->
                <div id="seccion-dentista" class="seccion-extra" style="display: none;">
                    <div class="campo-grupo">
                        <label for="especialidad">Especialidad:</label>
                        <input type="text" id="especialidad" name="especialidad" maxlength="50" value="<%= (esEdicion && perEdit instanceof Dentistas && ((Dentistas) perEdit).getEspecialidad() != null) ? ((Dentistas) perEdit).getEspecialidad() : ""%>">
                    </div>
                    <div class="campo-grupo">
                        <label for="cedula">Cédula Profesional:</label>
                        <input type="text" id="cedula" name="cedula" maxlength="20" value="<%= (esEdicion && perEdit instanceof Dentistas && ((Dentistas) perEdit).getCedula() != null) ? ((Dentistas) perEdit).getCedula() : ""%>">
                    </div>
                    <div class="campo-grupo">
                        <label for="turnoDentista">Turno:</label>
                        <select id="turnoDentista" name="turnoDentista">
                            <option value="Matutino" <%= (esEdicion && perEdit instanceof Dentistas && "Matutino".equals(((Dentistas) perEdit).getTurno())) ? "selected" : ""%>>Matutino</option>
                            <option value="Vespertino" <%= (esEdicion && perEdit instanceof Dentistas && "Vespertino".equals(((Dentistas) perEdit).getTurno())) ? "selected" : ""%>>Vespertino</option>
                        </select>
                    </div>
                </div>

                <!-- Campos extra Secretaria -->
                <div id="seccion-secretaria" class="seccion-extra" style="display: none;">
                    <div class="campo-grupo">
                        <label for="turnoSecretaria">Turno:</label>
                        <select id="turnoSecretaria" name="turnoSecretaria">
                            <option value="Matutino" <%= (esEdicion && perEdit instanceof Secretarias && "Matutino".equals(((Secretarias) perEdit).getTurno())) ? "selected" : ""%>>Matutino</option>
                            <option value="Vespertino" <%= (esEdicion && perEdit instanceof Secretarias && "Vespertino".equals(((Secretarias) perEdit).getTurno())) ? "selected" : ""%>>Vespertino</option>
                        </select>
                    </div>
                </div>

                <button type="submit" class="btn-submit-modal">
                    <%= esEdicion ? "Guardar Cambios" : "Guardar Personal"%>
                </button>
            </form>
        </dialog>

        <!-- MODAL CENTRALIZADO DE CAMBIO DE CONTRASEÑA (CONFIRMACIÓN + FORMULARIO) -->
        <dialog id="modalPassword">
            <form action="Control" method="post" id="formPassword">
                <div class="modal-header-registro">
                    <h3>Cambiar Contraseña</h3>
                    <button type="button" data-cerrar onclick="resetModalPassword()" class="modal-btn-x">&times;</button>
                </div>

                <input type="hidden" name="accion" value="cambiarPassword">
                <input type="hidden" id="passUsuario" name="usuario" value="">

                <!-- Paso 1: Confirmación -->
                <div id="paso-confirmar-pass">
                    <p class="modal-texto">
                        ¿Segur@ que quieres crear una contraseña nueva para <b id="passUsuarioTexto"></b>?
                    </p>
                    <div class="modal-acciones">
                        <button type="button" data-cerrar onclick="resetModalPassword()" class="btn-modal-cancelar">Cancelar</button>
                        <button type="button" onclick="confirmarNuevaPassword()" class="btn-accion-principal">Sí, crear nueva contraseña</button>
                    </div>
                </div>

                <!-- Paso 2: Campo de nueva contraseña -->
                <div id="paso-form-pass" style="display: none;">
                    <p class="modal-texto">Usuario: <b id="passUsuarioFormTexto"></b></p>

                    <div class="campo-grupo">
                        <label for="nuevaPassword">Nueva contraseña:</label>
                        <input type="password" id="nuevaPassword" name="nuevaPassword">
                    </div>

                    <button type="submit" class="btn-submit-modal">Actualizar Contraseña</button>
                </div>
            </form>
        </dialog>

        <!-- MODAL DE CONFIRMACIÓN DE ELIMINACIÓN -->
        <dialog id="modalEliminar">
            <div class="modal-header">
                <h3 class="modal-titulo-peligro"><span class="fa fa-exclamation-triangle"></span> Confirmar Baja</h3>
                <button type="button" data-cerrar class="modal-btn-cerrar">&times;</button>
            </div>
            <p class="modal-texto">¿Estás seguro de dar de baja a este usuario del personal?</p>
            <div class="modal-acciones">
                <button type="button" data-cerrar class="btn-modal-cancelar">Cancelar</button>
                <a id="btnConfirmarEliminar" href="#" class="btn-modal-peligro">Sí, Dar de Baja</a>
            </div>
        </dialog>
    </body>
</html>