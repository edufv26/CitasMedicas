/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import bean.Personal;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/Control"})
public class Control extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        // Obtenemos el parámetro 'accion' que envíen los formularios o menús HTML/JSP
        String accion = request.getParameter("accion");
        
        // Si no viene ninguna acción, mandamos un valor por defecto
        if (accion == null) {
            accion = "inicio";
        }

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Controlador - CitasMedicas</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Procesando peticiones en el Controlador (MVC)</h1>");
            
            // Evaluamos qué módulo o acción está solicitando la Vista
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
                    out.println("<p>Bienvenido al Sistema de Citas Médicas. Ruta del contexto: " + request.getContextPath() + "</p>");
                    break;
            }
            
            out.println("<br><a href='Admin/Menu1.html'>Volver al Menú Principal del Administrador</a>");
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
        String boton = request.getParameter("boton");
        Personal p = new Personal();
        //acceso
        if (boton.equals("validar")) {
            p.setInputlogin(request.getParameter("usuario"));
            p.setInputlogin(request.getParameter("password"));
            p.validar();
            response.sendRedirect(p.getRespuesta());
        }
    }

    @Override
    public String getServletInfo() {
        return "Controlador Central MVC para CitasMedicas";
    }
}