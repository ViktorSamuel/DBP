import org.postgresql.copy.CopyManager;
import org.postgresql.core.BaseConnection;
import java.io.FileReader;
import java.io.IOException;
import java.sql.*;

public class Main {
    private static final String DB_URL = "jdbc:postgresql://localhost:15432/podhradsky13";
    private static final String USR = "podhradsky13";
    private static final String PSW = "123HESLO";

    public static void main(String[] args) {
        Connection c1 = null;
        Connection c2 = null;
        try {
            Class.forName("org.postgresql.Driver");
            c1 = DriverManager.getConnection(DB_URL, USR, PSW);
            c2 = DriverManager.getConnection(DB_URL, USR, PSW);

            c1.setAutoCommit(false);
            c2.setAutoCommit(false);

            comparePerformance(c1);

            updateCityPopulationAndCheckCountry(c1, "Bratislava", 1000000);

            covidPandemic(c1, "Slovakia");
            migrationCrisis(c2, "Ukraine", "Slovakia");

            c1.commit();
            c2.commit();

        } catch (Exception e) {
            handleException(e, c1, c2);
        } finally {
            closeConnection(c1);
            closeConnection(c2);
        }
    }

    private static void copyData(Connection connection) throws SQLException, IOException {
        CopyManager copyManager = new CopyManager((BaseConnection) connection);
        FileReader fileReader = new FileReader("worldcities.csv");
        copyManager.copyIn("COPY world_cities(city, city_ascii, lat, lng, country, iso2, iso3, admin_name, capital, population, id) FROM STDIN (format CSV, HEADER,  FORCE_NULL (population))", fileReader);
    }

