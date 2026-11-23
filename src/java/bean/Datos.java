package bean;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.awt.Color;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PiePlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.general.DefaultPieDataset;

public class Datos extends Dentistas {

    conexion Conexion = new conexion();

    private String periodo = "mensual"; // semanal, mensual, anual
    private int idDentistaSeleccionado; // 0 = todos los doctores
    private String nombreDoctorSeleccionado;
    private String rutaBarras;
    private String rutaPie;
    private String mensaje;
    private String contextPath;
    private List<Dentistas> listaDoctores;

    // Completadas (ATENDIDA) = Rojo | Pendientes (PROGRAMADA / REAGENDADA) = Morado
    private static final Color COLOR_COMPLETADAS = new Color(220, 53, 69);
    private static final Color COLOR_PENDIENTES = new Color(124, 77, 255);

    public String getPeriodo() {
        return periodo;
    }

    public void setPeriodo(String periodo) {
        this.periodo = periodo;
    }

    public int getIdDentistaSeleccionado() {
        return idDentistaSeleccionado;
    }

    public void setIdDentistaSeleccionado(int idDentistaSeleccionado) {
        this.idDentistaSeleccionado = idDentistaSeleccionado;
    }

    public String getNombreDoctorSeleccionado() {
        return nombreDoctorSeleccionado;
    }

    public void setNombreDoctorSeleccionado(String nombreDoctorSeleccionado) {
        this.nombreDoctorSeleccionado = nombreDoctorSeleccionado;
    }

    public String getRutaBarras() {
        return rutaBarras;
    }

    public String getRutaPie() {
        return rutaPie;
    }

    public String getMensaje() {
        return mensaje;
    }

    public String getContextPath() {
        return contextPath;
    }

    public void setContextPath(String contextPath) {
        this.contextPath = contextPath;
    }

    public List<Dentistas> getListaDoctores() {
        return listaDoctores;
    }

    public void setListaDoctores(List<Dentistas> listaDoctores) {
        this.listaDoctores = listaDoctores;
    }

    public boolean isGraficasListas() {
        return rutaBarras != null && !rutaBarras.trim().isEmpty() && rutaPie != null && !rutaPie.trim().isEmpty();
    }

    // Selector de doctores usando listaDoctores o llenarListaDentistas() heredado de Dentistas
    public String getSelectDoctores() {
        List<Dentistas> doctores = (this.listaDoctores != null)
                ? this.listaDoctores
                : llenarListaDentistas(); //[cite: 3]

        StringBuilder sb = new StringBuilder();
        sb.append("<select id=\"idDentista\" name=\"idDentista\">");
        sb.append("<option value=\"0\"")
                .append(this.idDentistaSeleccionado == 0 ? " selected" : "")
                .append(">Todos los doctores</option>");

        if (doctores != null) {
            for (Dentistas doc : doctores) {
                String nom = doc.getNombre() != null ? doc.getNombre().trim() : ""; //[cite: 3]
                String pat = doc.getPaterno() != null ? doc.getPaterno().trim() : ""; //[cite: 3]
                String mat = doc.getMaterno() != null ? doc.getMaterno().trim() : ""; //[cite: 3]
                String esp = doc.getEspecialidad() != null ? doc.getEspecialidad().trim() : ""; //[cite: 3]
                String nombreCompleto = ("Dr(a). " + nom + " " + pat + " " + mat).trim().replaceAll("\\s+", " ");
                String texto = nombreCompleto + (!esp.isEmpty() ? " - " + esp : "");
                String selected = (this.idDentistaSeleccionado == doc.getIdDentista()) ? " selected" : ""; //[cite: 3]

                sb.append("<option value=\"").append(doc.getIdDentista()).append("\"") //[cite: 3]
                        .append(selected).append(">")
                        .append(texto)
                        .append("</option>");
            }
        }
        sb.append("</select>");
        setRespuesta(sb.toString()); //[cite: 3]
        return sb.toString();
    }

