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
public class Secretarias extends Personal {

    private String turno, telefono, correo;
    private int idSec;

    private final conexion Conexion = new conexion();

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

    public int getIdSec() {
        return idSec;
    }

    public void setIdSec(int idSec) {
        this.idSec = idSec;
    }

    public boolean actualizarSecretaria() {
        String updateSql = "UPDATE Secretarias SET turno = ?, telefono = ?, correo = ? WHERE usuario = ?";
        String insertSql = "INSERT INTO Secretarias (usuario, turno, telefono, correo) VALUES (?, ?, ?, ?)";

        String usr = getUsuario();
        String tur = (turno != null && !turno.trim().isEmpty()) ? turno.trim() : "Matutino";

        try (Connection cn = Conexion.conecta();
             PreparedStatement psUpd = cn.prepareStatement(updateSql)) {

            psUpd.setString(1, tur);
            psUpd.setString(2, telefono);
            psUpd.setString(3, correo);
            psUpd.setString(4, usr);

            if (psUpd.executeUpdate() > 0) {
                return true;
            }

            try (PreparedStatement psIns = cn.prepareStatement(insertSql)) {
                psIns.setString(1, usr);
                psIns.setString(2, tur);
                psIns.setString(3, telefono);
                psIns.setString(4, correo);
                return psIns.executeUpdate() > 0;
            }
        } catch (Exception e) {
            System.out.println("ERROR AL ACTUALIZAR SECRETARIA:");
            e.printStackTrace();
            return false;
        }
    }

    public List<Secretarias> llenarListaSecretarias() {
        List<Secretarias> lista = new ArrayList<>();

        String sql = "SELECT s.id_secretaria, s.usuario, s.turno, s.telefono, s.correo, "
                + "p.nombre, p.APaterno, p.AMaterno, p.estatus "
                + "FROM Secretarias s "
                + "JOIN Personal p ON s.usuario = p.usuario "
                + "WHERE p.estatus = 'A' "
                + "ORDER BY s.id_secretaria";

        try (Connection cn = Conexion.conecta();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Secretarias sec = new Secretarias();
                sec.setIdSec(rs.getInt("id_secretaria"));
                sec.setUsuario(rs.getString("usuario"));
                sec.setTurno(rs.getString("turno"));
                sec.setTelefono(rs.getString("telefono"));
                sec.setCorreo(rs.getString("correo"));
                sec.setNombre(rs.getString("nombre"));
                sec.setPaterno(rs.getString("APaterno"));
                sec.setMaterno(rs.getString("AMaterno"));
                sec.setEstatus(rs.getString("estatus"));
                lista.add(sec);
            }
        } catch (Exception e) {
            System.out.println("ERROR AL RECUPERAR SECRETARIAS:");
            e.printStackTrace();
        }

        return lista;
    }

    public Secretarias obtenerPorUsuario(String usr) {
        Secretarias sec = null;

        String sql = "SELECT s.id_secretaria, s.usuario, s.turno, s.telefono, s.correo, "
                + "p.nombre, p.APaterno, p.AMaterno, p.tipo, p.estatus "
                + "FROM Secretarias s "
                + "JOIN Personal p ON s.usuario = p.usuario "
                + "WHERE s.usuario = ?";

        try (Connection cn = Conexion.conecta();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, usr);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    sec = new Secretarias();
                    sec.setIdSec(rs.getInt("id_secretaria"));
                    sec.setUsuario(rs.getString("usuario"));
                    sec.setTurno(rs.getString("turno"));
                    sec.setTelefono(rs.getString("telefono"));
                    sec.setCorreo(rs.getString("correo"));
                    sec.setNombre(rs.getString("nombre"));
                    sec.setPaterno(rs.getString("APaterno"));
                    sec.setMaterno(rs.getString("AMaterno"));
                    sec.setTipo(rs.getInt("tipo"));
                    sec.setEstatus(rs.getString("estatus"));
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR AL OBTENER SECRETARIA POR USUARIO:");
            e.printStackTrace();
        }

        return sec;
    }
}