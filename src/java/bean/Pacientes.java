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

    public String getMensajeAttr() {
        if (respuesta == null) {
            return "";
        }
        return respuesta
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    public boolean isEsEdicion() {
        return this.idP > 0;
    }

    //procedure dar de alta a pacientes
    public String alta(Pacientes p) {
        String sql = "{CALL sp_RegistrarPaciente(?, ?, ?, ?, ?, ?, ?, ?)}";
        String respuesta = "No se pudo completar el registro";
        Connection cn = null;
        CallableStatement cs = null;

        try {
            cn = Conexion.conecta();
            cs = cn.prepareCall(sql);
            cs.setString(1, p.getNombre());
            cs.setString(2, p.getaPaterno());
            cs.setString(3, p.getaMaterno());
            cs.setString(4, p.getTelefono());
            cs.setString(5, p.getCorreo());
            cs.setString(6, p.getDireccion());

            if (p.getIdDenP() > 0) {
                cs.setInt(7, p.getIdDenP());
            } else {
                cs.setNull(7, java.sql.Types.INTEGER);
            }

            // Registramos el parámetro OUTPUT en la posición 8
            cs.registerOutParameter(8, java.sql.Types.VARCHAR);

            cs.execute();

            String salida = cs.getString(8);
            if (salida != null && !salida.trim().isEmpty()) {
                respuesta = salida;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            respuesta = "Error de conexión/BD: " + e.getMessage();
        } finally {
            try {
                if (cs != null) {
                    cs.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }

        return respuesta;
    }

    //procedure baja a pacientes (cambiar a 'D')
    public void baja(int idPaciente) {
        String sql = "{CALL sp_BajaPaciente(?, ?)}";
        this.setRespuesta("No se pudo dar de baja al paciente");
        Connection cn = null;
        CallableStatement cs = null;

        try {
            cn = Conexion.conecta();
            cs = cn.prepareCall(sql);
            cs.setInt(1, idPaciente);
            cs.registerOutParameter(2, java.sql.Types.VARCHAR);

            cs.execute();

            String salida = cs.getString(2);
            if (salida != null && !salida.trim().isEmpty()) {
                this.setRespuesta(salida);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            this.setRespuesta("Error al dar de baja: " + e.getMessage());
        } finally {
            try {
                if (cs != null) {
                    cs.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

// Al actualizar (método cambio)
    public void cambio() {
        String sql = "{call dbo.sp_ActualizarPaciente(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        Connection cn = null;
        CallableStatement cs = null;

        try {
            cn = Conexion.conecta();
            cs = cn.prepareCall(sql);

            cs.setInt(1, idP);
            cs.setString(2, nombre);
            cs.setString(3, aPaterno);
            cs.setString(4, aMaterno);
            cs.setString(5, telefono);
            cs.setString(6, correo);
            cs.setString(7, direccion);

            if (idDenP > 0) {
                cs.setInt(8, idDenP);
            } else {
                cs.setNull(8, java.sql.Types.INTEGER);
            }

            cs.registerOutParameter(9, java.sql.Types.VARCHAR);
            cs.execute();

            this.respuesta = cs.getString(9);
        } catch (Exception e) {
            e.printStackTrace();
            this.respuesta = "Error al actualizar paciente: " + e.getMessage();
        } finally {
            try {
                if (cs != null) {
                    cs.close();
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    //Llenar la tabla (para los jsp)
    public List<Pacientes> llenarTabla() {
        List<Pacientes> lista = new ArrayList<>();

        String sql = "SELECT p.id_paciente, p.nombre, p.APaterno, p.AMaterno, p.telefono, p.correo, p.direccion, p.id_dentista_preferencia, "
                + "LTRIM(RTRIM(CONCAT(ISNULL(per.nombre, ''), ' ', ISNULL(per.APaterno, ''), ' ', ISNULL(per.AMaterno, '')))) AS nombre_doc "
                + "FROM Pacientes p "
                + "LEFT JOIN Dentistas d ON p.id_dentista_preferencia = d.id_dentista "
                + "LEFT JOIN Personal per ON d.usuario = per.usuario "
                + "WHERE p.estatus = 'A' ORDER BY p.id_paciente";

        try {
            Connection cn = Conexion.conecta();
            PreparedStatement ps = cn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
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

        try (Connection cn = Conexion.conecta(); PreparedStatement ps = cn.prepareStatement(sql)) {

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

    public void mostrarTabla() {
        StringBuilder html = new StringBuilder();
        List<Pacientes> lista = llenarTabla();

        if (lista != null && !lista.isEmpty()) {
            for (Pacientes p : lista) {
                String nom = p.getNombre() != null ? p.getNombre() : "";
                String pat = p.getaPaterno() != null ? p.getaPaterno() : "";
                String mat = p.getaMaterno() != null ? p.getaMaterno() : "";
                String tel = p.getTelefono() != null ? p.getTelefono() : "";
                String cor = p.getCorreo() != null ? p.getCorreo() : "";
                String dir = p.getDireccion() != null ? p.getDireccion() : "";

                html.append("<tr>");
                html.append("<td>").append(p.getIdP()).append("</td>");
                html.append("<td>").append(nom).append(" ").append(pat).append(" ").append(mat).append("</td>");
                html.append("<td>").append(tel).append("</td>");
                html.append("<td>").append(cor).append("</td>");
                html.append("<td>").append(dir).append("</td>");

                html.append("<td>");
                if (p.getIdDenP() > 0 && p.getNombreDentista() != null && !p.getNombreDentista().equals("No asignado")) {
                    html.append("<b>Dr(a). ").append(p.getNombreDentista()).append("</b>");
                } else {
                    html.append("<i>No asignado</i>");
                }
                html.append("</td>");

                html.append("<td class=\"text-center\">");
                html.append("<a href=\"Control?accion=editar&id=").append(p.getIdP())
                        .append("\" class=\"btn-icon-tabla editar\" title=\"Editar\"><span class=\"fa fa-pencil\"></span></a>");
                html.append("<a href=\"#\" onclick=\"abrirModalEliminar('").append(p.getIdP())
                        .append("')\" class=\"btn-icon-tabla eliminar\" title=\"Eliminar\"><span class=\"fa fa-trash\"></span></a>");
                html.append("</td>");
                html.append("</tr>");
            }
        } else {
            html.append("<tr><td colspan=\"7\" class=\"text-center\" style=\"padding: 20px; color: #666;\">")
                    .append("No hay pacientes registrados en el sistema.</td></tr>");
        }

        this.respuesta = html.toString();
    }

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
