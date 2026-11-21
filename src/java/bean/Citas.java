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
 * @author edu
 */
public class Citas {

    // Datos de la cita
    private int idCita, idPaciente, idDentista;
    private String nombrePaciente, nombreDentista, estado, diagnostico, respuesta;
    private Date fecha;
    private Time hora;
    private boolean datosValidos = true;

    // Filtros de la vista (fecha, doctor, paciente y vista: pendientes / historial)
    private String filtroFecha = "", vista = "pendientes";
    private int filtroDentista, filtroPaciente;

    // Fragmentos HTML que se pintan en los JSP
    private String tablaHtml = "";
    private String opcionesDentistas = "", opcionesDentistasFiltro = "";
    private String opcionesPacientes = "", opcionesPacientesFiltro = "";

    //vista dashboard principal (citas del dia)
    private String miniTablaCitasHoy;
    private int tipoRol = 1;
    private String usuarioLogin;

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

    public int getIdDentista() {
        return idDentista;
    }

    public void setIdDentista(int idDentista) {
        this.idDentista = idDentista;
    }

    public String getNombrePaciente() {
        return nombrePaciente;
    }

    public void setNombrePaciente(String nombrePaciente) {
        this.nombrePaciente = nombrePaciente;
    }

    public String getNombreDentista() {
        return nombreDentista;
    }

