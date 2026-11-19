/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package bean;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author edu
 */
public class Personal {

    private String nombre, paterno, materno, usuario, correo, telefono, password, respuesta, estatus;
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

    public int getTipo() {
        return tipo;
    }

    public void setTipo(int tipo) {
        this.tipo = tipo;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }


    public void validar() {
        try {
            Connection cn = c.conecta();
            if (cn != null) {
                PreparedStatement ps = cn.prepareStatement("SELECT tipo, nombre FROM Personal WHERE usuario=? AND password=? AND estatus='A'");
                ps.setString(1, usuario); 
                ps.setString(2, password);   
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
    
   public List<Personal> llenarListaAdmins() {
    List<Personal> lista = new ArrayList<>();

    String sql = "SELECT usuario, nombre, APaterno, AMaterno, telefono, correo, tipo, estatus "
            + "FROM Personal "
            + "WHERE tipo = 1 AND estatus = 'A' "
            + "ORDER BY usuario";

    try {
        Connection cn = c.conecta();
        PreparedStatement ps = cn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Personal admin = new Personal();
            admin.setUsuario(rs.getString("usuario"));
            admin.setNombre(rs.getString("nombre"));
            admin.setPaterno(rs.getString("APaterno"));
            admin.setMaterno(rs.getString("AMaterno"));
            admin.setTelefono(rs.getString("telefono"));
            admin.setCorreo(rs.getString("correo"));
            admin.setTipo(rs.getInt("tipo"));
            admin.setEstatus(rs.getString("estatus"));
            lista.add(admin);
        }
    } catch (Exception e) {
        System.out.println("ERROR AL RECUPERAR ADMINS:");
        e.printStackTrace();
    }

    return lista;
}
    public Personal obtenerPorUsuario(String usr) {
        Personal per = null;
        String sql = "SELECT usuario, nombre, APaterno, AMaterno, telefono, correo, tipo, estatus "
                + "FROM Personal WHERE usuario = ?";

        try (Connection cn = c.conecta();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, usr);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    per = new Personal();
                    per.setUsuario(rs.getString("usuario"));
                    per.setNombre(rs.getString("nombre"));
                    per.setPaterno(rs.getString("APaterno"));
                    per.setMaterno(rs.getString("AMaterno"));
                    per.setTelefono(rs.getString("telefono"));
                    per.setCorreo(rs.getString("correo"));
                    per.setTipo(rs.getInt("tipo"));
                    per.setEstatus(rs.getString("estatus"));
                }
            }
        } catch (Exception e) {
            System.out.println("ERROR AL OBTENER PERSONAL POR USUARIO:");
            e.printStackTrace();
        }
        return per;
    }

    public boolean actualizarPersonal() {
        return actualizarPersonal(null, null, null);
    }

    public boolean actualizarPersonal(String especialidad, String cedula, String turno) {
        String sql = "UPDATE Personal SET nombre = ?, APaterno = ?, AMaterno = ?, "
                + "telefono = ?, correo = ?, tipo = ? WHERE usuario = ?";

        try (Connection cn = c.conecta();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, nombre);
            ps.setString(2, paterno);
            ps.setString(3, materno);
            ps.setString(4, telefono);
            ps.setString(5, correo);
            ps.setInt(6, tipo);
            ps.setString(7, usuario);

            boolean actualizoBase = ps.executeUpdate() > 0;
            if (!actualizoBase) {
                return false;
            }

            if (tipo == 2) {
                Dentistas den = new Dentistas();
                den.setUsuario(usuario);
                den.setEspecialidad(especialidad);
                den.setCedula(cedula);
                den.setTurno(turno);
                den.setTelefono(telefono);
                den.setCorreo(correo);
                return den.actualizarDentista();
            } else if (tipo == 3) {
                Secretarias sec = new Secretarias();
                sec.setUsuario(usuario);
                sec.setTurno(turno);
                sec.setTelefono(telefono);
                sec.setCorreo(correo);
                return sec.actualizarSecretaria();
            }

            return true;
        } catch (Exception e) {
            System.out.println("ERROR AL ACTUALIZAR PERSONAL:");
            e.printStackTrace();
            return false;
        }
    }
}
