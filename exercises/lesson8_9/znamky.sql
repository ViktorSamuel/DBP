DROP TABLE IF EXISTS znamky;
DROP TABLE IF EXISTS predmety;
DROP TABLE IF EXISTS triedy;
DROP TABLE IF EXISTS ucitelia;
DROP TABLE IF EXISTS studenti;

CREATE TABLE studenti (
    id SERIAL PRIMARY KEY,
    meno VARCHAR(50) NOT NULL,
    priezvisko VARCHAR(50) NOT NULL,
    pohlavie VARCHAR(10) CHECK (pohlavie IN ('M', 'F')),
    trieda VARCHAR(10) NOT NULL,
    datum_narodenia DATE CHECK (datum_narodenia BETWEEN '1900-01-01' AND '2023-12-31'),
    prihlasovacie_meno VARCHAR(50),
    moredata JSON
);

CREATE TABLE ucitelia (
    id SERIAL PRIMARY KEY,
    meno VARCHAR(50) NOT NULL,
    priezvisko VARCHAR(50) NOT NULL,
    pohlavie VARCHAR(10) CHECK (pohlavie IN ('M', 'F')),
    prihlasovacie_meno VARCHAR(50),
    UNIQUE (prihlasovacie_meno)
);

CREATE TABLE predmety (
    id SERIAL PRIMARY KEY,
    nazov VARCHAR(50) NOT NULL,
    skratka VARCHAR(10) NOT NULL,
    UNIQUE (nazov)
);

