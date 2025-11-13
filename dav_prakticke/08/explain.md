# EXPLAIN examples

TODO nejake indexy na emp, kde je  viac atributov / dodatocne stlpce / ...

Getting a query plan in SQL:
* [EXPLAIN syntax](https://www.postgresql.org/docs/current/sql-explain.html)
* [EXPLAIN usage](https://www.postgresql.org/docs/current/using-explain.html)
* [EXPLAIN simple tutorial](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-explain/)

## Example query plans

```
EXPLAIN SELECT * FROM employee e 
JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.name;

                                    QUERY PLAN                                     
-----------------------------------------------------------------------------------
 Sort  (cost=41.07..41.75 rows=270 width=508)
   Sort Key: e.name
   ->  Hash Join  (cost=16.75..30.17 rows=270 width=508)
         Hash Cond: (e.dept_id = d.dept_id)
         ->  Seq Scan on employee e  (cost=0.00..12.70 rows=270 width=268)
         ->  Hash  (cost=13.00..13.00 rows=300 width=240)
               ->  Seq Scan on department d  (cost=0.00..13.00 rows=300 width=240)
```

```
EXPLAIN SELECT * FROM employee e WHERE NOT EXISTS (
	SELECT 1 FROM project p 
	WHERE p.emp_id = e.emp_id AND p.name LIKE '%N%'
	ORDER BY p.proj_id	/* ignored by the db */
);

                               QUERY PLAN                               
------------------------------------------------------------------------
 Hash Anti Join  (cost=23.25..41.70 rows=135 width=268)
   Hash Cond: (e.emp_id = p.emp_id)
   ->  Seq Scan on employee e  (cost=0.00..12.70 rows=270 width=268)
   ->  Hash  (cost=16.62..16.62 rows=530 width=4)
         ->  Seq Scan on project p  (cost=0.00..16.62 rows=530 width=4)
               Filter: ((name)::text ~~ '%N%'::text)
```

```
EXPLAIN
WITH emp_without_prj(emp_id) AS (
      (SELECT e.emp_id FROM employee e)
      EXCEPT
      (SELECT p.emp_id FROM project p)
)
SELECT d.dept_id, e.emp_id
FROM department d
JOIN employee e ON e.dept_id = d.dept_id
JOIN emp_without_prj ewp ON ewp.emp_id = e.emp_id;

                                                  QUERY PLAN
--------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=156.49..169.55 rows=989 width=8)
   Hash Cond: (e.emp_id = ewp.emp_id)
   ->  Merge Join  (cost=73.46..83.92 rows=989 width=8)
         Merge Cond: (d.dept_id = e.dept_id)
         ->  Index Only Scan using department_pkey on department d  (cost=0.42..23637.00 rows=909905 width=4)
         ->  Sort  (cost=68.09..70.56 rows=989 width=8)
               Sort Key: e.dept_id
               ->  Seq Scan on employee e  (cost=0.00..18.89 rows=989 width=8)
   ->  Hash  (cost=70.66..70.66 rows=989 width=4)
         ->  Subquery Scan on ewp  (cost=0.00..70.66 rows=989 width=4)
               ->  HashSetOp Except  (cost=0.00..60.77 rows=989 width=8)
                     ->  Append  (cost=0.00..56.98 rows=1519 width=8)
                           ->  Subquery Scan on "*SELECT* 1"  (cost=0.00..28.78 rows=989 width=8)
                                 ->  Seq Scan on employee e_1  (cost=0.00..18.89 rows=989 width=4)
                           ->  Subquery Scan on "*SELECT* 2"  (cost=0.00..20.60 rows=530 width=8)
                                 ->  Seq Scan on project p  (cost=0.00..15.30 rows=530 width=4)
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
------------------------------------------------------------------------------------------
 Aggregate  (cost=36.71..36.72 rows=1 width=8)
   ->  Hash Join  (cost=23.23..36.63 rows=30 width=0)
         Hash Cond: (e.dept_id = b.dept_id)
         Join Filter: ((e.salary >= b.lower) AND (e.salary <= b.upper))
         ->  Seq Scan on employee e  (cost=0.00..12.70 rows=270 width=20)
         ->  Hash  (cost=20.73..20.73 rows=200 width=68)
               ->  Subquery Scan on b  (cost=14.72..20.73 rows=200 width=68)
                     ->  HashAggregate  (cost=14.72..18.73 rows=200 width=68)
                           Group Key: employee.dept_id
                           ->  Seq Scan on employee  (cost=0.00..12.70 rows=270 width=20)
```

```
EXPLAIN
SELECT COUNT(*) FROM employee AS e
WHERE e.emp_id NOT IN (SELECT emp_id FROM project);

                               QUERY PLAN                               
------------------------------------------------------------------------
 Aggregate  (cost=30.34..30.35 rows=1 width=8)
   ->  Seq Scan on employee e  (cost=16.62..30.00 rows=135 width=0)
         Filter: (NOT (hashed SubPlan 1))
         SubPlan 1
           ->  Seq Scan on project  (cost=0.00..15.30 rows=530 width=4)
```

