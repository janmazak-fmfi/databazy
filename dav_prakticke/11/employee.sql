-- Note that we drop the tables in the reverse order because
-- we don't want to e.g. delete employees before deleting projects assigned to them.
DROP TABLE IF EXISTS emp_projects;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

-- In the tables that follow, we only include necessary information:
-- Some are missing primary keys and there are no foreign keys.
-- We will deal with constraints later; we don't want any confusion at this stage.

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

INSERT INTO department VALUES (10, 'Accounting', 'New York');
INSERT INTO department VALUES (20, 'Research', 'Dallas');
INSERT INTO department VALUES (30, 'Sales', 'Chicago');

INSERT INTO employee VALUES (11, 'King', 'president', 5000, NULL, 10);
INSERT INTO employee VALUES (12, 'AccountingManager', 'manager', 1500, 11, 10);
INSERT INTO employee VALUES (13, 'AccountingClerk', 'clerk', 1300, 12, 10);
INSERT INTO employee VALUES (14, 'SalesManager', 'manager', 2975, 11, 30);
INSERT INTO employee VALUES (15, 'MoneyMagnet', 'salesman', 2650, 14, 30);
INSERT INTO employee VALUES (16, 'DealMaster', 'salesman', 1900, 14, 30);
INSERT INTO employee VALUES (17, 'MrFixIt', 'clerk', 950, 14, 30);
INSERT INTO employee VALUES (18, 'InsightNinja', 'analyst', 3000, 14, 30);

INSERT INTO project VALUES (1, 'Enviro1');
INSERT INTO project VALUES (2, 'Enviro2');
INSERT INTO project VALUES (3, 'Nuclear3');

INSERT INTO emp_projects VALUES (15, 1);
INSERT INTO emp_projects VALUES (17, 1);
INSERT INTO emp_projects VALUES (14, 2);
INSERT INTO emp_projects VALUES (14, 3);
INSERT INTO emp_projects VALUES (18, 3);
