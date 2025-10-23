/* a decision tree */
DROP TABLE IF EXISTS tree;

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


-- search with unpredictable order of discovery
WITH RECURSIVE search_tree(vFrom, vTo) AS (
    SELECT t.vFrom, t.vTo
    FROM tree t
  UNION ALL
    SELECT st.vFrom, t.vTo
    FROM search_tree st, tree t
    WHERE t.vFrom = st.vTo
)
SELECT * FROM search_tree;

-- breadth-first search
WITH RECURSIVE search_tree(vFrom, vTo, depth) AS (
    SELECT t.vFrom, t.vTo, 1
    FROM tree t
  UNION ALL
    SELECT st.vFrom, t.vTo, depth + 1
    FROM search_tree st, tree t
    WHERE t.vFrom = st.vTo
)
SELECT * FROM search_tree ORDER BY depth;

-- depth-first search
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
DROP TABLE IF EXISTS graph;

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