    // Selector de periodo para <jsp:getProperty name="datosGraficas" property="selectPeriodo"/>
    public String getSelectPeriodo() {
        String perActual = (this.periodo == null || this.periodo.trim().isEmpty())
                ? "mensual"
                : this.periodo.trim().toLowerCase();

        StringBuilder sb = new StringBuilder();
        sb.append("<select id=\"periodo\" name=\"periodo\">");
        sb.append("<option value=\"semanal\"").append("semanal".equals(perActual) ? " selected" : "").append(">Semanal</option>");
        sb.append("<option value=\"mensual\"").append("mensual".equals(perActual) ? " selected" : "").append(">Mensual</option>");
        sb.append("<option value=\"anual\"").append("anual".equals(perActual) ? " selected" : "").append(">Anual</option>");
        sb.append("</select>");
        return sb.toString();
    }

    // Mensaje + tarjetas de gráficas (o aviso inicial) para <jsp:getProperty name="datosGraficas" property="bloqueGraficas"/>
    public String getBloqueGraficas() {
        StringBuilder sb = new StringBuilder();

        if (this.mensaje != null && !this.mensaje.trim().isEmpty()) {
            sb.append("<div class=\"mensaje\">").append(this.mensaje).append("</div>");
        }

        if (isGraficasListas()) {
            String ctx = (this.contextPath != null) ? this.contextPath : "";
            sb.append("<div class=\"grid-graficas\">")
                    .append("<div class=\"tarjeta-grafica\">")
                    .append("<h3>Gráfica de Barras</h3>")
                    .append("<img src=\"").append(ctx).append("/").append(this.rutaBarras).append("\" alt=\"Gráfica de Barras\">")
                    .append("</div>")
                    .append("<div class=\"tarjeta-grafica\">")
                    .append("<h3>Gráfica de Pastel (Pie)</h3>")
                    .append("<img src=\"").append(ctx).append("/").append(this.rutaPie).append("\" alt=\"Gráfica de Pastel\">")
                    .append("</div>")
                    .append("</div>");
        } else {
            sb.append("<div class=\"tarjeta-grafica\">")
                    .append("<p>Selecciona un doctor y un periodo, y haz clic en <strong>Crear Gráficas</strong> para generar las imágenes.</p>")
                    .append("</div>");
        }

        return sb.toString();
    }

    public String getBloquePdf() {
        boolean listas = isGraficasListas();
        String attrDisabled = !listas ? " disabled=\"disabled\"" : "";
        StringBuilder sb = new StringBuilder();

        sb.append("<label for=\"tipoGraficaPdf\">Exportar a PDF:</label>")
                .append("<select id=\"tipoGraficaPdf\" name=\"tipoGraficaPdf\"").append(attrDisabled).append(">")
                .append("<option value=\"ambos\">Ambos (Barras y Pie)</option>")
                .append("<option value=\"barras\">Solo Barras</option>")
                .append("<option value=\"pie\">Solo Pie</option>")
                .append("</select>")
                .append("<button type=\"submit\" class=\"btn btn-pdf\"").append(attrDisabled).append(">")
                .append("<span class=\"fa fa-file-pdf-o\"></span> Exportar PDF")
                .append("</button>");

        if (!listas) {
            sb.append("<span class=\"mensaje-grafica-pendiente\">")
                    .append("Primero genera las gráficas para habilitar el PDF.")
                    .append("</span>");
        }

        return sb.toString();
    }

