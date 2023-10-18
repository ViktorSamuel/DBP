/* ------------------------------------------------------------------------ */
/* Write and test the following queries ----------------------------------- */
/* ------------------------------------------------------------------------ */

/* 1. Print all jobs. */
SELECT DISTINCT job
FROM emp;

/* 2. Print names and hiring dates of all clerks. */
SELECT name, hiredate
FROM emp
WHERE job = 'clerk';

/* 3. List names and jobs of all employees. */
  
/* 4. List names and jobs of employees with salary at least 2000. */

/* 5. Print names of employees who were hired between 1981 and 1982. */

/* 6. Print names and salaries of all managers and analysts. */

/* 7. Print the name of the department in which the president works. */

/* 8. Print jobs of employees who work in Chicago. */

/* 9. For each employee, print a list of all coworkers, that is, list all tuples [Employee name, Locations, Coworker]. */

/* 10. Print names of employees together with names of their managers. */

/* 11. Find the lowest salary in New York. */

/* 12. Print names, department names and salaries of all employees whose salary is greater than the lowest salary in department 20. */

/* 13. Which departments contain all job positions? */

/* 14. Which departments are empty (have no employees)? */

/* 15. Which employees manage only clerks? */

/* 16. Which departments employ no salesmen? */

/* 17. Find names of all employees who are subordinates of Blake (both direct and indirect). */

/* 18. Determine if there are two employees having the same wage. */

