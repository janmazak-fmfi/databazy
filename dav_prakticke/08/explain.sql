DROP TABLE IF EXISTS ab;
CREATE TABLE ab (
        a integer,
        b integer NOT NULL
);

DROP TABLE IF EXISTS bc;
CREATE TABLE bc (
        b integer NOT NULL,
        c integer NOT NULL,
	data text
);

DROP TABLE IF EXISTS cd;
CREATE TABLE cd (
        c integer,
        d integer
);

INSERT INTO ab SELECT x.id, x.id FROM generate_series(1, 1000) as x(id);

INSERT INTO bc SELECT x.id, x.id + 1, md5(random()::text) FROM generate_series(1, 1000) as x(id);

INSERT INTO cd VALUES (1, 21), (2, 22), (11, 31);
