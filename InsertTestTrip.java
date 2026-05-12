import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class InsertTestTrip {
    public static void main(String[] args) throws Exception {
        String url  = "jdbc:mysql://trolley.proxy.rlwy.net:31694/railway?useSSL=false&allowPublicKeyRetrieval=true";
        String user = "root";
        String pass = "ZbuqEpkmhwZkPQNLqPazHWPSLNBAIlOX";

        try (Connection c = DriverManager.getConnection(url, user, pass)) {
            System.out.println("Connected.");

            // Find a driver
            Long driverId = null; String driverName = null;
            try (ResultSet rs = c.createStatement().executeQuery(
                    "SELECT u.user_id, u.name FROM users u WHERE u.role='DRIVER' AND u.status='ACTIVE' LIMIT 1")) {
                if (rs.next()) { driverId = rs.getLong(1); driverName = rs.getString(2); }
            }
            if (driverId == null) { System.out.println("No active DRIVER found."); return; }

            // Find a bus
            Long busId = null; String busReg = null;
            try (ResultSet rs = c.createStatement().executeQuery(
                    "SELECT bus_id, registration_number FROM buses LIMIT 1")) {
                if (rs.next()) { busId = rs.getLong(1); busReg = rs.getString(2); }
            }
            if (busId == null) { System.out.println("No bus found."); return; }

            // Find a route
            Long routeId = null; String routeName = null;
            try (ResultSet rs = c.createStatement().executeQuery(
                    "SELECT route_id, route_name FROM routes LIMIT 1")) {
                if (rs.next()) { routeId = rs.getLong(1); routeName = rs.getString(2); }
            }
            if (routeId == null) { System.out.println("No route found."); return; }

            // Start time = now + 10 min, end = now + 70 min
            LocalDateTime start = LocalDateTime.now().plusMinutes(10);
            LocalDateTime end   = LocalDateTime.now().plusMinutes(70);
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

            PreparedStatement ps = c.prepareStatement(
                "INSERT INTO trips (driver_id, bus_id, route_id, start_time, end_time, status) VALUES (?,?,?,?,?,'SCHEDULED')");
            ps.setLong(1, driverId);
            ps.setLong(2, busId);
            ps.setLong(3, routeId);
            ps.setString(4, start.format(fmt));
            ps.setString(5, end.format(fmt));
            ps.executeUpdate();

            System.out.println("Trip inserted!");
            System.out.println("  Driver : " + driverName + " (id=" + driverId + ")");
            System.out.println("  Bus    : " + busReg + " (id=" + busId + ")");
            System.out.println("  Route  : " + routeName + " (id=" + routeId + ")");
            System.out.println("  Start  : " + start.format(fmt));
            System.out.println("  End    : " + end.format(fmt));
        }
    }
}
