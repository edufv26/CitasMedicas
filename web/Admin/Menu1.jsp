<%-- 
    Document   : Menu1
    Created on : 12 nov 2026, 10:45:34 p.m.
    Author     : edu
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Menú Principal - Clínica Dental</title>
        <!-- Icono de la pestaña (Favicon) -->
        <link rel="icon" type="image/svg+xml" href="../icons/favicon.svg">
        <!-- Estilos -->
        <link rel="stylesheet" href="../css/menu.css">
        <link rel="stylesheet" href="../css/font-awesome.css">
        <!-- JavaScript -->
        <script src="../js/menu.js"></script>
        <script src="../js/modoOscuro.js"></script>
        
    </head>
    <body>

        <nav class="navbar-clinica" aria-label="Menú principal">

            <!-- Nombre de la clínica -->
            <div class="nav-brand">
                <a href="Menu1.html">
                    <span class="fa fa-plus icon-menu"></span>
                    Clínica Dental - Vitalis
                </a>
            </div>
            <!-- Saludo del usuario logueado -->

            <div class="nav-user-welcome" style="display: flex; align-items: center; margin-right: 15px; font-size: 13px; color: #542b83; font-weight: 500;">
                <h2> Hola, <%= session.getAttribute("nombreUsuario") != null ? session.getAttribute("nombreUsuario") : "Usuario"%></h2>
            </div>
            <!-- Opciones principales -->
            <ul class="nav-menu">

                <!-- Pacientes -->
                <li class="nav-item">

                    <button
                        type="button"
                        class="drop-toggle"
                        aria-expanded="false"
                        aria-controls="menu-pacientes">

                        <span class="fa fa-user icon-menu"></span>
                        Pacientes
                        <span class="arrow">▾</span>
                    </button>

                    <div class="dropdown-menu" id="menu-pacientes">
                        <a href="AltaPacientes.html">Alta de Pacientes</a>
                        <a href="BajaPacientes.jsp">Baja de Pacientes</a>
                        <a href="ConsultaMedico.jsp"><span class="fa fa-users icon-menu"></span>    Consultar Pacientes</a>
                        <a href="ModificaPaciente.jsp">Modificar Datos de Paciente</a>
                    </div>

                </li>

                <!-- Personal -->
                <li class="nav-item">

                    <button
                        type="button"
                        class="drop-toggle"
                        aria-expanded="false"
                        aria-controls="menu-personal">

                        <span class="fa fa-user-md icon-menu"></span>
                        Personal
                        <span class="arrow">▾</span>
                    </button>

                    <div class="dropdown-menu" id="menu-personal">
                        <a href="AltaPersonal.html">Alta de Personal</a>
                        <a href="Baja.html">Baja de Personal</a>
                        <a href="ConsultaPaciente.jsp">Consultar Personal</a>
                        <a href="ConsultaMedico.jsp">Consultar Médicos</a>
                        <a href="ModificaPaciente.jsp">Modificar Paciente</a>
                        <a href="ModificaMédico.jsp">Modificar Médico</a>
                    </div>

                </li>

                <!-- Citas -->
                <li class="nav-item">

                    <button
                        type="button"
                        class="drop-toggle"
                        aria-expanded="false"
                        aria-controls="menu-citas">

                        <span class="fa fa-calendar icon-menu"></span>
                        Citas
                        <span class="arrow">▾</span>
                    </button>

                    <div class="dropdown-menu" id="menu-citas">
                        <a href="Agendar.jsp">Agendar Cita</a>
                        <a href="Cancelar.jsp">Cancelar / Reagendar Cita</a>
                        <a href="ConsultarCitas.jsp">Consultar Citas</a>
                    </div>

                </li>

                <!-- Reportes -->
                <li class="nav-item">

                    <button
                        type="button"
                        class="drop-toggle"
                        aria-expanded="false"
                        aria-controls="menu-reportes">

                        <span class="fa fa-file-text icon-menu"></span>
                        Reportes
                        <span class="arrow">▾</span>
                    </button>

                    <div class="dropdown-menu" id="menu-reportes">

                        <a href="Historialdecitas.jsp">
                            <span class="fa fa-file-pdf-o icon-menu"></span>
                            Historial General de Citas
                        </a>
                        <a href="#">
                            <span class="fa fa-file-pdf-o icon-menu"></span>
                            Historial de Citas del Medico    
                        </a>
                        <a href="#">
                            <span class="fa fa-bar-chart-o icon-menu"></span>
                            Reporte con grafico de barras
                        </a>
                        <a href="#">
                            <span class="fa fa-pie-chart icon-menu"></span>
                            Reporte con grafico de barras
                        </a>
                    </div>

                </li>

            </ul>
            <!-- Lado izquierdo o medio de la barra (El botón del modo oscuro solito) -->
            <div class="nav-actions">
                <button type="button" id="btn-modo-oscuro" class="btn-theme-toggle" title="Cambiar modo oscuro">
                    <span class="fa fa-moon-o" style="font-size: 22px;"></span>
                </button>
            </div>

            <!-- Lado derecho de la barra (Tu botón de Cerrar Sesión solito) -->
            <div class="nav-actions">
                <a href="../index.html" class="btn-salir">
                    Cerrar Sesión
                </a>
            </div>

        </nav>
    </body>
</html>
