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
    private String especialidad, cedula, turno, telefono, correo;
    private int idDen;

    conexion Conexion = new conexion();

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

    public int getIdDen() {
        return idDen;
    }

    public void setIdDen(int idDen) {
        this.idDen = idDen;
    }
    
    // Alias para que coincida exactamente con el llamado d.getIdDentista() del JSP
    public int getIdDentista() {
        return idDen;
    }
    // Método encargado de traer todos los dentistas haciendo JOIN con Personal
    public List<Dentistas> llenarListaDentistas() {
        List<Dentistas> lista = new ArrayList<>();
        
        // Hacemos el JOIN con la tabla Personal utilizando su relación por usuario
        String sql = "SELECT d.id_dentista, d.especialidad, d.cedula_profesional, d.turno, d.telefono, d.correo, p.nombre " +
                     "FROM Dentistas d JOIN Personal p ON d.usuario = p.usuario";

        try (Connection cn = Conexion.conecta();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Dentistas d = new Dentistas();
                d.setIdDen(rs.getInt("id_dentista"));
                d.setEspecialidad(rs.getString("especialidad"));
                d.setCedula(rs.getString("cedula_profesional"));
                d.setTurno(rs.getString("turno"));
                d.setTelefono(rs.getString("telefono"));
                d.setCorreo(rs.getString("correo"));
                d.setNombre(rs.getString("nombre")); // <-- ¡Asignamos el nombre heredado de Personal!
                
                lista.add(d);
            }
        } catch (Exception e) {
            System.out.println("ERROR AL RECUPERAR DENTISTAS:");
            e.printStackTrace();
        }

        return lista;
    }
}