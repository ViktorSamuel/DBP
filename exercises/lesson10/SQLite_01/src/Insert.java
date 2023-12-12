import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.concurrent.ThreadLocalRandom;

public class Insert {
    public static void main(String args[]) {
        int q = 0;
        Connection c = null;

        ArrayList<String> ucitelia = new ArrayList<>();
        for(int i = 1; i <= 100; i++){
            ucitelia.add("Ucitel" + i);
        }

        ArrayList<String> studenti = new ArrayList<>();
        for(int i = 1; i <= 600; i++){
            studenti.add("Student" + i);
        }

        ArrayList<String> predmety = new ArrayList<>();
        for(int i = 1; i <= 20; i++){
            predmety.add("Predmet" + i);
        }

        ArrayList<String> triedy = new ArrayList<>();
        for(int i = 0; i < 18; i++){
            if(i % 2 == 0){
                triedy.add(((i%9)+1)+"A");
            } else {
                triedy.add(((i%9)+1)+"B");
            }
        }

        try {
            Class.forName("org.postgresql.Driver");
            c = DriverManager
                    .getConnection("jdbc:postgresql://localhost:15432/podhradsky13",
                            "podhradsky13", "123HESLO");

            c.setAutoCommit(false);

            try (PreparedStatement uciteliaStmt = c.prepareStatement("INSERT INTO ucitelia (meno, priezvisko, pohlavie, prihlasovacie_meno) VALUES (?, ?, ?, ?)");
                 PreparedStatement studentiStmt = c.prepareStatement("INSERT INTO studenti (meno, priezvisko, pohlavie, trieda, datum_narodenia, prihlasovacie_meno) VALUES (?, ?, ?, ?, ?, ?)");
                 PreparedStatement predmetyStmt = c.prepareStatement("INSERT INTO predmety (nazov, skratka) VALUES (?, ?)");
                 PreparedStatement triedyStmt = c.prepareStatement("INSERT INTO triedy (trieda, predmet_id) VALUES (?, ?)");
                 PreparedStatement znamkyStmt = c.prepareStatement("INSERT INTO znamky (znamka, student_id, ucitel_id, predmet_id, cas_zadania, typ_zadania, vaha) VALUES (?, ?, ?, ?, ?, ?, ?)")) {

                String sql = "DELETE FROM znamky; DELETE FROM predmety; DELETE FROM studenti; DELETE FROM ucitelia; DELETE FROM triedy;";
                try (PreparedStatement deleteStmt = c.prepareStatement(sql)) {
                    deleteStmt.executeUpdate();
                } catch (SQLException e) {
                    System.out.println(e.getMessage());
                }

                int i = 0;
                for (String ucitel : ucitelia) {
                    uciteliaStmt.setString(1, ucitel);
                    uciteliaStmt.setString(2, ucitel);
                    uciteliaStmt.setString(3, String.valueOf((i % 2 == 0) ? 'M' : 'F'));
                    uciteliaStmt.setString(4, ucitel);
                    uciteliaStmt.addBatch();
                    i++;
                }
                uciteliaStmt.executeBatch();

                i = 0;
                LocalDate startDate = LocalDate.of(2000, 1, 1);
                for (String student : studenti){
                    studentiStmt.setString(1, student);
                    studentiStmt.setString(2, student);
                    studentiStmt.setString(3, String.valueOf((i%2 == 0) ? 'M' : 'F'));
                    studentiStmt.setString(4, triedy.get(i%18));
                    studentiStmt.setDate(5, java.sql.Date.valueOf(startDate.plusDays(i)));
                    studentiStmt.setString(6, student);
                    studentiStmt.addBatch();
                    i++;
                }
                studentiStmt.executeBatch();

                i = 0;
                for(String predmet : predmety){
                    predmetyStmt.setString(1, predmet);
                    predmetyStmt.setString(2, predmet.substring(0, 1)+(i+1));
                    predmetyStmt.addBatch();
                    i++;
                }
                predmetyStmt.executeBatch();

                for (String trieda : triedy) {
                    for(String predmet: predmety){
                        triedyStmt.setString(1, trieda);
                        triedyStmt.setInt(2, predmety.indexOf(predmet) + 1);
                        triedyStmt.addBatch();
                    }
                }
                triedyStmt.executeBatch();

                String[] zadania = {"test", "du", "projekt"};
                for (i = 1; i <= 600; i++) {
                    for (String predmet : predmety) {
                        for (int j = 0; j < (10 + (i % 6)); j++) {
                            znamkyStmt.setInt(1, (int) (Math.random() * 5 + 1));
                            znamkyStmt.setInt(2, i);
                            int ucitel = (int) (Math.random() * 100 + 1);
                            znamkyStmt.setInt(3, ucitel);
                            znamkyStmt.setInt(4, predmety.indexOf(predmet) + 1);

                            long startMillis = Timestamp.valueOf("2010-01-01 00:00:00").getTime();
                            long endMillis = Timestamp.valueOf("2022-12-31 23:59:59").getTime();
                            long randomMillis = ThreadLocalRandom.current().nextLong(startMillis, endMillis + 1);
                            znamkyStmt.setTimestamp(5, new Timestamp(randomMillis));

                            znamkyStmt.setString(6, zadania[i%3]);
                            znamkyStmt.setDouble(7, i%5);

                            znamkyStmt.addBatch();
                        }
                    }
                }
                znamkyStmt.executeBatch();

                c.commit();
            } catch (SQLException e) {
                c.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getClass().getName() + ": " + e.getMessage());
            System.exit(0);
        } finally {
            try {
                if (c != null) c.close();
            } catch (Exception e) {
                e.printStackTrace();
                System.err.println(e.getClass().getName() + ": " + e.getMessage());
                System.exit(0);
            }
        }
        System.out.println("Operation done successfully");
    }
}
