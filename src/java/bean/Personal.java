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
                            respuesta = "Admin/Menu1.jsp";
                            break;
                        case 2:
                            respuesta = "Secretaria/Menu2.jsp";
                            break;
                        case 3:
                            respuesta = "Dentista/Menu3.jsp";
                            break;
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

        try (Connection cn = c.conecta(); PreparedStatement ps = cn.prepareStatement(sql)) {
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

    public String getTablaAdminsHtml() {
        return generarFilasAdminsHtml(llenarListaAdmins());
    }

    public String generarFilasAdminsHtml(List<Personal> lista) {
        StringBuilder sb = new StringBuilder();

        if (lista != null && !lista.isEmpty()) {
            for (Personal a : lista) {
                String usr = a.getUsuario() != null ? a.getUsuario() : "";
                String nom = a.getNombre() != null ? a.getNombre() : "";
                String pat = a.getPaterno() != null ? a.getPaterno() : "";
                String mat = a.getMaterno() != null ? a.getMaterno() : "";
                String tel = (a.getTelefono() != null && !a.getTelefono().isEmpty()) ? a.getTelefono() : "-";
                String cor = (a.getCorreo() != null && !a.getCorreo().isEmpty()) ? a.getCorreo() : "-";

                sb.append("<tr>")
                        .append("<td><b>").append(usr).append("</b></td>")
                        .append("<td>").append(nom).append(" ").append(pat).append(" ").append(mat).append("</td>")
                        .append("<td>").append(tel).append("</td>")
                        .append("<td>").append(cor).append("</td>")
                        .append("<td class=\"text-center\">")
                        .append("<a href=\"Control?accion=editarPersonal&usuario=").append(usr).append("&tipo=1\" class=\"btn-icon-tabla editar\" title=\"Editar\"><span class=\"fa fa-pencil\"></span></a>")
                        .append("<button type=\"button\" class=\"btn-icon-tabla\" title=\"Cambiar contraseña\" onclick=\"abrirModalPassword('").append(usr).append("')\"><span class=\"fa fa-key\"></span></button>")
                        .append("<a href=\"#\" onclick=\"abrirModalEliminar('").append(usr).append("')\" class=\"btn-icon-tabla eliminar\" title=\"Eliminar\"><span class=\"fa fa-trash\"></span></a>")
                        .append("</td>")
                        .append("</tr>");
            }
        } else {
            sb.append("<tr><td colspan=\"5\" class=\"text-center\" style=\"padding: 16px; color: #666;\">No hay administradores registrados.</td></tr>");
        }

        return sb.toString();
    }
    
    // Dar de alta al personal con transaccion en sp_RegistrarPersonal
    // tipo: 1 = Administrador, 2 = Secretaria, 3 = Dentista
    public void agregarUsuario(String especialidad, String cedula, String turno) {
        try {
            String nomLimpio = (nombre != null) ? nombre.trim() : "";
            String patLimpio = (paterno != null) ? paterno.trim() : "";
            String matLimpio = (materno != null) ? materno.trim() : "";
            String telLimpio = (telefono != null) ? telefono.trim() : "";
            String corLimpio = (correo != null) ? correo.trim() : "";
            String espLimpio = (especialidad != null) ? especialidad.trim() : "";
            String cedLimpio = (cedula != null) ? cedula.trim() : "";
            String turLimpio = (turno != null) ? turno.trim() : "";

            if (nomLimpio.isEmpty() || patLimpio.isEmpty()
                    || (tipo != 1 && tipo != 2 && tipo != 3)) {
                respuesta = "Error.jsp?respuesta=Faltan campos obligatorios para registrar al personal.";
                return;
            }

            if (tipo == 3 && (espLimpio.isEmpty() || cedLimpio.isEmpty() || turLimpio.isEmpty())) {
                respuesta = "Error.jsp?respuesta=Faltan especialidad, cedula o turno para el dentista.";
                return;
            }

            if (tipo == 2 && turLimpio.isEmpty()) {
                respuesta = "Error.jsp?respuesta=Falta el turno para la secretaria.";
                return;
            }

            nombre = nomLimpio;
            paterno = patLimpio;
            materno = matLimpio;
            usuario = generaUsuario();

            String passEncriptada = EncriptarMD5.encripta(usuario);

            Connection cn = c.conecta();
            if (cn != null) {
                String sql = "{Call dbo.sp_RegistrarPersonal(?,?,?,?,?,?,?,?,?,?,?,?)}";
                try (CallableStatement cs = cn.prepareCall(sql)) {
                    cs.setString(1, usuario);
                    cs.setString(2, passEncriptada);
                    cs.setString(3, nomLimpio);
                    cs.setString(4, patLimpio);
                    cs.setString(5, matLimpio.isEmpty() ? null : matLimpio);
                    cs.setString(6, telLimpio.isEmpty() ? null : telLimpio);
                    cs.setString(7, corLimpio.isEmpty() ? null : corLimpio);
                    cs.setInt(8, tipo);
                    cs.setString(9, tipo == 3 ? espLimpio : null);
                    cs.setString(10, tipo == 3 ? cedLimpio : null);
                    cs.setString(11, (tipo == 2 || tipo == 3) ? turLimpio : null);
                    cs.registerOutParameter(12, Types.VARCHAR);

                    cs.execute();
                    String msg = cs.getString(12);
                    if (msg != null && (msg.startsWith("Personal registrado") || msg.startsWith("Usuario registrado"))) {
                        respuesta = "Personal registrado correctamente. Usuario: " + usuario + " | Contraseña: " + passEncriptada;
                    } else {
                        respuesta = "Error.jsp?respuesta=" + (msg != null ? msg : "No se pudo registrar el personal.");
                    }
                }
                cn.close();
            } else {
                respuesta = "Error.jsp?respuesta=No hay conexion a la base";
            }
        } catch (Exception e) {
            respuesta = "Error.jsp?respuesta=Error al agregar personal: " + e.getMessage();
        }
    }

    public String generaUsuario() {
        String user = nombre.substring(0, 3) + paterno.substring(0, 3) + materno.substring(0, 3);
        int aleatorio = (int) (Math.random() * 999) + 1;
        if (aleatorio < 10) {
            user = user + "00" + aleatorio;
        } else if (aleatorio < 100) {
            user = user + "0" + aleatorio;
        } else {
            user = user + aleatorio;
        }
        return user;
    }
    
    // Procedure baja de personal (cambiar estatus a 'D')
    public void baja(String usuario) {
        String sql = "{CALL dbo.sp_BajaUsuario(?, ?)}";
        this.setRespuesta("No se pudo dar de baja al personal");
        Connection cn = null;
        CallableStatement cs = null;

        try {
            cn = c.conecta();
            cs = cn.prepareCall(sql);
            cs.setString(1, usuario);
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

    // Actualizar datos del personal con transacción en sp_ActualizarPersonal
    // tipo: 1 = Administrador, 2 = Secretaria, 3 = Dentista
    public boolean actualizarPersonal(String especialidad, String cedula, String turno) {
        try {
            String usrLimpio = (usuario != null) ? usuario.trim() : "";
            String nomLimpio = (nombre != null) ? nombre.trim() : "";
            String patLimpio = (paterno != null) ? paterno.trim() : "";
            String matLimpio = (materno != null) ? materno.trim() : "";
            String telLimpio = (telefono != null) ? telefono.trim() : "";
            String corLimpio = (correo != null) ? correo.trim() : "";
            String espLimpio = (especialidad != null) ? especialidad.trim() : "";
            String cedLimpio = (cedula != null) ? cedula.trim() : "";
            String turLimpio = (turno != null) ? turno.trim() : "";

            if (usrLimpio.isEmpty() || nomLimpio.isEmpty() || patLimpio.isEmpty()
                    || (tipo != 1 && tipo != 2 && tipo != 3)) {
                respuesta = "Error.jsp?respuesta=Faltan campos obligatorios para actualizar al personal.";
                return false;
            }

            if (tipo == 3 && (espLimpio.isEmpty() || cedLimpio.isEmpty() || turLimpio.isEmpty())) {
                respuesta = "Error.jsp?respuesta=Faltan especialidad, cedula o turno para el dentista.";
                return false;
            }

            if (tipo == 2 && turLimpio.isEmpty()) {
                respuesta = "Error.jsp?respuesta=Falta el turno para la secretaria.";
                return false;
            }

            Connection cn = c.conecta();
            if (cn != null) {
                String sql = "{Call dbo.sp_ActualizarPersonal(?,?,?,?,?,?,?,?,?,?,?)}";
                try (CallableStatement cs = cn.prepareCall(sql)) {
                    cs.setString(1, usrLimpio);
                    cs.setString(2, nomLimpio);
                    cs.setString(3, patLimpio);
                    cs.setString(4, matLimpio.isEmpty() ? null : matLimpio);
                    cs.setString(5, telLimpio.isEmpty() ? null : telLimpio);
                    cs.setString(6, corLimpio.isEmpty() ? null : corLimpio);
                    cs.setInt(7, tipo);
                    cs.setString(8, tipo == 3 ? espLimpio : null);
                    cs.setString(9, tipo == 3 ? cedLimpio : null);
                    cs.setString(10, (tipo == 2 || tipo == 3) ? turLimpio : null);
                    cs.registerOutParameter(11, Types.VARCHAR);

                    cs.execute();
                    String msg = cs.getString(11);
                    if (msg != null && msg.startsWith("Personal actualizado")) {
                        respuesta = msg;
                        return true;
                    } else {
                        respuesta = "Error.jsp?respuesta=" + (msg != null ? msg : "No se pudo actualizar el personal.");
                        return false;
                    }
                } finally {
                    cn.close();
                }
            } else {
                respuesta = "Error.jsp?respuesta=No hay conexion a la base";
                return false;
            }
        } catch (Exception e) {
            System.out.println("ERROR AL ACTUALIZAR PERSONAL:");
            e.printStackTrace();
            respuesta = "Error.jsp?respuesta=Error al actualizar personal: " + e.getMessage();
            return false;
        }
    }
    
    public String regenerarPassword(String usuarioTarget) {
        String usrLimpio = (usuarioTarget != null) ? usuarioTarget.trim() : "";
        if (usrLimpio.isEmpty()) {
            return "";
        }

        Personal per = obtenerPorUsuario(usrLimpio);
        if (per != null) {
            nombre = per.getNombre() != null ? per.getNombre().trim() : "";
            paterno = per.getPaterno() != null ? per.getPaterno().trim() : "";
            materno = per.getMaterno() != null ? per.getMaterno().trim() : "";
        } else {
            nombre = usrLimpio;
            paterno = usrLimpio;
            materno = usrLimpio;
        }

        String candidata = generaUsuario();
        return EncriptarMD5.encripta(candidata);
    }
    
    public void cambiarPasswordUsuario(String usuarioTarget, String passEncriptada) {
        try {
            String usrLimpio = (usuarioTarget != null) ? usuarioTarget.trim() : "";
            String passLimpio = (passEncriptada != null) ? passEncriptada.trim() : "";

            if (usrLimpio.isEmpty() || passLimpio.isEmpty()) {
                respuesta = "Error.jsp?respuesta=Falta el usuario o la contraseña.";
                return;
            }

            Connection cn = c.conecta();
            if (cn != null) {
                String sql = "{Call dbo.sp_CambiarPasswordUsuario(?,?,?)}";
                try (CallableStatement cs = cn.prepareCall(sql)) {
                    cs.setString(1, usrLimpio);
                    cs.setString(2, passLimpio);
                    cs.registerOutParameter(3, Types.VARCHAR);

                    cs.execute();
                    String msg = cs.getString(3);
                    if (msg != null && (msg.startsWith("Contraseña actualizada") || msg.startsWith("Password actualizado"))) {
                        respuesta = "Contraseña restablecida correctamente. Usuario: " + usrLimpio + " | Contraseña: " + passLimpio;
                    } else {
                        respuesta = "Error.jsp?respuesta=" + (msg != null ? msg : "No se pudo cambiar la contraseña.");
                    }
                }
                cn.close();
            } else {
                respuesta = "Error.jsp?respuesta=No hay conexion a la base";
            }
        } catch (Exception e) {
            respuesta = "Error.jsp?respuesta=Error al cambiar contraseña: " + e.getMessage();
        }
    }
}