    /**
     * Consulta pacientes (vía citas) por médico según periodo (semanal,
     * mensual, anual) y opcionalmente filtrado por id_dentista (0 = todos).
     *
     * Clave = Nombre del médico int[0] = Completadas (estado = 'ATENDIDA') ->
     * Rojo int[1] = Pendientes (estado IN ('PROGRAMADA', 'REAGENDADA')) ->
     * Morado
     */
    public Map<String, int[]> obtenerPacientesPorEstado(String periodoSeleccionado, int idDentista) {
        Map<String, int[]> datos = new LinkedHashMap<>();

        StringBuilder where = new StringBuilder(" WHERE p.estatus = 'A' ");

        if ("semanal".equalsIgnoreCase(periodoSeleccionado)) {
            where.append(" AND c.fecha >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) ");
        } else if ("anual".equalsIgnoreCase(periodoSeleccionado)) {
            where.append(" AND c.fecha >= DATEADD(YEAR, -1, CAST(GETDATE() AS DATE)) ");
        } else {
            // mensual por defecto
            where.append(" AND c.fecha >= DATEADD(MONTH, -1, CAST(GETDATE() AS DATE)) ");
        }

        if (idDentista > 0) {
            where.append(" AND d.id_dentista = ? ");
        }

        String sql = "SELECT "
                + "LTRIM(RTRIM(CONCAT(ISNULL(per.nombre, ''), ' ', ISNULL(per.APaterno, ''), ' ', ISNULL(per.AMaterno, '')))) AS medico, "
                + "COUNT(DISTINCT CASE WHEN UPPER(LTRIM(RTRIM(c.estado))) = 'ATENDIDA' THEN p.id_paciente END) AS completadas, "
                + "COUNT(DISTINCT CASE WHEN UPPER(LTRIM(RTRIM(c.estado))) IN ('PROGRAMADA', 'REAGENDADA') THEN p.id_paciente END) AS pendientes "
                + "FROM dbo.Citas c "
                + "INNER JOIN dbo.Pacientes p ON c.id_paciente = p.id_paciente "
                + "INNER JOIN dbo.Dentistas d ON c.id_dentista = d.id_dentista "
                + "INNER JOIN dbo.Personal per ON d.usuario = per.usuario "
                + where.toString()
                + "GROUP BY d.id_dentista, per.nombre, per.APaterno, per.AMaterno "
                + "ORDER BY medico ASC";

        try (Connection con = Conexion.conecta(); PreparedStatement ps = con.prepareStatement(sql)) {

            if (idDentista > 0) {
                ps.setInt(1, idDentista);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String medico = rs.getString("medico");
                    if (medico == null || medico.trim().isEmpty()) {
                        medico = "Médico sin nombre";
                    }
                    int comp = rs.getInt("completadas");
                    int pend = rs.getInt("pendientes");
                    datos.put("Dr(a). " + medico.trim().replaceAll("\\s+", " "), new int[]{comp, pend});
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            mensaje = "Error al consultar pacientes por estado: " + e.getMessage();
        }

        return datos;
    }

    /**
     * Consulta los pacientes (vía citas) correspondientes al periodo (semanal,
     * mensual, anual) y doctor seleccionado para la tabla del PDF.
     */
    public List<String[]> obtenerDetallePacientesPeriodo(String periodoSeleccionado, int idDentista) {
        List<String[]> lista = new ArrayList<>();

        StringBuilder where = new StringBuilder(" WHERE p.estatus = 'A' ");
        if ("semanal".equalsIgnoreCase(periodoSeleccionado)) {
            where.append(" AND c.fecha >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE)) ");
        } else if ("anual".equalsIgnoreCase(periodoSeleccionado)) {
            where.append(" AND c.fecha >= DATEADD(YEAR, -1, CAST(GETDATE() AS DATE)) ");
        } else {
            where.append(" AND c.fecha >= DATEADD(MONTH, -1, CAST(GETDATE() AS DATE)) ");
        }

        if (idDentista > 0) {
            where.append(" AND d.id_dentista = ? ");
        }

        String sql = "SELECT "
                + "LTRIM(RTRIM(CONCAT(ISNULL(p.nombre, ''), ' ', ISNULL(p.APaterno, ''), ' ', ISNULL(p.AMaterno, '')))) AS paciente, "
                + "LTRIM(RTRIM(CONCAT('Dr(a). ', ISNULL(per.nombre, ''), ' ', ISNULL(per.APaterno, '')))) AS medico, "
                + "CONVERT(VARCHAR(10), c.fecha, 120) AS fecha, "
                + "CONVERT(VARCHAR(8), c.hora, 108) AS hora, "
                + "c.estado "
                + "FROM dbo.Citas c "
                + "INNER JOIN dbo.Pacientes p ON c.id_paciente = p.id_paciente "
                + "INNER JOIN dbo.Dentistas d ON c.id_dentista = d.id_dentista "
                + "INNER JOIN dbo.Personal per ON d.usuario = per.usuario "
                + where.toString()
                + "ORDER BY c.fecha DESC, c.hora DESC";

        try (Connection con = Conexion.conecta(); PreparedStatement ps = con.prepareStatement(sql)) {

            if (idDentista > 0) {
                ps.setInt(1, idDentista);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new String[]{
                        rs.getString("paciente"),
                        rs.getString("medico"),
                        rs.getString("fecha"),
                        rs.getString("hora"),
                        rs.getString("estado")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    public boolean generarGraficas(String rutaRealApp, String periodoSeleccionado, int idDentista, String nombreDoctor) {
        this.periodo = (periodoSeleccionado == null || periodoSeleccionado.trim().isEmpty())
                ? "mensual"
                : periodoSeleccionado.trim().toLowerCase();
        this.idDentistaSeleccionado = idDentista;
        this.nombreDoctorSeleccionado = (nombreDoctor != null && !nombreDoctor.trim().isEmpty())
                ? nombreDoctor.trim()
                : "Todos los doctores";

        File carpetaGraficas = new File(rutaRealApp, "graficas");
        if (!carpetaGraficas.exists()) {
            boolean creada = carpetaGraficas.mkdirs();
            if (!creada) {
                mensaje = "No se pudo crear la carpeta 'graficas'.";
                return false;
            }
        }

        File[] archivosAnteriores = carpetaGraficas.listFiles();
        if (archivosAnteriores != null) {
            for (File archivo : archivosAnteriores) {
                if (archivo.isFile()) {
                    archivo.delete();
                }
            }
        }

        Map<String, int[]> resumen = obtenerPacientesPorEstado(this.periodo, this.idDentistaSeleccionado);

        long timestamp = System.currentTimeMillis();
        String nombreBarras = "barras_" + this.periodo + "_" + this.idDentistaSeleccionado + "_" + timestamp + ".png";
        String nombrePie = "pie_" + this.periodo + "_" + this.idDentistaSeleccionado + "_" + timestamp + ".png";

        File archivoBarras = new File(carpetaGraficas, nombreBarras);
        File archivoPie = new File(carpetaGraficas, nombrePie);

        String tituloPeriodo;
        if ("semanal".equals(this.periodo)) {
            tituloPeriodo = "Semanal";
        } else if ("anual".equals(this.periodo)) {
            tituloPeriodo = "Anual";
        } else {
            tituloPeriodo = "Mensual";
        }

        String subtituloFiltro = (this.idDentistaSeleccionado > 0)
                ? " - " + this.nombreDoctorSeleccionado
                : " - Todos";

        int totalCompletadas = 0;
        int totalPendientes = 0;

        try {
            // --- Gráfica de Barras (Completadas = Rojo, Pendientes = Morado) ---
            DefaultCategoryDataset barDataset = new DefaultCategoryDataset();

            if (resumen.isEmpty()) {
                barDataset.addValue(0, "Completadas", "Sin registros");
                barDataset.addValue(0, "Pendientes", "Sin registros");
            } else {
                for (Map.Entry<String, int[]> entry : resumen.entrySet()) {
                    String etiqueta = entry.getKey();
                    int comp = entry.getValue()[0];
                    int pend = entry.getValue()[1];

                    totalCompletadas += comp;
                    totalPendientes += pend;

                    barDataset.addValue(comp, "Completadas", etiqueta);
                    barDataset.addValue(pend, "Pendientes", etiqueta);
                }
            }

            JFreeChart chartBarras = ChartFactory.createBarChart(
                    "Pacientes (" + tituloPeriodo + ")" + subtituloFiltro,
                    "Médico",
                    "Cantidad de Pacientes",
                    barDataset,
                    PlotOrientation.VERTICAL,
                    true,
                    true,
                    false
            );
            chartBarras.setBackgroundPaint(Color.WHITE);
            chartBarras.getTitle().setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 15));

            CategoryPlot barPlot = chartBarras.getCategoryPlot();
            barPlot.setBackgroundPaint(new Color(248, 249, 252));
            barPlot.setRangeGridlinePaint(Color.LIGHT_GRAY);

            BarRenderer renderer = (BarRenderer) barPlot.getRenderer();
            renderer.setSeriesPaint(0, COLOR_COMPLETADAS); // Rojo: Completadas
            renderer.setSeriesPaint(1, COLOR_PENDIENTES);  // Morado: Pendientes

            ChartUtilities.saveChartAsPNG(archivoBarras, chartBarras, 640, 380);

            // --- Gráfica de Pastel (Pie) ---
            DefaultPieDataset pieDataset = new DefaultPieDataset();
            if (totalCompletadas == 0 && totalPendientes == 0) {
                pieDataset.setValue("Sin registros", 1);
            } else {
                if (totalCompletadas > 0) {
                    pieDataset.setValue("Completadas (" + totalCompletadas + ")", totalCompletadas);
                }
                if (totalPendientes > 0) {
                    pieDataset.setValue("Pendientes (" + totalPendientes + ")", totalPendientes);
                }
            }

            JFreeChart chartPie = ChartFactory.createPieChart(
                    "Completadas vs Pendientes (" + tituloPeriodo + ")" + subtituloFiltro,
                    pieDataset,
                    true,
                    true,
                    false
            );
            chartPie.setBackgroundPaint(Color.WHITE);
            chartPie.getTitle().setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 15));

            PiePlot piePlot = (PiePlot) chartPie.getPlot();
            piePlot.setBackgroundPaint(Color.WHITE);
            piePlot.setOutlinePaint(null);
            piePlot.setLabelFont(new java.awt.Font("SansSerif", java.awt.Font.PLAIN, 12));

            if (totalCompletadas == 0 && totalPendientes == 0) {
                piePlot.setSectionPaint("Sin registros", Color.LIGHT_GRAY);
            } else {
                if (totalCompletadas > 0) {
                    piePlot.setSectionPaint("Completadas (" + totalCompletadas + ")", COLOR_COMPLETADAS);
                }
                if (totalPendientes > 0) {
                    piePlot.setSectionPaint("Pendientes (" + totalPendientes + ")", COLOR_PENDIENTES);
                }
            }

            ChartUtilities.saveChartAsPNG(archivoPie, chartPie, 600, 380);

            this.rutaBarras = "graficas/" + nombreBarras;
            this.rutaPie = "graficas/" + nombrePie;
            this.mensaje = "Gráficas generadas (" + tituloPeriodo + subtituloFiltro
                    + ") | Completadas: " + totalCompletadas + " (Rojo) | Pendientes: " + totalPendientes + " (Morado).";
            return true;

        } catch (IOException e) {
            e.printStackTrace();
            this.mensaje = "Error al guardar las imágenes de las gráficas: " + e.getMessage();
            return false;
        }
    }

    public void generarPdfGraficas(OutputStream out, String rutaRealApp,
            String periodoSeleccionado, int idDentista, String nombreDoctor, String tipoGraficaPdf) {
        String per = (periodoSeleccionado == null || periodoSeleccionado.trim().isEmpty())
                ? "mensual"
                : periodoSeleccionado.trim().toLowerCase();
        String tipoPdf = (tipoGraficaPdf == null || tipoGraficaPdf.trim().isEmpty())
                ? "ambos"
                : tipoGraficaPdf.trim().toLowerCase();

        generarGraficas(rutaRealApp, per, idDentista, nombreDoctor);

        File carpetaGraficas = new File(rutaRealApp, "graficas");
        File archivoBarras = null;
        File archivoPie = null;

        if (carpetaGraficas.exists() && carpetaGraficas.isDirectory()) {
            File[] archivos = carpetaGraficas.listFiles();
            if (archivos != null) {
                for (File f : archivos) {
                    if (f.isFile()) {
                        String n = f.getName().toLowerCase();
                        if (n.startsWith("barras_") && n.endsWith(".png")) {
                            archivoBarras = f;
                        } else if (n.startsWith("pie_") && n.endsWith(".png")) {
                            archivoPie = f;
                        }
                    }
                }
            }
        }

        String tituloPeriodo;
        if ("semanal".equals(per)) {
            tituloPeriodo = "Semanal";
        } else if ("anual".equals(per)) {
            tituloPeriodo = "Anual";
        } else {
            tituloPeriodo = "Mensual";
        }

        String docLabel = (idDentista > 0 && nombreDoctor != null && !nombreDoctor.trim().isEmpty())
                ? nombreDoctor.trim()
                : "Todos los doctores";

        Document doc = new Document(PageSize.LETTER, 36, 36, 36, 36);
        try {
            PdfWriter.getInstance(doc, out);
            doc.open();

            Font fuenteTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16, BaseColor.DARK_GRAY);
            Font fuenteSub = FontFactory.getFont(FontFactory.HELVETICA, 10, BaseColor.GRAY);
            Font fuenteSeccion = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, new BaseColor(108, 92, 231));
            Font fuenteHeaderTabla = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, BaseColor.WHITE);
            Font fuenteCelda = FontFactory.getFont(FontFactory.HELVETICA, 9, BaseColor.BLACK);

