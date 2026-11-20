/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package bean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author edu
 */
public class Dentistas extends Personal {

    private String especialidad, cedula, turno, telefono, correo, respuesta;
    private int idDentista;

    private final conexion Conexion = new conexion();

    public String getEspecialidad() {
        return especialidad;
    }

    public void setEspecialidad(String especialidad) {
        this.especialidad = especialidad;
    }

    public String getCedula() {
        return cedula;
    }

    public void setCedula(String cedula) {
        this.cedula = cedula;
    }

    public String getTurno() {
        return turno;
    }

    public void setTurno(String turno) {
        this.turno = turno;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public int getIdDentista() {
        return idDentista;
    }

    public void setIdDentista(int idDentista) {
        this.idDentista = idDentista;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }
    

    public boolean actualizarDentista() {
        String updateSql = "UPDATE Dentistas SET especialidad = ?, cedula_profesional = ?, "
                + "turno = ?, telefono = ?, correo = ? WHERE usuario = ?";
        String insertSql = "INSERT INTO Dentistas (usuario, especialidad, cedula_profesional, turno, telefono, correo) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        String usr = getUsuario();
        String esp = (especialidad != null) ? especialidad.trim() : "";
        String ced = (cedula != null) ? cedula.trim() : "";
        String tur = (turno != null && !turno.trim().isEmpty()) ? turno.trim() : "Matutino";

        try (Connection cn = Conexion.conecta(); PreparedStatement psUpd = cn.prepareStatement(updateSql)) {

            psUpd.setString(1, esp);
            psUpd.setString(2, ced);
            psUpd.setString(3, tur);
            psUpd.setString(4, telefono);
            psUpd.setString(5, correo);
            psUpd.setString(6, usr);

            if (psUpd.executeUpdate() > 0) {
                return true;
            }

            try (PreparedStatement psIns = cn.prepareStatement(insertSql)) {
                psIns.setString(1, usr);
                psIns.setString(2, esp);
                psIns.setString(3, ced);
                psIns.setString(4, tur);
                psIns.setString(5, telefono);
                psIns.setString(6, correo);
                return psIns.executeUpdate() > 0;
            }
        } catch (Exception e) {
            System.out.println("ERROR AL ACTUALIZAR DENTISTA:");
            e.printStackTrace();
            return false;
        }
    }

    // Método encargado de traer todos los dentistas haciendo JOIN con Personal
    public List<Dentistas> llenarListaDentistas() {
        List<Dentistas> lista = new ArrayList<>();

        String sql = "SELECT d.id_dentista, d.usuario, d.especialidad, d.cedula_profesional, d.turno, "
                + "d.telefono, d.correo, p.nombre, p.APaterno, p.AMaterno "
                + "FROM Dentistas d "
                + "JOIN Personal p ON d.usuario = p.usuario "
                + "WHERE p.estatus = 'A' "
                + "ORDER BY d.id_dentista";

        try (Connection cn = Conexion.conecta(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Dentistas d = new Dentistas();
                d.setIdDentista(rs.getInt("id_dentista"));
                d.setUsuario(rs.getString("usuario"));
                d.setEspecialidad(rs.getString("especialidad"));
                d.setCedula(rs.getString("cedula_profesional"));
                d.setTurno(rs.getString("turno"));
                d.setTelefono(rs.getString("telefono"));
                d.setCorreo(rs.getString("correo"));
                d.setNombre(rs.getString("nombre"));
                d.setPaterno(rs.getString("APaterno"));
                d.setMaterno(rs.getString("AMaterno"));

                lista.add(d);
            }
        } catch (Exception e) {
            System.out.println("ERROR AL RECUPERAR DENTISTAS:");
            e.printStackTrace();
        }

        return lista;
    }

    public Dentistas obtenerPorUsuario(String usr) {
        Dentistas d = null;

        String sql = "SELECT d.id_dentista, d.usuario, d.especialidad, d.cedula_profesional, d.turno, "
                + "d.telefono, d.correo, p.nombre, p.APaterno, p.AMaterno, p.tipo, p.estatus "
                + "FROM Dentistas d "
                + "JOIN Personal p ON d.usuario = p.usuario "
                + "WHERE d.usuario = ?";

        try (Connection cn = Conexion.conecta(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, usr);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    d = new Dentistas();
                    d.setIdDentista(rs.getInt("id_dentista"));
                    d.setUsuario(rs.getString("usuario"));
                    d.setEspecialidad(rs.getString("especialidad"));
                    d.setCedula(rs.getString("cedula_profesional"));
                    d.setTurno(rs.getString("turno"));
                    d.setTelefono(rs.getString("telefono"));
                    d.setCorreo(rs.getString("correo"));
                    d.setNombre(rs.getString("nombre"));
                    d.setPaterno(rs.getString("APaterno"));
                    d.setMaterno(rs.getString("AMaterno"));
                    d.setTipo(rs.getInt("tipo"));
                    d.setEstatus(rs.getString("estatus"));
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR AL OBTENER DENTISTA POR USUARIO:");
            e.printStackTrace();
        }

        return d;
    }

    public void generarSelectDoctor(int idDoctorSeleccionado, boolean esEdicion) {
        if (!esEdicion) {
            respuesta = "";
            return;
        }

        StringBuilder html = new StringBuilder();
        html.append("<div class=\"campo-grupo select-doctor\">");
        html.append("<label>Doctor de Preferencia:</label>");
        html.append("<select name=\"idDenP\">");
        html.append("<option value=\"0\"")
                .append(idDoctorSeleccionado == 0 ? " selected" : "")
                .append(">-- No asignado --</option>");

        List<Dentistas> listaDentistas = llenarListaDentistas();
        if (listaDentistas != null && !listaDentistas.isEmpty()) {
            for (Dentistas d : listaDentistas) {
                boolean seleccionado = (idDoctorSeleccionado == d.getIdDentista());

                String nom = (d.getNombre() != null) ? d.getNombre().trim() : "";
                String pat = (d.getPaterno() != null) ? d.getPaterno().trim() : "";
                String mat = (d.getMaterno() != null) ? d.getMaterno().trim() : "";
                String esp = (d.getEspecialidad() != null) ? d.getEspecialidad().trim() : "";

                String nombreCompletoDoc = (nom + " " + pat + " " + mat).trim().replaceAll("\\s+", " ");

                html.append("<option value=\"").append(d.getIdDentista()).append("\"")
                        .append(seleccionado ? " selected" : "")
                        .append(">Dr(a). ").append(nombreCompletoDoc);

                if (!esp.isEmpty()) {
                    html.append(" - ").append(esp);
                }
                html.append("</option>");
            }
        }

        html.append("</select>");
        html.append("</div>");

        respuesta = html.toString();
    }
}
