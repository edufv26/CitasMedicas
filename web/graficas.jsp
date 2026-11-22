<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="bean.Datos"%>
<%@page import="bean.Dentistas"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gráficas de Pacientes por Médico</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #12101d;
            color: #f3f2f7;
            margin: 0;
            padding: 24px;
        }
        .contenedor {
            max-width: 1200px;
            margin: 0 auto;
        }
        .barra-superior {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 20px;
        }
        .btn {
            background-color: #7c4dff;
            color: #fff;
            border: none;
            padding: 10px 18px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
        }
        .btn:hover {
            background-color: #6533e8;
        }
        .btn-secundario {
            background-color: #2b2740;
            color: #e2dfec;
        }
        .panel-controles {
            background-color: #1c192b;
            padding: 18px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }
        select {
            padding: 10px 14px;
            border-radius: 8px;
            border: 1px solid #3c3659;
            background-color: #26223b;
            color: #fff;
            font-size: 14px;
        }
        .grid-graficas {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(460px, 1fr));
            gap: 20px;
        }
        .tarjeta-grafica {
            background-color: #1c192b;
            padding: 16px;
            border-radius: 12px;
            text-align: center;
        }
        .tarjeta-grafica img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            background-color: #fff;
        }
        .mensaje {
            margin-bottom: 18px;
            padding: 12px 16px;
            border-radius: 8px;
            background-color: #242038;
            color: #c8b6ff;
        }
    </style>
</head>
<body>
<%
    Datos datos = (Datos) request.getAttribute("datosGraficas");
    List<Dentistas> listaDoctores = (List<Dentistas>) request.getAttribute("listaDoctores");

    String periodoActual = (datos != null && datos.getPeriodo() != null) ? datos.getPeriodo() : "mensual";
    int doctorActual = (datos != null) ? datos.getIdDentistaSeleccionado() : 0;
%>
<div class="contenedor">
    <div class="barra-superior">
        <h2>Gráficas de Pacientes por Médico</h2>
        <a class="btn btn-secundario" href="<%= request.getContextPath() %>/Control?accion=pacientes">
            &lt; Volver a Pacientes
        </a>
    </div>

    <form class="panel-controles" action="<%= request.getContextPath() %>/Control" method="get">
        <input type="hidden" name="accion" value="graficas">
        <input type="hidden" name="generar" value="1">

        <label for="idDentista">Doctor:</label>
        <select id="idDentista" name="idDentista">
            <option value="0" <%= doctorActual == 0 ? "selected" : "" %>>Todos los doctores</option>
            <% if (listaDoctores != null) {
                for (Dentistas doc : listaDoctores) {
                    String nom = doc.getNombre() != null ? doc.getNombre().trim() : "";
                    String pat = doc.getPaterno() != null ? doc.getPaterno().trim() : "";
                    String mat = doc.getMaterno() != null ? doc.getMaterno().trim() : "";
                    String esp = doc.getEspecialidad() != null ? doc.getEspecialidad().trim() : "";
                    String nombreCompleto = ("Dr(a). " + nom + " " + pat + " " + mat).trim().replaceAll("\\s+", " ");
            %>
            <option value="<%= doc.getIdDentista() %>" <%= doctorActual == doc.getIdDentista() ? "selected" : "" %>>
                <%= nombreCompleto %><%= !esp.isEmpty() ? " - " + esp : "" %>
            </option>
            <%  }
               } %>
        </select>

        <label for="periodo">Periodo:</label>
        <select id="periodo" name="periodo">
            <option value="semanal" <%= "semanal".equals(periodoActual) ? "selected" : "" %>>Semanal</option>
            <option value="mensual" <%= "mensual".equals(periodoActual) ? "selected" : "" %>>Mensual</option>
            <option value="anual" <%= "anual".equals(periodoActual) ? "selected" : "" %>>Anual</option>
        </select>

        <button type="submit" class="btn">Crear Gráficas</button>
    </form>

    <% if (datos != null && datos.getMensaje() != null && !datos.getMensaje().isEmpty()) { %>
        <div class="mensaje"><%= datos.getMensaje() %></div>
    <% } %>

    <% if (datos != null && datos.getRutaBarras() != null && datos.getRutaPie() != null) { %>
        <div class="grid-graficas">
            <div class="tarjeta-grafica">
                <h3>Gráfica de Barras</h3>
                <img src="<%= request.getContextPath() + "/" + datos.getRutaBarras() %>" alt="Gráfica de Barras">
            </div>
            <div class="tarjeta-grafica">
                <h3>Gráfica de Pastel (Pie)</h3>
                <img src="<%= request.getContextPath() + "/" + datos.getRutaPie() %>" alt="Gráfica de Pastel">
            </div>
        </div>
    <% } else { %>
        <div class="tarjeta-grafica">
            <p>Selecciona un doctor y un periodo, y haz clic en <strong>Crear Gráficas</strong> para generar las imágenes.</p>
        </div>
    <% } %>
</div>
<form class="panel-controles" action="<%= request.getContextPath() %>/Control" method="get" style="margin-top: 12px;">
        <input type="hidden" name="accion" value="pdfGraficas">
        <input type="hidden" name="idDentista" value="<%= doctorActual %>">
        <input type="hidden" name="periodo" value="<%= periodoActual %>">

        <label for="tipoGraficaPdf">Exportar a PDF:</label>
        <select id="tipoGraficaPdf" name="tipoGraficaPdf">
            <option value="ambos">Ambos (Barras y Pie)</option>
            <option value="barras">Solo Barras</option>
            <option value="pie">Solo Pie</option>
        </select>

        <button type="submit" class="btn">Crear PDF</button>
    </form>
</body>
</html>