    private static void bulkInsertData(Connection connection) throws SQLException {
        String sql = "INSERT INTO world_cities(city, city_ascii, lat, lng, country, iso2, iso3, admin_name, capital, population, id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            for (int i = 0; i < 100; i++) {
                pstmt.setString(1, "City" + i);
                pstmt.setString(2, "CityAscii" + i);
                pstmt.setDouble(3, i);
                pstmt.setDouble(4, i);
                pstmt.setString(5, "Country" + i);
                pstmt.setString(6, "ISO2" + i);
                pstmt.setString(7, "ISO3" + i);
                pstmt.setString(8, "AdminName" + i);
                pstmt.setString(9, "Capital" + i);
                pstmt.setInt(10, i); // population
                pstmt.setInt(11, i); // id
                pstmt.addBatch();
            }
            pstmt.executeBatch();
        }
    }

    private static void comparePerformance(Connection connection) throws SQLException, IOException {
        long startCopyData = System.currentTimeMillis();
        copyData(connection);
        long endCopyData = System.currentTimeMillis();
        long durationCopyData = endCopyData - startCopyData;

        long startBulkInsertData = System.currentTimeMillis();
        bulkInsertData(connection);
        long endBulkInsertData = System.currentTimeMillis();
        long durationBulkInsertData = endBulkInsertData - startBulkInsertData;

        System.out.println("Time taken by copyData: " + durationCopyData + " ms");
        System.out.println("Time taken by bulkInsertData: " + durationBulkInsertData + " ms");
    }

    private static void updateCityPopulationAndCheckCountry(Connection connection, String cityName, int newPopulation) throws SQLException {
        String updateCitySql = "UPDATE world_cities SET population = ? WHERE city = ?";
        try (PreparedStatement pstmt = connection.prepareStatement(updateCitySql)) {
            pstmt.setInt(1, newPopulation);
            pstmt.setString(2, cityName);
            pstmt.executeUpdate();
        }

        try (Statement stmt = connection.createStatement()) {
            ResultSet rs = stmt.executeQuery("SELECT 1 FROM pg_tables WHERE tablename = 'world_countries'");
            if (!rs.next()) {
                stmt.execute("CREATE TABLE world_countries (name VARCHAR(255), population INT)");
            }
        }

        String getCountryPopulationSql = "SELECT population FROM world_countries WHERE country = (SELECT country FROM world_cities WHERE city = ?)";
        try (PreparedStatement pstmt = connection.prepareStatement(getCountryPopulationSql)) {
            pstmt.setString(1, cityName);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                int countryPopulation = rs.getInt("population");
                System.out.println("Updated population for country: " + countryPopulation);
            }
        }
    }

    private static void handleException(Exception e, Connection connection1, Connection connection2) {
        e.printStackTrace();
        try {
            if (connection1 != null) connection1.rollback();
            if (connection2 != null) connection2.rollback();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    private static void closeConnection(Connection connection) {
        try {
            if (connection != null) connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void covidPandemic(Connection c, String country) throws SQLException {
        String selectQuery = "SELECT country, population FROM world_countries WHERE country = ?";

        try (PreparedStatement selectStmt = c.prepareStatement(selectQuery)) {
            selectStmt.setString(1, country);

            ResultSet rsBefore = selectStmt.executeQuery();

            if (rsBefore.next()) {
                int populationBefore = rsBefore.getInt("population");
                System.out.println("Before COVID Pandemic: " + country + " Population: " + populationBefore);

                String updateQuery = "UPDATE world_countries SET population = population * 0.999 WHERE country = ?";
                try (PreparedStatement updateStmt = c.prepareStatement(updateQuery)) {
                    updateStmt.setString(1, country);
                    updateStmt.executeUpdate();
                }
                ResultSet rsAfter = selectStmt.executeQuery();

                if (rsAfter.next()) {
                    int populationAfter = rsAfter.getInt("population");
                    System.out.println("After COVID Pandemic: " + country + " Population: " + populationAfter);

                    logPopulationChange(c, country, 2023, populationBefore, populationAfter);
                } else {
                    System.out.println("No data after COVID Pandemic update for " + country);
                }
            } else {
                System.out.println("No data before COVID Pandemic update for " + country);
            }
        }
    }


    private static void migrationCrisis(Connection c, String srcCountry, String dstCountry) throws SQLException {
        String selectSrcQuery = "SELECT country, population FROM world_countries WHERE country = ?";
        String selectDstQuery = "SELECT country, population FROM world_countries WHERE country = ?";

        try (PreparedStatement selectSrcStmt = c.prepareStatement(selectSrcQuery);
             PreparedStatement selectDstStmt = c.prepareStatement(selectDstQuery)) {

            selectSrcStmt.setString(1, srcCountry);
            selectDstStmt.setString(1, dstCountry);

            ResultSet rsSrcBefore = selectSrcStmt.executeQuery();
            ResultSet rsDstBefore = selectDstStmt.executeQuery();

            if (rsSrcBefore.next() && rsDstBefore.next()) {
                int srcPopulationBefore = rsSrcBefore.getInt("population");
                System.out.println("Before Migration Crisis: " + srcCountry + " Population: " + srcPopulationBefore);

                int dstPopulationBefore = rsDstBefore.getInt("population");
                System.out.println("Before Migration Crisis: " + dstCountry + " Population: " + dstPopulationBefore);

                String updateSrcQuery = "UPDATE world_countries SET population = population * 0.99 WHERE country = ?";
                String updateDstQuery = "UPDATE world_countries SET population = population * 1.01 WHERE country = ?";

                try (PreparedStatement updateSrcStmt = c.prepareStatement(updateSrcQuery);
                     PreparedStatement updateDstStmt = c.prepareStatement(updateDstQuery)) {

                    updateSrcStmt.setString(1, srcCountry);
                    updateDstStmt.setString(1, dstCountry);

                    updateSrcStmt.executeUpdate();
                    updateDstStmt.executeUpdate();
                }

                ResultSet rsSrcAfter = selectSrcStmt.executeQuery();
                ResultSet rsDstAfter = selectDstStmt.executeQuery();

                if (rsSrcAfter.next() && rsDstAfter.next()) {
                    int srcPopulationAfter = rsSrcAfter.getInt("population");
                    System.out.println("After Migration Crisis: " + srcCountry + " Population: " + srcPopulationAfter);

                    int dstPopulationAfter = rsDstAfter.getInt("population");
                    System.out.println("After Migration Crisis: " + dstCountry + " Population: " + dstPopulationAfter);

                    logPopulationChange(c, srcCountry, 2023, srcPopulationBefore, srcPopulationAfter);
                    logPopulationChange(c, dstCountry, 2023, dstPopulationBefore, dstPopulationAfter);
                } else {
                    System.out.println("No data after Migration Crisis update for " + srcCountry + " or " + dstCountry);
                }
            } else {
                System.out.println("No data before Migration Crisis update for " + srcCountry + " or " + dstCountry);
            }
        }
    }

    private static void logPopulationChange(Connection c, String country, int year, int populationIn, int populationOut) throws SQLException {
        try (PreparedStatement pstmt = c.prepareStatement("INSERT INTO population_changes(country, year, population_in, population_out) VALUES (?, ?, ?, ?)")) {
            pstmt.setString(1, country);
            pstmt.setInt(2, year);
            pstmt.setInt(3, populationIn);
            pstmt.setInt(4, populationOut);
            pstmt.executeUpdate();
        }
    }
}

