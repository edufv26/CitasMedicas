/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package bean;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.OutputStream;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.Time;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 *
 *
 * @author edu
 */
public class Citas {

    // Datos de la cita
    private int idCita, idPaciente, idDentista;
    private String nombrePaciente, nombreDentista, estado, diagnostico, respuesta;
    private Date fecha;
    private Time hora;
    private boolean exito, datosValidos = true;

    // Filtros de la vista (fecha, doctor, paciente y vista: pendientes / historial)
    private String filtroFecha = "", vista = "pendientes";
    private int filtroDentista, filtroPaciente;

    // Fragmentos HTML que se pintan en los JSP
    private String tablaHtml = "";
    private String opcionesDentistas = "", opcionesDentistasFiltro = "";
    private String opcionesPacientes = "", opcionesPacientesFiltro = "";

    conexion Conexion = new conexion();

    public int getIdCita() {
        return idCita;
    }

    public void setIdCita(int idCita) {
        this.idCita = idCita;
    }

    public int getIdPaciente() {
        return idPaciente;
    }

    public void setIdPaciente(int idPaciente) {
        this.idPaciente = idPaciente;
    }

    public String getNombrePaciente() {
        return nombrePaciente;
    }

    public void setNombrePaciente(String nombrePaciente) {
        this.nombrePaciente = nombrePaciente;
    }

    public int getIdDentista() {
        return idDentista;
    }

    public void setIdDentista(int idDentista) {
        this.idDentista = idDentista;
    }

    public String getNombreDentista() {
        return nombreDentista;
    }

    public void setNombreDentista(String nombreDentista) {
        this.nombreDentista = nombreDentista;
    }

