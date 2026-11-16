/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import bean.Dentistas;
import bean.Pacientes;
import bean.Personal;
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

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     */
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

        System.out.println("Método HTTP: " + request.getMethod());
        System.out.println("Acción recibida: " + accion);

        // 2. Validación de inicio de sesión
        if (accion.equals("validar")) {

            p.setInputlogin(request.getParameter("usuario"));
            p.setPassword(request.getParameter("password"));
            p.validar();

            String destino = p.getRespuesta();

            System.out.println("Usuario: " + request.getParameter("usuario"));
            System.out.println("Destino recibido: " + destino);

            if (destino == null || destino.trim().isEmpty()) {
                response.sendError(500, "La validación no devolvió un destino.");
                return;
            }

            if (!destino.contains("Error.jsp")) {
                HttpSession session = request.getSession();
                session.setAttribute("nombreUsuario", p.getNombre());
            }

            response.sendRedirect(request.getContextPath() + "/" + destino);
            return;
        }

        // 3. Módulo de pacientes
        if (accion.equals("pacientes")) {

            System.out.println("Servlet: acción pacientes detectada");

            List<Pacientes> lista = pa.llenarTabla();

            System.out.println("Servlet: pacientes recibidos = " + lista.size());

            request.setAttribute("listaPacientes", lista);

            request.getRequestDispatcher("/Admin/Pacientes.jsp")
                    .forward(request, response);

            return;
        }

        // 4. Módulo de edición de pacientes
        if (accion.equals("editar")) {
            int idEditar = Integer.parseInt(request.getParameter("id"));

            // Buscamos al paciente por su ID real
            Pacientes pacienteEncontrado = pa.obtenerPorId(idEditar);

            request.setAttribute("pacienteEdit", pacienteEncontrado);
            request.setAttribute("listaPacientes", pa.llenarTabla());

            // En tu Servlet, al procesar la petición de Pacientes:
            Dentistas dModel = new Dentistas();
            request.setAttribute("listaDentistas", dModel.llenarListaDentistas());

            request.getRequestDispatcher("/Admin/Pacientes.jsp")
                    .forward(request, response);
            return;
        }
        if (accion.equals("actualizar")) {
            pa.setIdP(Integer.parseInt(request.getParameter("idP")));
            pa.setNombre(request.getParameter("nombre"));
            pa.setaPaterno(request.getParameter("paterno"));
            pa.setaMaterno(request.getParameter("materno"));
            pa.setTelefono(request.getParameter("tel"));
            pa.setCorreo(request.getParameter("correo"));
            pa.setDireccion(request.getParameter("direccion"));

            // Ejecutamos tu método cambio para actualizar en la BD
            pa.cambio();

            // Redirigimos para limpiar la URL y refrescar la tabla
            response.sendRedirect("Control?accion=pacientes");
            return;
        }

        // 4. Procesamiento de las demás acciones
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
        processRequest(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Controlador Central MVC para CitasMedicas";
    }
}
