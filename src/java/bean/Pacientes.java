/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package bean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.*;

/**
 *
 * @author edu
 */

public class Pacientes {
    private String nombre, aPaterno, aMaterno, telefono, correo, direccion, respuesta;
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
            Connection cn = Conexion.conecta();
            if (cn != null) {
                PreparedStatement ps = cn.prepareStatement("SELECT id_paciente, APaterno, AMaterno, nombre FROM Pacientes WHERE estatus = 'A' ORDER BY id_paciente");
                ResultSet rs = ps.executeQuery();
                
                if (rs.next()) {
                    respuesta = "<select name='id_paciente' required>";
                    respuesta += "<option value='' disabled selected>-- Seleccione un paciente --</option>";
                    do {
                        idP = rs.getInt("id_paciente");
                        String nombreCompleto = rs.getString("nombre") + " " + rs.getString("APaterno") + " " + rs.getString("AMaterno");
                        respuesta += "<option value='" + idP + "'>" + nombreCompleto + "</option>";
                    } while (rs.next());
                    respuesta += "</select>";
                } else {
                    respuesta = "<select name='id_paciente' required><option disabled selected>No hay pacientes activos</option></select>";
                }
                
                rs.close();
                ps.close();
                cn.close();
            } else {
                respuesta = "<select name='id_paciente' required><option disabled selected>No hay conexion a la base</option></select>";
            }
        } catch (Exception e) {
            respuesta = "<select name='id_paciente' required><option disabled selected>Error al cargar datos</option></select>";
            e.printStackTrace();
        }
    }
}
