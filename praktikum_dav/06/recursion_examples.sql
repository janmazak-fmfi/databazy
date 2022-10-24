-- https://sourceforge.net/p/postgres-xl/postgres-xl/ci/56008fbd7d08d3e8719ca2c91013507fdd011d3f/tree/src/test/regress/expected/with.out

--
-- Tests for common table expressions (WITH query, ... SELECT ...)
--
-- Basic WITH
WITH q1(x,y) AS (SELECT 1,2)
SELECT * FROM q1, q1 AS q2;
 x | y | x | y 
---+---+---+---
 1 | 2 | 1 | 2
(1 row)

-- Multiple uses are evaluated only once
SELECT count(*) FROM (
  WITH q1(x) AS (SELECT random() FROM generate_series(1, 5))
    SELECT * FROM q1
  UNION
    SELECT * FROM q1
) ss;
 count 
-------
     5
(1 row)

-- WITH RECURSIVE
-- sum of 1..100
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;
 sum  
------
 5050
(1 row)

WITH RECURSIVE t(n) AS (
    SELECT (VALUES(1))
UNION ALL
    SELECT n+1 FROM t WHERE n < 5
)
SELECT * FROM t ORDER BY n;
 n 
---
 1
 2
 3
 4
 5
(5 rows)

-- This is an infinite loop with UNION ALL, but not with UNION
WITH RECURSIVE t(n) AS (
    SELECT 1
UNION
    SELECT 10-n FROM t)
SELECT * FROM t ORDER BY n;
 n 
---
 1
 9
(2 rows)

-- This'd be an infinite loop, but outside query reads only as much as needed
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n+1 FROM t)
SELECT * FROM t LIMIT 10;
 n  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- UNION case should have same property
WITH RECURSIVE t(n) AS (
    SELECT 1
UNION
    SELECT n+1 FROM t)
SELECT * FROM t LIMIT 10;
 n  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- Test behavior with an unknown-type literal in the WITH
WITH q AS (SELECT 'foo' AS x)
SELECT x, x IS OF (unknown) as is_unknown FROM q;
  x  | is_unknown 
-----+------------
 foo | t
(1 row)

WITH RECURSIVE t(n) AS (
    SELECT 'foo'
UNION ALL
    SELECT n || ' bar' FROM t WHERE length(n) < 20
)
SELECT n, n IS OF (text) as is_text FROM t ORDER BY n;
            n            | is_text 
-------------------------+---------
 foo                     | t
 foo bar                 | t
 foo bar bar             | t
 foo bar bar bar         | t
 foo bar bar bar bar     | t
 foo bar bar bar bar bar | t
(6 rows)

