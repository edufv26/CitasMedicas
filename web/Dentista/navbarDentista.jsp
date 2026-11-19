<%-- 
    Document   : navbarSecretaria
    Created on : 16 nov 2026, 6:02:56 p.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<nav class="navbar-clinica" aria-label="Menú principal Admin">
    <!-- Nombre de la clínica -->
    <div class="nav-brand">
        <h2>
            <span class="fa fa-plus icon-menu"></span>
            Clínica Dental - Vitalis <span style="font-size: 11px; opacity: 0.8;">(Dentista)</span>
        </h2>
    </div>

    <!-- Saludo del usuario logueado -->
    <div class="nav-user-welcome" style="display: flex; align-items: center; margin-right: 15px; font-size: 13px; color: #542b83; font-weight: 500;">
        <h2>Hola, <%= session.getAttribute("nombreUsuario") != null ? session.getAttribute("nombreUsuario") : "Admin"%></h2>
    </div>

    <!-- Opciones principales -->
    <ul class="nav-menu">

        <!-- Pacientes -->
        <li class="nav-item">
            <button type="button" class="drop-toggle" aria-expanded="false" aria-controls="menu-pacientes">
                <span class="fa fa-user icon-menu"></span> Pacientes <span class="arrow">▾</span>
            </button>
            <div class="dropdown-menu" id="menu-pacientes">
                <a href="<%= request.getContextPath()%>/Control?accion=pacientes">
                    <span class="fa fa-users"></span> Gestion de Pacientes
                </a>
            </div>
        </li>
        <!-- Citas -->
        <li class="nav-item">
            <button type="button" class="drop-toggle" aria-expanded="false" aria-controls="menu-citas">
                <span class="fa fa-calendar icon-menu"></span> Citas <span class="arrow">▾</span>
            </button>
            <div class="dropdown-menu" id="menu-citas">
                <a href="<%= request.getContextPath()%>/Control?accion=citas">
                    <span class="fa fa-calendar-o"></span> Gestion de Citas
                </a>
            </div>
        </li>
    </ul>

    <!-- Botón del modo oscuro -->
    <div class="nav-actions">
        <button type="button" id="btn-modo-oscuro" class="btn-theme-toggle" title="Cambiar modo oscuro">
            <span class="fa fa-moon-o" style="font-size: 22px;"></span>
        </button>
    </div>

    <!-- Botón de Cerrar Sesión -->
    <div class="nav-actions">
        <a href="<%= request.getContextPath()%>/Control?accion=logout" class="btn-salir">
            Cerrar Sesión
        </a>
    </div>

</nav>