            Paragraph titulo = new Paragraph("Reporte de Pacientes por Médico (" + tituloPeriodo + ")", fuenteTitulo);
            titulo.setSpacingAfter(4f);
            doc.add(titulo);

            Paragraph subtitulo = new Paragraph("Filtro: " + docLabel + "  |  Gráficas en PDF: " + tipoPdf.toUpperCase(), fuenteSub);
            subtitulo.setSpacingAfter(14f);
            doc.add(subtitulo);

            boolean incluirBarras = "barras".equals(tipoPdf) || "ambos".equals(tipoPdf);
            boolean incluirPie = "pie".equals(tipoPdf) || "ambos".equals(tipoPdf);

            if (incluirBarras && archivoBarras != null && archivoBarras.exists()) {
                doc.add(new Paragraph("Gráfica de Barras", fuenteSeccion));
                Image imgBarras = Image.getInstance(archivoBarras.getAbsolutePath());
                imgBarras.scaleToFit(500f, 260f);
                imgBarras.setAlignment(Element.ALIGN_CENTER);
                imgBarras.setSpacingBefore(6f);
                imgBarras.setSpacingAfter(12f);
                doc.add(imgBarras);
            }

            if (incluirPie && archivoPie != null && archivoPie.exists()) {
                doc.add(new Paragraph("Gráfica de Pastel (Pie)", fuenteSeccion));
                Image imgPie = Image.getInstance(archivoPie.getAbsolutePath());
                imgPie.scaleToFit(480f, 260f);
                imgPie.setAlignment(Element.ALIGN_CENTER);
                imgPie.setSpacingBefore(6f);
                imgPie.setSpacingAfter(14f);
                doc.add(imgPie);
            }

