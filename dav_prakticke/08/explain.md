# EXPLAIN examples

Getting a query plan in SQL:

* [EXPLAIN syntax](https://www.postgresql.org/docs/current/sql-explain.html)
* [EXPLAIN usage](https://www.postgresql.org/docs/current/using-explain.html)
* [EXPLAIN simple tutorial](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-explain/)

## Example query plans

The examples use the schema and sample data from [exercise 4](../04/employee.sql), followed by `ANALYZE`. The plans below were obtained with PostgreSQL 16; plans and cost estimates depend on the data, statistics, and database version.

```
EXPLAIN SELECT * FROM employee e
JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.name;

QUERY PLAN
Sort  (cost=2.32..2.34 rows=8 width=57)
  Sort Key: e.name
  ->  Hash Join  (cost=1.07..2.20 rows=8 width=57)
        Hash Cond: (e.dept_id = d.dept_id)
        ->  Seq Scan on employee e  (cost=0.00..1.08 rows=8 width=37)
        ->  Hash  (cost=1.03..1.03 rows=3 width=20)
              ->  Seq Scan on department d  (cost=0.00..1.03 rows=3 width=20)
```

```
EXPLAIN SELECT * FROM employee e WHERE NOT EXISTS (
	SELECT 1 FROM emp_projects ep
	JOIN project p ON p.proj_id = ep.proj_id
	WHERE ep.emp_id = e.emp_id AND p.name LIKE '%N%'
	ORDER BY p.proj_id	/* ignored by the db */
);

QUERY PLAN
Hash Right Anti Join  (cost=2.26..3.47 rows=3 width=37)
  Hash Cond: (ep.emp_id = e.emp_id)
  ->  Hash Join  (cost=1.08..2.21 rows=8 width=4)
        Hash Cond: (ep.proj_id = p.proj_id)
        ->  Seq Scan on emp_projects ep  (cost=0.00..1.08 rows=8 width=8)
        ->  Hash  (cost=1.04..1.04 rows=3 width=4)
              ->  Seq Scan on project p  (cost=0.00..1.04 rows=3 width=4)
                    Filter: (name ~~ '%N%'::text)
  ->  Hash  (cost=1.08..1.08 rows=8 width=37)
        ->  Seq Scan on employee e  (cost=0.00..1.08 rows=8 width=37)
```

```
EXPLAIN
WITH emp_without_prj(emp_id) AS (
      (SELECT e.emp_id FROM employee e)
      EXCEPT
      (SELECT ep.emp_id FROM emp_projects ep)
)
SELECT d.dept_id, e.emp_id
FROM department d
JOIN employee e ON e.dept_id = d.dept_id
JOIN emp_without_prj ewp ON ewp.emp_id = e.emp_id;

QUERY PLAN
Hash Join  (cost=2.25..4.77 rows=8 width=8)
  Hash Cond: (e.dept_id = d.dept_id)
  ->  Hash Join  (cost=1.18..3.65 rows=8 width=8)
        Hash Cond: (ewp.emp_id = e.emp_id)
        ->  Subquery Scan on ewp  (cost=0.00..2.44 rows=8 width=4)
              ->  HashSetOp Except  (cost=0.00..2.44 rows=8 width=8)
                    ->  Append  (cost=0.00..2.40 rows=16 width=8)
                          ->  Subquery Scan on "*SELECT* 1"  (cost=0.00..1.16 rows=8 width=8)
                                ->  Seq Scan on employee e_1  (cost=0.00..1.08 rows=8 width=4)
                          ->  Subquery Scan on "*SELECT* 2"  (cost=0.00..1.16 rows=8 width=8)
                                ->  Seq Scan on emp_projects ep  (cost=0.00..1.08 rows=8 width=4)
        ->  Hash  (cost=1.08..1.08 rows=8 width=8)
              ->  Seq Scan on employee e  (cost=0.00..1.08 rows=8 width=8)
  ->  Hash  (cost=1.03..1.03 rows=3 width=4)
        ->  Seq Scan on department d  (cost=0.00..1.03 rows=3 width=4)
```

```
EXPLAIN
WITH bounds AS (
	SELECT dept_id, AVG(salary) * 0.6 AS upper, AVG(salary) * 0.4 as lower
	FROM employee
	GROUP BY dept_id
)
SELECT COUNT(*) AS c
FROM employee e
	JOIN bounds b ON e.dept_id = b.dept_id
WHERE e.salary >= b.lower AND e.salary <= b.upper;

QUERY PLAN
Aggregate  (cost=2.30..2.31 rows=1 width=8)
  ->  Hash Join  (cost=1.20..2.30 rows=1 width=0)
        Hash Cond: (e.dept_id = b.dept_id)
        Join Filter: ((e.salary >= b.lower) AND (e.salary <= b.upper))
        ->  Seq Scan on employee e  (cost=0.00..1.08 rows=8 width=9)
        ->  Hash  (cost=1.18..1.18 rows=2 width=68)
              ->  Subquery Scan on b  (cost=1.12..1.18 rows=2 width=68)
                    ->  HashAggregate  (cost=1.12..1.16 rows=2 width=68)
                          Group Key: employee.dept_id
                          ->  Seq Scan on employee  (cost=0.00..1.08 rows=8 width=9)
```

```
EXPLAIN
SELECT COUNT(*) FROM employee AS e
WHERE e.emp_id NOT IN (SELECT emp_id FROM emp_projects);

QUERY PLAN
Aggregate  (cost=2.21..2.22 rows=1 width=8)
  ->  Seq Scan on employee e  (cost=1.10..2.20 rows=4 width=0)
        Filter: (NOT (hashed SubPlan 1))
        SubPlan 1
          ->  Seq Scan on emp_projects  (cost=0.00..1.08 rows=8 width=4)
```

