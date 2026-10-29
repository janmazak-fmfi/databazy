-- Examples of WITH and WITH RECURSIVE queries for the exercises in 07.md.
-- Adapted from the PostgreSQL regression tests (src/test/regress/sql/with.sql);
-- the Postgres-XL specific parts (DISTRIBUTE BY) have been removed.
-- Run the whole file with: psql -f recursion_examples.sql
-- Each example is independent; the tables are temporary, so nothing is left in your database.
-- Replacing UNION with UNION ALL in the termination example would make it run forever.
--
-- How to read a recursive query:
--   WITH RECURSIVE name(columns) AS (
--       <non-recursive term>      -- starting rows, computed once
--   UNION ALL                     -- or UNION, which also removes duplicates
--       <recursive term>          -- refers to name; sees only the rows added in the previous step
--   )
--   SELECT ... FROM name ...;     -- the result is the union of all steps


-- ---------------------------------------------------------------------------
-- 1. Non-recursive WITH: a named subquery used like a table
-- ---------------------------------------------------------------------------

WITH q1(x, y) AS (SELECT 1, 2)
SELECT * FROM q1, q1 AS q2;


-- ---------------------------------------------------------------------------
-- 2. Recursive WITH: a non-recursive term (VALUES (1)) and a recursive term
--    that refers to the query itself
-- ---------------------------------------------------------------------------

