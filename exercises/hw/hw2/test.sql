-- DROP TABLE statements
DROP TABLE IF EXISTS odpoved;
DROP TABLE IF EXISTS vysledok;
DROP TABLE IF EXISTS pridelenie;
DROP TABLE IF EXISTS otazka_test;
DROP TABLE IF EXISTS test;
DROP TABLE IF EXISTS otazka;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS ucitel;

-- CREATE TABLE statements

CREATE TABLE ucitel (
    ucitel_id SERIAL PRIMARY KEY,
    meno VARCHAR(255) NOT NULL,
    priezvisko VARCHAR(255) NOT NULL
);

CREATE TABLE student (
    student_id SERIAL PRIMARY KEY,
    meno VARCHAR(255) NOT NULL,
    priezvisko VARCHAR(255) NOT NULL
);

CREATE TABLE otazka (
    otazka_id SERIAL PRIMARY KEY,
    text_otazky TEXT NOT NULL,
    spravna_odpoved CHAR(1) NOT NULL CHECK(spravna_odpoved IN ('A', 'B', 'C', 'D')),
    nespravne_odpovedi_1 CHAR(1) NOT NULL CHECK(nespravne_odpovedi_1 IN ('A', 'B', 'C', 'D')),
    nespravne_odpovedi_2 CHAR(1) NOT NULL CHECK(nespravne_odpovedi_2 IN ('A', 'B', 'C', 'D')),
    nespravne_odpovedi_3 CHAR(1) NOT NULL CHECK(nespravne_odpovedi_3 IN ('A', 'B', 'C', 'D'))
);

