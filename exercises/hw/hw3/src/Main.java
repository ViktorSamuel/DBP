import java.sql.*;
import java.util.*;

public class Main {

    private static final String DB = "jdbc:postgresql://localhost:15432/podhradsky13";
    private static final String USERNAM = "podhradsky13";
    private static final String PASSWORD = "123HESLO";

    public static void main(String[] args) {
        Connection connection = null;
        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection(DB, USERNAM, PASSWORD);
            connection.setAutoCommit(false);

            String studentLogin = prihlasenieStudenta(connection);
            int testId = vyberTestu(connection, studentLogin);
            zobrazOtazky(connection, testId, studentLogin);
            vyhodnotTest(connection, testId, studentLogin);

            connection.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException se2) {
                    se2.printStackTrace();
                }
            }
        } finally {
            try {
                if (connection != null) connection.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }

    private static String prihlasenieStudenta(Connection connection) throws SQLException {
        Scanner scanner = new Scanner(System.in);
        String studentLogin = null;
        boolean validLogin = false;

        while (!validLogin) {
            System.out.println("Zadajte prihlasovacie meno:");
            studentLogin = scanner.nextLine().toLowerCase();

            String query = "SELECT prihlasovacie_meno FROM student WHERE LOWER(prihlasovacie_meno) = ?";
            try (PreparedStatement pstmt = connection.prepareStatement(query)) {
                pstmt.setString(1, studentLogin);
                ResultSet rs = pstmt.executeQuery();

                if (rs.next()) {
                    validLogin = true;
                } else {
                    System.out.println("Zlé prihlasovacie meno");
                }
            }
        }

        return studentLogin;
    }

    private static int vyberTestu(Connection connection, String studentLogin) throws SQLException {
        Scanner scanner = new Scanner(System.in);
        Map<Integer, Integer> indexToTestIdMap = new HashMap<>();
        int chosenTestId = 0;
        boolean validTest = false;
        int index = 1;
        while (!validTest) {
            System.out.println("Zoznam pridelených testov:");

            String query = "SELECT test.testid, test.nazov, ucitel.meno, pridelenie.cas_pridelenia " +
                    "FROM test " +
                    "JOIN pridelenie ON test.testid = pridelenie.testid " +
                    "JOIN ucitel ON pridelenie.ucitelid = ucitel.ucitelid " +
                    "JOIN student ON pridelenie.studentid = student.studentid " +
                    "WHERE LOWER(student.prihlasovacie_meno) = ? " +
                    "ORDER BY pridelenie.cas_pridelenia DESC";

            try (PreparedStatement pstmt = connection.prepareStatement(query)) {
                pstmt.setString(1, studentLogin);
                ResultSet rs = pstmt.executeQuery();

                while (rs.next()) {
                    int testId = rs.getInt("testid");
                    String testName = rs.getString("nazov");
                    String teacherName = rs.getString("meno");
                    Timestamp assignmentTime = rs.getTimestamp("cas_pridelenia");

                    System.out.println(index + ". " + testName + " (Učiteľ: " + teacherName + ", Čas pridelenia: " + assignmentTime + ")");
                    indexToTestIdMap.put(index, testId);
                    index++;
                }
            }

            System.out.println("Číslo testu na vyplnenie:");
            int chosenIndex = scanner.nextInt();

            if (indexToTestIdMap.containsKey(chosenIndex)) {
                validTest = true;
                chosenTestId = indexToTestIdMap.get(chosenIndex);
            } else {
                System.out.println("neplatné číslo testu");
            }
        }

        String insertResultQuery = "INSERT INTO vysledok (pridelenieid, skore, cas_vypracovania) " +
                                   "SELECT pridelenie.pridelenieid, 0, NOW() " +
                                   "FROM pridelenie " +
                                   "JOIN student ON pridelenie.studentid = student.studentid " +
                                   "WHERE pridelenie.testid = ? AND LOWER(student.prihlasovacie_meno) = ?";

        try (PreparedStatement insertResultStmt = connection.prepareStatement(insertResultQuery)) {
            insertResultStmt.setInt(1, chosenTestId);
            insertResultStmt.setString(2, studentLogin);
            insertResultStmt.executeUpdate();
        }

        return chosenTestId;
    }
    private static void vyhodnotTest(Connection connection, int testId, String studentLogin) throws SQLException {
        int totalQuestions = 0;
        int correctAnswers = 0;

        String query = "SELECT otazka.otazkaid, otazka.spravne, odpoved.text_odpovede " +
                "FROM otazka " +
                "JOIN odpoved ON otazka.otazkaid = odpoved.otazkaid " +
                "JOIN vysledok ON odpoved.vysledokid = vysledok.vysledokid " +
                "JOIN pridelenie ON vysledok.pridelenieid = pridelenie.pridelenieid " +
                "JOIN student ON pridelenie.studentid = student.studentid " +
                "WHERE otazka.testid = ? AND LOWER(student.prihlasovacie_meno) = ?";

        try (PreparedStatement pstmt = connection.prepareStatement(query)) {
            pstmt.setInt(1, testId);
            pstmt.setString(2, studentLogin);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                totalQuestions++;
                String correctAnswer = rs.getString("spravne");
                String studentAnswer = rs.getString("text_odpovede");

                if (correctAnswer.equalsIgnoreCase(studentAnswer)) {
                    correctAnswers++;
                }
            }
        }

        double successRate = (double) correctAnswers / totalQuestions * 100;
        System.out.println("Percento správnych: " + successRate + "%");

        ulozVysledok(connection, testId, studentLogin, correctAnswers, totalQuestions);
    }

    private static void zobrazOtazky(Connection connection, int testId, String studentLogin) throws SQLException {
        Scanner scanner = new Scanner(System.in);
        List<Integer> questionIds = new ArrayList<>();
        List<String> studentAnswers = new ArrayList<>();

        String query = "SELECT otazka.otazkaid, otazka.text, otazka.spravne, otazka.nespravne1, otazka.nespravne2, otazka.nespravne3 " +
                "FROM otazka " +
                "WHERE otazka.testid = ?";

        try (PreparedStatement pstmt = connection.prepareStatement(query)) {
            pstmt.setInt(1, testId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                int questionId = rs.getInt("otazkaid");
                String questionText = rs.getString("text");
                String correctAnswer = rs.getString("spravne");
                String incorrectAnswer1 = rs.getString("nespravne1");
                String incorrectAnswer2 = rs.getString("nespravne2");
                String incorrectAnswer3 = rs.getString("nespravne3");

                List<String> answers = Arrays.asList(correctAnswer, incorrectAnswer1, incorrectAnswer2, incorrectAnswer3);
                Collections.shuffle(answers);

                System.out.println("Otázka: " + questionText);
                for (int i = 0; i < answers.size(); i++) {
                    System.out.println((char) ('A' + i) + ") " + answers.get(i));
                }

                System.out.println("Vyber odpoveď:");
                char studentAnswerIndex = scanner.nextLine().toLowerCase().charAt(0);
                String studentAnswer = answers.get(studentAnswerIndex - 'a');

                questionIds.add(questionId);
                studentAnswers.add(studentAnswer);
            }
        }

        int vysledokId = getVysledokId(connection, testId, studentLogin);
        if (vysledokId != -1) {
            ulozOdpovede(connection, vysledokId, questionIds, studentAnswers);
        } else {
            System.out.println("Nespravny student/test");
        }
    }

    private static int getVysledokId(Connection connection, int testId, String studentLogin) throws SQLException {
        String query = "SELECT vysledok.vysledokid FROM vysledok " +
                "JOIN pridelenie ON vysledok.pridelenieid = pridelenie.pridelenieid " +
                "JOIN student ON pridelenie.studentid = student.studentid " +
                "WHERE pridelenie.testid = ? AND LOWER(student.prihlasovacie_meno) = ?";
        try (PreparedStatement pstmt = connection.prepareStatement(query)) {
            pstmt.setInt(1, testId);
            pstmt.setString(2, studentLogin);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("vysledokid");
            }
        }
        return -1;
    }

    private static void ulozOdpovede(Connection connection, int vysledokId, List<Integer> questionIds, List<String> studentAnswers) throws SQLException {
        String insertAnswerQuery = "INSERT INTO odpoved (vysledokid, otazkaid, text_odpovede) VALUES (?, ?, ?)";
        for (int i = 0; i < questionIds.size(); i++) {
            try (PreparedStatement insertAnswerStmt = connection.prepareStatement(insertAnswerQuery)) {
                insertAnswerStmt.setInt(1, vysledokId);
                insertAnswerStmt.setInt(2, questionIds.get(i));
                insertAnswerStmt.setString(3, studentAnswers.get(i));
                insertAnswerStmt.executeUpdate();
            }
        }
    }

    private static void ulozVysledok(Connection connection, int testId, String studentLogin, int correctAnswers, int totalQuestions) throws SQLException {
        int vysledokId = getVysledokId(connection, testId, studentLogin);
        if (vysledokId != -1) {
            double successRate = (double) correctAnswers / totalQuestions * 100;
            String query = "UPDATE vysledok SET skore = ? WHERE vysledokid = ?";
            try (PreparedStatement pstmt = connection.prepareStatement(query)) {
                pstmt.setDouble(1, successRate);
                pstmt.setInt(2, vysledokId);
                pstmt.executeUpdate();
            }
        } else {
            System.out.println("Nemožno uložiť výsledok");
        }
    }
}