    public void setNombreDentista(String nombreDentista) {
        this.nombreDentista = nombreDentista;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
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

    public boolean isDatosValidos() {
        return datosValidos;
    }

    public void setDatosValidos(boolean datosValidos) {
        this.datosValidos = datosValidos;
    }

    public int getFiltroDentista() {
        return filtroDentista;
    }

    public void setFiltroDentista(int filtroDentista) {
        this.filtroDentista = filtroDentista;
    }

    public int getFiltroPaciente() {
        return filtroPaciente;
    }

    public void setFiltroPaciente(int filtroPaciente) {
        this.filtroPaciente = filtroPaciente;
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

    public String getFiltroFecha() {
        return filtroFecha;
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

    public String getMiniTablaCitasHoy() {
        return miniTablaCitasHoy;
    }

    public void setMiniTablaCitasHoy(String miniTablaCitasHoy) {
        this.miniTablaCitasHoy = miniTablaCitasHoy;
    }

    public int getTipoRol() {
        return tipoRol;
    }

    public void setTipoRol(int tipoRol) {
        this.tipoRol = tipoRol;
        cargarMiniTablaPorRol(this.tipoRol, this.usuarioLogin);
    }

    public String getUsuarioLogin() {
        return usuarioLogin;
    }

    public void setUsuarioLogin(String usuarioLogin) {
        this.usuarioLogin = usuarioLogin;
        cargarMiniTablaPorRol(this.tipoRol, this.usuarioLogin);
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

    public String getPestanasHtml() {
        String clasePendientes = isHistorial() ? "tab-cita" : "tab-cita activo";
        String claseHistorial = isHistorial() ? "tab-cita activo" : "tab-cita";

        return "<div class=\"tabs-citas\" data-seccion-cita=\"pestanas\">"
                + "<a href=\"Control?accion=citas&vista=pendientes\" class=\"" + clasePendientes + "\">"
                + "<span class=\"fa fa-clock-o\"></span> Pendientes</a>"
                + "<a href=\"Control?accion=citas&vista=historial\" class=\"" + claseHistorial + "\">"
                + "<span class=\"fa fa-history\"></span> Historial</a>"
                + "</div>";
    }

    public String getPestanaPendientesClass() {
        return isHistorial() ? "tab-cita" : "tab-cita activo";
    }

    public String getPestanaHistorialClass() {
        return isHistorial() ? "tab-cita activo" : "tab-cita";
    }

    public String getBotonPdfHtml() {
        if (!isHistorial()) {
            return "";
        }
        return "<a href=\"Control?accion=pdfCitas" + getQueryFiltros()
                + "\" class=\"btn-pdf\">"
                + "<span class=\"fa fa-file-pdf-o\"></span> Exportar PDF</a>";
    }

    public String getBotonPdfDentistaHtml() {
        if (!isHistorial()) {
            return "";
        }
        return "<a href=\"Control?accion=pdfCitas" + getQueryFiltros()
                + "\" target=\"_blank\" class=\"btn-pdf\">"
                + "<span class=\"fa fa-file-pdf-o\"></span> Exportar PDF</a>";
    }

    public String getEncabezadoDinamicoHtml() {
        if (isHistorial()) {
            return "<th>Diagnóstico</th>";
        }
        return "<th class=\"text-center\">Acciones</th>";
    }

    // Si idDentista es null -> manda SQL NULL (Admin / Secretaria)
    // Si idDentista tiene valor -> manda el ID del dentista
    public void mostrarMiniTablaCitasDelDia(Integer idDentista) {
        StringBuilder html = new StringBuilder();
        String sql = "{CALL sp_ListarCitasDelDia(?)}";

        try (Connection cn = Conexion.conecta()) {
            if (cn == null) {
                miniTablaCitasHoy = "<tr><td colspan=\"5\" class=\"text-center\">No hay conexión a la base de datos.</td></tr>";
                return;
            }

            try (CallableStatement cs = cn.prepareCall(sql)) {
                if (idDentista != null && idDentista > 0) {
                    cs.setInt(1, idDentista);
                } else {
                    cs.setNull(1, java.sql.Types.INTEGER);
                }

                boolean hayFilas = false;
                try (ResultSet rs = cs.executeQuery()) {
                    while (rs.next()) {
                        hayFilas = true;
                        Time horaSql = rs.getTime("hora");
                        String hora = (horaSql != null) ? horaCorta(horaSql) : "";
                        String paciente = rs.getString("Paciente") != null ? rs.getString("Paciente") : "";
                        String telefono = rs.getString("telefono") != null ? rs.getString("telefono") : "";
                        String dentista = rs.getString("Dentista") != null ? rs.getString("Dentista") : "";
                        String estado = rs.getString("estado") != null ? rs.getString("estado") : "";
                        String claseEst = estado.trim().toLowerCase();

                        html.append("<tr>");
                        html.append("<td class=\"col-hora\">").append(esc(hora)).append("</td>");
                        html.append("<td>").append(esc(paciente)).append("</td>");
                        html.append("<td class=\"col-tel\">").append(esc(telefono)).append("</td>");
                        html.append("<td>").append(esc(dentista)).append("</td>");
                        html.append("<td><span class=\"badge-citashoy ").append(esc(claseEst)).append("\">")
                                .append(esc(estado)).append("</span></td>");
                        html.append("</tr>");
                    }
                }
                if (!hayFilas) {
                    html.append("<tr><td colspan=\"5\" class=\"text-center\">No hay citas programadas para hoy.</td></tr>");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            html.setLength(0);
            html.append("<tr><td colspan=\"5\" class=\"text-center\">Error al cargar las citas del día.</td></tr>");
        }

        miniTablaCitasHoy = html.toString();
    }

    public void cargarMiniTablaPorRol(int rol, String usuario) {
        Integer idDentistaFiltro = null;
        if (rol == 3) {
            if (usuario != null && !usuario.trim().isEmpty()) {
                Dentistas den = new Dentistas().obtenerPorUsuario(usuario.trim());
                idDentistaFiltro = (den != null && den.getIdDentista() > 0) ? den.getIdDentista() : -1;
            } else {
                idDentistaFiltro = -1;
            }
        }
        mostrarMiniTablaCitasDelDia(idDentistaFiltro);
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

    // procedure reagendar cita (valida turno/disponibilidad del doctor y mantiene PROGRAMADA)
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
                cs.setDate(3, Date.valueOf(filtroFecha));
            } else {
                cs.setNull(3, Types.DATE);
            }
            cs.setBoolean(4, soloPendientes);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Citas c = new Citas();
                    c.idCita = rs.getInt("id_cita");
                    c.nombrePaciente = rs.getString("Paciente");
                    c.nombreDentista = rs.getString("Dentista");
                    c.fecha = rs.getDate("fecha");
                    c.hora = rs.getTime("hora");
                    c.estado = rs.getString("estado");
                    c.diagnostico = rs.getString("diagnostico");
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
                html.append("<td>#").append(c.idCita).append("</td>");
                html.append("<td>").append(esc(c.nombrePaciente)).append("</td>");
                html.append("<td>Dr(a). ").append(esc(c.nombreDentista)).append("</td>");
                html.append("<td>").append(c.fecha).append("</td>");
                html.append("<td>").append(horaCorta(c.hora)).append("</td>");
                html.append("<td><span class=\"badge-estado ").append(c.claseEstado()).append("\">")
                        .append(esc(c.estado)).append("</span></td>");

                if (isHistorial()) {
                    html.append("<td class=\"diagnostico\">").append(esc(c.diagnostico)).append("</td>");
                } else {
                    html.append("<td class=\"text-center\">");
                    if (tipoUsuario == 3) {
                        html.append("<button type=\"button\" class=\"btn-icon-tabla atender\" title=\"Atender cita\" onclick=\"abrirModalAtender(")
                                .append(c.idCita).append(")\"><span class=\"fa fa-stethoscope\"></span></button>");
                    } else {
                        html.append("<button type=\"button\" class=\"btn-icon-tabla reagendar\" title=\"Reagendar\" onclick=\"abrirModalReagendar(")
                                .append(c.idCita).append(",'").append(c.fecha).append("','")
                                .append(horaCorta(c.hora)).append("')\"><span class=\"fa fa-calendar-check-o\"></span></button>");
                        html.append("<button type=\"button\" class=\"btn-icon-tabla eliminar\" title=\"Cancelar cita\" onclick=\"abrirModalCancelar(")
                                .append(c.idCita).append(")\"><span class=\"fa fa-calendar-times-o\"></span></button>");
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

    // Historial de citas en PDF (itextpdf-5.4.1.jar) enviado directo al OutputStream de descarga
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
            tabla.addCell(new Phrase(String.valueOf(c.fecha), cellFont));
            tabla.addCell(new Phrase(horaCorta(c.hora), cellFont));
            tabla.addCell(new Phrase(c.nombrePaciente != null ? c.nombrePaciente : "", cellFont));
            tabla.addCell(new Phrase(c.nombreDentista != null ? c.nombreDentista : "", cellFont));
            tabla.addCell(new Phrase(c.estado != null ? c.estado : "", cellFont));
            tabla.addCell(new Phrase(c.diagnostico != null ? c.diagnostico : "", cellFont));
        }
        document.add(tabla);
        document.close();
    }

    // ================================
    //  AUXILIARES
    // ================================
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

    private void resultado(String error, String ok, String fallo) {
        boolean okFlag = (error == null);
        this.respuesta = (ok == null) ? error : (okFlag ? ok : fallo + error);
    }

    // Clase css del badge de estado (programada, atendida, cancelada)
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