--
-- Some examples with a tree
--
-- department structure represented here is as follows:
--
-- ROOT-+->A-+->B-+->C
--      |         |
--      |         +->D-+->F
--      +->E-+->G
CREATE TEMP TABLE department (
	id INTEGER PRIMARY KEY,  -- department ID
	parent_department INTEGER ,
	name TEXT -- department name
) DISTRIBUTE BY REPLICATION;
NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "department_pkey" for table "department"
INSERT INTO department VALUES (0, NULL, 'ROOT');
INSERT INTO department VALUES (1, 0, 'A');
INSERT INTO department VALUES (2, 1, 'B');
INSERT INTO department VALUES (3, 2, 'C');
INSERT INTO department VALUES (4, 2, 'D');
INSERT INTO department VALUES (5, 0, 'E');
INSERT INTO department VALUES (6, 4, 'F');
INSERT INTO department VALUES (7, 5, 'G');
-- extract all departments under 'A'. Result should be A, B, C, D and F
WITH RECURSIVE subdepartment AS
(
	-- non recursive term
	SELECT name as root_name, * FROM department WHERE name = 'A'
	UNION ALL
	-- recursive term
	SELECT sd.root_name, d.* FROM department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY name;
 root_name | id | parent_department | name 
-----------+----+-------------------+------
 A         |  1 |                 0 | A
 A         |  2 |                 1 | B
 A         |  3 |                 2 | C
 A         |  4 |                 2 | D
 A         |  6 |                 4 | F
(5 rows)

-- extract all departments under 'A' with "level" number
WITH RECURSIVE subdepartment(level, id, parent_department, name) AS
(
	-- non recursive term
	SELECT 1, * FROM department WHERE name = 'A'
	UNION ALL
	-- recursive term
	SELECT sd.level + 1, d.* FROM department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY name;
 level | id | parent_department | name 
-------+----+-------------------+------
     1 |  1 |                 0 | A
     2 |  2 |                 1 | B
     3 |  3 |                 2 | C
     3 |  4 |                 2 | D
     4 |  6 |                 4 | F
(5 rows)

-- extract all departments under 'A' with "level" number.
-- Only shows level 2 or more
WITH RECURSIVE subdepartment(level, id, parent_department, name) AS
(
	-- non recursive term
	SELECT 1, * FROM department WHERE name = 'A'
	UNION ALL
	-- recursive term
	SELECT sd.level + 1, d.* FROM department AS d, subdepartment AS sd
		WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment WHERE level >= 2 ORDER BY name;
 level | id | parent_department | name 
-------+----+-------------------+------
     2 |  2 |                 1 | B
     3 |  3 |                 2 | C
     3 |  4 |                 2 | D
     4 |  6 |                 4 | F
(4 rows)

-- "RECURSIVE" is ignored if the query has no self-reference
WITH RECURSIVE subdepartment AS
(
	-- note lack of recursive UNION structure
	SELECT * FROM department WHERE name = 'A'
)
SELECT * FROM subdepartment ORDER BY name;
 id | parent_department | name 
----+-------------------+------
  1 |                 0 | A
(1 row)

-- inside subqueries
SELECT count(*) FROM (
    WITH RECURSIVE t(n) AS (
        SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 500
    )
    SELECT * FROM t) AS t WHERE n < (
        SELECT count(*) FROM (
            WITH RECURSIVE t(n) AS (
                   SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 100
                )
            SELECT * FROM t WHERE n < 50000
         ) AS t WHERE n < 100);
 count 
-------
    98
(1 row)

-- use same CTE twice at different subquery levels
WITH q1(x,y) AS (
    SELECT hundred, sum(ten) FROM tenk1 GROUP BY hundred
  )
SELECT count(*) FROM q1 WHERE y > (SELECT sum(y)/100 FROM q1 qsub);
 count 
-------
    50
(1 row)

-- via a VIEW
CREATE TEMPORARY VIEW vsubdepartment AS
	WITH RECURSIVE subdepartment AS
	(
		 -- non recursive term
		SELECT * FROM department WHERE name = 'A'
		UNION ALL
		-- recursive term
		SELECT d.* FROM department AS d, subdepartment AS sd
			WHERE d.parent_department = sd.id
	)
	SELECT * FROM subdepartment;
SELECT * FROM vsubdepartment ORDER BY name;
 id | parent_department | name 
----+-------------------+------
  1 |                 0 | A
  2 |                 1 | B
  3 |                 2 | C
  4 |                 2 | D
  6 |                 4 | F
(5 rows)

-- Check reverse listing
SELECT pg_get_viewdef('vsubdepartment'::regclass);
                                                                                                                                                                                    pg_get_viewdef                                                                                                                                                                                     
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 WITH RECURSIVE subdepartment AS (SELECT department.id, department.parent_department, department.name FROM department WHERE (department.name = 'A'::text) UNION ALL SELECT d.id, d.parent_department, d.name FROM department d, subdepartment sd WHERE (d.parent_department = sd.id)) SELECT subdepartment.id, subdepartment.parent_department, subdepartment.name FROM subdepartment;
(1 row)

SELECT pg_get_viewdef('vsubdepartment'::regclass, true);
                                pg_get_viewdef                                 
-------------------------------------------------------------------------------
  WITH RECURSIVE subdepartment AS (                                           +
                  SELECT department.id, department.parent_department,         +
                     department.name                                          +
                    FROM department                                           +
                   WHERE department.name = 'A'::text                          +
         UNION ALL                                                            +
                  SELECT d.id, d.parent_department, d.name                    +
                    FROM department d, subdepartment sd                       +
                   WHERE d.parent_department = sd.id                          +
         )                                                                    +
  SELECT subdepartment.id, subdepartment.parent_department, subdepartment.name+
    FROM subdepartment;
(1 row)

-- corner case in which sub-WITH gets initialized first
select * from (with recursive q as (
      (select * from department order by id)
    union all
      (with x as (select * from q)
       select * from x)
    )
select * from q limit 24) rel_alias order by 1, 2, 3;
 id | parent_department | name 
----+-------------------+------
  0 |                   | ROOT
  0 |                   | ROOT
  0 |                   | ROOT
  1 |                 0 | A
  1 |                 0 | A
  1 |                 0 | A
  2 |                 1 | B
  2 |                 1 | B
  2 |                 1 | B
  3 |                 2 | C
  3 |                 2 | C
  3 |                 2 | C
  4 |                 2 | D
  4 |                 2 | D
  4 |                 2 | D
  5 |                 0 | E
  5 |                 0 | E
  5 |                 0 | E
  6 |                 4 | F
  6 |                 4 | F
  6 |                 4 | F
  7 |                 5 | G
  7 |                 5 | G
  7 |                 5 | G
(24 rows)

select * from (with recursive q as (
      (select * from department order by id)
    union all
      (with recursive x as (
           select * from department
         union all
           (select * from q union all select * from x)
        )
       select * from x)
    )
select * from q limit 32) rel_alias order by 1, 2, 3;
 id | parent_department | name 
----+-------------------+------
  0 |                   | ROOT
  0 |                   | ROOT
  0 |                   | ROOT
  0 |                   | ROOT
  1 |                 0 | A
  1 |                 0 | A
  1 |                 0 | A
  1 |                 0 | A
  2 |                 1 | B
  2 |                 1 | B
  2 |                 1 | B
  2 |                 1 | B
  3 |                 2 | C
  3 |                 2 | C
  3 |                 2 | C
  3 |                 2 | C
  4 |                 2 | D
  4 |                 2 | D
  4 |                 2 | D
  4 |                 2 | D
  5 |                 0 | E
  5 |                 0 | E
  5 |                 0 | E
  5 |                 0 | E
  6 |                 4 | F
  6 |                 4 | F
  6 |                 4 | F
  6 |                 4 | F
  7 |                 5 | G
  7 |                 5 | G
  7 |                 5 | G
  7 |                 5 | G
(32 rows)

-- recursive term has sub-UNION
WITH RECURSIVE t(i,j) AS (
	VALUES (1,2)
	UNION ALL
	SELECT t2.i, t.j+1 FROM
		(SELECT 2 AS i UNION ALL SELECT 3 AS i) AS t2
		JOIN t ON (t2.i = t.i+1))
	SELECT * FROM t order by i;
 i | j 
---+---
 1 | 2
 2 | 3
 3 | 4
(3 rows)

--
-- different tree example
--
CREATE TEMPORARY TABLE tree(
    id INTEGER PRIMARY KEY,
    parent_id INTEGER 
) DISTRIBUTE BY REPLICATION;
NOTICE:  CREATE TABLE / PRIMARY KEY will create implicit index "tree_pkey" for table "tree"
INSERT INTO tree
VALUES (1, NULL), (2, 1), (3,1), (4,2), (5,2), (6,2), (7,3), (8,3),
       (9,4), (10,4), (11,7), (12,7), (13,7), (14, 9), (15,11), (16,11);
--
-- get all paths from "second level" nodes to leaf nodes
--
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tree.id, t.path || tree.id
    FROM tree JOIN t ON (tree.parent_id = t.id)
)
SELECT t1.*, t2.* FROM t AS t1 JOIN t AS t2 ON
	(t1.path[1] = t2.path[1] AND
	array_upper(t1.path,1) = 1 AND
	array_upper(t2.path,1) > 1)
	ORDER BY t1.id, t2.id;
 id | path | id |    path     
----+------+----+-------------
  2 | {2}  |  4 | {2,4}
  2 | {2}  |  5 | {2,5}
  2 | {2}  |  6 | {2,6}
  2 | {2}  |  9 | {2,4,9}
  2 | {2}  | 10 | {2,4,10}
  2 | {2}  | 14 | {2,4,9,14}
  3 | {3}  |  7 | {3,7}
  3 | {3}  |  8 | {3,8}
  3 | {3}  | 11 | {3,7,11}
  3 | {3}  | 12 | {3,7,12}
  3 | {3}  | 13 | {3,7,13}
  3 | {3}  | 15 | {3,7,11,15}
  3 | {3}  | 16 | {3,7,11,16}
(13 rows)

-- just count 'em
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tree.id, t.path || tree.id
    FROM tree JOIN t ON (tree.parent_id = t.id)
)
SELECT t1.id, count(t2.*) FROM t AS t1 JOIN t AS t2 ON
	(t1.path[1] = t2.path[1] AND
	array_upper(t1.path,1) = 1 AND
	array_upper(t2.path,1) > 1)
	GROUP BY t1.id
	ORDER BY t1.id;
 id | count 
----+-------
  2 |     6
  3 |     7
(2 rows)

-- this variant tickled a whole-row-variable bug in 8.4devel
WITH RECURSIVE t(id, path) AS (
    VALUES(1,ARRAY[]::integer[])
UNION ALL
    SELECT tree.id, t.path || tree.id
    FROM tree JOIN t ON (tree.parent_id = t.id)
)
SELECT t1.id, t2.path, t2 FROM t AS t1 JOIN t AS t2 ON
(t1.id=t2.id) ORDER BY id;
 id |    path     |         t2         
----+-------------+--------------------
  1 | {}          | (1,{})
  2 | {2}         | (2,{2})
  3 | {3}         | (3,{3})
  4 | {2,4}       | (4,"{2,4}")
  5 | {2,5}       | (5,"{2,5}")
  6 | {2,6}       | (6,"{2,6}")
  7 | {3,7}       | (7,"{3,7}")
  8 | {3,8}       | (8,"{3,8}")
  9 | {2,4,9}     | (9,"{2,4,9}")
 10 | {2,4,10}    | (10,"{2,4,10}")
 11 | {3,7,11}    | (11,"{3,7,11}")
 12 | {3,7,12}    | (12,"{3,7,12}")
 13 | {3,7,13}    | (13,"{3,7,13}")
 14 | {2,4,9,14}  | (14,"{2,4,9,14}")
 15 | {3,7,11,15} | (15,"{3,7,11,15}")
 16 | {3,7,11,16} | (16,"{3,7,11,16}")
(16 rows)

--
-- test cycle detection
--
create temp table graph( f int, t int, label text ) DISTRIBUTE BY REPLICATION;
insert into graph values
	(1, 2, 'arc 1 -> 2'),
	(1, 3, 'arc 1 -> 3'),
	(2, 3, 'arc 2 -> 3'),
	(1, 4, 'arc 1 -> 4'),
	(4, 5, 'arc 4 -> 5'),
	(5, 1, 'arc 5 -> 1');
with recursive search_graph(f, t, label, path, cycle) as (
	select *, array[row(g.f, g.t)], false from graph g
	union all
	select g.*, path || row(g.f, g.t), row(g.f, g.t) = any(path)
	from graph g, search_graph sg
	where g.f = sg.t and not cycle
)
select * from search_graph order by path;
ERROR:  WITH RECURSIVE currently not supported on distributed tables.
-- ordering by the path column has same effect as SEARCH DEPTH FIRST
with recursive search_graph(f, t, label, path, cycle) as (
	select *, array[row(g.f, g.t)], false from graph g
	union all
	select g.*, path || row(g.f, g.t), row(g.f, g.t) = any(path)
	from graph g, search_graph sg
	where g.f = sg.t and not cycle
)
select * from search_graph order by path;
ERROR:  WITH RECURSIVE currently not supported on distributed tables.
--
-- test multiple WITH queries
--
WITH RECURSIVE
  y (id) AS (VALUES (1)),
  x (id) AS (SELECT * FROM y UNION ALL SELECT id+1 FROM x WHERE id < 5)
SELECT * FROM x ORDER BY id;
 id 
----
  1
  2
  3
  4
  5
(5 rows)

-- forward reference OK
WITH RECURSIVE
    x(id) AS (SELECT * FROM y UNION ALL SELECT id+1 FROM x WHERE id < 5),
    y(id) AS (values (1))
 SELECT * FROM x ORDER BY id;
 id 
----
  1
  2
  3
  4
  5
(5 rows)

WITH RECURSIVE
   x(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 5),
   y(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM y WHERE id < 10)
 SELECT y.*, x.* FROM y LEFT JOIN x USING (id) ORDER BY 1;
 id | id 
----+----
  1 |  1
  2 |  2
  3 |  3
  4 |  4
  5 |  5
  6 |   
  7 |   
  8 |   
  9 |   
 10 |   
(10 rows)

WITH RECURSIVE
   x(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 5),
   y(id) AS
     (VALUES (1) UNION ALL SELECT id+1 FROM x WHERE id < 10)
 SELECT y.*, x.* FROM y LEFT JOIN x USING (id) ORDER BY 1;
 id | id 
----+----
  1 |  1
  2 |  2
  3 |  3
  4 |  4
  5 |  5
  6 |   
(6 rows)

WITH RECURSIVE
   x(id) AS
     (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 3 ),
   y(id) AS
     (SELECT * FROM x UNION ALL SELECT * FROM x),
   z(id) AS
     (SELECT * FROM x UNION ALL SELECT id+1 FROM z WHERE id < 10)
 SELECT * FROM z ORDER BY id;
 id 
----
  1
  2
  2
  3
  3
  3
  4
  4
  4
  5
  5
  5
  6
  6
  6
  7
  7
  7
  8
  8
  8
  9
  9
  9
 10
 10
 10
(27 rows)

WITH RECURSIVE
   x(id) AS
     (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 3 ),
   y(id) AS
     (SELECT * FROM x UNION ALL SELECT * FROM x),
   z(id) AS
     (SELECT * FROM y UNION ALL SELECT id+1 FROM z WHERE id < 10)
 SELECT * FROM z ORDER BY id;
 id 
----
  1
  1
  2
  2
  2
  2
  3
  3
  3
  3
  3
  3
  4
  4
  4
  4
  4
  4
  5
  5
  5
  5
  5
  5
  6
  6
  6
  6
  6
  6
  7
  7
  7
  7
  7
  7
  8
  8
  8
  8
  8
  8
  9
  9
  9
  9
  9
  9
 10
 10
 10
 10
 10
 10
(54 rows)

--
-- Test WITH attached to a data-modifying statement
--
CREATE TEMPORARY TABLE y (a INTEGER) DISTRIBUTE BY REPLICATION;
INSERT INTO y SELECT generate_series(1, 10);
WITH t AS (
	SELECT a FROM y
)
INSERT INTO y
SELECT a+20 FROM t RETURNING *;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

WITH t AS (
	SELECT a FROM y
)
UPDATE y SET a = y.a-10 FROM t WHERE y.a > 20 AND t.a = y.a RETURNING y.a;
ERROR:  could not plan this distributed update
DETAIL:  correlated UPDATE or updating distribution column currently not supported in Postgres-XL.
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

WITH RECURSIVE t(a) AS (
	SELECT 11
	UNION ALL
	SELECT a+1 FROM t WHERE a < 50
)
DELETE FROM y USING t WHERE t.a = y.a RETURNING y.a;
ERROR:  WITH RECURSIVE currently not supported on distributed tables.
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

DROP TABLE y;
--
-- error cases
--
-- INTERSECT
WITH RECURSIVE x(n) AS (SELECT 1 INTERSECT SELECT n+1 FROM x)
	SELECT * FROM x;
ERROR:  recursive query "x" does not have the form non-recursive-term UNION [ALL] recursive-term
LINE 1: WITH RECURSIVE x(n) AS (SELECT 1 INTERSECT SELECT n+1 FROM x...
                       ^
WITH RECURSIVE x(n) AS (SELECT 1 INTERSECT ALL SELECT n+1 FROM x)
	SELECT * FROM x;
ERROR:  recursive query "x" does not have the form non-recursive-term UNION [ALL] recursive-term
LINE 1: WITH RECURSIVE x(n) AS (SELECT 1 INTERSECT ALL SELECT n+1 FR...
                       ^
-- EXCEPT
WITH RECURSIVE x(n) AS (SELECT 1 EXCEPT SELECT n+1 FROM x)
	SELECT * FROM x;
ERROR:  recursive query "x" does not have the form non-recursive-term UNION [ALL] recursive-term
LINE 1: WITH RECURSIVE x(n) AS (SELECT 1 EXCEPT SELECT n+1 FROM x)
                       ^
WITH RECURSIVE x(n) AS (SELECT 1 EXCEPT ALL SELECT n+1 FROM x)
	SELECT * FROM x;
ERROR:  recursive query "x" does not have the form non-recursive-term UNION [ALL] recursive-term
LINE 1: WITH RECURSIVE x(n) AS (SELECT 1 EXCEPT ALL SELECT n+1 FROM ...
                       ^
-- no non-recursive term
WITH RECURSIVE x(n) AS (SELECT n FROM x)
	SELECT * FROM x;
ERROR:  recursive query "x" does not have the form non-recursive-term UNION [ALL] recursive-term
LINE 1: WITH RECURSIVE x(n) AS (SELECT n FROM x)
                       ^
-- recursive term in the left hand side (strictly speaking, should allow this)
WITH RECURSIVE x(n) AS (SELECT n FROM x UNION ALL SELECT 1)
	SELECT * FROM x;
ERROR:  recursive reference to query "x" must not appear within its non-recursive term
LINE 1: WITH RECURSIVE x(n) AS (SELECT n FROM x UNION ALL SELECT 1)
                                              ^
CREATE TEMPORARY TABLE y (a INTEGER) DISTRIBUTE BY REPLICATION;
INSERT INTO y SELECT generate_series(1, 10);
-- LEFT JOIN
WITH RECURSIVE x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT x.n+1 FROM y LEFT JOIN x ON x.n = y.a WHERE n < 10)
SELECT * FROM x;
ERROR:  recursive reference to query "x" must not appear within an outer join
LINE 3:  SELECT x.n+1 FROM y LEFT JOIN x ON x.n = y.a WHERE n < 10)
                                       ^
-- RIGHT JOIN
WITH RECURSIVE x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT x.n+1 FROM x RIGHT JOIN y ON x.n = y.a WHERE n < 10)
SELECT * FROM x;
ERROR:  recursive reference to query "x" must not appear within an outer join
LINE 3:  SELECT x.n+1 FROM x RIGHT JOIN y ON x.n = y.a WHERE n < 10)
                           ^