            doc.add(new Paragraph("Pacientes en el periodo (" + tituloPeriodo + ")", fuenteSeccion));
            Paragraph esp = new Paragraph(" ");
            esp.setSpacingAfter(4f);
            doc.add(esp);

            List<String[]> filas = obtenerDetallePacientesPeriodo(per, idDentista);

            PdfPTable tabla = new PdfPTable(5);
            tabla.setWidthPercentage(100f);
            tabla.setWidths(new float[]{28f, 26f, 15f, 13f, 18f});

            String[] headers = {"Paciente", "Médico", "Fecha", "Hora", "Estado"};
            BaseColor colorHeader = new BaseColor(75, 56, 175);
            for (String h : headers) {
                PdfPCell celdaH = new PdfPCell(new Phrase(h, fuenteHeaderTabla));
                celdaH.setBackgroundColor(colorHeader);
                celdaH.setPadding(6f);
                tabla.addCell(celdaH);
            }

            if (filas.isEmpty()) {
                PdfPCell vacia = new PdfPCell(new Phrase("No hay registros de pacientes en este periodo.", fuenteCelda));
                vacia.setColspan(5);
                vacia.setPadding(8f);
                vacia.setHorizontalAlignment(Element.ALIGN_CENTER);
                tabla.addCell(vacia);
            } else {
                for (String[] fila : filas) {
                    for (String col : fila) {
                        PdfPCell celda = new PdfPCell(new Phrase(col != null ? col : "", fuenteCelda));
                        celda.setPadding(5f);
                        tabla.addCell(celda);
                    }
                }
            }

            doc.add(tabla);
            doc.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