-- sum of 1..100
WITH RECURSIVE t(n) AS (
    VALUES (1)
UNION ALL
    SELECT n + 1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;

-- the same numbers as rows, ordered
WITH RECURSIVE t(n) AS (
    SELECT (VALUES (1))
UNION ALL
    SELECT n + 1 FROM t WHERE n < 5
)
SELECT * FROM t ORDER BY n;


-- ---------------------------------------------------------------------------
-- 3. Termination: UNION ALL keeps every row, UNION removes duplicates
--    The query below with UNION ALL would produce 1, 9, 1, 9, ... forever.
--    With UNION the repeated rows are discarded and the recursion stops.
-- ---------------------------------------------------------------------------

WITH RECURSIVE t(n) AS (
    SELECT 1
UNION
    SELECT 10 - n FROM t
)
SELECT * FROM t ORDER BY n;

-- a recursion without an end: the outer query reads only the rows it needs
WITH RECURSIVE naturals(n) AS (
    VALUES (1)
UNION ALL
    SELECT n + 1 FROM naturals
)
SELECT * FROM naturals LIMIT 10;


-- ---------------------------------------------------------------------------
-- 4. A tree stored as a table: departments and their parents
--
--  ROOT
--  +-- A
--  |   +-- B
--  |       +-- C
--  |       +-- D
--  |           +-- F
--  +-- E
--      +-- G
-- ---------------------------------------------------------------------------

CREATE TEMP TABLE example_department (
    id INTEGER PRIMARY KEY,         -- department ID
    parent_department INTEGER,      -- NULL for the root
    name TEXT                       -- department name
);

INSERT INTO example_department VALUES (0, NULL, 'ROOT');
INSERT INTO example_department VALUES (1, 0, 'A');
INSERT INTO example_department VALUES (2, 1, 'B');
INSERT INTO example_department VALUES (3, 2, 'C');
INSERT INTO example_department VALUES (4, 2, 'D');
INSERT INTO example_department VALUES (5, 0, 'E');
INSERT INTO example_department VALUES (6, 4, 'F');
INSERT INTO example_department VALUES (7, 5, 'G');

-- all departments under 'A' (A, B, C, D and F)
WITH RECURSIVE subdepartment AS (
    -- non-recursive term: the starting node
    SELECT name AS root_name, * FROM example_department WHERE name = 'A'
    UNION ALL
    -- recursive term: children of the nodes found so far
    SELECT sd.root_name, d.* FROM example_department AS d, subdepartment AS sd
    WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY name;

-- the same, with the level (distance from A) computed in the recursion
WITH RECURSIVE subdepartment(level, id, parent_department, name) AS (
    SELECT 0, * FROM example_department WHERE name = 'A'
    UNION ALL
    SELECT sd.level + 1, d.* FROM example_department AS d, subdepartment AS sd
    WHERE d.parent_department = sd.id
)
SELECT * FROM subdepartment ORDER BY level, name;


-- ---------------------------------------------------------------------------
-- 5. Keeping the path in an array while walking down a tree
--
--  1 -+-> 2 -+-> 4 -+-> 9 -+-> 14
--     |      |      |
--     |      |      +-> 10
--     |      +-> 5
--     |      +-> 6
--     +-> 3 -+-> 7 -+-> 11 -+-> 15
--            |      |       +-> 16
--            |      +-> 12
--            |      +-> 13
--            +-> 8
-- ---------------------------------------------------------------------------

CREATE TEMP TABLE example_tree (
    id INTEGER PRIMARY KEY,
    parent_id INTEGER
);

INSERT INTO example_tree VALUES (1, NULL), (2, 1), (3, 1), (4, 2), (5, 2), (6, 2),
    (7, 3), (8, 3), (9, 4), (10, 4), (11, 7), (12, 7), (13, 7), (14, 9),
    (15, 11), (16, 11);

-- the path from the root to each node
WITH RECURSIVE paths(id, path) AS (
    SELECT id, ARRAY[id] FROM example_tree WHERE parent_id IS NULL
UNION ALL
    SELECT example_tree.id, paths.path || example_tree.id
    FROM example_tree JOIN paths ON example_tree.parent_id = paths.id
)
SELECT * FROM paths ORDER BY path;

-- only the paths that end in a leaf (a node without children)
WITH RECURSIVE paths(id, path) AS (
    SELECT id, ARRAY[id] FROM example_tree WHERE parent_id IS NULL
UNION ALL
    SELECT example_tree.id, paths.path || example_tree.id
    FROM example_tree JOIN paths ON example_tree.parent_id = paths.id
)
SELECT paths.*
FROM paths
WHERE NOT EXISTS (SELECT 1 FROM example_tree AS child WHERE child.parent_id = paths.id)
ORDER BY path;

-- the number of nodes in each branch below the root (path[2] is the child of the root)
WITH RECURSIVE paths(id, path) AS (
    SELECT id, ARRAY[id] FROM example_tree WHERE parent_id IS NULL
UNION ALL
    SELECT example_tree.id, paths.path || example_tree.id
    FROM example_tree JOIN paths ON example_tree.parent_id = paths.id
)
SELECT path[2] AS branch, count(*) AS nodes
FROM paths
WHERE cardinality(path) > 1
GROUP BY path[2]
ORDER BY branch;

-- stopping the recursion by a condition: only the first three levels (the root has depth 0)
WITH RECURSIVE nodes(id, depth) AS (
    SELECT id, 0 FROM example_tree WHERE parent_id IS NULL
UNION ALL
    SELECT example_tree.id, nodes.depth + 1
    FROM example_tree JOIN nodes ON example_tree.parent_id = nodes.id
    WHERE nodes.depth < 2
)
SELECT * FROM nodes ORDER BY depth, id;


-- ---------------------------------------------------------------------------
-- 6. Cycles in a graph: remember the path and stop when a node repeats
--
--  1 -> 2, 1 -> 3, 2 -> 3, 1 -> 4, 4 -> 5, 5 -> 1   (5 -> 1 closes a cycle)
-- ---------------------------------------------------------------------------

CREATE TEMP TABLE example_graph (
    f INTEGER,
    t INTEGER
);

INSERT INTO example_graph VALUES (1, 2), (1, 3), (2, 3), (1, 4), (4, 5), (5, 1);

-- all walks that start with an edge of the graph; a walk is extended only while
-- its last edge did not close a cycle (rows with cycle = true are the closing ones)
WITH RECURSIVE search_graph(f, t, path, cycle) AS (
    SELECT g.f, g.t, ARRAY[g.f, g.t], false
    FROM example_graph g
UNION ALL
    SELECT g.f, g.t, sg.path || g.t, g.t = ANY(sg.path)
    FROM search_graph sg JOIN example_graph g ON g.f = sg.t
    WHERE NOT sg.cycle
)
SELECT * FROM search_graph ORDER BY cycle, path;
