-- Sample database for the exercises. Load with: psql -f library.sql
--
-- The script runs in a single transaction. If DROP TABLE fails in PostgreSQL because you created
-- views on these tables, the database stays unchanged. In that case drop those views (DROP VIEW ...)
-- or add CASCADE to the DROP TABLE statements below (this drops the dependent views too) and rerun.
-- Add your own INSERT statements above the COMMIT line at the end of this file.

BEGIN;

DROP TABLE IF EXISTS borrowing;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS reader;

CREATE TABLE reader (
	id_r INTEGER PRIMARY KEY,
	name TEXT NOT NULL,
	registration DATE NOT NULL
);

CREATE TABLE book (
	id_b INTEGER PRIMARY KEY,
	title TEXT NOT NULL,
	author TEXT NOT NULL
);

CREATE TABLE borrowing (
	id_b INTEGER NOT NULL,
	id_r INTEGER NOT NULL,
	borrowingDate DATE NOT NULL,
	returnDate DATE
);

COMMIT;