-- FULL JOIN
WITH RECURSIVE x(n) AS (SELECT a FROM y WHERE a = 1
	UNION ALL
	SELECT x.n+1 FROM x FULL JOIN y ON x.n = y.a WHERE n < 10)
SELECT * FROM x;
ERROR:  recursive reference to query "x" must not appear within an outer join
LINE 3:  SELECT x.n+1 FROM x FULL JOIN y ON x.n = y.a WHERE n < 10)
                           ^
-- subquery
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x
                          WHERE n IN (SELECT * FROM x))
  SELECT * FROM x;
ERROR:  recursive reference to query "x" must not appear within a subquery
LINE 2:                           WHERE n IN (SELECT * FROM x))
                                                            ^
-- aggregate functions
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT count(*) FROM x)
  SELECT * FROM x;
ERROR:  aggregate functions not allowed in a recursive query's recursive term
LINE 1: WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT count(*) F...
                                                          ^
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT sum(n) FROM x)
  SELECT * FROM x;
ERROR:  aggregate functions not allowed in a recursive query's recursive term
LINE 1: WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT sum(n) FRO...
                                                          ^
-- ORDER BY
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x ORDER BY 1)
  SELECT * FROM x;
ERROR:  ORDER BY in a recursive query is not implemented
LINE 1: ...VE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x ORDER BY 1)
                                                                     ^
