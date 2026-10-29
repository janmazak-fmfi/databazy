-- Setup for E1-E5 in 08.md. Run from the exercise directory:
-- psql -v ON_ERROR_STOP=1 -f explain_setup.sql
-- E4 also sets -v n_employees=... -v n_departments=... .
-- This recreates the four tables and removes any indexes added in earlier tasks.
-- The schema is the same as in exercise 4; all rows here are generated.

\set ON_ERROR_STOP on
\if :{?n_employees}
\else
\set n_employees 1000000
\endif
\if :{?n_departments}
\else
\set n_departments 1000
\endif

BEGIN;
DROP TABLE IF EXISTS emp_projects;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

CREATE TABLE department (
    dept_id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location VARCHAR(50) NOT NULL
);
CREATE TABLE employee (
    emp_id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    job VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2),
    superior INTEGER,
    dept_id INTEGER NOT NULL
);
CREATE TABLE project (
    proj_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);
CREATE TABLE emp_projects (
    emp_id INTEGER NOT NULL,
    proj_id INTEGER NOT NULL
);

SELECT setseed(0.42);

INSERT INTO department (dept_id, name, location)
SELECT i, 'Department ' || i, 'Bratislava'
FROM generate_series(1, :n_departments) AS g(i);

INSERT INTO employee (emp_id, name, job, salary, superior, dept_id)
SELECT i, 'Employee ' || i, 'analyst',
       1000 + floor(random() * 10000), NULL,
       1 + floor(random() * :n_departments)::integer
FROM generate_series(1, :n_employees) AS g(i);
COMMIT;

-- ANALYZE updates the planner's row-count and value-distribution estimates after the bulk insert.
-- VACUUM prepares page metadata so E2 can demonstrate an index-only scan without table-row lookups.
-- These commands are outside BEGIN/COMMIT because VACUUM cannot run inside a transaction block.
VACUUM ANALYZE department;
VACUUM ANALYZE employee;
