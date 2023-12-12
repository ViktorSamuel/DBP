import java.sql.*;
import java.util.Scanner;

public class StudentInfo {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:15432/podhradsky13";
        String user = "podhradsky13";
        String password = "123HESLO";

        Scanner scanner = new Scanner(System.in);

        System.out.println("Enter student's first name:");
        String firstName = scanner.nextLine();

        System.out.println("Enter student's last name:");
        String lastName = scanner.nextLine();

        System.out.println("Enter student's class:");
        String studentClass = scanner.nextLine();

        scanner.close();

        String sql = "SELECT p.nazov, z.znamka " +
                "FROM znamky z " +
                "JOIN studenti s ON z.student_id = s.id " +
                "JOIN predmety p ON z.predmet_id = p.id " +
                "WHERE LOWER(s.meno) = LOWER(?) AND LOWER(s.priezvisko) = LOWER(?) AND s.trieda = ? " +
                "ORDER BY s.id, p.id";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Set parameters
            pstmt.setString(1, firstName);
            pstmt.setString(2, lastName);
            pstmt.setString(3, studentClass);

            ResultSet rs = pstmt.executeQuery();

            // Check if the student exists
            if (!rs.isBeforeFirst()) {
                System.out.println("No student found with the provided details.");
                return;
            }

            System.out.println("Grades for " + firstName + " " + lastName + " (" + studentClass + "):");
            while (rs.next()) {
                String subject = rs.getString("nazov");
                String grade = rs.getString("znamka");
                System.out.println(subject + ": " + grade);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