-- LIMIT/OFFSET
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x LIMIT 10 OFFSET 1)
  SELECT * FROM x;
ERROR:  OFFSET in a recursive query is not implemented
LINE 1: ... AS (SELECT 1 UNION ALL SELECT n+1 FROM x LIMIT 10 OFFSET 1)
                                                                     ^
-- FOR UPDATE
WITH RECURSIVE x(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM x FOR UPDATE)
  SELECT * FROM x;
ERROR:  FOR UPDATE/SHARE in a recursive query is not implemented
-- target list has a recursive query name
WITH RECURSIVE x(id) AS (values (1)
    UNION ALL
    SELECT (SELECT * FROM x) FROM x WHERE id < 5
) SELECT * FROM x;
ERROR:  recursive reference to query "x" must not appear within a subquery
LINE 3:     SELECT (SELECT * FROM x) FROM x WHERE id < 5
                                  ^
-- mutual recursive query (not implemented)
WITH RECURSIVE
  x (id) AS (SELECT 1 UNION ALL SELECT id+1 FROM y WHERE id < 5),
  y (id) AS (SELECT 1 UNION ALL SELECT id+1 FROM x WHERE id < 5)
SELECT * FROM x;
ERROR:  mutual recursion between WITH items is not implemented
LINE 2:   x (id) AS (SELECT 1 UNION ALL SELECT id+1 FROM y WHERE id ...
          ^
-- non-linear recursion is not allowed
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM foo WHERE i < 10
          UNION ALL
       SELECT i+1 FROM foo WHERE i < 5)
) SELECT * FROM foo;
ERROR:  recursive reference to query "foo" must not appear more than once
LINE 6:        SELECT i+1 FROM foo WHERE i < 5)
                               ^
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
	   SELECT * FROM
       (SELECT i+1 FROM foo WHERE i < 10
          UNION ALL
       SELECT i+1 FROM foo WHERE i < 5) AS t
) SELECT * FROM foo;
ERROR:  recursive reference to query "foo" must not appear more than once
LINE 7:        SELECT i+1 FROM foo WHERE i < 5) AS t
                               ^
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM foo WHERE i < 10
          EXCEPT
       SELECT i+1 FROM foo WHERE i < 5)
) SELECT * FROM foo;
ERROR:  recursive reference to query "foo" must not appear within EXCEPT
LINE 6:        SELECT i+1 FROM foo WHERE i < 5)
                               ^
