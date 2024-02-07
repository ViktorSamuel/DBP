-- DROP TABLE statements
DROP TABLE IF EXISTS odpoved;
DROP TABLE IF EXISTS vysledok;
DROP TABLE IF EXISTS pridelenie;
DROP TABLE IF EXISTS otazka_test CASCADE;
DROP TABLE IF EXISTS test CASCADE;
DROP TABLE IF EXISTS otazka;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS ucitel CASCADE;

-- CREATE TABLE statements
-- CREATE TABLE statements
CREATE TABLE IF NOT EXISTS student (
    studentid SERIAL PRIMARY KEY,
    meno VARCHAR(255) NOT NULL,
    priezvisko VARCHAR(255) NOT NULL,
    prihlasovacie_meno VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS ucitel (
    ucitelid SERIAL PRIMARY KEY,
    meno VARCHAR(255) NOT NULL,
    priezvisko VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS test (
    testid SERIAL PRIMARY KEY,
    autor_ucitelid INT,
    nazov VARCHAR(255) NOT NULL,
    FOREIGN KEY (autor_ucitelid) REFERENCES ucitel(ucitelid) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS otazka (
    otazkaid SERIAL PRIMARY KEY,
    testid INT,
    text TEXT NOT NULL,
    FOREIGN KEY (testid) REFERENCES test(testid) ON DELETE CASCADE ON UPDATE CASCADE,
    spravne VARCHAR(255),
    nespravne1 VARCHAR(255),
    nespravne2 VARCHAR(255),
    nespravne3 VARCHAR(255)
);

CREATE TABLE pridelenie (
    pridelenieid SERIAL PRIMARY KEY,
    testid INT,
    studentid INT,
    ucitelid INT,
    cas_pridelenia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ucitelid) REFERENCES ucitel(ucitelid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (studentid) REFERENCES student(studentid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (testid) REFERENCES test(testid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE vysledok (
    vysledokid SERIAL PRIMARY KEY,
    pridelenieid INT,
    skore INT NOT NULL,
    cas_vypracovania TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pridelenieid) REFERENCES pridelenie(pridelenieid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE odpoved (
    vysledokid INT,
    otazkaid INT,
    text_odpovede VARCHAR(1) NOT NULL,
    FOREIGN KEY (vysledokid) REFERENCES vysledok(vysledokid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (otazkaid) REFERENCES otazka(otazkaid) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO student (meno, priezvisko, prihlasovacie_meno) VALUES ('s1', 's1', 's1');

INSERT INTO ucitel (meno, priezvisko) VALUES ('u1', 'u1');

INSERT INTO test (autor_ucitelid, nazov) 
VALUES (
    (SELECT ucitelid FROM ucitel WHERE meno = 'u1' AND priezvisko = 'u1'), 
    't1'
);

INSERT INTO otazka (testid, text, spravne, nespravne1, nespravne2, nespravne3)
VALUES (
    (SELECT testid FROM test WHERE nazov = 't1'),
    'What is 2 + 2?',
    '4', '3', '5', '2'
);

INSERT INTO pridelenie (testid, studentid, ucitelid)
VALUES (
    (SELECT testid FROM test WHERE nazov = 't1'),
    (SELECT studentid FROM student WHERE meno = 's1' AND priezvisko = 's1'),
    (SELECT ucitelid FROM ucitel WHERE meno = 'u1' AND priezvisko = 'u1')
);
