/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean;

import java.sql.*;

/**
 *
 * @author hp
 */
public class Usuarios {
    private String nombre,paterno,materno, usuario, password,respuesta,estatus;
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
    
    public void validar(){
        try {
           Connection cn = c.conecta("Sistemas5551");
            if (c!=null) {
                PreparedStatement ps=cn.prepareStatement("SELECT tipo FROM Usuarios WHERE usuario=? AND password=?");
                ps.setString(1, usuario);
                ps.setString(2, password);
                ResultSet rs=ps.executeQuery();
                if (rs.next()) {
                    int tipo=rs.getInt(1);
                    switch (tipo) {
                        case 1: respuesta="Menu1.html"; break;
                        case 2: respuesta="Menu2.html"; break;
                        case 3: respuesta="Menu3.html"; break;
                    }
                }else{
                    respuesta="Error.jsp?respuesta=No existe el usuario ";
                }
            }else{
                respuesta="Error.jsp?respuesta=No hay conexion a la base ";
            }
        } catch (Exception e) {
            respuesta="Error.jsp?respuesta=error al validar usuario "+e;
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
 
    public void agregarUsuario() {
        try {
            Connection cn = c.conecta("Sistemas5551");
            if (cn != null) {
                CallableStatement cs = cn.prepareCall("{Call dbo.AgregaUsuario(?,?,?,?,?,?)}");
                cs.setString(1, nombre);
                cs.setString(2, paterno);
                cs.setString(3, materno);
                usuario = generaUsuario();
                System.out.println(usuario);
                cs.setString(4, usuario);
                cs.setString(5, EncriptarMD5.encripta(usuario));
                cs.registerOutParameter(6, Types.VARCHAR);
                cs.execute();
                String r = cs.getString(6);
                respuesta = "Error.jsp?respuesta=" + r;
            } else {
                respuesta = "Error.jsp?respuesta=No hay conexion a la base ";
            }
        } catch (Exception e) {
            respuesta = "Error.jsp?respuesta=error al agregar usuario " + e+" "+usuario;
        }
    }
    
    public void tabla() {
    try {
        Connection cn = c.conecta("Sistemas5551");
        if (cn != null) {
            Statement st = cn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            ResultSet rs = st.executeQuery("SELECT * FROM Usuarios");

            if (rs.isBeforeFirst()) {
                respuesta = "<h2><table border='1'>";
                int columnas = rs.getMetaData().getColumnCount();

                respuesta += "<tr>";
                for (int i = 1; i <= columnas; i++) {
                    respuesta += "<th>" + rs.getMetaData().getColumnName(i) + "</th>";
                }
                respuesta += "</tr>";

                while (rs.next()) {
                    respuesta += "<tr>";
                    for (int j = 1; j <= columnas; j++) {
                        respuesta += "<td>" + rs.getString(j) + "</td>";
                    }
                    respuesta += "</tr>";
                }
                respuesta += "</table></h2>";
            } else {
                respuesta = "<h1>No hay datos</h1>";
            }
        }
    } catch (Exception e) {
        respuesta = "Error al llenar tabla: " + e;
    }
}
    
}