WITH RECURSIVE foo(i) AS
    (values (1)
    UNION ALL
       (SELECT i+1 FROM foo WHERE i < 10
          INTERSECT
       SELECT i+1 FROM foo WHERE i < 5)
) SELECT * FROM foo;
ERROR:  recursive reference to query "foo" must not appear more than once
LINE 6:        SELECT i+1 FROM foo WHERE i < 5)
                               ^
-- Wrong type induced from non-recursive term
WITH RECURSIVE foo(i) AS
   (SELECT i FROM (VALUES(1),(2)) t(i)
   UNION ALL
   SELECT (i+1)::numeric(10,0) FROM foo WHERE i < 10)
SELECT * FROM foo;
ERROR:  recursive query "foo" column 1 has type integer in non-recursive term but type numeric overall
LINE 2:    (SELECT i FROM (VALUES(1),(2)) t(i)
                   ^
HINT:  Cast the output of the non-recursive term to the correct type.
-- rejects different typmod, too (should we allow this?)
WITH RECURSIVE foo(i) AS
   (SELECT i::numeric(3,0) FROM (VALUES(1),(2)) t(i)
   UNION ALL
   SELECT (i+1)::numeric(10,0) FROM foo WHERE i < 10)
SELECT * FROM foo;
ERROR:  recursive query "foo" column 1 has type numeric(3,0) in non-recursive term but type numeric overall
LINE 2:    (SELECT i::numeric(3,0) FROM (VALUES(1),(2)) t(i)
                   ^
HINT:  Cast the output of the non-recursive term to the correct type.
-- disallow OLD/NEW reference in CTE
CREATE TEMPORARY TABLE x (n integer) DISTRIBUTE BY REPLICATION  ;
CREATE RULE r2 AS ON UPDATE TO x DO INSTEAD
    WITH t AS (SELECT OLD.*) UPDATE y SET a = t.n FROM t;
ERROR:  cannot refer to OLD within WITH query
--
-- test for bug #4902
--
with cte(foo) as ( values(42) ) values((select foo from cte));
 column1 
---------
      42
(1 row)

with cte(foo) as ( select 42 ) select * from ((select foo from cte)) q;
 foo 
-----
  42
(1 row)

-- test CTE referencing an outer-level variable (to see that changed-parameter
-- signaling still works properly after fixing this bug)
select ( with cte(foo) as ( values(f1) )
         select (select foo from cte) )
from int4_tbl order by 1;
     foo     
-------------
 -2147483647
     -123456
           0
      123456
  2147483647
(5 rows)

select ( with cte(foo) as ( values(f1) )
          values((select foo from cte)) )
from int4_tbl order by 1;
   column1   
-------------
 -2147483647
     -123456
           0
      123456
  2147483647
(5 rows)

--
-- test for nested-recursive-WITH bug
--
WITH RECURSIVE t(j) AS (
    WITH RECURSIVE s(i) AS (
        VALUES (1)
        UNION ALL
        SELECT i+1 FROM s WHERE i < 10
    )
    SELECT i FROM s
    UNION ALL
    SELECT j+1 FROM t WHERE j < 10
)
SELECT * FROM t order by 1;
 j  
----
  1
  2
  2
  3
  3
  3
  4
  4
  4
  4
  5
  5
  5
  5
  5
  6
  6
  6
  6
  6
  6
  7
  7
  7
  7
  7
  7
  7
  8
  8
  8
  8
  8
  8
  8
  8
  9
  9
  9
  9
  9
  9
  9
  9
  9
 10
 10
 10
 10
 10
 10
 10
 10
 10
 10
(55 rows)

--
-- test WITH attached to intermediate-level set operation
--
WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM innermost
         UNION SELECT 3)
)
SELECT * FROM outermost;
 x 
