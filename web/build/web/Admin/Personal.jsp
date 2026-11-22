<%-- 
    Document   : Personal (ADMIN)
    Created on : 18 nov 2026
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<jsp:useBean id="perEdit" class="bean.Personal" scope="request"/>
<jsp:useBean id="denEdit" class="bean.Dentistas" scope="request"/>
<jsp:useBean id="secEdit" class="bean.Secretarias" scope="request"/>

<jsp:useBean id="adminVista" class="bean.Personal" scope="page"/>
<jsp:setProperty name="adminVista" property="respuesta" value="${requestScope.tablaAdminsHtml}"/>

<jsp:useBean id="dentistaVista" class="bean.Dentistas" scope="page"/>
<jsp:setProperty name="dentistaVista" property="respuesta" value="${requestScope.tablaDentistasHtml}"/>

<jsp:useBean id="secretariaVista" class="bean.Secretarias" scope="page"/>
<jsp:setProperty name="secretariaVista" property="respuesta" value="${requestScope.tablaSecretariasHtml}"/>

<%
    boolean esEdicion = (perEdit.getUsuario() != null && !perEdit.getUsuario().trim().isEmpty());
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
    <body data-es-edicion="<%= esEdicion%>" data-tipo-edicion="<jsp:getProperty name="perEdit" property="tipo"/>" data-turno-dentista="<jsp:getProperty name="denEdit" property="turno"/>" data-turno-secretaria="<jsp:getProperty name="secEdit" property="turno"/>">
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

            <!-- Filtros de Personal (Tipo + Búsqueda general, activado con botón Filtrar) -->
            <div id="filtrosPersonal" class="filtros">
                <div class="campo-grupo">
                    <label for="fPerTipo">Tipo de personal:</label>
                    <select id="fPerTipo">
                        <option value="todos">Todos</option>
                        <option value="admin">Solo Administradores</option>
                        <option value="dentista">Solo Dentistas</option>
                        <option value="secretaria">Solo Secretarias</option>
                    </select>
                </div>

                <div class="campo-grupo">
                    <label for="fPerBuscar">Buscar por nombre, usuario, especialidad, cédula, turno, teléfono o correo:</label>
                    <input type="text" id="fPerBuscar" placeholder="Ej. Eduardo, Matutino, Ortodoncia...">
                </div>

                <div class="filtros-acciones">
                    <button type="button" id="btnFiltrarPersonal" class="btn-accion-principal">
                        <span class="fa fa-filter"></span> Filtrar
                    </button>
                    <button type="button" id="btnLimpiarPersonal" class="btn-limpiar">
                        <span class="fa fa-eraser"></span> Limpiar
                    </button>
                </div>
            </div>

            <!-- 1. TABLA DE ADMINISTRADORES -->
            <div data-rol-personal="admin">
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
                            <jsp:getProperty name="adminVista" property="respuesta"/>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 2. TABLA DE DENTISTAS -->
            <div data-rol-personal="dentista">
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
                            <jsp:getProperty name="dentistaVista" property="respuesta"/>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 3. TABLA DE SECRETARIAS -->
            <div data-rol-personal="secretaria">
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
                            <jsp:getProperty name="secretariaVista" property="respuesta"/>
                        </tbody>
                    </table>
                </div>
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
                    <input type="text" id="usuario" name="usuario" maxlength="12" value="<jsp:getProperty name="perEdit" property="usuario"/>" <%= esEdicion ? "readonly" : "required"%>>
                </div>

                <% if (!esEdicion) { %>
                <div class="campo-grupo">
                    <label for="password">Contraseña:</label>
                    <input type="password" id="password" name="password" required>
                </div>
                <% } %>

                <div class="campo-grupo">
                    <label for="nombre">Nombre:</label>
                    <input type="text" id="nombre" name="nombre" value="<jsp:getProperty name="perEdit" property="nombre"/>" required>
                </div>
                <div class="campo-grupo">
                    <label for="APaterno">Apellido paterno:</label>
                    <input type="text" id="APaterno" name="APaterno" value="<jsp:getProperty name="perEdit" property="paterno"/>" required>
                </div>
                <div class="campo-grupo">
                    <label for="AMaterno">Apellido materno:</label>
                    <input type="text" id="AMaterno" name="AMaterno" value="<jsp:getProperty name="perEdit" property="materno"/>">
                </div>
                <div class="campo-grupo">
                    <label for="telefono">Teléfono:</label>
                    <input type="tel" id="telefono" name="telefono" maxlength="15" value="<jsp:getProperty name="perEdit" property="telefono"/>">
                </div>
                <div class="campo-grupo">
                    <label for="correo">Correo:</label>
                    <input type="email" id="correo" name="correo" maxlength="50" value="<jsp:getProperty name="perEdit" property="correo"/>">
                </div>

                <div class="campo-grupo">
                    <label for="tipo">Tipo de Personal:</label>
                    <select id="tipo" name="tipo" onchange="mostrarCamposExtra()" required>
                        <option value="">Seleccione un rol...</option>
                        <option value="1">Administrador</option>
                        <option value="2">Dentista</option>
                        <option value="3">Secretaria</option>
                    </select>
                </div>

                <!-- Campos extra Dentista -->
                <div id="seccion-dentista" class="seccion-extra" style="display: none;">
                    <div class="campo-grupo">
                        <label for="especialidad">Especialidad:</label>
                        <input type="text" id="especialidad" name="especialidad" maxlength="50" value="<jsp:getProperty name="denEdit" property="especialidad"/>">
                    </div>
                    <div class="campo-grupo">
                        <label for="cedula">Cédula Profesional:</label>
                        <input type="text" id="cedula" name="cedula" maxlength="20" value="<jsp:getProperty name="denEdit" property="cedula"/>">
                    </div>
                    <div class="campo-grupo">
                        <label for="turnoDentista">Turno:</label>
                        <select id="turnoDentista" name="turnoDentista">
                            <option value="Matutino">Matutino</option>
                            <option value="Vespertino">Vespertino</option>
                        </select>
                    </div>
                </div>

                <!-- Campos extra Secretaria -->
                <div id="seccion-secretaria" class="seccion-extra" style="display: none;">
                    <div class="campo-grupo">
                        <label for="turnoSecretaria">Turno:</label>
                        <select id="turnoSecretaria" name="turnoSecretaria">
                            <option value="Matutino">Matutino</option>
                            <option value="Vespertino">Vespertino</option>
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