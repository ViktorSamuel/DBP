-- Write a recursive query that calculates the value of n! (factorial) for n = 10.
WITH RECURSIVE nFactorial AS (
    SELECT 1 AS n, 1 AS factorial
    UNION
    SELECT n + 1, factorial * (n + 1)
    FROM nFactorial
    WHERE n < 10
)
SELECT factorial FROM nFactorial WHERE n = 4;

-- Write a recursive query that calculates the value of the 30th Fibonacci number.
WITH RECURSIVE fibonacci AS (
    SELECT 1 AS n, 1 AS a, 1 AS b
    UNION 
    SELECT n + 1, b, a + b
    FROM fibonacci
    WHERE n < 30
)
SELECT a FROM fibonacci;


-- Consider db world.sql
-- city(id, name, countrycode, disctrict, population)
-- country(code, name, continent, region, surfacearea, indepyear, population, lifeexpectancy, gnp, gnpold, localname, governmentform, headofstate, capital, code2)
-- countrylanguage(countrycode, language, isofficial, percentage)

/* 1. Find all countries that use English. For each of them, print its name, name of the capital, and the fraction of inhabitants of the country that live in the capital. */
SELECT c.code, city.name, city.population / c.population AS fraction 
FROM
    (SELECT country.code, country.population, country.capital FROM country 
    JOIN countrylanguage ON country.code = countrylanguage.countrycode 
    WHERE countrylanguage.language = 'English') AS c
JOIN city ON c.capital = city.id;

/* 2. List 10 countries with the largest number of cities, total number of inhabitants of those cities and the fraction of the population living in rural areas. */
SELECT country.code, SUM(city.population) AS urbanPopulation, 
(country.population - SUM(city.population)) / country.population AS fractionOfRuralPopulation
FROM country JOIN city ON country.code = city.countrycode 
GROUP BY country.code 
ORDER BY COUNT(city.id) DESC LIMIT 10;

/* 3. For the 10 countries with the largest number inhabitants, list all their districts, number of cities in the districts, and total number of urban inhabitants in the disctrict. Sort the districts of each individual country according to the number of inhabitants. */
SELECT city.district, COUNT(city.id) AS numCitiesInDistrict, SUM(city.population) AS urbanPopulationInDistrict
FROM city WHERE city.countrycode IN (SELECT code FROM country ORDER BY population DESC LIMIT 10)
GROUP BY city.district

/* 4. Find all monarchies that use at least three languages. (Beware: monarchies are described in various ways, e.g. 'Monarch (Sultanate)' or 'Constitutional monarchy', so use the "like" operator.)  */
SELECT country.code FROM country 
WHERE country.governmentform LIKE '%Monarchy%' 
OR country.governmentform LIKE '%Sultanate%'
OR country.governmentform LIKE '%Emirate%'
OR country.governmentform LIKE '%Kingdom%'
OR country.governmentform LIKE '%Constitutional%'
AND country.code IN (
    SELECT countrylanguage.countrycode FROM countrylanguage GROUP BY countrylanguage.countrycode HAVING COUNT(countrylanguage.language) >= 3
);

/* 5. Find all the countries with the highest population density. Do the same for the countries with the second highest density. (There might be several tying for either place.) */
WITH populationDensity AS (
    SELECT country.code, country.population / country.surfacearea AS density
    FROM country
)

SELECT * FROM populationDensity WHERE density = (SELECT MAX(density) FROM populationDensity);

WITH secondHighestDensity AS (
    SELECT country.code, density
    FROM (
        SELECT country.code, country.population / country.surfacearea AS density FROM country
    )
    WHERE density != SELECT MAX(density) FROM (
        SELECT country.code, country.population / country.surfacearea AS density FROM country
    )
)

-- WITH secondHighestDensity AS (
--     SELECT country.code, density
--     FROM populationDensity
--     WHERE country.code NOT IN (
--         SELECT code FROM populationDensity WHERE density = (SELECT MAX(density) FROM populationDensity)
--     )
-- )

SELECT * FROM secondHighestDensity WHERE density = (SELECT MAX(density) FROM secondHighestDensity);

/* 6. For each letter of the alphabet, find the Earth surface area covered by countries whose name begins with that letter. (Only include letters with non-zero area.) */
SELECT LEFT(country.name, 1) AS firstLetter, SUM(country.surfacearea)
FROM country
GROUP BY firstLetter, country.name
HAVING SUM(country.surfacearea) > 0
ORDER BY firstLetter;


-- Consider the employee database we used in previous exercises. 
-- emp(empno, name, job, superior, hiredate, salary, deptno)
-- dept(deptno, name, location)

-- Find for each manager the list of his subordinates and for each subordinate state whether he is direct or indirect.
WITH RECURSIVE subordinates AS (
    SELECT emp.empno AS managerno, emp.name AS manager, emp1.empno AS subordinateno, emp1.name AS subordinate, 1 AS level
    FROM emp JOIN emp AS emp1 ON emp.empno = emp1.superior
    WHERE emp.job = 'manager'
    UNION
    SELECT managerno, manager, emp2.empno AS subordinateno, emp2.name AS subordinate, level + 1
    FROM subordinates JOIN emp AS emp2 ON emp2.superior = subordinates.subordinateno
)
SELECT * FROM subordinates;


-- Consider db roads.sql
-- cities(id, name)
-- road(id1, id2, d)

-- from where can you get to Rome
WITH RECURSIVE roadsToRome AS (
    SELECT id2 AS id FROM road WHERE id1 = 1
    UNION
    SELECT road.id2 AS id FROM roadsToRome JOIN road ON road.id1 = roadsToRome.id
)
SELECT name FROM cities WHERE id IN (SELECT * FROM roadsToRome);

-- from where can you get to Rome in less than 1000 km
WITH RECURSIVE roadsToRomeLessThan1K AS (
    SELECT id2 AS id, d AS distance FROM road WHERE id1 = 1
    UNION
    SELECT road.id2 AS id, roadsToRomeLessThan1K.distance + road.d AS distance FROM roadsToRomeLessThan1K JOIN road ON road.id1 = roadsToRomeLessThan1K.id WHERE roadsToRomeLessThan1K.distance + road.d < 1000
)
SELECT name FROM cities WHERE id IN (SELECT id FROM roadsToRomeLessThan1K);

-- Truck driver can drive max 720km per day. Create table of triples [city, number_of_days, number_of_cities], where number_of_cities is number of cities that can be reached from city in number_of_days days.
WITH RECURSIVE cityNumOfDaysNumOfCities AS (
    SELECT id1 AS start, id2 AS destination, 1 AS day, d AS distance FROM road WHERE d < 720
    UNION
    SELECT start, id2 AS destination, day + 1, distance + d
    FROM cityNumOfDaysNumOfCities JOIN road ON road.id1 = cityNumOfDaysNumOfCities.start
    WHERE distance < 720
)
SELECT start, destination, day FROM cityNumOfDaysNumOfCities;
