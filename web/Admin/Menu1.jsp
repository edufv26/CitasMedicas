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
        <!-- Estilos -->
    <link rel="stylesheet" href="../css/menu.css">

    <!-- JavaScript -->
    <script src="../js/menu.js"></script>
    </head>
    <body>
       
    <nav class="navbar-clinica" aria-label="Menú principal">

        <!-- Nombre de la clínica -->
        <div class="nav-brand">
            <a href="Menu1.html">
                <span class="brand-icon">✚</span>
                Clínica Dental
            </a>
        </div>
        <!-- Saludo del usuario logueado -->
        
<div class="nav-user-welcome" style="display: flex; align-items: center; margin-right: 15px; font-size: 13px; color: #542b83; font-weight: 500;">
    <h2><span class="fa fa-home icon-menu"> Hola, <%= session.getAttribute("nombreUsuario") != null ? session.getAttribute("nombreUsuario") : "Usuario" %></span></h2>
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

                    <span class="nav-icon">♙</span>
                    Pacientes
                    <span class="arrow">▾</span>
                </button>

                <div class="dropdown-menu" id="menu-pacientes">
                    <a href="AltaPacientes.html">Alta de Pacientes</a>
                    <a href="BajaPacientes.jsp">Baja de Pacientes</a>
                    <a href="ConsultaMedico.jsp">Consultar Pacientes</a>
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

                    <span class="nav-icon">♧</span>
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

                    <span class="nav-icon">▦</span>
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

                    <span class="nav-icon">▤</span>
                    Reportes
                    <span class="arrow">▾</span>
                </button>

                <div class="dropdown-menu" id="menu-reportes">
                    <a href="Historialdecitas.jsp">
                        Historial General de Citas (PDF)
                    </a>
                </div>

            </li>

        </ul>

        <!-- Cerrar sesión -->
        <div class="nav-actions">
            <a href="../index.html" class="btn-salir">
                Cerrar Sesión
            </a>
        </div>

    </nav>
    </body>
</html>
