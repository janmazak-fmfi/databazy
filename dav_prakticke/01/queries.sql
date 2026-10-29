/* ------------------------------------------------------------------------ */
/* Write and test the following queries ----------------------------------- */
/* ------------------------------------------------------------------------ */

/* 1. Print all jobs alphabetically without duplicity. */

/* 2. List names and jobs of employees with salary at least 2000. */

/* 3. Print names and salaries of all managers and analysts (in a single SELECT query). */

/* 4. Print the names of employees whose name has the letter n as its third character. Use LIKE; in a pattern, % stands for any text and _ for exactly one character. Note: SQLite's LIKE ignores case, PostgreSQL's does not; PostgreSQL has ILIKE for case-insensitive matching (SQLite does not support ILIKE). */

/* 5. Print the name and the annual salary (12 times the monthly salary) of every employee. Name the computed column annual_salary and sort the result by it, from the highest to the lowest. Employees with unknown salary (NULL) must come last in both SQLite and PostgreSQL (see NULLS LAST in the ORDER BY documentation). */

/* 6. Print the name and the salary after a 10 % raise, rounded to whole euros (name the column raised_salary). Show only employees whose raised salary is at least 2000. Do not use the alias raised_salary in WHERE: PostgreSQL does not accept it (SQLite does, but the query must work in both), so repeat the expression. */

/* 7. For every employee print the name, the salary and a salary level: 'low' for salary below 1500, 'medium' for salary from 1500 to 2999, 'high' for salary 3000 or more, and 'unknown' for NULL salary. Use CASE ... WHEN and name the column salary_level. */

/* 8. Print the names of all employees who have no superior. Why would WHERE superior = NULL not work? */

/* 9. Print the name and the salary of every employee, with 'unknown' instead of a missing (NULL) salary. Use COALESCE. Hint: both arguments of COALESCE must have the same type. */

/* 10. Print the names of employees with salary < 2000 OR salary >= 2000. Why is the result not the same as the list of all employees? */

/* 11. Print the title of every employee in the form 'King (president)', i.e. name, a space and the job in parentheses (name the column title). Use || for string concatenation. Sort the result by job, then by salary from the highest, with unknown salaries last. */

/* 12. (1 point) For every employee whose name contains the letter a, then any one character, then the letter a (e.g. 'Manager'), print the name and the annual salary, with 'unknown' for a missing salary. Sort by the annual salary from the highest, unknown last. (Mind the LIKE case sensitivity, see task 4.) */