---
 1
 2
 3
(3 rows)

WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost  -- fail
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost;
ERROR:  relation "outermost" does not exist
LINE 4:          SELECT * FROM outermost  
                               ^
DETAIL:  There is a WITH item named "outermost", but it cannot be referenced from this part of the query.
HINT:  Use WITH RECURSIVE, or re-order the WITH items to remove forward references.
WITH RECURSIVE outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost;
 x 
---
 1
 2
(2 rows)

WITH RECURSIVE outermost(x) AS (
  WITH innermost as (SELECT 2 FROM outermost) -- fail
    SELECT * FROM innermost
    UNION SELECT * from outermost
)
SELECT * FROM outermost;
ERROR:  recursive reference to query "outermost" must not appear within a subquery
LINE 2:   WITH innermost as (SELECT 2 FROM outermost) 
                                           ^
--
-- This test will fail with the old implementation of PARAM_EXEC parameter
-- assignment, because the "q1" Var passed down to A's targetlist subselect
-- looks exactly like the "A.id" Var passed down to C's subselect, causing
-- the old code to give them the same runtime PARAM_EXEC slot.  But the
-- lifespans of the two parameters overlap, thanks to B also reading A.
--
with
A as ( select q2 as id, (select q1) as x from int8_tbl ),
B as ( select id, row_number() over (partition by id) as r from A ),
C as ( select A.id, array(select B.id from B where B.id = A.id) from A )
select * from C;
        id         |                array                
-------------------+-------------------------------------
               456 | {456}
  4567890123456789 | {4567890123456789,4567890123456789}
               123 | {123}
  4567890123456789 | {4567890123456789,4567890123456789}
 -4567890123456789 | {-4567890123456789}
(5 rows)

--
-- Test CTEs read in non-initialization orders
--
WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION ALL (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;
 id_key | row_type | link 
--------+----------+------
      0 | base     |   17
      1 | true     |   17
      2 | true     |   17
      3 | true     |   17
      4 | true     |   17
      5 | true     |   17
      6 | true     |   17
(7 rows)

WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;
 id_key | row_type | link 
--------+----------+------
      0 | base     |   17
      1 | true     |   17
      2 | true     |   17
      3 | true     |   17
      4 | true     |   17
      5 | true     |   17
      6 | true     |   17
(7 rows)

--
-- test WITH attached to intermediate-level set operation
--
WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM innermost
         UNION SELECT 3)
)
SELECT * FROM outermost;
 x 
---
 1
 2
 3
(3 rows)

WITH outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost  -- fail
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost;
ERROR:  relation "outermost" does not exist
LINE 4:          SELECT * FROM outermost  
                               ^
DETAIL:  There is a WITH item named "outermost", but it cannot be referenced from this part of the query.
HINT:  Use WITH RECURSIVE, or re-order the WITH items to remove forward references.
WITH RECURSIVE outermost(x) AS (
  SELECT 1
  UNION (WITH innermost as (SELECT 2)
         SELECT * FROM outermost
         UNION SELECT * FROM innermost)
)
SELECT * FROM outermost;
 x 
---
 1
 2
(2 rows)

WITH RECURSIVE outermost(x) AS (
  WITH innermost as (SELECT 2 FROM outermost) -- fail
    SELECT * FROM innermost
    UNION SELECT * from outermost
)
SELECT * FROM outermost;
ERROR:  recursive reference to query "outermost" must not appear within a subquery
LINE 2:   WITH innermost as (SELECT 2 FROM outermost) 
                                           ^
