/* ------------------------------------------------------------------------ */
/* Do not edit this part ---------------------------------------------------*/
/* ------------------------------------------------------------------------ */
:- consult('emp.pl').
:- consult('subtotal.pl').
:- consult('query.pl').

%Database emp:
%emp(Empno, Ename, Job, Mgr, Hiredate, Sal, Comm, Deptno)
%dept(Deptno, Dname, Loc)
%salgrade(Grade, Losal, Hisal)

/* ------------------------------------------------------------------------ */
/* Write and test the following queries ----------------------------------- */
/* ------------------------------------------------------------------------ */

/* 1. Find the number of employees who work in Dallas. */

emp_dallas(E) :-
  emp(E, _, _, _, _, _, _, D),
  dept(D, _, dallas).

nr_emp_dallas(N) :-
  subtotal(emp_dallas(E), [], [N = count(E)]).


/* 2. Find the average salary of employees who work in Dallas. */

/* 3. For each department, including departments with no employees, find the sum of salaries of all employees who work in that department. */

/* 4. Find departments (deptno) with more than 3 employees. */

/* 5. For each department, find the number of analysts who work in that department. */

/* 6. Find the jobs with the maximal standard deviation of salaries. */

/* 7. Find tuples [D, J, Sum, Average] which, for each pair [D, J], state the sum of salaries and average salary of employees who work in department D and do job J. */

/* 8. Find tuples [Y, N], where N is number of employees hired in the year Y (the resuslt contains only years when an employee was hired) */

/* 9. For each year since 1990, find number of employees hired in that year (the resuslt must contain also years when no employee was hired). Hint: use PostgreSQL function generate_series(). */

/* 10. For each employee, find the number of subordinates (both direct and indirect) of that employee. Include employees with no subordinates. */
