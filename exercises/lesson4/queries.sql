
/* ------------------------------------------------------------------------ */

/* 1. Print all jobs. */
SELECT DISTINCT job
FROM emp;

/* 2. Print names and hiring dates of all clerks. */
SELECT name, hiredate
FROM emp
WHERE job = 'clerk';

/* 3. List names and jobs of all employees. */
SELECT name, job FROM emp;  

/* 4. List names and jobs of employees with salary at least 2000. */
SELECT name, job FROM emp WHERE salary >= 2000;

/* 5. Print names of employees who were hired between 1995 and 1996. */
SELECT name FROM emp WHERE hiredate BETWEEN '1995-01-01' AND '1996-12-31';

/* 6. Print names and salaries of all managers and analysts. */
SELECT name, salary FROM emp WHERE job IN ('manager', 'analyst');

/* 7. Print the name of the department in which the president works. */
SELECT dept.name FROM dept JOIN emp ON dept.deptno = emp.deptno AND emp.job = 'president';

/* 8. Print jobs of employees who work in Chicago. */
SELECT DISTINCT job FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE d.location = 'Chicago'; 

/* 9. For each employee, print a list of all coworkers, that is, list all tuples [Employee name, Locations, Coworker]. */
SELECT e1.name, d.location, e2.name FROM emp e1 JOIN emp e2 ON e1.deptno = e2.deptno JOIN dept d ON e1.deptno = d.deptno WHERE e1.empno != e2.empno;

/* 10. Print names of employees together with names of their managers. */
SELECT e1.name, e2.name FROM emp e1 JOIN emp e2 ON e1.deptno = e2.deptno WHERE e1.job != 'manager' AND e2.job = 'manager';

/* 11. Find the lowest salary in New York. */
SELECT min(salary) FROM emp JOIN dept ON emp.deptno = dept.deptno WHERE location = 'New York';

/* 12. Print names, department names and salaries of all employees whose salary is greater than the lowest salary in department 20. */
SELECT e.name, d.location, e.salary FROM emp e JOIN dept d ON e.deptno = d.deptno WHERE e.salary > (SELECT min(salary) FROM emp WHERE deptno = 20);

/* 13. Which departments contain all job positions? */
SELECT name FROM dept WHERE deptno IN (SELECT deptno FROM emp WHERE deptno NOT IN (SELECT DISTINCT e1.deptno, e2.job FROM emp e1, emp e2 WHERE (e2.job, e1.deptno) NOT IN (SELECT job, deptno FROM emp)));

/* 14. Which departments are empty (have no employees)? */
SELECT deptno FROM dept WHERE deptno NOT IN (SELECT deptno FROM emp);

/* 15. Which employees manage only clerks? */
SELECT name FROM emp WHERE job = 'manager' AND deptno NOT IN (SELECT deptno FROM emp WHERE empno NOT IN (SELECT empno FROM emp WHERE job IN ('clerk', 'manager', 'president'));

/* 16. Which departments employ no salesmen? */
SELECT name FROM dept WHERE deptno NOT IN (SELECT deptno FROM emp WHERE job = 'salesman');

/* 17. Find names of all employees who are subordinates of Blake (both direct and indirect). */

/* 18. Determine if there are two employees having the same wage. */
SELECT e1.name, e2.name FROM emp e1 JOIN emp e2 ON e1.salary = e2.salary WHERE e1.empno != e2.empno;

