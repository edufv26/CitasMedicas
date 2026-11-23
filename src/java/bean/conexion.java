package bean;

import java.io.IOException;
import java.sql.*;

public class conexion {
    String USER = "sa";
    //String PASS = "sasa";
    String PASS = "Edu260604";
    String respuesta;
    
    public Connection conecta(){
        Connection cn = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            
            String URL = "jdbc:sqlserver://localhost:1433;databaseName=Consultorio;encrypt=true;trustServerCertificate=true;";
            
            cn = DriverManager.getConnection(URL, USER, PASS);
            System.out.println("¡Conexión exitosa a la base de datos!");
            
        } catch(Exception e) {
            respuesta = "Error en la conexion " + e;
            System.out.println(respuesta);
        }
        
        return cn;
    }
    
    public void desconectar() {
            Connection cn = null;
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
    
