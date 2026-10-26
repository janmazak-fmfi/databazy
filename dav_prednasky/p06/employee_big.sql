-- Sample database for the exercises. Load with: psql -f employee_big.sql
--
-- The script runs in a single transaction. If DROP TABLE fails in PostgreSQL because you created
-- views on these tables, the database stays unchanged. In that case drop those views (DROP VIEW ...)
-- or add CASCADE to the DROP TABLE statements below (this drops the dependent views too) and rerun.

BEGIN;

-- Note that we drop the tables in the reverse order because
-- we don't want to e.g. delete employees before deleting projects assigned to them.
DROP TABLE IF EXISTS emp_projects;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

CREATE TABLE department(
   dept_id INTEGER PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   location VARCHAR(50) NOT NULL
);

CREATE TABLE employee(
   emp_id INTEGER PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   job VARCHAR(50) NOT NULL,
   salary DECIMAL(10, 2),
   superior INTEGER,
   dept_id INTEGER NOT NULL
);

-- Projects part of the schema (same as in the exercises): an employee can work on
-- several projects and a project can have several employees (many-to-many via emp_projects).
CREATE TABLE project (
   proj_id INTEGER PRIMARY KEY,
   name TEXT NOT NULL
);

CREATE TABLE emp_projects (
   emp_id INTEGER NOT NULL,
   proj_id INTEGER NOT NULL
);

INSERT INTO department SELECT generate_series(1,1000000), md5(random()::text), md5(random()::text);
INSERT INTO employee SELECT generate_series(1,1000000), md5(random()::text), md5(random()::text), random(), NULL, 1 + floor(random()*1000000)::int;
INSERT INTO project SELECT generate_series(1,1000000), md5(random()::text);
INSERT INTO emp_projects SELECT 1 + floor(random()*1000000)::int, 1 + floor(random()*1000000)::int FROM generate_series(1,1000000);

COMMIT;
