-- Sample database for the exercises. Load with: sqlite3 employee.db < employee.sql, or: psql -f employee.sql
--
-- The script runs in a single transaction. If DROP TABLE fails in PostgreSQL because you created
-- views on these tables, the database stays unchanged. In that case drop those views (DROP VIEW ...)
-- or add CASCADE to the DROP TABLE statements below (this drops the dependent views too) and rerun.

BEGIN;

DROP TABLE IF EXISTS employee;

CREATE TABLE employee(
   emp_id INTEGER PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   job VARCHAR(50) NOT NULL,
   salary DECIMAL(10, 2),
   superior INTEGER,
   dept_id INTEGER NOT NULL
);

INSERT INTO employee VALUES (11, 'King', 'president', 5000, NULL, 10);
INSERT INTO employee VALUES (12, 'AccountingManager', 'manager', 1500, 11, 10);
INSERT INTO employee VALUES (13, 'AccountingClerk', 'clerk', 1300, 12, 10);
INSERT INTO employee VALUES (14, 'SalesManager', 'manager', 2975, 11, 30);
INSERT INTO employee VALUES (15, 'MoneyMagnet', 'salesman', 2650, 14, 30);
INSERT INTO employee VALUES (16, 'DealMaster', 'salesman', 1900, 14, 30);
INSERT INTO employee VALUES (17, 'MrFixIt', 'clerk', 950, 14, 30);
INSERT INTO employee VALUES (18, 'InsightNinja', 'analyst', 3000, 14, 30);
INSERT INTO employee VALUES (19, 'Tamara', 'clerk', NULL, 12, 10);

COMMIT;