    public Date getFecha() {
        return fecha;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public Time getHora() {
        return hora;
    }

    public void setHora(Time hora) {
        this.hora = hora;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getDiagnostico() {
        return diagnostico;
    }

    public void setDiagnostico(String diagnostico) {
        this.diagnostico = diagnostico;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }

    public boolean isExito() {
        return exito;
    }

    public void setExito(boolean exito) {
        this.exito = exito;
    }

    public String getFiltroFecha() {
        return filtroFecha;
    }

    public int getFiltroDentista() {
        return filtroDentista;
    }

    public int getFiltroPaciente() {
        return filtroPaciente;
    }

    public String getVista() {
        return vista;
    }

    public boolean isHistorial() {
        return "historial".equals(vista);
    }

    public String getTablaHtml() {
        return tablaHtml;
    }

    public String getOpcionesDentistas() {
        return opcionesDentistas;
    }

    public String getOpcionesDentistasFiltro() {
        return opcionesDentistasFiltro;
    }

    public String getOpcionesPacientes() {
        return opcionesPacientes;
    }

    public String getOpcionesPacientesFiltro() {
        return opcionesPacientesFiltro;
    }

    // Mensaje listo para usarse dentro de un atributo HTML (data-mensaje-respuesta)
    public String getMensajeAttr() {
        return (respuesta == null) ? "" : esc(respuesta);
    }

    // Filtros actuales como query string (para el enlace de exportar PDF)
    public String getQueryFiltros() {
        return "&fecha=" + filtroFecha
                + "&idDentista=" + (filtroDentista > 0 ? String.valueOf(filtroDentista) : "")
                + "&idPaciente=" + (filtroPaciente > 0 ? String.valueOf(filtroPaciente) : "");
    }

    // ================================
    //  CAPTURA DE DATOS DESDE EL SERVLET
    // ================================
    // Filtros del listado (fecha yyyy-MM-dd, id doctor, id paciente, vista)
    public void setFiltros(String fecha, String dentista, String paciente, String vista) {
        String f = (fecha != null) ? fecha.trim() : "";
        this.filtroFecha = f.matches("\\d{4}-\\d{2}-\\d{2}") ? f : "";
        this.filtroDentista = aEntero(dentista);
        this.filtroPaciente = aEntero(paciente);
        this.vista = "historial".equals(vista) ? "historial" : "pendientes";
    }

    // El dentista solo puede ver sus propias citas
    public void aplicarRol(int tipoUsuario, String usuarioLogin) {
        if (tipoUsuario == 3) {
            Dentistas d = new Dentistas().obtenerPorUsuario(usuarioLogin != null ? usuarioLogin.trim() : "");
            // -1 = dentista no encontrado: no se muestra ninguna cita
            this.filtroDentista = (d != null) ? d.getIdDentista() : -1;
        }
    }

    // Datos de una operación (los que no apliquen se mandan null). Medico "AUTO" = 0
    public void setDatos(String cita, String paciente, String medico, String fecha, String hora) {
        try {
            this.datosValidos = true;
            this.idCita = aEntero(cita);
            this.idPaciente = aEntero(paciente);
            this.idDentista = aEntero(medico);
            this.fecha = (fecha != null && !fecha.trim().isEmpty()) ? Date.valueOf(fecha.trim()) : null;
            this.hora = (hora != null && !hora.trim().isEmpty()) ? Time.valueOf(normalizarHora(hora)) : null;
        } catch (IllegalArgumentException e) {
            this.datosValidos = false;
        }
    }

    // ================================
    //  OPERACIONES (stored procedures)
    // ================================
    // procedure agendar cita (médico automático si idDentista = 0)
    public void agendar() {
        if (!datosValidos || idPaciente <= 0 || fecha == null || hora == null) {
            resultado("Verifica el paciente, la fecha y la hora capturados.", null, null);
            return;
        }
        String error = ejecutarSP("{CALL sp_AgendarCita(?, ?, ?, ?)}",
                idPaciente, (idDentista > 0) ? (Object) idDentista : null, fecha, hora);
        resultado(error, "Cita agendada correctamente.", "No se pudo agendar la cita: ");
    }

    // procedure cancelar cita
    public void cancelar() {
        if (idCita <= 0) {
            resultado("Folio de cita no válido.", null, null);
            return;
        }
        String error = ejecutarSP("{CALL sp_CancelarCita(?)}", idCita);
        resultado(error, "Cita #" + idCita + " cancelada correctamente.", "No se pudo cancelar la cita: ");
    }

    // procedure reagendar cita (valida disponibilidad del dentista)
    public void reagendar() {
        if (!datosValidos || idCita <= 0 || fecha == null || hora == null) {
            resultado("Verifica el folio, la nueva fecha y la nueva hora.", null, null);
            return;
        }
        String error = ejecutarSP("{CALL sp_ReagendarCita(?, ?, ?)}", idCita, fecha, hora);
        resultado(error, "Cita #" + idCita + " reagendada correctamente.", "No se pudo reagendar la cita: ");
    }

    // procedure atender cita (guarda diagnóstico y cambia a ATENDIDA)
    public void atender() {
        if (idCita <= 0 || diagnostico == null || diagnostico.trim().isEmpty()) {
            resultado("Debes escribir un diagnóstico para atender la cita.", null, null);
            return;
        }
        String error = ejecutarSP("{CALL sp_AtenderCita(?, ?)}", idCita, diagnostico.trim());
        resultado(error, "Cita #" + idCita + " atendida y registrada en el historial.", "No se pudo atender la cita: ");
    }

    // ================================
    //  CONSULTAS (para los jsp)
    // ================================
    public List<Citas> llenarTabla(boolean soloPendientes) {
        List<Citas> lista = new ArrayList<>();
        if (filtroDentista < 0) {
            return lista;
        }

        try (Connection cn = Conexion.conecta(); CallableStatement cs = cn.prepareCall("{CALL sp_FiltrarHistorial(?, ?, ?, ?)}")) {

            if (filtroDentista > 0) {
                cs.setInt(1, filtroDentista);
            } else {
                cs.setNull(1, Types.INTEGER);
            }
            if (filtroPaciente > 0) {
                cs.setInt(2, filtroPaciente);
            } else {
                cs.setNull(2, Types.INTEGER);
            }
            if (filtroFecha != null && !filtroFecha.isEmpty()) {
                cs.setDate(3, java.sql.Date.valueOf(filtroFecha));
            } else {
                cs.setNull(3, Types.DATE);
            }
            cs.setBoolean(4, soloPendientes);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Citas c = new Citas();
                    c.setIdCita(rs.getInt("id_cita"));
                    c.setNombrePaciente(rs.getString("Paciente"));
                    c.setNombreDentista(rs.getString("Dentista"));
                    c.setFecha(rs.getDate("fecha"));
                    c.setHora(rs.getTime("hora"));
                    c.setEstado(rs.getString("estado"));
                    c.setDiagnostico(rs.getString("diagnostico"));

                    lista.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    // Filas de la tabla según la vista (pendientes / historial) y el rol (1 admin, 2 secretaria, 3 dentista)
    public void mostrarTabla(int tipoUsuario) {
        StringBuilder html = new StringBuilder();
        List<Citas> lista = llenarTabla(!isHistorial());

        if (lista != null && !lista.isEmpty()) {
            for (Citas c : lista) {
                html.append("<tr>");
                html.append("<td>#").append(c.getIdCita()).append("</td>");
                html.append("<td>").append(esc(c.getNombrePaciente())).append("</td>");
                html.append("<td>Dr(a). ").append(esc(c.getNombreDentista())).append("</td>");
                html.append("<td>").append(c.getFecha()).append("</td>");
                html.append("<td>").append(horaCorta(c.getHora())).append("</td>");
                html.append("<td><span class=\"badge-estado ").append(c.claseEstado()).append("\">")
                        .append(esc(c.getEstado())).append("</span></td>");

                if (isHistorial()) {
                    html.append("<td class=\"diagnostico\">").append(esc(c.getDiagnostico())).append("</td>");
                } else {
                    html.append("<td class=\"text-center\">");
                    if (tipoUsuario == 3) {
                        html.append("<button type=\"button\" class=\"btn-icon-tabla atender\" title=\"Atender cita\" onclick=\"abrirModalAtender(")
                                .append(c.getIdCita()).append(")\"><span class=\"fa fa-stethoscope\"></span></button>");
                    } else {
                        html.append("<button type=\"button\" class=\"btn-icon-tabla reagendar\" title=\"Reagendar\" onclick=\"abrirModalReagendar(")
                                .append(c.getIdCita()).append(",'").append(c.getFecha()).append("','")
                                .append(horaCorta(c.getHora())).append("')\"><span class=\"fa fa-calendar-check-o\"></span></button>");
                        html.append("<button type=\"button\" class=\"btn-icon-tabla eliminar\" title=\"Cancelar cita\" onclick=\"abrirModalCancelar(")
                                .append(c.getIdCita()).append(")\"><span class=\"fa fa-calendar-times-o\"></span></button>");
                    }
                    html.append("</td>");
                }
                html.append("</tr>");
            }
        } else {
            html.append("<tr><td colspan=\"7\" class=\"text-center\" style=\"padding: 20px; color: #666;\">")
                    .append(isHistorial() ? "No hay citas en el historial con los filtros seleccionados."
                            : "No hay citas pendientes con los filtros seleccionados.")
                    .append("</td></tr>");
        }

        this.tablaHtml = html.toString();
    }

    // Opciones de los select de doctor y paciente (reutiliza llenarListaDentistas y llenarTabla)
    public void generarOpciones() {
        StringBuilder docModal = new StringBuilder(), docFiltro = new StringBuilder();
        StringBuilder pacModal = new StringBuilder(), pacFiltro = new StringBuilder();

        List<Dentistas> dentistas = new Dentistas().llenarListaDentistas();
        if (dentistas != null) {
            for (Dentistas d : dentistas) {
                String esp = (d.getEspecialidad() != null) ? d.getEspecialidad().trim() : "";
                String texto = "Dr(a). " + nombreCompleto(d.getNombre(), d.getPaterno(), d.getMaterno())
                        + (esp.isEmpty() ? "" : " - " + esp);
                agregarOpcion(docModal, d.getIdDentista(), texto, false);
                agregarOpcion(docFiltro, d.getIdDentista(), texto, d.getIdDentista() == filtroDentista);
            }
        }

        List<Pacientes> pacientes = new Pacientes().llenarTabla();
        if (pacientes != null) {
            for (Pacientes p : pacientes) {
                String texto = nombreCompleto(p.getNombre(), p.getaPaterno(), p.getaMaterno());
                agregarOpcion(pacModal, p.getIdP(), texto, false);
                agregarOpcion(pacFiltro, p.getIdP(), texto, p.getIdP() == filtroPaciente);
            }
        }

        this.opcionesDentistas = docModal.toString();
        this.opcionesDentistasFiltro = docFiltro.toString();
        this.opcionesPacientes = pacModal.toString();
        this.opcionesPacientesFiltro = pacFiltro.toString();
    }

    // Historial de citas en PDF (itextpdf-5.4.1.jar) con los filtros actuales
    public void generarPdf(OutputStream salida) throws DocumentException {
        List<Citas> lista = llenarTabla(false);

        Font tituloFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);
        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
        Font cellFont = FontFactory.getFont(FontFactory.HELVETICA, 9);

        Document document = new Document();
        PdfWriter.getInstance(document, salida);
        document.open();
        document.add(new Paragraph("Historial Clínico y Diagnósticos de Citas", tituloFont));
        document.add(new Paragraph(" "));

        PdfPTable tabla = new PdfPTable(6);
        tabla.setWidthPercentage(100);
        for (String titulo : new String[]{"Fecha", "Hora", "Paciente", "Médico", "Estado", "Diagnóstico"}) {
            tabla.addCell(new Phrase(titulo, headerFont));
        }
        for (Citas c : lista) {
            tabla.addCell(new Phrase(String.valueOf(c.getFecha()), cellFont));
            tabla.addCell(new Phrase(horaCorta(c.getHora()), cellFont));
            tabla.addCell(new Phrase(c.getNombrePaciente() != null ? c.getNombrePaciente() : "", cellFont));
            tabla.addCell(new Phrase(c.getNombreDentista() != null ? c.getNombreDentista() : "", cellFont));
            tabla.addCell(new Phrase(c.getEstado() != null ? c.getEstado() : "", cellFont));
            tabla.addCell(new Phrase(c.getDiagnostico() != null ? c.getDiagnostico() : "", cellFont));
        }
        document.add(tabla);
        document.close();
    }

    // ================================
    //  AUXILIARES
    // ================================
    // Ejecuta un procedure con parámetros (Integer, Date, Time o String; null = INTEGER nulo).
    // Regresa null si todo salió bien o el mensaje de error de la BD.
    private String ejecutarSP(String sql, Object... params) {
        try (Connection cn = Conexion.conecta()) {
            if (cn == null) {
                return "No hay conexión con la base de datos.";
            }
            try (CallableStatement cs = cn.prepareCall(sql)) {
                for (int i = 0; i < params.length; i++) {
                    Object p = params[i];
                    if (p == null) {
                        cs.setNull(i + 1, Types.INTEGER);
                    } else if (p instanceof Integer) {
                        cs.setInt(i + 1, (Integer) p);
                    } else if (p instanceof Date) {
                        cs.setDate(i + 1, (Date) p);
                    } else if (p instanceof Time) {
                        cs.setTime(i + 1, (Time) p);
                    } else {
                        cs.setString(i + 1, p.toString());
                    }
                }
                cs.execute();
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return (e.getMessage() != null) ? e.getMessage() : e.toString();
        }
    }

    // Arma el mensaje final: error == null es éxito. Sin textos (ok/fallo) el error se muestra tal cual.
    private void resultado(String error, String ok, String fallo) {
        this.exito = (error == null);
        this.respuesta = (ok == null) ? error : (exito ? ok : fallo + error);
    }

    private boolean esPendiente() {
        String e = (estado != null) ? estado.trim().toUpperCase() : "";
        return !"ATENDIDA".equals(e) && !"CANCELADA".equals(e);
    }

    // Clase css del badge de estado (programada, reagendada, atendida, cancelada)
    private String claseEstado() {
        return (estado != null) ? estado.trim().toLowerCase() : "";
    }

    private static void agregarOpcion(StringBuilder sb, int valor, String texto, boolean seleccionada) {
        sb.append("<option value=\"").append(valor).append("\"")
                .append(seleccionada ? " selected" : "").append(">")
                .append(esc(texto)).append("</option>");
    }

    private static String nombreCompleto(String... partes) {
        StringBuilder sb = new StringBuilder();
        for (String p : partes) {
            if (p != null && !p.trim().isEmpty()) {
                sb.append(sb.length() > 0 ? " " : "").append(p.trim());
            }
        }
        return sb.toString();
    }

    private static String horaCorta(Time t) {
        return (t == null) ? "" : t.toString().substring(0, 5);
    }

    private static String normalizarHora(String h) {
        String limpia = h.trim();
        return (limpia.length() == 5) ? limpia + ":00" : limpia;
    }

    private static int aEntero(String valor) {
        try {
            return Integer.parseInt(valor.trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
