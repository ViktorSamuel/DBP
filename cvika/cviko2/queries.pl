/* ------------------------------------------------------------------------ */
/* Do not edit this part ---------------------------------------------------*/
/* ------------------------------------------------------------------------ */
:- consult('emp.pl').
:- consult('query.pl').

% emp(Employee Number, Name, Job, Superior, Employed from, Salary, Department Number)
% dept(Department Number, Name, Location)

/* ------------------------------------------------------------------------ */
/* Write and test the following queries ----------------------------------- */
/* ------------------------------------------------------------------------ */

/* 1. List names and jobs of all employees. */
allNamesAndJobs(N, J) :- emp(_, N, J, _, _, _, _).

/* 2. List names and jobs of employees with salary at least 2000. */
salaryOver2000(N, J) :- emp(_, N, J, _, _, S, _), S >= 2000.

/* 3. Print names of employees who were hired between 1995 and 1998. */
hired95_98(N) :- emp(_, N, _, _, Y, _, _), Y >= 1995, Y =< 1998.

/* 4. Print names and salaries of all managers and analysts. */
managers_and_analysts(N, S) :- emp(_, N, manager, _, _, S, _).
managers_and_analysts(N, S) :- emp(_, N, analyst, _, _, S, _).

/* 5. Print the name of the department in which the president works. */
presidentDeptName(D) :- emp(_, _, president, _, _, _, N), dept(N, D, _).

/* 6. Print jobs of employees who work in Chicago. */
chicagoJobs(J) :- emp(_, _, J, _, _, _, N), dept(N, _, chicago).

/* 7. For each employee, print a list of all coworkers, that is, list all tuples [Employee name, Locations, Coworker]. */
coworkers(N, L, C) :- emp(_, N, _, _, _, _, D), dept(D, _, L), emp(_, C, _, _, _, _, D). 

/* 8. Print names of employees together with names of their managers. */
managers(E, M) :- emp(_, E, _, _, _, _, D), emp(_, M, manager, _, _, _, D).

/* 9. Find the lowest salary in New York. */
notLowest(S, D) :- emp(_, _, _, _, _, S2, D), S2 < S.
lowestSalary(S) :- dept(D, _, newyork), emp(_, _, _, _, _, S, D), \+ notLowest(S, D).

/* 10. Print names, department names and salaries of all employees whose salary is greater than the lowest salary in department 20. */
notLowest20(S) :- emp(_, _, _, _, _, S2, 20), S2 < S.
lowestSalary20(S) :- dept(20, _, _), emp(_, _, _, _, _, S, 20), \+ notLowest20(S).
notAsLow(N, D, S) :- emp(_, N, _, _, _, S, DN), dept(DN, _, D), \+ lowestSalary20(S).

/* Check whether all the rules you have used so far are safe. */

/* 11. Which departments contain all job positions? */
jobDept(J, D) :- emp(_, _, J, _, _, _, D).
missingJob(D) :- emp(_, _, J, _, _, _, _), emp(_, _, _, _, _, _, D), \+ jobDept(J, D).
allJobsD(N) :- dept(D, N, _), \+ missingJob(D). 

/* 12. Which departments are empty (have no employees)? */
nonEmptyD(D) :- emp(_, _, _, _, _, _, D).
emptyD(N) :- dept(D, N, _), \+ nonEmptyD(D).

/* 13. Which employees manage only clerks? */
isNot(C) :- emp(C, _, clerk, _, _, _, _).
isNot(C) :- emp(C, _, manager, _, _, _, _).
isNot(C) :- emp(C, _, president, _, _, _, _).
clerk(D) :- emp(C, _, _, _, _, _, D), \+isNot(C).
manager(M) :- emp(_, M, manager, _, _, _, D), \+ clerk(D).

/* 14. Which departments employ no salesmen? */
salesman(D) :- emp(_, _, salesman, _, _, _, D).
noSales(D) :- dept(N, D, _), \+ salesman(N).

/* 15. Find names of all employees who are subordinates of Blake (both direct and indirect). */
subordinateOfBlake(N) :- emp(_, blake, _, S, _, _, _), subordinateNames(S, N).
subordinateNames(S, N) :- emp(_, N, _, S, _, _, _).
subordinateNames(S, N) :- emp(_, N1, _, S, _, _, _), subordinateNames(N1, N).

/* 16. Determine if there are two employees having the same wage. */
sameSalary(E, E1) :- emp(E1, _, _, _, _, S, _), emp(E, _, _, _, _, S, _), E1 =\= E.
checkSameSalary(R) :- (emp(E1, _, _, _, _, _, _), emp(E, _, _, _, _, _, _), sameSalary(E, E1)) -> R = true ; R = false.

/* Check whether all the rules you have used are safe. */