--
-- Test CTEs read in non-initialization orders
--
WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION ALL (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;
 id_key | row_type | link 
--------+----------+------
      0 | base     |   17
      1 | true     |   17
      2 | true     |   17
      3 | true     |   17
      4 | true     |   17
      5 | true     |   17
      6 | true     |   17
(7 rows)

WITH RECURSIVE
  tab(id_key,link) AS (VALUES (1,17), (2,17), (3,17), (4,17), (6,17), (5,17)),
  iter (id_key, row_type, link) AS (
      SELECT 0, 'base', 17
    UNION (
      WITH remaining(id_key, row_type, link, min) AS (
        SELECT tab.id_key, 'true'::text, iter.link, MIN(tab.id_key) OVER ()
        FROM tab INNER JOIN iter USING (link)
        WHERE tab.id_key > iter.id_key
      ),
      first_remaining AS (
        SELECT id_key, row_type, link
        FROM remaining
        WHERE id_key=min
      ),
      effect AS (
        SELECT tab.id_key, 'new'::text, tab.link
        FROM first_remaining e INNER JOIN tab ON e.id_key=tab.id_key
        WHERE e.row_type = 'false'
      )
      SELECT * FROM first_remaining
      UNION ALL SELECT * FROM effect
    )
  )
SELECT * FROM iter;
 id_key | row_type | link 
--------+----------+------
      0 | base     |   17
      1 | true     |   17
      2 | true     |   17
      3 | true     |   17
      4 | true     |   17
      5 | true     |   17
      6 | true     |   17
(7 rows)

--
-- Data-modifying statements in WITH
--
-- INSERT ... RETURNING
WITH t AS (
    INSERT INTO y
    VALUES
        (11),
        (12),
        (13),
        (14),
        (15),
        (16),
        (17),
        (18),
        (19),
        (20)
    RETURNING *
)
SELECT * FROM t;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- UPDATE ... RETURNING
WITH t AS (
    UPDATE y
    SET a=a+1
    RETURNING *
)
SELECT * FROM t;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- DELETE ... RETURNING
WITH t AS (
    DELETE FROM y
    WHERE a <= 10
    RETURNING *
)
SELECT * FROM t;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- forward reference
WITH RECURSIVE t AS (
	INSERT INTO y
		SELECT a+5 FROM t2 WHERE a > 5
	RETURNING *
), t2 AS (
	UPDATE y SET a=a-11 RETURNING *
)
SELECT * FROM t
UNION ALL
SELECT * FROM t2;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- unconditional DO INSTEAD rule
CREATE RULE y_rule AS ON DELETE TO y DO INSTEAD
  INSERT INTO y VALUES(42) RETURNING *;
WITH t AS (
	DELETE FROM y RETURNING *
)
SELECT * FROM t;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

DROP RULE y_rule ON y;
-- check merging of outer CTE with CTE in a rule action
CREATE TEMP TABLE bug6051 AS
  select i from generate_series(1,3) as t(i);
SELECT * FROM bug6051 ORDER BY 1;
 i 
---
 1
 2
 3
(3 rows)

WITH t1 AS ( DELETE FROM bug6051 RETURNING * )
INSERT INTO bug6051 SELECT * FROM t1;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM bug6051 ORDER BY 1;
 i 
---
 1
 2
 3
(3 rows)

CREATE TEMP TABLE bug6051_2 (i int) DISTRIBUTE BY REPLICATION;
CREATE RULE bug6051_ins AS ON INSERT TO bug6051 DO INSTEAD
 INSERT INTO bug6051_2
 SELECT NEW.i;
WITH t1 AS ( DELETE FROM bug6051 RETURNING * )
INSERT INTO bug6051 SELECT * FROM t1;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM bug6051 ORDER BY 1;
 i 
---
 1
 2
 3
(3 rows)

SELECT * FROM bug6051_2;
 i 
---
(0 rows)

-- a truly recursive CTE in the same list
WITH RECURSIVE t(a) AS (
	SELECT 0
		UNION ALL
	SELECT a+1 FROM t WHERE a+1 < 5
), t2 as (
	INSERT INTO y
		SELECT * FROM t RETURNING *
)
SELECT * FROM t2 JOIN y USING (a) ORDER BY a;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- data-modifying WITH in a modifying statement
WITH t AS (
    DELETE FROM y
    WHERE a <= 10
    RETURNING *
)
INSERT INTO y SELECT -a FROM t RETURNING *;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- check that WITH query is run to completion even if outer query isn't
WITH t AS (
    UPDATE y SET a = a * 100 RETURNING *
)
SELECT * FROM t LIMIT 10;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

-- check that run to completion happens in proper ordering
TRUNCATE TABLE y;
INSERT INTO y SELECT generate_series(1, 3);
CREATE TEMPORARY TABLE yy (a INTEGER) DISTRIBUTE BY REPLICATION;
WITH RECURSIVE t1 AS (
  INSERT INTO y SELECT * FROM y RETURNING *
), t2 AS (
  INSERT INTO yy SELECT * FROM t1 RETURNING *
)
SELECT 1;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a 
---
 1
 2
 3
(3 rows)

SELECT * FROM yy;
 a 
---
(0 rows)

WITH RECURSIVE t1 AS (
  INSERT INTO yy SELECT * FROM t2 RETURNING *
), t2 AS (
  INSERT INTO y SELECT * FROM y RETURNING *
)
SELECT 1;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a 
---
 1
 2
 3
(3 rows)

SELECT * FROM yy order by 1;
 a 
---
(0 rows)

-- triggers
TRUNCATE TABLE y;
INSERT INTO y SELECT generate_series(1, 10);
CREATE FUNCTION y_trigger() RETURNS trigger AS $$
begin
  raise notice 'y_trigger: a = %', new.a;
  return new;
end;
$$ LANGUAGE plpgsql;
CREATE TRIGGER y_trig BEFORE INSERT ON y FOR EACH ROW
    EXECUTE PROCEDURE y_trigger();
ERROR:  Postgres-XL does not support TRIGGER yet
DETAIL:  The feature is not currently supported
WITH t AS (
    INSERT INTO y
    VALUES
        (21),
        (22),
        (23)
    RETURNING *
)
SELECT * FROM t;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

DROP TRIGGER y_trig ON y;
ERROR:  trigger "y_trig" for table "y" does not exist
CREATE TRIGGER y_trig AFTER INSERT ON y FOR EACH ROW
    EXECUTE PROCEDURE y_trigger();
ERROR:  Postgres-XL does not support TRIGGER yet
DETAIL:  The feature is not currently supported
WITH t AS (
    INSERT INTO y
    VALUES
        (31),
        (32),
        (33)
    RETURNING *
)
SELECT * FROM t LIMIT 1;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

DROP TRIGGER y_trig ON y;
ERROR:  trigger "y_trig" for table "y" does not exist
CREATE OR REPLACE FUNCTION y_trigger() RETURNS trigger AS $$
begin
  raise notice 'y_trigger';
  return null;
end;
$$ LANGUAGE plpgsql;
CREATE TRIGGER y_trig AFTER INSERT ON y FOR EACH STATEMENT
    EXECUTE PROCEDURE y_trigger();
ERROR:  Postgres-XL does not support TRIGGER yet
DETAIL:  The feature is not currently supported
WITH t AS (
    INSERT INTO y
    VALUES
        (41),
        (42),
        (43)
    RETURNING *
)
SELECT * FROM t;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM y order by 1;
 a  
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)

