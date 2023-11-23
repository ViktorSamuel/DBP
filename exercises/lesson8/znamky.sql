DROP TABLE IF EXISTS znamky;
DROP TABLE IF EXISTS predmety;
DROP TABLE IF EXISTS triedy;
DROP TABLE IF EXISTS ucitelia;
DROP TABLE IF EXISTS studenti;

CREATE TABLE studenti (
    id SERIAL PRIMARY KEY,
    meno VARCHAR(50),
    priezvisko VARCHAR(50),
    pohlavie VARCHAR(10),
    trieda VARCHAR(10),
    datum_narodenia DATE
);

CREATE TABLE ucitelia (
    id SERIAL PRIMARY KEY,
    meno VARCHAR(50),
    priezvisko VARCHAR(50),
    pohlavie VARCHAR(10)
);

CREATE TABLE predmety (
    id SERIAL PRIMARY KEY,
    nazov VARCHAR(50),
    skratka VARCHAR(10)
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
    FOREIGN KEY (student_id) REFERENCES studenti(id),
    FOREIGN KEY (ucitel_id) REFERENCES ucitelia(id),
    FOREIGN KEY (predmet_id) REFERENCES predmety(id)
);

CREATE TABLE triedy (
    id SERIAL PRIMARY KEY,
    trieda VARCHAR(10),
    predmet_id INT,
    FOREIGN KEY (predmet_id) REFERENCES predmety(id)
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


UPDATE znamky SET ucitel_id = 2 WHERE ucitel_id = 1;
DELETE FROM ucitelia WHERE id = 1;

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


-- Chceme založiť databázu pre evidenciu známok, študentov a učiteľov na strednej škole. Potrebujeme evidovať nasledovné:

-- Študent --- meno, priezvisko, pohlavie, trieda, dátum narodenia
-- Učiteľ --- meno, priezvisko, pohlavie
-- Predmet --- názov predmetu, skratka
-- Známka --- samotná známka (text), študent, ktorý učiteľ ju zadal, z akého je predmetu, čas zadania, z čoho bola (napr. že z domácej úlohy), váha známky (do priemeru)

-- Nie všetky triedy majú všetky predmety, preto potrebujeme evidovať, ktorá trieda má ktorý predmet.

-- Navrhnite štruktúru tabuliek vyššie uvedenej databázy --- vytvorte súbor znamky.sql, ktorý bude obsahovať SQL definície tabuliek (CREATE TABLE). Na začiatok súboru pridajte príkaz DROP TABLE IF EXISTS, aby ste súbor znamky.sql mohli spúšťať viackrát. (Integritu databázy, čiže veci ako cudzie kľúče, budeme riešiť až na ďalšom cvičení.)

-- Súbor znamky.sql doplňte o údaje --- do každej tabuľky pridajte pomocou INSERT niekoľko riadkov (opäť --- príkazy chceme mať spísané v súbore, aby sme ich mohli vykonať opakovane; môže to byť súbor znamky.sql).

-- Skúste použiť aj diakritiku --- pozor na kódovanie súboru znamky.sql.

-- Rozhodli sme sa sprístupniť zadávanie a prezeranie známok cez internet. Pomocou ALTER TABLE doplňte do tabuliek študent a učiteľ stĺpce na evidenciu prihlasovacích mien (heslá pre jednoduchosť nepoužijeme, z bezpečnostných dôvodov sa nesmú v databáze ukladať v odkrytej podobe). Vytvorte index na vyhľadávanie podľa prihlasovacieho mena.

-- vytvorte index tak, aby vyhľadávanie fungovalo case-insensitive

-- Jeden z učiteľov sa rozhodol odísť zo školy a chceme ho vymazať z databázy. Známky však musia ostať, t.j. jeho známky sa presunú na iného učiteľa.

-- Napíšte dotaz, ktorý presunie známky z jedného učiteľa na druhého (poznáme ID oboch učiteľov).

-- Napíšte dotaz, ktorý vymaže učiteľa z databázy (na základe jeho ID).

-- (Evidencia historických dát je jeden z najotravnejších praktických problémov, s ktorými sa pri návrhu databáz stretávame. Pozrite si, hoci len zbežne, jedno z možných riešení.)

-- Ďalšie úlohy:
-- Zdvojnásobte váhu všetkých známok, ktorých hodnota začína na "5" --- napíšte dotaz.
-- Vypíšte meno študenta, predmet, počet študentových známok z daného predmetu a zoznam týchto známok oddelených čiarkami (skúste použiť funkciu array_agg, prípadne aj array_to_string).
-- Vypíšte zoznam študentov a ku každému z nich mená predmetov takých, že z nich študent nemá známku, ale mal by mať (tento predmet je v zozname predmetov jeho triedy). Doplňte zoznam o priemerný počet známok z daného predmetu pre danú triedu.
-- Pre každý predmet spočítajte celkový počet a priemerný počet známok na žiaka. Výsledok usporiadajte podľa celkového počtu známok a zobrazte len prvých 10 riadkov.
-- Pre každého učiteľa vypočítajte priemer prirodzeno-číselných známok, ktore zadal. Pozor, funkcia AVG potrebuje na vstupe číslo --- potrebujete použiť CAST(... AS INTEGER). Ak to číslo však nebude číslo, vyhlási to chybu. Nečíselné známky odfiltrujte napr. pomocou regulárnych výrazov (napr. konštrukcia WHERE znamka ~ '^[0-9]*$').
-- O študentoch často potrebujeme evidovať veľmi špecifické údaje - evidujú sa len pre malé množstvo študentov. Vytvorne v tabuľke študentov JSON pole "moredata", v ktorom bude takéto údaje možné evidovať. Vyplnťe niektorým študentom zrakové postihnutie a následne napíšte dotaz, ktorý zobrazí študentov so zrakovým postihnutím.