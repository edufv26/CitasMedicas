import bean.Citas;
import bean.Datos;
import bean.Dentistas;
import bean.Pacientes;
import bean.Personal;
import bean.Secretarias;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/Control"})
public class Control extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        System.out.println("ENTRÓ A PROCESSREQUEST");
        // 1. Obtener la acción solicitada
        String accion = request.getParameter("accion");
        System.out.println("================================");
        System.out.println("MÉTODO: " + request.getMethod());
        System.out.println("URI: " + request.getRequestURI());
        System.out.println("ACCIÓN ORIGINAL: " + accion);
        System.out.println("USUARIO: " + request.getParameter("usuario"));
        System.out.println("================================");

        if (accion == null || accion.trim().isEmpty()) {
            accion = "inicio";
        }
        Personal p = new Personal();
        Pacientes pa = new Pacientes();
        Dentistas d = new Dentistas();
        Secretarias s = new Secretarias();
        Citas ci = new Citas();

        System.out.println("Método HTTP: " + request.getMethod());
        System.out.println("Acción recibida: " + accion);

        // 2. Validación de inicio de sesión
        if (accion.equals("validar")) {

            // Dentro de tu acción de login/validar en el Servlet:
            p.setUsuario(request.getParameter("usuario"));
            p.setPassword(request.getParameter("password"));
            p.validar();

            if (p.getRespuesta() != null && !p.getRespuesta().contains("Error.jsp")) {
                HttpSession session = request.getSession();
                session.setAttribute("tipo", p.getTipo());
                session.setAttribute("nombreUsuario", p.getNombre());
                session.setAttribute("usuarioLogin", p.getUsuario());
            }

            //redirección a respuesta
            response.sendRedirect(p.getRespuesta());
            return;
        }

        // 3. Módulo de pacientes
        if (accion.equals("pacientes")) {
            System.out.println("Servlet: acción pacientes detectada");

            HttpSession session = request.getSession();
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;

            if (tipoUsuario == 3) {
                String idPacStr = request.getParameter("idPaciente");
                int idPac = 0;
                if (idPacStr != null && !idPacStr.trim().isEmpty()) {
                    try {
                        idPac = Integer.parseInt(idPacStr.trim());
                    } catch (NumberFormatException e) {
                        idPac = 0;
                    }
                }
                pa.setFiltroIdPaciente(idPac);
                pa.aplicarRolDentista((String) session.getAttribute("usuarioLogin"));
                pa.generarOpcionesDentista();
                pa.mostrarTablaDentista();
                request.setAttribute("pacienteVista", pa);
            } else {
                pa.mostrarTabla();
            }
            request.setAttribute("tablaPacientesHtml", pa.getRespuesta());

            String msg = (String) session.getAttribute("mensajeDialog");
            if (msg != null) {
                session.removeAttribute("mensajeDialog");
            }
            Pacientes mensajeBean = new Pacientes();
            mensajeBean.setRespuesta(msg != null ? msg : "");
            request.setAttribute("mensajeBean", mensajeBean);

            // Determinamos la carpeta dinámicamente
            String carpeta = "Admin/";
            if (tipoUsuario == 2) {
                carpeta = "Secretaria/";
            } else if (tipoUsuario == 3) {
                carpeta = "Dentista/";
            }

            String vistaDestino = carpeta + "Pacientes.jsp";
            System.out.println("Servlet: redirigiendo a -> " + vistaDestino);

            request.getRequestDispatcher(vistaDestino).forward(request, response);
            return;
        }

        // 3b. Módulo de gráficas de pacientes por médico
        if (accion.equals("graficas")) {
            System.out.println("Servlet: acción graficas detectada");

            String periodo = request.getParameter("periodo");
            String generar = request.getParameter("generar");
            String idDentistaParam = request.getParameter("idDentista");

            int idDentistaSel = 0;
            if (idDentistaParam != null && !idDentistaParam.trim().isEmpty()) {
                try {
                    idDentistaSel = Integer.parseInt(idDentistaParam.trim());
                } catch (NumberFormatException e) {
                    idDentistaSel = 0;
                }
            }

            List<Dentistas> listaDoctores = d.llenarListaDentistas();
            String nombreDoctorSel = "Todos los doctores";

            if (idDentistaSel > 0 && listaDoctores != null) {
                for (Dentistas doc : listaDoctores) {
                    if (doc.getIdDentista() == idDentistaSel) {
                        String nom = doc.getNombre() != null ? doc.getNombre().trim() : "";
                        String pat = doc.getPaterno() != null ? doc.getPaterno().trim() : "";
                        String mat = doc.getMaterno() != null ? doc.getMaterno().trim() : "";
                        nombreDoctorSel = ("Dr(a). " + nom + " " + pat + " " + mat).trim().replaceAll("\\s+", " ");
                        break;
                    }
                }
            }

            Datos datosGraficas = new Datos();
            datosGraficas.setPeriodo((periodo != null && !periodo.trim().isEmpty()) ? periodo : "mensual");
            datosGraficas.setIdDentistaSeleccionado(idDentistaSel);
            datosGraficas.setNombreDoctorSeleccionado(nombreDoctorSel);

            if ("1".equals(generar)) {
                String rutaReal = getServletContext().getRealPath("/");
                datosGraficas.generarGraficas(rutaReal, datosGraficas.getPeriodo(), idDentistaSel, nombreDoctorSel);
            }

            request.setAttribute("listaDoctores", listaDoctores);
            request.setAttribute("datosGraficas", datosGraficas);
            request.getRequestDispatcher("graficas.jsp").forward(request, response);
            return;
        }

        // 3c. Exportar gráficas y tabla de pacientes del periodo a PDF
        if (accion.equals("pdfGraficas")) {
            System.out.println("Servlet: acción pdfGraficas detectada");

            String periodo = request.getParameter("periodo");
            String idDentistaParam = request.getParameter("idDentista");
            String tipoGraficaPdf = request.getParameter("tipoGraficaPdf");

            int idDentistaSel = 0;
            if (idDentistaParam != null && !idDentistaParam.trim().isEmpty()) {
                try {
                    idDentistaSel = Integer.parseInt(idDentistaParam.trim());
                } catch (NumberFormatException e) {
                    idDentistaSel = 0;
                }
            }

            List<Dentistas> listaDoctores = d.llenarListaDentistas();
            String nombreDoctorSel = "Todos los doctores";
            if (idDentistaSel > 0 && listaDoctores != null) {
                for (Dentistas doc : listaDoctores) {
                    if (doc.getIdDentista() == idDentistaSel) {
                        String nom = doc.getNombre() != null ? doc.getNombre().trim() : "";
                        String pat = doc.getPaterno() != null ? doc.getPaterno().trim() : "";
                        String mat = doc.getMaterno() != null ? doc.getMaterno().trim() : "";
                        nombreDoctorSel = ("Dr(a). " + nom + " " + pat + " " + mat).trim().replaceAll("\\s+", " ");
                        break;
                    }
                }
            }

            String perFinal = (periodo != null && !periodo.trim().isEmpty()) ? periodo : "mensual";
            String tipoFinal = (tipoGraficaPdf != null && !tipoGraficaPdf.trim().isEmpty()) ? tipoGraficaPdf : "ambos";

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=Graficas_Pacientes_" + perFinal + ".pdf");

            Datos datosPdf = new Datos();
            String rutaReal = getServletContext().getRealPath("/");
            try {
                datosPdf.generarPdfGraficas(response.getOutputStream(), rutaReal, perFinal, idDentistaSel, nombreDoctorSel, tipoFinal);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return;
        }

        //dar de alta a pacientes
        if (accion.equals("registrar")) {

            Pacientes tempo = new Pacientes();
            tempo.setNombre(request.getParameter("nombre"));
            tempo.setaPaterno(request.getParameter("paterno"));
            tempo.setaMaterno(request.getParameter("materno"));
            tempo.setTelefono(request.getParameter("tel"));
            tempo.setCorreo(request.getParameter("correo"));
            tempo.setDireccion(request.getParameter("direccion"));

            String idDenParam = request.getParameter("idDenP");
            int idDen = 0;
            if (idDenParam != null && !idDenParam.trim().isEmpty()) {
                try {
                    idDen = Integer.parseInt(idDenParam.trim());
                } catch (NumberFormatException ex) {
                    idDen = 0;
                }
            }
            tempo.setIdDenP(idDen);

            String mensajeAlta = pa.alta(tempo);
            System.out.println("PACIENTE REGISTRADO: " + pa.getNombre() + " " + pa.getaPaterno() + " " + pa.getaMaterno());
            request.getSession().setAttribute("mensajeDialog", mensajeAlta);

            response.sendRedirect(request.getContextPath() + "/Control?accion=pacientes");
            return;
        }

        //dar de baja a pacientes
        if (accion.equals("eliminar")) {
            String idParam = request.getParameter("id");
            int idPac = 0;

            if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    idPac = Integer.parseInt(idParam.trim());
                } catch (NumberFormatException ex) {
                    idPac = 0;
                }
            }

            if (idPac > 0) {
                pa.baja(idPac);
                request.getSession().setAttribute("mensajeDialog", pa.getRespuesta());
            } else {
                request.getSession().setAttribute("mensajeDialog", "ID de paciente no válido");
            }

            response.sendRedirect(request.getContextPath() + "/Control?accion=pacientes");
            return;
        }

        // 4. Módulo de edición de pacientes
        if (accion.equals("editar")) {
            int idEditar = Integer.parseInt(request.getParameter("id"));

            Pacientes pacienteEncontrado = pa.obtenerPorId(idEditar);
            boolean esEdicion = (pacienteEncontrado != null);

            // Filas de la tabla de fondo
            pa.mostrarTabla();
            request.setAttribute("tablaPacientesHtml", pa.getRespuesta());

            // Selector de doctor de preferencia desde Dentistas
            int idDoctorPref = esEdicion ? pacienteEncontrado.getIdDenP() : 0;
            d.generarSelectDoctor(idDoctorPref, esEdicion);

            request.setAttribute("pacienteEdit", pacienteEncontrado);
            request.setAttribute("selectDoctorHtml", d.getRespuesta());

            HttpSession session = request.getSession();
            String msg = (String) session.getAttribute("mensajeDialog");
            if (msg != null) {
                session.removeAttribute("mensajeDialog");
            }
            Pacientes mensajeBean = new Pacientes();
            mensajeBean.setRespuesta(msg != null ? msg : "");
            request.setAttribute("mensajeBean", mensajeBean);

            // Obtenemos el tipo de usuario de la sesión para la redirección dinámica
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;

            String carpeta = "Admin/";
            if (tipoUsuario == 2) {
                carpeta = "Secretaria/";
            }

            String vistaDestino = carpeta + "Pacientes.jsp";
            System.out.println("Servlet (editar): redirigiendo a -> " + vistaDestino);

            request.getRequestDispatcher(vistaDestino).forward(request, response);
            return;
        }

        //actualizar info del paciente
        if (accion.equals("actualizar")) {

            pa.setIdP(Integer.parseInt(request.getParameter("idP")));
            pa.setNombre(request.getParameter("nombre"));
            pa.setaPaterno(request.getParameter("paterno"));
            pa.setaMaterno(request.getParameter("materno"));
            pa.setTelefono(request.getParameter("tel"));
            pa.setCorreo(request.getParameter("correo"));
            pa.setDireccion(request.getParameter("direccion"));

            String idDenParam = request.getParameter("idDenP");
            if (idDenParam != null && !idDenParam.trim().isEmpty()) {
                pa.setIdDenP(Integer.parseInt(idDenParam));
            } else {
                pa.setIdDenP(0);
            }

            // Ejecutamos el SP de actualización en la BD
            pa.cambio();
            System.out.println("PACIENTE MODIFICADO: " + pa.getNombre() + " " + pa.getaPaterno() + " " + pa.getaMaterno());
            if (pa.getRespuesta() != null && !pa.getRespuesta().trim().isEmpty()) {
                request.getSession().setAttribute("mensajeDialog", pa.getRespuesta());
            }

            response.sendRedirect("Control?accion=pacientes");
            return;
        }

        // 3. Módulo de personal
        if (accion.equals("personal")) {
            System.out.println("Servlet: acción personal detectada");

            // Validamos sesión y rol (Solo Admin = 1)
            HttpSession session = request.getSession();
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;

            if (tipoUsuario != 1) {
                System.out.println("Servlet: Acceso no autorizado a personal por rol: " + tipoUsuario);
                response.sendRedirect("index.jsp");
                return;
            }

            List<Personal> listaAdmins = p.llenarListaAdmins();
            List<Dentistas> listaDentistas = d.llenarListaDentistas();
            List<Secretarias> listaSecretarias = s.llenarListaSecretarias();

            System.out.println("Servlet: Admins = " + listaAdmins.size()
                    + " | Dentistas = " + listaDentistas.size()
                    + " | Secretarias = " + listaSecretarias.size());

            request.setAttribute("tablaAdminsHtml", p.generarFilasAdminsHtml(listaAdmins));
            request.setAttribute("tablaDentistasHtml", d.generarFilasDentistasHtml(listaDentistas));
            request.setAttribute("tablaSecretariasHtml", s.generarFilasSecretariasHtml(listaSecretarias));

            String vistaDestino = "Admin/Personal.jsp";
            System.out.println("Servlet: redirigiendo a -> " + vistaDestino);

            request.getRequestDispatcher(vistaDestino).forward(request, response);
            return;
        }

        // 4. Módulo de edición de personal
        if (accion.equals("editarPersonal")) {
            HttpSession session = request.getSession();
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;

            if (tipoUsuario != 1) {
                response.sendRedirect("index.jsp");
                return;
            }

            String usuarioEditar = request.getParameter("usuario");
            int tipoEditar = Integer.parseInt(request.getParameter("tipo"));

            Personal personalEncontrado = null;
            if (tipoEditar == 2) {
                Dentistas den = d.obtenerPorUsuario(usuarioEditar);
                personalEncontrado = den;
                request.setAttribute("dentistaEdit", den);
            } else if (tipoEditar == 3) {
                Secretarias sec = s.obtenerPorUsuario(usuarioEditar);
                personalEncontrado = sec;
                request.setAttribute("secretariaEdit", sec);
            } else {
                personalEncontrado = p.obtenerPorUsuario(usuarioEditar);
            }

            List<Personal> listaAdmins = p.llenarListaAdmins();
            List<Dentistas> listaDentistas = d.llenarListaDentistas();
            List<Secretarias> listaSecretarias = s.llenarListaSecretarias();

            request.setAttribute("personalEdit", personalEncontrado);
            request.setAttribute("tablaAdminsHtml", p.generarFilasAdminsHtml(listaAdmins));
            request.setAttribute("tablaDentistasHtml", d.generarFilasDentistasHtml(listaDentistas));
            request.setAttribute("tablaSecretariasHtml", s.generarFilasSecretariasHtml(listaSecretarias));

            request.getRequestDispatcher("Admin/Personal.jsp").forward(request, response);
            return;
        }

        if (accion.equals("actualizarPersonal")) {
            HttpSession session = request.getSession();
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;

            if (tipoUsuario != 1) {
                response.sendRedirect("index.jsp");
                return;
            }

            String usuario = request.getParameter("usuario");
            String nombre = request.getParameter("nombre");
            String aPaterno = request.getParameter("APaterno");
            String aMaterno = request.getParameter("AMaterno");
            String telefono = request.getParameter("telefono");
            String correo = request.getParameter("correo");
            int nuevoTipo = Integer.parseInt(request.getParameter("tipo"));

            p.setUsuario(usuario);
            p.setNombre(nombre);
            p.setPaterno(aPaterno);
            p.setMaterno(aMaterno);
            p.setTelefono(telefono);
            p.setCorreo(correo);
            p.setTipo(nuevoTipo);
            p.actualizarPersonal();

            if (nuevoTipo == 2) {
                d.setUsuario(usuario);
                d.setEspecialidad(request.getParameter("especialidad"));
                d.setCedula(request.getParameter("cedula"));
                d.setTurno(request.getParameter("turnoDentista"));
                d.setTelefono(telefono);
                d.setCorreo(correo);
                d.actualizarDentista();
            } else if (nuevoTipo == 3) {
                s.setUsuario(usuario);
                s.setTurno(request.getParameter("turnoSecretaria"));
                s.setTelefono(telefono);
                s.setCorreo(correo);
                s.actualizarSecretaria();
            }

            response.sendRedirect("Control?accion=personal");
            return;
        }

        if (accion.equals("citas")) {
            System.out.println("Servlet: acción citas detectada");

            HttpSession session = request.getSession();
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;

            // Filtros (fecha, doctor, paciente, vista) y restricción por rol
            ci.setFiltros(request.getParameter("fecha"), request.getParameter("idDentista"),
                    request.getParameter("idPaciente"), request.getParameter("vista"));
            ci.aplicarRol(tipoUsuario, (String) session.getAttribute("usuarioLogin"));

            // Filas de la tabla y opciones de los select
            ci.mostrarTabla(tipoUsuario);
            ci.generarOpciones();

            String msg = (String) session.getAttribute("mensajeDialog");
            if (msg != null) {
                session.removeAttribute("mensajeDialog");
            }
            ci.setRespuesta(msg != null ? msg : "");
            request.setAttribute("citasVista", ci);

            // Determinamos la carpeta dinámicamente
            String carpeta = "Admin/";
            if (tipoUsuario == 2) {
                carpeta = "Secretaria/";
            } else if (tipoUsuario == 3) {
                carpeta = "Dentista/";
            }

            String vistaDestino = carpeta + "Citas.jsp";
            System.out.println("Servlet: redirigiendo a -> " + vistaDestino);

            request.getRequestDispatcher(vistaDestino).forward(request, response);
            return;
        }

        //agendar citas
        if (accion.equals("agendar")) {
            ci.setDatos(null, request.getParameter("paciente"), request.getParameter("medico"),
                    request.getParameter("fecha"), request.getParameter("hora"));
            ci.agendar();

            request.getSession().setAttribute("mensajeDialog", ci.getRespuesta());
            response.sendRedirect(request.getContextPath() + "/Control?accion=citas");
            return;
        }

        //reagendar citas
        if (accion.equals("reagendar")) {
            ci.setDatos(request.getParameter("idCita"), null, null,
                    request.getParameter("nuevaFecha"), request.getParameter("nuevaHora"));
            ci.reagendar();

            request.getSession().setAttribute("mensajeDialog", ci.getRespuesta());
            response.sendRedirect(request.getContextPath() + "/Control?accion=citas");
            return;
        }

        //cancelar citas
        if (accion.equals("cancelar")) {
            ci.setDatos(request.getParameter("idCita"), null, null, null, null);
            ci.cancelar();

            request.getSession().setAttribute("mensajeDialog", ci.getRespuesta());
            response.sendRedirect(request.getContextPath() + "/Control?accion=citas");
            return;
        }

        //atender citas (dentista: registra el diagnóstico)
        if (accion.equals("atender")) {
            String idCitaParam = request.getParameter("idCita");
            String diagParam = request.getParameter("diagnostico");

            if (idCitaParam != null && !idCitaParam.trim().isEmpty()) {
                ci.setDatos(idCitaParam.trim(), null, null, null, null);
            } else {
                ci.setIdCita(0);
            }
            ci.setDiagnostico(diagParam);
            ci.atender();

            request.getSession().setAttribute("mensajeDialog", ci.getRespuesta());
            response.sendRedirect(request.getContextPath() + "/Control?accion=citas");
            return;
        }

        //exportar historial de citas a pdf
        if (accion.equals("pdfCitas")) {
            HttpSession session = request.getSession();
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;

            ci.setFiltros(request.getParameter("fecha"), request.getParameter("idDentista"),
                    request.getParameter("idPaciente"), "historial");
            ci.aplicarRol(tipoUsuario, (String) session.getAttribute("usuarioLogin"));

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=Historial_Citas.pdf");
            try {
                ci.generarPdf(response.getOutputStream());
            } catch (Exception e) {
                e.printStackTrace();
            }
            return;
        }

        // 5. Módulo para regresar al Menú Principal según el rol
        if (accion.equals("menu")) {
            HttpSession session = request.getSession();
            Integer tipoObj = (Integer) session.getAttribute("tipo");
            int tipoUsuario = (tipoObj != null) ? tipoObj : 1;
            String usuarioLogin = (String) session.getAttribute("usuarioLogin");

            Integer idDentistaFiltro = null;
            if (tipoUsuario == 3) {
                if (usuarioLogin != null && !usuarioLogin.trim().isEmpty()) {
                    Dentistas den = d.obtenerPorUsuario(usuarioLogin.trim());
                    idDentistaFiltro = (den != null && den.getIdDentista() > 0) ? den.getIdDentista() : -1;
                } else {
                    idDentistaFiltro = -1;
                }
            }

            ci.mostrarMiniTablaCitasDelDia(idDentistaFiltro);
            request.setAttribute("citasHoyBean", ci);

            String menuDestino = "Admin/Menu1.jsp";
            if (tipoUsuario == 2) {
                menuDestino = "Secretaria/Menu2.jsp";
            } else if (tipoUsuario == 3) {
                menuDestino = "Dentista/Menu3.jsp";
            }

            System.out.println("Servlet (menu): redirigiendo al menú de rol " + tipoUsuario + " -> " + menuDestino);
            request.getRequestDispatcher(menuDestino).forward(request, response);
            return;
        }

        if (accion.equals("logout")) {
            response.sendRedirect("index.html");
            return;
        }

        // 6. Procesamiento de las demás acciones
        try (PrintWriter out = response.getWriter()) {

            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Controlador - CitasMedicas</title>");
            out.println("</head>");
            out.println("<body>");

            out.println("<h1>Procesando peticiones en el Controlador (MVC)</h1>");

            switch (accion) {

                case "agendar":
                    out.println("<p style='color:green;'>--> Acción detectada: Agendar Cita con éxito.</p>");
                    break;

                case "alta":
                    out.println("<p style='color:green;'>--> Acción detectada: Registro de Alta procesado.</p>");
                    break;

                case "baja":
                    out.println("<p style='color:red;'>--> Acción detectada: Baja lógica aplicada.</p>");
                    break;

                default:
                    out.println("<p>Bienvenido al Sistema de Citas Médicas. Ruta del contexto: "
                            + request.getContextPath() + "</p>");
                    break;
            }

            out.println("<br><a href='" + request.getContextPath()
                    + "/Admin/Menu1.jsp'>Volver al Menú Principal del Administrador</a>");

            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Controlador Central MVC para CitasMedicas";
    }
}