CREATE TABLE test (
    test_id SERIAL PRIMARY KEY,
    nazov_testu VARCHAR(255) NOT NULL,
    autor_id INT,
    FOREIGN KEY (autor_id) REFERENCES ucitel(ucitel_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE otazka_test (
    otazka_test_id SERIAL PRIMARY KEY,
    test_id INT,
    otazka_id INT,
    FOREIGN KEY (test_id) REFERENCES test(test_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (otazka_id) REFERENCES otazka(otazka_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE pridelenie (
    pridelenie_id SERIAL PRIMARY KEY,
    ucitel_id INT,
    student_id INT,
    test_id INT,
    cas_pridelenia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ucitel_id) REFERENCES ucitel(ucitel_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (test_id) REFERENCES test(test_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE vysledok (
    vysledok_id SERIAL PRIMARY KEY,
    pridelenie_id INT,
    cas_vypracovania TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    skore_percenta DECIMAL(5, 2) NOT NULL,
    FOREIGN KEY (pridelenie_id) REFERENCES pridelenie(pridelenie_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE odpoved (
    odpoved_id SERIAL PRIMARY KEY,
    vysledok_id INT,
    otazka_id INT,
    zvolena_odpoved VARCHAR(1) NOT NULL,
    FOREIGN KEY (vysledok_id) REFERENCES vysledok(vysledok_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (otazka_id) REFERENCES otazka(otazka_id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Fill tables with data
-- Učitelia
INSERT INTO ucitel (meno, priezvisko) VALUES
('Peter', 'Novák'),
('Anna', 'Kováčová'),
('Marek', 'Šimko');

-- Študenti
INSERT INTO student (meno, priezvisko) VALUES
('Jana', 'Hrušková'),
('Michal', 'Kováč'),
('Eva', 'Nováková');

-- Otázky
INSERT INTO otazka (text_otazky, spravna_odpoved, nespravne_odpovedi_1, nespravne_odpovedi_2, nespravne_odpovedi_3) VALUES
('Čo je hlavné mesto Slovenska?', 'B', 'A', 'C', 'D'),
('Aký je symbol vodíka v periodickom systéme prvkov?', 'A', 'B', 'C', 'D'),
('Koľko dní má február počas priestupného roka?', 'C', 'A', 'B', 'D');

-- Testy
INSERT INTO test (nazov_testu, autor_id) VALUES
('Všeobecný test', 1),
('Chémia 1', 2),
('Geografia 101', 3);

-- Otázky v testoch
INSERT INTO otazka_test (test_id, otazka_id) VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 1),
(3, 3);

-- Pridelenie testov študentom
INSERT INTO pridelenie (ucitel_id, student_id, test_id, cas_pridelenia) VALUES
(1, 1, 1, CURRENT_TIMESTAMP),
(2, 2, 2, CURRENT_TIMESTAMP),
(3, 3, 3, CURRENT_TIMESTAMP);

-- Výsledky študentov
INSERT INTO vysledok (pridelenie_id, cas_vypracovania, skore_percenta) VALUES
(1, CURRENT_TIMESTAMP, 75.0),
(2, CURRENT_TIMESTAMP, 90.5),
(3, CURRENT_TIMESTAMP, 65.2);

-- Odpovede študentov
INSERT INTO odpoved (vysledok_id, otazka_id, zvolena_odpoved) VALUES
(1, 1, 'B'),
(1, 2, 'A'),
(2, 2, 'A'),
(2, 3, 'C'),
(3, 1, 'A'),
(3, 3, 'D');

-- Zmena autora testu
UPDATE test
SET autor_id = 1
WHERE autor_id = 3;

-- Vymazanie testu, pridelení a výsledkov pre dané ID testu
DELETE FROM odpoved
WHERE otazka_id IN (SELECT otazka_id FROM otazka_test WHERE test_id = 3);

DELETE FROM otazka_test
WHERE test_id = 3;

DELETE FROM vysledok
WHERE pridelenie_id IN (SELECT pridelenie_id FROM pridelenie WHERE test_id = 3);

DELETE FROM pridelenie
WHERE test_id = 3;

DELETE FROM test
WHERE test_id = 3;

-- Pridanie stĺpca termin_vypracovania do tabuľky pridelenie 
ALTER TABLE pridelenie
ADD COLUMN termin_vypracovania TIMESTAMP;

-- 5-tice Meno študenta, Priezvisko študenta, Názov testu, Čas pridelenia, Čas vypracovania, Výsledok v percentachs, Zodpovedal všetky otázky
SELECT
    s.meno AS "Meno študenta",
    s.priezvisko AS "Priezvisko študenta",
    t.nazov_testu AS "NazovTestu",
    p.cas_pridelenia AS "CasPridelenia",
    MAX(v.cas_vypracovania) AS "CasVypracovania",
    v.skore_percenta AS "VysledokPercenta",
    CASE WHEN COUNT(o.otazka_id) = COUNT(od.odpoved_id) THEN 'ano' ELSE 'nie' END AS "Dokoncil"
FROM pridelenie p
JOIN student s ON p.student_id = s.student_id
JOIN test t ON p.test_id = t.test_id
LEFT JOIN vysledok v ON p.pridelenie_id = v.pridelenie_id AND v.cas_vypracovania = (SELECT MAX(cas_vypracovania) FROM vysledok WHERE pridelenie_id = p.pridelenie_id)
LEFT JOIN otazka_test ot ON t.test_id = ot.test_id
LEFT JOIN otazka o ON ot.otazka_id = o.otazka_id
LEFT JOIN odpoved od ON v.vysledok_id = od.vysledok_id AND o.otazka_id = od.otazka_id
GROUP BY s.meno, s.priezvisko, t.nazov_testu, p.cas_pridelenia, v.skore_percenta
ORDER BY p.cas_pridelenia DESC;

-- Otazky kt neboli zodpovedane nespravne
SELECT
    o.text_otazky AS "Text",
    o.spravna_odpoved AS "SpravnaOdpoved"
FROM otazka o
WHERE NOT EXISTS (
    SELECT 1
    FROM student s
    JOIN pridelenie p ON s.student_id = p.student_id
    JOIN vysledok v ON p.pridelenie_id = v.pridelenie_id
    JOIN odpoved od ON v.vysledok_id = od.vysledok_id AND o.otazka_id = od.otazka_id
    WHERE od.zvolena_odpoved != o.spravna_odpoved
);

