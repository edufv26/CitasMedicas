/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package bean;

import java.io.IOException;
import java.sql.*;

/**
 *
 * @author edu
 */
public class conexion {
    String USER = "sa";
    String PASS = "Edu260604";
    String respuesta;
    
    Connection cn = null;
    
    public Connection conecta(String base){
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            
            String URL = "jdbc:sqlserver://localhost:1433;databaseName=" + base + ";encrypt=true;trustServerCertificate=true;";
            
            cn = DriverManager.getConnection(URL, USER, PASS);
            System.out.println("¡Conexión exitosa a la base de datos: " + base + "!");
            
        } catch(Exception e) {
            respuesta = "Error en la conexion " + e;
            System.out.println(respuesta);
        }
        
        return cn;
    }
    
    public void desconectar() {
        try {
            if (cn != null && !cn.isClosed()) {
                cn.close();
                respuesta = "Conexión cerrada.";
            }
        } catch (Exception e) {
            respuesta = "Error al cerrar la conexión: " + e;
        }
    }
}
    