CREATE TABLE znamky (
    id SERIAL PRIMARY KEY,
    znamka VARCHAR(5),
    student_id INT,
    ucitel_id INT,
    predmet_id INT,
    cas_zadania TIMESTAMP,
    typ_zadania VARCHAR(50),
    vaha INTEGER,
    FOREIGN KEY (student_id) REFERENCES studenti(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ucitel_id) REFERENCES ucitelia(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (predmet_id) REFERENCES predmety(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE triedy (
    id SERIAL PRIMARY KEY,
    trieda VARCHAR(10) NOT NULL,
    predmet_id INT,
    FOREIGN KEY (predmet_id) REFERENCES predmety(id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (trieda, predmet_id)
);

INSERT INTO studenti (meno, priezvisko, pohlavie, trieda, datum_narodenia) VALUES 
    ('Janko', 'Hrasko', 'M', '3C', '2000-01-01'),
    ('Ferko', 'Mrkvicka', 'M', '2B', '2001-01-01'),
    ('Anka', 'Hraskovie', 'M', '1A', '2002-01-01'),
    ('Martinko', 'Klingacik', 'M', '1A', '2002-05-05');

INSERT INTO ucitelia (meno, priezvisko, pohlavie) VALUES 
   ('Ucitel1', 'PUcitel1', 'M'),
   ('Ucitel2', 'PUcitel2', 'Z');


INSERT INTO znamky (znamka, student_id, ucitel_id, predmet_id, cas_zadania, typ_zadania, vaha) VALUES
    ('1', 1, 1, 1, '2019-01-01', 'test', 1),
    ('2', 1, 2, 1, '2019-01-02', 'du', 1),
    ('3', 1, 2, 2, '2019-01-03', 'test', 5),
    ('4', 2, 2, 2, '2019-01-04', 'du', 1),
    ('5', 1, 1, 1, '2019-01-05', 'test', 1);

INSERT INTO predmety (nazov, skratka) VALUES
    ('Matematika', 'MAT'),
    ('Fyzika', 'FYZ'),
    ('Informatika', 'INF');

INSERT INTO triedy (trieda, predmet_id)
VALUES
    ('1A', 1),
    ('2B', 2),
    ('3C', 3);


ALTER TABLE studenti
ADD COLUMN prihlasovacie_meno VARCHAR(50);

ALTER TABLE ucitelia
ADD COLUMN prihlasovacie_meno VARCHAR(50);

CREATE INDEX idx_studenti_prihlasovacie_meno ON studenti (LOWER(prihlasovacie_meno));
CREATE INDEX idx_ucitelia_prihlasovacie_meno ON ucitelia (LOWER(prihlasovacie_meno));

-- Presun známok z MAT pre študentov z 1.A od jedného učiteľa na iného
UUPDATE znamky
SET ucitel_id = novy_ucitel_id
FROM studenti
JOIN triedy ON studenti.trieda = triedy.trieda
JOIN predmety ON predmety.id = triedy.predmet_id
WHERE predmety.skratka = 'MAT'
    AND studenti.trieda = '1A'
    AND znamky.ucitel_id = stary_ucitel_id;

-- Vymazanie učiteľa zo školy (záznamy o jeho známkach zostanú zachované)
DELETE FROM ucitelia WHERE id = odchadzajuci_ucitel_id;

UPDATE znamky SET ucitel_id = 2 WHERE ucitel_id = 1;
DELETE FROM ucitelia WHERE id = 1;

-- VIEW
CREATE VIEW priemer_znamok_pohlad AS
SELECT
    s.id AS student_id,
    s.meno AS student_meno,
    s.priezvisko AS student_priezvisko,
    p.id AS predmet_id,
    p.nazov AS predmet_nazov,
    AVG(z.znamka::NUMERIC) AS priemer_znamok
FROM studenti s
JOIN triedy t ON s.trieda = t.trieda
JOIN predmety p ON t.predmet_id = p.id
LEFT JOIN znamky z ON s.id = z.student_id AND p.id = z.predmet_id
GROUP BY s.id, s.meno, s.priezvisko, p.id, p.nazov
ORDER BY s.meno ASC, p.nazov ASC, priemer_znamok ASC;


UPDATE znamky SET vaha = 2*vaha WHERE vaha LIKE '5%';

SELECT studenti.meno, studenti.priezvisko, predmety.nazov, COUNT(znamky.znamka) AS pocet_znamok, array_agg(znamky.znamka) AS znamky
FROM studenti JOIN znamky ON studenti.id = znamky.student_id JOIN predmety ON znamky.predmet_id = predmety.id
GROUP BY studenti.meno, studenti.priezvisko, predmety.nazov;

SELECT studenti.meno, studenti.priezvisko, array_agg(predmety.nazov) AS predmety_bez_znamky
FROM studenti JOIN predmety ON studenti.trieda = predmety.trieda LEFT JOIN znamky ON studenti.id = znamky.student_id AND predmety.id = znamky.predmet_id
WHERE znamky.id IS NULL
GROUP BY studenti.meno, studenti.priezvisko;

SELECT predmety.nazov AS nazov_predmetu, COUNT(*) AS celkovy_pocet_znamok, AVG(znamky1.pocet_znamok) AS priemerny_pocet_znamok_na_ziaka
FROM predmety LEFT JOIN (
    SELECT predmet_id, student_id, COUNT(id) AS pocet_znamok
    FROM znamky1
    GROUP BY predmet_id, student_id
) AS znamky1 ON predmety.id = znamky1.predmet_id
GROUP BY predmety.id, predmety.nazov
ORDER BY celkovy_pocet_znamok DESC
LIMIT 10;

SELECT ucitelia.meno, ucitelia.priezvisko, AVG(znamky.znamka AS INTEGER) AS priemer_znamok
FROM ucitelia JOIN znamky ON ucitelia.id = znamky.ucitel_id
WHERE znamky.znamka ~ '^[0-9]*$'
GROUP BY ucitelia.meno, ucitelia.priezvisko;

ALTER TABLE studenti
ADD COLUMN moredata JSON;

UPDATE studenti
SET moredata = '{"zrakove_postihnutie": true}'
WHERE id = 1;

SELECT id, meno, priezvisko
FROM studenti
WHERE moredata->>'zrakove_postihnutie' = 'true';