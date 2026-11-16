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
public class Pacientes {

    private String nombre, aPaterno, aMaterno, telefono, correo, direccion, respuesta, nombreDentista;
    private int idP, idDenP;

    public int getIdP() {
        return idP;
    }

    public void setIdP(int idP) {
        this.idP = idP;
    }

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

    public String getNombreDentista() {
        return nombreDentista;
    }

    public void setNombreDentista(String nombreDentista) {
        this.nombreDentista = nombreDentista;
    }

    public void alta() {

    }

    public void baja() {

    }
    
// Al actualizar (método cambio)
    public void cambio() {
        String sql = "UPDATE Pacientes SET nombre = ?, APaterno = ?, AMaterno = ?, telefono = ?, correo = ?, direccion = ?, id_dentista_preferencia = ? WHERE id_paciente = ?";
        
        try (Connection cn = Conexion.conecta();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            
            ps.setString(1, nombre);
            ps.setString(2, aPaterno);
            ps.setString(3, aMaterno);
            ps.setString(4, telefono);
            ps.setString(5, correo);
            ps.setString(6, direccion);
            
            // Si es 0 (No asignado), mandamos SQL NULL a la base de datos para evitar error de FK
            if (idDenP > 0) {
                ps.setInt(7, idDenP);
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            
            ps.setInt(8, idP);
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Al llenar la tabla
    public List<Pacientes> llenarTabla() {
        List<Pacientes> lista = new ArrayList<>();

        String sql = "SELECT p.id_paciente, p.nombre, p.APaterno, p.AMaterno, p.telefono, p.correo, p.direccion, p.id_dentista_preferencia, " +
                     "per.nombre AS nombre_doc " +
                     "FROM Pacientes p " +
                     "LEFT JOIN Dentistas d ON p.id_dentista_preferencia = d.id_dentista " +
                     "LEFT JOIN Personal per ON d.usuario = per.usuario " +
                     "WHERE p.estatus = 'A' ORDER BY p.id_paciente";

        try (Connection cn = Conexion.conecta();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Pacientes pac = new Pacientes();
                pac.setIdP(rs.getInt("id_paciente"));
                pac.setNombre(rs.getString("nombre"));
                pac.setaPaterno(rs.getString("APaterno"));
                pac.setaMaterno(rs.getString("AMaterno"));
                pac.setTelefono(rs.getString("telefono"));
                pac.setCorreo(rs.getString("correo"));
                pac.setDireccion(rs.getString("direccion"));
                
                int denPref = rs.getInt("id_dentista_preferencia");
                pac.setIdDenP(rs.wasNull() ? 0 : denPref);
                
                // Guardamos el nombre del doctor o "No asignado" si viene null
                String docNombre = rs.getString("nombre_doc");
                pac.setNombreDentista(docNombre != null ? docNombre : "No asignado");

                lista.add(pac);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    // Al buscar por ID para la edición
    public Pacientes obtenerPorId(int idBusqueda) {
        Pacientes p = null;
        String sql = "SELECT id_paciente, nombre, APaterno, AMaterno, telefono, correo, direccion, id_dentista_preferencia FROM Pacientes WHERE id_paciente = ?";
        
        try (Connection cn = Conexion.conecta();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            
            ps.setInt(1, idBusqueda);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Pacientes();
                    p.setIdP(rs.getInt("id_paciente"));
                    p.setNombre(rs.getString("nombre"));
                    p.setaPaterno(rs.getString("APaterno"));
                    p.setaMaterno(rs.getString("AMaterno"));
                    p.setTelefono(rs.getString("telefono"));
                    p.setCorreo(rs.getString("correo"));
                    p.setDireccion(rs.getString("direccion"));
                    
                    int denPref = rs.getInt("id_dentista_preferencia");
                    p.setIdDenP(rs.wasNull() ? 0 : denPref);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return p;
    }

//este lo guardamos para cambiar contraseña de parte del admin :)
/*
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
*/

}
