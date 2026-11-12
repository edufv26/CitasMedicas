/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package bean;

import java.sql.*;

/**
 *
 * @author edu
 */

public class Pacientes {
    private String nombre,aPaterno,aMaterno,telefono,correo,direccion,respuesta;
    private int idP, idDenP;
    
    conexion Conexion = new conexion();

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getaPaterno() {
        return aPaterno;
    }

    public void setaPaterno(String aPaterno) {
        this.aPaterno = aPaterno;
    }

    public String getaMaterno() {
        return aMaterno;
    }

    public void setaMaterno(String aMaterno) {
        this.aMaterno = aMaterno;
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

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }

    public int getIdDenP() {
        return idDenP;
    }

    public void setIdDenP(int idDenP) {
        this.idDenP = idDenP;
    }

    public conexion getConexion() {
        return Conexion;
    }

    public void setConexion(conexion Conexion) {
        this.Conexion = Conexion;
    }
    
    public void llenarSelectorPacientes() {
    try {
        Connection c = Conexion.conecta("Consultorio");
        if (c != null) {
            // Ojo aquí: puedes filtrar por estatus 'A' para que solo salgan los activos
            PreparedStatement ps = c.prepareStatement("SELECT id_paciente, nombre, APaterno FROM Pacientes WHERE estatus = 'A'");
            ResultSet rs = ps.executeQuery();
            
            respuesta = "<select name='id_paciente' required>";
            respuesta += "<option value='' disabled selected>-- Seleccione un paciente --</option>";
            
            while (rs.next()) {
                int id = rs.getInt("id_paciente");
                String nombreCompleto = rs.getString("nombre") + " " + rs.getString("APaterno");
                respuesta += "<option value='" + id + "'>" + nombreCompleto + "</option>";
            }
            respuesta += "</select>";
            
            rs.close();
            ps.close();
            c.close();
        } else {
            respuesta = "<option>No hay conexion a la base</option>";
        }
    } catch (Exception e) {
        respuesta = "<option>Error al cargar datos</option>";
    }
}
    
}
