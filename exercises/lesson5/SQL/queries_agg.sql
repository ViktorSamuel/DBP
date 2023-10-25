/* ---------------------------------------------------------------------- */
/* Write and test the following queries --------------------------------- */
/* ---------------------------------------------------------------------- */
/*
dept(deptno, name, location)
emp(empno, name, job, superior, hiredate, salary, deptno)
*/

/* 1. Find the number of employees who work in Dallas. */

SELECT COUNT(DISTINCT e.empno)
FROM emp e, dept d
WHERE e.deptno = d.deptno and d.location = 'Dallas';

/* 2. Find the average salary of employees who work in Dallas. */
SELECT avg(salary) FROM emp JOIN dept ON emp.deptno = dept.deptno WHERE location = 'Dallas';

/* 3. For each department, including departments with no employees, find the sum of salaries of all employees who work in that department. */
SELECT d.name, sum(salary) FROM emp e FULL JOIN dept d ON e.deptno = d.deptno GROUP BY d.deptno;

/* 4. Find departments (deptno) with more than 3 employees. */
SELECT deptno FROM emp GROUP BY deptno HAVING count(*) > 3;

/* 5. For each department, find the number of analysts who work in that department. */
SELECT d.name, count(e.empno) FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.job = 'analyst' GROUP BY d.deptno;

/* 6. Find the jobs with the maximal standard deviation of salaries. */
-- WITH SalaryStdDevs AS (
--     SELECT job, STDDEV(salary) AS salary_stddev
--     FROM emp
--     GROUP BY job
-- )
-- SELECT job, salary_stddev
-- FROM SalaryStdDevs
-- WHERE salary_stddev = (SELECT MAX(salary_stddev) FROM SalaryStdDevs);


/* 7. Find tuples [D, J, Sum, Average] which, for each pair [D, J], state the sum of salaries and average salary of employees who work in department D and do job J. */

/* 8. Find tuples [Y, N], where N is number of employees hired in the year Y (the resuslt contains only years when an employee was hired) */

/* 9. For each year since 1990, find number of employees hired in that year (the resuslt must contain also years when no employee was hired). Hint: use PostgreSQL function generate_series(). */

/* 10. For each employee, find the number of subordinates (both direct and indirect) of that employee. Include employees with no subordinates. */
