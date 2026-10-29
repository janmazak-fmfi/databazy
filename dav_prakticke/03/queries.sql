/* ------------------------------------------------------------------------ */
/* Write and test the following queries ----------------------------------- */
/* ------------------------------------------------------------------------ */

/*
    You can use aggregate functions, e.g. MIN, SUM, COUNT, together with GROUP BY and HAVING. WITH and subqueries are allowed.
    GROUP BY must use the key of each group (e.g. emp_id), not a name: names need not be unique, and two different employees with the same name would be merged into one group.
    You might want to add records in the tables for testing correctness of your answers. Feel free to modify 'employee.sql'.
*/

/* 1. Which departments have at least two employees such that each of them is assigned to at least two projects? Print the department names. */

/* 2. Print the number of employees and the total yearly payroll (sum of 12 times the monthly salaries) in one row. */

/* 3. Print the name of each department with at least two employees, together with its number of employees. (Group by the department id, not by its name.) */

/* 4. Which departments have no employee working on project 3? Print the department names. (Use EXCEPT.) */

/* 5. Which departments have no employee working on project 3? Print the department names. (Use NOT EXISTS.) */

/* 6. Print the names of employees who have no subordinates. */

/* 7. Print every employee's name together with the name of his/her superior, or 'none' if the employee has no superior. */

/* 8. For every job held by some employee, print the job, the number of employees having that job with salary at least 2000 and the number of employees having that job with salary below 2000 (print 0 if there are none). */

/* 9. (1 point) For each department print its name and the average yearly salary (12 times the monthly salary) of its employees. Departments without employees must be printed too, with NULL as the average. */

/* 10. Print the name of the department with the highest average monthly salary (print all such departments if there is a tie). */

/* 11. Which employees earn more than each of their subordinates? Employees without subordinates are not printed. */

/* 12. For every employee print the name and the number of projects he/she works on, with 0 for an employee without projects. Why would COUNT(*) give a wrong result here? */

/* 13. Which departments have an employee working on each of the projects? */

/* 14. Which departments have an average number of projects per employee below 1? An employee without projects counts as 0. */

/* 15. (1 point) Which employees work on all projects but one? */
