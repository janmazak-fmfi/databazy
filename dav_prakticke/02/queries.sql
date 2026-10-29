/* ------------------------------------------------------------------------ */
/* Write and test the following queries ----------------------------------- */
/* ------------------------------------------------------------------------ */

/*
    DO NOT use aggregate functions (COUNT, SUM, AVG, MIN, MAX) or GROUP BY/HAVING in this exercise.
    Also, avoid ORDER BY and LIMIT to determine minimum.
    For now, we are practicing using WHERE NOT EXISTS when calculating minimum.
*/

/* 1. List all employees together with the location where they work, as one string in the form 'King (New York)'. */

/* 2. Print the name of every department together with the names of its employees. For a department without employees, print 'none'. Your query must not use a specific emp_id or dept_id. */

/* 3. Print the names of employees who earn more than their superior. */

/* 4. Which jobs whose second letter is 'a' occur both in department 10 and in department 30? (Use INTERSECT and LIKE.) */

/* 5. (1 point) For each employee, list all his/her subordinates (those that have him/her as the superior).
Use an outer join so that your list contains every employee, even those without subordinates. */

/* 6. Print the names of employees who have no subordinates. Why would WHERE emp_id NOT IN (SELECT superior FROM employee) not work? */

/* 7. Which departments are empty (have no employees)? */

/* 8. Find the lowest salary in New York. */

/* 9. Which departments employ only salesmen? */

/* 10. Which employees manage only clerks? (Interpretation: at least one clerk and only clerks.) */

/* 11. (1 point) Which departments have an employee for every job in the database? (Your query must not rely on specific jobs in the given dataset.) */

/* 12. For every employee print the name and a column role: 'manager' if the employee has at least one subordinate, 'staff' otherwise. (Use CASE ... WHEN.) */
