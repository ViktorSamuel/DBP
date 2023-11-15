# Prístupové práva 

## Dokumentácia: [GRANT](https://www.postgresql.org/docs/current/sql-grant.html), [REVOKE](https://www.postgresql.org/docs/current/sql-revoke.html)

## Prihlásenie a pripojenie k databáze

1. Prihláste sa na [cvika.dcs.fmph.uniba.sk](cvika.dcs.fmph.uniba.sk).
2. Pripojte sa na databázu "test" pomocou príkazu: `psql test`.

## Užitočné príkazy v psql:

- `\du`: Zobrazí zoznam používateľov.
- `\z tablename`: Zobrazí prístupové práva pre konkrétnu tabuľku.
- `SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name='test';`: Zobrazí prístupové práva k tabuľke "test".

## Práce s tabuľkou

1. **Vytvorte novú tabuľku príkazom:**
   ```sql
   CREATE TABLE test_vasemeno (i INTEGER, t TEXT);
   ```

   a doplňte do nej niekoľko riadkov:
   ```sql
   INSERT INTO test_vasemeno VALUES (1, 'a');
   INSERT INTO test_vasemeno VALUES (2, 'b');
   ```

2. **Prideľte právo na SELECT z tejto tabuľky role "test" (ďalej testovacia rola) a overte pomocou \z, či je naozaj pridelené.**

    ```sql
    GRANT SELECT ON TABLE test_vasemeno TO test;
    ```

    Overte pomocou `\z`, či je právo naozaj pridelené.

3. **Spustite psql -U test test, skúste si prezrieť obsah tabuľky `test_vasemeno` a skúste do nej vložiť nový riadok.**

    ```bash
    psql -U test test
    ```

    V psql skúste:

    ```sql
    SELECT * FROM test_vasemeno;
    INSERT INTO test_vasemeno VALUES (3, 'c');
    ```

4. **Upravte testovacej role práva na SELECT tak, aby mala možnosť prezerať si v tabuľke `test_vasemeno` len obsah stĺpca `t`.**

    ```sql
    GRANT SELECT (t) ON TABLE test_vasemeno TO test;
    ```

5. **Povoľte spolužiakovi vkladať do tabuľky `test_vasemeno` riadky tak, aby mohol toto oprávnenie prideliť iným. Vyskúšajte: nech pridelí toto oprávnenie role `test`. Potom mu odoberte možnosť prideliť toto oprávnenie iným (`REVOKE GRANT OPTION FOR`), tak aby stále sám mohol vkladať riadky. Požiadajte ho, nech vyskúša, či to funguje.**

    ```sql
    GRANT INSERT ON TABLE test_vasemeno TO spoluziak WITH GRANT OPTION;
    REVOKE GRANT OPTION FOR INSERT ON TABLE test_vasemeno FROM spoluziak;
    ```

6. **Vyskúšajte možnosť kaskádovitého odobratia oprávnenia.**

    [Dokumentácia k CASCADE](http://www.postgresql.org/docs/9.1/static/sql-revoke.html)

7. **Odoberte spolužiakom a testovacej role všetky oprávnenia, ktoré ste im udelili (`REVOKE ALL PRIVILEGES FROM`).**

    ```sql
    REVOKE ALL PRIVILEGES ON TABLE test_vasemeno FROM test, spoluziak;
    ```

8. **Zbežne si pozrite možnosti autentifikácie pri prihlasovaní k databáze, aby ste si vytvorili predstavu o súčasných technológiách. (Nie, nebudeme to vyžadovať na žiadnej skúške.)**


