-- Sample database for the exercises. Load with: psql -f graph_search.sql
--
-- The script runs in a single transaction. If DROP TABLE fails in PostgreSQL because you created
-- views on these tables, the database stays unchanged. In that case drop those views (DROP VIEW ...)
-- or add CASCADE to the DROP TABLE statements below (this drops the dependent views too) and rerun.

BEGIN;

/* a decision tree */
DROP TABLE IF EXISTS tree;
DROP TABLE IF EXISTS graph;

CREATE TABLE tree (
	vFrom integer NOT NULL,
	vTo integer NOT NULL,
    p real NOT NULL,
        CHECK(0 <= p AND p <= 1)
);

INSERT INTO tree VALUES (1, 2, 0.6);
INSERT INTO tree VALUES (1, 3, 0.4);
INSERT INTO tree VALUES (2, 4, 0.2);
INSERT INTO tree VALUES (2, 5, 0.8);
INSERT INTO tree VALUES (5, 6, 1.0);


-- These queries start from every edge and extend paths from all starting vertices.
-- The breadth-first and depth-first variants order the output; ORDER BY does not
-- control the order in which PostgreSQL evaluates the recursion.

-- paths with unspecified output order
WITH RECURSIVE search_tree(vFrom, vTo) AS (
    SELECT t.vFrom, t.vTo
    FROM tree t
  UNION ALL
    SELECT st.vFrom, t.vTo
    FROM search_tree st, tree t
    WHERE t.vFrom = st.vTo
)
SELECT * FROM search_tree;

-- breadth-first output order (by path length, across all starting vertices)
WITH RECURSIVE search_tree(vFrom, vTo, depth) AS (
    SELECT t.vFrom, t.vTo, 1
    FROM tree t
  UNION ALL
    SELECT st.vFrom, t.vTo, depth + 1
    FROM search_tree st, tree t
    WHERE t.vFrom = st.vTo
)
SELECT * FROM search_tree ORDER BY depth;

-- depth-first output order (by path, grouped by starting vertex)
WITH RECURSIVE search_tree(vFrom, vTo, path) AS (
    SELECT t.vFrom, t.vTo, ARRAY[t.vFrom, t.vTo]
    FROM tree t
  UNION ALL
    SELECT st.vFrom, t.vTo, path || t.vTo
    FROM search_tree st, tree t
    WHERE t.vFrom = st.vTo
)
SELECT * FROM search_tree ORDER BY path;

/* an oriented graph with a cycle */
CREATE TABLE graph (
	vFrom integer NOT NULL,
	vTo integer NOT NULL
);

INSERT INTO graph SELECT vFrom, vTo FROM tree;
INSERT INTO graph VALUES (5, 3);
INSERT INTO graph VALUES (3, 1); -- two oppositely oriented edges between 1 and 3


-- cycle detection
WITH RECURSIVE
    search_graph(vFrom, vTo, depth, path, is_cycle)
AS (
    SELECT g.vFrom, g.vTo, 1,
        ARRAY[g.vFrom, g.vTo], false
    FROM graph g
  UNION ALL
    SELECT sg.vFrom, g.vTo, sg.depth + 1,
        path || g.vTo, g.vTo = ANY(path)
    FROM search_graph sg, graph g
    WHERE g.vFrom = sg.vTo AND NOT sg.is_cycle
)
SELECT * FROM search_graph
-- WHERE vFrom = 1
ORDER BY is_cycle, path;

COMMIT;
