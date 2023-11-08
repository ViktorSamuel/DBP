BEGIN;
	
drop table if exists cities;
drop table if exists road;
CREATE TABLE cities (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE road (
    id1 INTEGER,
    id2 INTEGER,
    d FLOAT
);

INSERT INTO cities VALUES (1, 'Roma');
INSERT INTO cities VALUES (2, 'Berlin');
INSERT INTO cities VALUES (3, 'Wien');
INSERT INTO cities VALUES (4, 'Bratislava');
INSERT INTO cities VALUES (5, 'Praha');
INSERT INTO cities VALUES (6, 'Rio de Janeiro');
INSERT INTO cities VALUES (7, 'Caracas');
INSERT INTO cities VALUES (8, 'Los Angeles');
INSERT INTO cities VALUES (9, 'Quebec');
INSERT INTO cities VALUES (10, 'Johannesburg');

INSERT INTO road VALUES (1, 3, 765.56);
INSERT INTO road VALUES (2, 5, 279.76);
INSERT INTO road VALUES (3, 5, 252.56);
INSERT INTO road VALUES (3, 4, 54.88);
INSERT INTO road VALUES (6, 7, 4525.34);
INSERT INTO road VALUES (7, 8, 5818.52);
INSERT INTO road VALUES (8, 9, 4155.44);

INSERT INTO road (SELECT id2, id1, d FROM road);

COMMIT;

