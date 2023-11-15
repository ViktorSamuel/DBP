-- dept(deptno, name, location)
-- emp(empno, name, job, superior, hiredate, salary, deptno)

-- For each employee, find their rank according to their salary (column salary). Employees with the same salary should have the same rank.
SELECT emp.name, emp.salary, 
       RANK() OVER(ORDER BY SALARY DESC)
FROM emp;

-- For each employee, print the difference between their salary and the average salary in their department.
WITH name_salary_avgDeptSalary AS (
    SELECT name, salary, 
           AVG(salary) OVER(PARTITION BY deptno) AS dept_avg
    FROM emp
)

SELECT name, salary - dept_avg AS difference FROM name_salary_avgDeptSalary;

-- For each employee, print their rank according to their salary among employees from the same city, the difference from the average salary in the given city, and the number of employees in this city
WITH name_salary_city_cityAvg_cityCout AS (
    SELECT name, salary, deptno, 
           AVG(salary) OVER(PARTITION BY deptno) AS city_avg,
           COUNT(*) OVER(PARTITION BY deptno) AS city_count,
           RANK() OVER(PARTITION BY deptno ORDER BY salary DESC) AS city_rank
    FROM emp
)

SELECT name, city_rank, (salary - city_avg) AS difference, city_count FROM name_salary_city_cityAvg_cityCout;

-- Company needs to save 8000 USD on salaries per month. Display the longest possible list of employees with the lowest salary, whose sum of salaries is less than 8000 (i.e. starting with the employee with the lowest salary, up to the employee whose salary together with the previous employees is closest to the 8000 limit).
WITH emp_salary_sum AS (
    SELECT name, salary, 
           SUM(salary) OVER(ORDER BY salary ASC ROWS UNBOUNDED PRECEDING) AS sum
    FROM emp
)

SELECT * FROM emp_salary_sum WHERE sum < 8000;

-- Similarly to the previous exercise, but we want to end just above 8000 euros (i.e. the list ends as soon as the sum of salaries exceeds 8000).
WITH emp_salary_sum AS (
    SELECT name, salary, 
           SUM(salary) OVER(ORDER BY salary ASC ROWS UNBOUNDED PRECEDING) AS sum
    FROM emp
)

SELECT * FROM emp_salary_sum WHERE sum - salary <= 8000;

-- Find median salary for each department. (Hint: before the introduction of PERCENTILE_CONT in PostgreSQL 9.4 in 2014, calculating the median was highly non-trivial.)
SELECT deptno, PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY salary) AS median_salary FROM emp GROUP BY deptno;