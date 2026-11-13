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
public class Personal {

    private String nombre, paterno, materno, usuario, correo, password, respuesta, estatus, inputlogin;
    private int tipo;
    conexion c = new conexion();

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getPaterno() {
        return paterno;
    }

    public void setPaterno(String paterno) {
        this.paterno = paterno;
    }

    public String getMaterno() {
        return materno;
    }

    public void setMaterno(String materno) {
        this.materno = materno;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }

    public String getEstatus() {
        return estatus;
    }

    public void setEstatus(String estatus) {
        this.estatus = estatus;
    }

    public String getInputlogin() {
        return inputlogin;
    }

    public void setInputlogin(String inputlogin) {
        this.inputlogin = inputlogin;
    }

    public int getTipo() {
        return tipo;
    }

    public void setTipo(int tipo) {
        this.tipo = tipo;
    }


    public void validar() {
        try {
            Connection cn = c.conecta();
            if (cn != null) {
                PreparedStatement ps = cn.prepareStatement("SELECT tipo, nombre FROM Personal WHERE (usuario=? OR correo=?) AND password=? AND estatus='A'");
                ps.setString(1, inputlogin); 
                ps.setString(2, inputlogin); 
                ps.setString(3, password);   
                ResultSet rs = ps.executeQuery();
                
                if (rs.next()) {
                    tipo = rs.getInt(1);          
                    nombre = rs.getString(2);     
                    
                    switch (tipo) {
                        case 1:
                            respuesta = "Admin/Menu1.jsp"; break;
                        case 2:
                            respuesta = "Secretaria/Menu2.jsp"; break;
                        case 3:
                            respuesta = "Dentista/Menu3.jsp"; break;
                    }
                } else {
                    respuesta = "Error.jsp?respuesta=No existe el usuario ";
                }
                
                rs.close();
                ps.close();
                cn.close();
            } else {
                respuesta = "Error.jsp?respuesta=No hay conexion a la base ";
            }
        } catch (Exception e) {
            respuesta = "Error.jsp?respuesta=error al validar usuario " + e;
        }
    }

}