DROP TRIGGER y_trig ON y;
ERROR:  trigger "y_trig" for table "y" does not exist
DROP FUNCTION y_trigger();
-- WITH attached to inherited UPDATE or DELETE
CREATE TEMP TABLE parent ( id int, val text ) DISTRIBUTE BY REPLICATION;
CREATE TEMP TABLE child1 ( ) INHERITS ( parent ) DISTRIBUTE BY REPLICATION;
CREATE TEMP TABLE child2 ( ) INHERITS ( parent ) DISTRIBUTE BY REPLICATION;
INSERT INTO parent VALUES ( 1, 'p1' );
INSERT INTO child1 VALUES ( 11, 'c11' ),( 12, 'c12' );
INSERT INTO child2 VALUES ( 23, 'c21' ),( 24, 'c22' );
WITH rcte AS ( SELECT sum(id) AS totalid FROM parent )
UPDATE parent SET id = id + totalid FROM rcte;
SELECT * FROM parent ORDER BY id;
 id | val 
----+-----
 72 | p1
 82 | c11
 83 | c12
 94 | c21
 95 | c22
(5 rows)

WITH wcte AS ( INSERT INTO child1 VALUES ( 42, 'new' ) RETURNING id AS newid )
UPDATE parent SET id = id + newid FROM wcte;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM parent ORDER BY id;
 id | val 
----+-----
 72 | p1
 82 | c11
 83 | c12
 94 | c21
 95 | c22
(5 rows)

WITH rcte AS ( SELECT max(id) AS maxid FROM parent )
DELETE FROM parent USING rcte WHERE id = maxid;
SELECT * FROM parent ORDER BY id;
 id | val 
----+-----
 72 | p1
 82 | c11
 83 | c12
 94 | c21
(4 rows)

WITH wcte AS ( INSERT INTO child2 VALUES ( 42, 'new2' ) RETURNING id AS newid )
DELETE FROM parent USING wcte WHERE id = newid;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
SELECT * FROM parent ORDER BY id;
 id | val 
----+-----
 72 | p1
 82 | c11
 83 | c12
 94 | c21
(4 rows)

-- check EXPLAIN VERBOSE for a wCTE with RETURNING
EXPLAIN (VERBOSE, COSTS OFF, NODES OFF, NUM_NODES OFF)
WITH wcte AS ( INSERT INTO int8_tbl VALUES ( 42, 47 ) RETURNING q2 )
DELETE FROM a USING wcte WHERE aa = q2;
ERROR:  INSERT/UPDATE/DELETE is not supported in subquery
-- error cases
-- data-modifying WITH tries to use its own output
WITH RECURSIVE t AS (
	INSERT INTO y
		SELECT * FROM t
)
VALUES(FALSE);
ERROR:  recursive query "t" must not contain data-modifying statements
LINE 1: WITH RECURSIVE t AS (
                       ^
-- no RETURNING in a referenced data-modifying WITH
WITH t AS (
	INSERT INTO y VALUES(0)
)
SELECT * FROM t;
ERROR:  WITH query "t" does not have a RETURNING clause
LINE 4: SELECT * FROM t;
                      ^
-- data-modifying WITH allowed only at the top level
SELECT * FROM (
	WITH t AS (UPDATE y SET a=a+1 RETURNING *)
	SELECT * FROM t
) ss;
ERROR:  WITH clause containing a data-modifying statement must be at the top level
LINE 2:  WITH t AS (UPDATE y SET a=a+1 RETURNING *)
              ^
-- most variants of rules aren't allowed
CREATE RULE y_rule AS ON INSERT TO y WHERE a=0 DO INSTEAD DELETE FROM y;
WITH t AS (
	INSERT INTO y VALUES(0)
)
VALUES(FALSE);
ERROR:  conditional DO INSTEAD rules are not supported for data-modifying statements in WITH
DROP RULE y_rule ON y;
