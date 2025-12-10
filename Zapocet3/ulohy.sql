INSERT INTO tomas.backup_predmet@remote_link
SELECT *
FROM p_predmet;

INSERT INTO lenka.data_vzdelanie@remote_link
SELECT *
FROM p_vzdelanie;

-- 3.	Máme vytvorený databázový link remote_link, ktorý sa odkazuje na inštanciu students_pdb servera orion. Použitý používateľ je tomas.
--    Napíšte príkaz, ktorý vloží do tabuľky log_osoby používateľa lenka na vzdialenom serveri všetky záznamy z lokálnej tabuľky p_osoba,
--    pre ktoré hodnota id_osoby ešte neexistuje v tabuľke log_osoby na vzdialenom serveri. Predpokladajte, že tabuľky majú rovnakú štruktúru.
INSERT INTO lenka.log_osoby@remote_link
SELECT *
FROM p_osoba po
WHERE NOT EXISTS (SELECT 'x'
                  FROM lenka.log_osoby@remote_link lo
                  WHERE lo.id_osoby = po.id_osoby);

-- ******************************* UPDATE ********************************************************************
-- 4.	Máme vytvorený databázový link remote_link, ktorý sa odkazuje na inštanciu orcl_pdb.
--    Použitý používateľ je dusan. Aktualizujte lokálnu tabuľku p_poistenie tak, aby ste nastavili dátum ukončenia poistného pre všetky osoby,
--    ktorých id_osoby sa nachádza v tabuľke data_osoby používateľa dusan na vzdialenom serveri.
UPDATE p_poistenie
SET dat_do = SYSDATE
WHERE id_osoby IN (SELECT id_osoby
                   FROM dusan.data_osoby@remote_link
);

-- 5.	Máme vytvorený databázový link remote_link, ktorý sa odkazuje na inštanciu orcl_pdb.Použitý používateľ je jana.
--    Aktualizujte lokálnu tabuľku p_zamestnanec a nastavte stav zamestnania na „NEAKTÍVNY“ pre všetkých zamestnancov,
--    ktorých identifikátor je uložený v tabuľke inactive_ids používateľa tomas na vzdialenom serveri.
UPDATE p_zamestnanec
SET stav = 'NEAKTIVNY'
WHERE id_zamestnanec in (SELECT ID_ZAMESTNANEC from tomas.inactive_ids@remote_link);

-- 6. Máme vytvorený databázový link remote_link, ktorý sa odkazuje na inštanciu orcl_pdb.
-- Použitý používateľ je jana. Aktualizujte lokálnu tabuľku p_student, kde ukončíte platnosť štúdia pre všetkých študentov,
-- ktorých os_cislo sa nachádza v tabuľke ukonceni_studenti používateľa lenka na vzdialenom serveri.
UPDATE p_student
SET dat_do = sysdate
WHERE os_cislo in (SELECT os_cislo from lenka.ukonceni_studenti@remote_link);

-- ******************************* INSERT ********************************************************************
-- 7.	Máme vytvorený databázový link remote_link, ktorý sa odkazuje na inštanciu students_pdb servera orion.
--    Použitý používateľ je martin. Napíšte príkaz,
--    ktorý vloží do lokálnej tabuľky p_predmet obsah tabuľky predmet_link používateľa martin na vzdialenom serveri.
insert into p_predmet
select * from martin.predmet_link@remote_link;

-- 8.	Máme vytvorený databázový link remote_link, ktorý sa odkazuje na inštanciu students_pdb.
-- Použitý používateľ je martin. Napíšte príkaz,
-- ktorý vloží do lokálnej tabuľky p_ucty záznamy z tabuľky backup_ucty používateľa lenka na vzdialenom serveri.
INSERT INTO p_ucty
SELECT * from lenka.backup_ucty@remote_link;

-- ********************************** DELETE cez DB link *****************************************************
-- 9.	Máme vytvorený databázový link remote_link.Použitý používateľ je andrea, ktorá má prístup ku všetkým tabuľkám celej inštancie.
-- Odstráňte z lokálnej tabuľky p_poberatel všetkých poberateľov, ktorých id_poberatela sa nachádza v
-- tabuľke del_ids používateľa andrea na vzdialenom serveri.
DELETE from p_poberatel
WHERE id_poberatela in (SELECT ID_POBERATELA from andrea.del_ids@remote_link);

-- 10.	Máme vytvorený databázový link remote_link. Použitý používateľ je andrea.
-- Odstráňte z lokálnej tabuľky p_nepritomnost všetky záznamy,
-- ktorých id_neprit sa nachádza v tabuľke del_neprit používateľa tomas na vzdialenom serveri.
DELETE from p_nepritomnost pn
WHERE exists(select 'x' from tomas.del_neprit@remote_link rmt
             where pn.id_neprit = rmt.id_neprit);

-- ******************************************* Indexy **********************************************************
-- Sada 1 – Generovanie SQL príkazov

-- 11.	Vygenerujte príkazy (netreba spustiť) na zrušenie všetkých B-tree indexov nad tabuľkou p_poistenie.
-- Použite pohľad user_indexes (atribúty index_name, table_name, index_type), pričom index_type nadobúda hodnotu „NORMAL“.

    SELECT 'DROP INDEX "' || index_name || '";'
    FROM user_indexes
    WHERE table_name = 'P_POISTENIE'
      AND index_type = 'NORMAL';


-- 12.	Vygenerujte príkazy (netreba spustiť) na zrušenie všetkých indexov nad tabuľkou p_mesto,
-- okrem indexov, ktoré zabezpečujú unikátnosť. Použite pohľady user_indexes a user_constraints (constraint_type = 'U').
    SELECT 'DROP INDEX ' || index_name || ';'
    FROM user_indexes
    WHERE table_name = 'P_MESTO'
      AND index_name NOT IN (SELECT index_name
                             FROM user_constraints
                             WHERE table_name = 'P_MESTO'
                               AND constraint_type = 'U'
    );

    select * from user_indexes;
    select * from user_constraints;

-- 13.	Vygenerujte príkazy (netreba spustiť) na rebuild všetkých indexov,
-- ktoré sú asociované s cudzími kľúčmi v schéme používateľa.
-- Použite pohľady user_constraints (constraint_type = 'R') a user_indexes.
    SELECT 'ALTER INDEX ' || i.index_name || ' REBUILD;'
    FROM user_indexes i
    JOIN user_constraints c ON i.index_name = c.constraint_name
    WHERE c.constraint_type = 'R';

-- Sada 2 – Otázky na návrh indexov

-- 14.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select rod_cislo, meno, priezvisko
-- from p_osoba
-- where lower(priezvisko) like 'nov%';

    --Pouzivam vsetky stlpce zo selectu (aj v povodnom tvare - cize priezvisko v tomto pripade) aby sa nemusel robit Table access
    create index ind_osoba_priezv_lower
    on p_osoba(lower(priezvisko), rod_cislo, meno, priezvisko);

-- 15.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select meno, priezvisko, nazov_mesta
-- from p_osoba join p_mesto using (psc)
-- where psc between '01000' and '09999';

    --MUSIM urobit 2, pretoze jeden pre každú tabuľku
    create index ind_osoba_psc
    on p_osoba(psc, meno, priezvisko);

    create index ind_mesto_psc
    on p_mesto(psc, nazov_mesta);

-- 16.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select suma
-- from p_prispevky
-- where kedy between to_date('01-01-2020','DD-MM-YYYY')
-- and to_date('31-12-2020','DD-MM-YYYY');
    create index ind_prispevky_todate
    on p_prispevky(kedy, suma);


-- 17.	Vytvorte najvhodnejší index pre nasledujúci dotaz:
-- select nazov
-- from p_postihnutie
-- where lower(nazov) like '%sluch%'
    create index ind_post_lower
    on p_postihnutie(lower(nazov), nazov); --Tu treba vediet ze B-tree indexy sú neefektívne, ak sa v LIKE nachádza znak % na začiatku reťazca
    -- Aj keď databáza musí prejsť celý index (Index Fast Full Scan), je to stále rýchlejšie
    -- ako prechádzať celú tabuľku (Full Table Scan), pretože index je fyzicky menší (obsahuje len dva stĺpce) ako celá tabuľka so všetkými ostatnými stĺpcami.


-- 18.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select meno, priezvisko
-- from zamestnanec
-- where datum_do is null;
    create index ind_zamestnanec_datum
    on zamestnanec(datum_do, meno, priezvisko);
    --TU POZOR: Ak sú všetky stĺpce v kľúči indexu NULL, potom sa tento riadok do B-tree indexu NEULOŽÍ.
    -- Keby som vytvoril index len takto:
    -- CREATE INDEX zly_index ON zamestnanec(datum_do);
    -- A potom spustil dotaz:
    -- SELECT ... WHERE datum_do IS NULL;
    -- Databáza by tento index nemohla použiť, pretože záznamy s NULL v indexe jednoducho nie sú. Musela by urobiť Full Table Scan.
    -- ALE KEDZE SOM POUZIL AJ MENO A PRIEZVISKO CO SU NOT NULL STLPCE, TAK DB UROBI INDEX ONLY SCAN CO JE NAJRYCHLEJSIE

-- 19.	Vytvorte najvhodnejší index pre dotaz:
-- select *
-- from p_osoba
-- where substr(rod_cislo,1,1) = '6';
    create index ind_osoba_substr
    on p_osoba(substr(rod_cislo, 1, 1));

-- ************************************************** JSON **************************************************************************
-- 50.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým knihám z tabuľky kniha_json, ktorých autor začína na písmeno M (atribút autor).
-- Jednotlivé knihy sú vo formáte JSON.
    select * from kniha_json k
    where k.doc.autor like 'M%'

-- 51.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým názvom kníh z tabuľky kniha_json, ktoré boli vydané po roku 2010 (atribúty nazov, rok_vydania).
-- Jednotlivé knihy sú vo formáte JSON.
    SELECT JSON_VALUE(doc, '$.nazov')
    FROM kniha_json
        WHERE JSON_VALUE(doc, '$.rok_vydania' RETURNING NUMBER) > 2010;

-- 52.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým študentom z tabuľky student_json, ktorých ročník je väčší ako 2 (atribút rocnik).
-- Jednotliví študenti sú vo formáte JSON.
    select * from student_json s
        where s.student.rocnik > 2;

-- 53.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým menám študentov z tabuľky student_json, ktorí majú priemer známok menší než 2.0 (atribúty meno, priemer).
-- Jednotliví študenti sú vo formáte JSON.
    select json_value(student, '$.meno') from student_json
        where json_value(student, '$.priemer' returning number) < 2.0;

-- 54.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým produktom z tabuľky produkt_json, ktorých cena je vyššia ako 20 eur (atribút cena).
-- Jednotlivé produkty sú vo formáte JSON.
    select * from produkt_json
        where json_value(produkt, '$.cena' returning number) > 20;

-- 55.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým názvom produktov z tabuľky produkt_json, ktoré patria do kategórie Elektronika (atribúty nazov, kategoria).
-- Jednotlivé produkty sú vo formáte JSON.
    select p.produkt.nazov from produkt_json p
        where p.produkt.kategoria = 'Elektronika';

-- 56.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým zamestnancom z tabuľky zamestnanec_json, ktorí pracujú na pozícii manager (atribút pozicia).
-- Jednotliví zamestnanci sú vo formáte JSON.
    select * from zamestnanec_json
        where json_value(zamestnanec, '$.pozicia') = 'Manager';

-- 57.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým platom zamestnancov z tabuľky zamestnanec_json, ktoré sú vyššie než 1500 eur (atribúty plat).
-- Jednotliví zamestnanci sú vo formáte JSON.

-- 58.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým objednávkam z tabuľky objednavka_json, ktorých počet položiek je väčší ako 3 (atribút pocet_poloziek).
-- Jednotlivé objednávky sú vo formáte JSON.

-- 59.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým celkovým cenám objednávok z tabuľky objednavka_json, ktorých suma presahuje 100 eur (atribúty celkova_cena).
-- Jednotlivé objednávky sú vo formáte JSON.

-- 60.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým zákazníkom z tabuľky zakaznik_json, ktorí majú vek väčší ako 30 rokov (atribút vek).
-- Jednotliví zákazníci sú vo formáte JSON.

-- 61.	Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým názvom filmov z tabuľky film_json, ktorých hodnotenie (atribút rating) je vyššie než 7.5.
-- Jednotlivé filmy sú vo formáte JSON.

-- ************************************************* CONNECT BY LEVEL *********************************************************************************
-- 69.	Pre KAŽDÝ mesiac minulého roka uveďte počet poistencov, ktorým v danom mesiaci vzniklo poistenie (atribút dat_od v tabuľke p_poistenie).
    SELECT
        k.mesiac,
        COUNT(p.id_poistenca) AS pocet
    FROM
        (SELECT level AS mesiac FROM dual CONNECT BY level <= 12) k
            LEFT JOIN p_poistenie p
                      ON EXTRACT(MONTH FROM p.dat_od) = k.mesiac
                          AND EXTRACT(YEAR FROM p.dat_od) = EXTRACT(YEAR FROM sysdate) - 1
    GROUP BY k.mesiac
    ORDER BY k.mesiac;


-- 70.	Pre KAŽDÝ mesiac minulého roka uveďte počet poistencov, ktorým v danom mesiaci poistenie zaniklo (atribút dat_do v tabuľke p_poistenie).
-- Dbajte na univerzálnosť dotazu.
    select c.mesiac,
           count(ID_POISTENCA)
    from (select level as mesiac from dual connect by level <= 12) c
        LEFT JOIN p_poistenie on (to_char(dat_do, 'MM') = c.mesiac
                                    AND extract(year from dat_do) = extract(year from sysdate) - 1)
    group by c.mesiac
    order by c.MESIAC;

-- 71.	Pre KAŽDÝ mesiac minulého roka vypíšte počet zamestnávateľov, ktorým v danom mesiaci pribudol nový zamestnanec (atribút dat_nastupu v p_zamestnanec).
    with mesiace as (
        select level mesiac from dual
        connect by level <= 12
    ) select mesiac, count(distinct ID_ZAMESTNAVATELA) as pocet_zamestnavatelov from MESIACE
    left join p_zamestnanec on (mesiac = extract(month from dat_od)
                                AND extract(year from dat_od) = extract(year from sysdate) - 9)
    group by mesiac
    ORDER BY mesiac;

-- 72.	Pre KAŽDÝ mesiac minulého roka uveďte počet poistencov, ktorí mali v danom mesiaci platný záznam v tabuľke p_poistenie
-- (čiže dat_od ≤ deň a zároveň (dat_do je NULL alebo ≥ deň)).
WITH mesiace AS (SELECT level AS mesiac
                 FROM dual
                 CONNECT BY level <= 12)
SELECT m.mesiac,
       COUNT(p.id_poistenca)
FROM mesiace m
         LEFT JOIN p_poistenie p ON(
            p.dat_od <= LAST_DAY(TO_DATE(m.mesiac || '.' || (EXTRACT(YEAR FROM SYSDATE) - 1), 'MM.YYYY'))
                AND
            (p.dat_do IS NULL OR
             p.dat_do >= TO_DATE('01.' || m.mesiac || '.' || (EXTRACT(YEAR FROM SYSDATE) - 1), 'DD.MM.YYYY'))
        )
GROUP BY m.mesiac
ORDER BY m.mesiac;


-- 73.	Pre KAŽDÝ deň minulého roka vypíšte celkový počet príspevkov vyplatených v danom dni (atribút kedy v p_prispevky).
    SELECT
    k.den,
    COUNT(p.id_poberatela) AS pocet
FROM
    (
        SELECT TRUNC(SYSDATE, 'YYYY') - LEVEL AS den
        FROM dual
        CONNECT BY LEVEL <= 366
    ) k
LEFT JOIN p_prispevky p ON TRUNC(p.kedy) = k.den
WHERE EXTRACT(YEAR FROM k.den) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY k.den
ORDER BY k.den;


-- 74.	Pre KAŽDÝ deň v mesiaci APRÍL minulého roka vypíšte počet zamestnancov, ktorým v daný deň vznikol pracovný pomer.
    with dni as(
        select level as den from dual
        CONNECT BY level <= 30
    ) select den, count(ROD_CISLO) from DNI
    left join p_zamestnanec on(
        extract(day from dat_od) = DEN AND
        extract(year from dat_od) = extract(year from sysdate) -1
        and extract(month from dat_od) = 4
    )
    group by den
    order by den;

-- 75.	Pre KAŽDÝ deň v treťom štvrťroku minulého roka vypíšte počet poistencov, ktorým v daný deň zaniklo poistenie.

-- 76.	Pre KAŽDÝ deň minulého roka vypíšte počet osôb z tabuľky p_osoba, ktoré mali v daný deň narodeniny (iba podľa dňa a mesiaca, rok ignorujte).

-- 77.	Pre KAŽDÝ mesiac minulého roka vypíšte počet poberateľov, ktorí mali v danom mesiaci aktívne poberanie
-- (dat_od ≤ posledný deň mesiaca AND (dat_do je NULL OR dat_do ≥ prvý deň mesiaca)).

-- 78.	Pre KAŽDÝ deň v mesiaci MÁJ minulého roka vypíšte počet príspevkov, ktoré boli vyplatené sumou vyššou ako 100 €.

-- 79.	Pre KAŽDÝ mesiac minulého roka vypíšte počet osôb z tabuľky p_osoba, ktoré sa narodili v danom mesiaci.

-- 80.	Pre KAŽDÝ mesiac minulého roka vypíšte počet poistencov, ktorí mali v danom mesiaci zmenu poistenia (t. j. buď dat_od alebo dat_do spadá do mesiaca).

-- 81.	Pre KAŽDÝ deň v januári minulého roka vypíšte počet poistencov, ktorí mali v daný deň platné poistenie.

-- 82.	Pre KAŽDÝ mesiac minulého roka vypíšte celkový počet nových ZTP evidovaných v tabuľke p_ztp.

-- 83.	Pre KAŽDÝ deň v mesiaci DECEMBER minulého roka vypíšte počet poberateľov, ktorí v daný deň prestali byť poberateľmi.

-- 84.	Pre KAŽDÝ mesiac minulého roka vypíšte počet zamestnancov, ktorí mali v danom mesiaci platnú pracovnú zmluvu
-- (dat_nastupu ≤ posledný deň mesiaca AND (dat_ukoncenia je NULL alebo ≥ prvý deň mesiaca)).

-- 85.	Pre KAŽDÝ deň minulého roka vypíšte počet poistencov, ktorým v daný deň vzniklo poistenie.
    with dni as (
        select level as den from dual
        CONNECT BY level <= to_number(to_char(to_date('31.12.' || (extract(year from sysdate) - 1), 'DD.MM.YYYY'), 'DDD'))
    ) select den, count(ID_POISTENCA) from DNI
    left join p_poistenie on(
        to_number(to_char(dat_od, 'DDD')) = DEN
        AND extract(year from dat_od) = extract(year from sysdate) - 1
    )
    group by den
    order by den;


-- 86.	Pre KAŽDÝ mesiac minulého roka vypíšte priemernú dennú sumu príspevkov vyplatenú v danom mesiaci.

-- 88.	Čo vráti posledný select??
create table tab1 ( id integer );
insert into tab1 values ( 10 );
insert into tab1 values ( 20 );
savepoint sp1;
insert into tab1 values ( 30 );
rollback;
insert into tab1 values ( 40 );
commit;
select * from tab1;

--VRATI 40 - pretoze rollback nema specifikovane savepoint cize sa vrati cela transakcia vratane insertov

-- 89.	Čo vráti posledný select??
create table tab1 ( id integer );
insert into tab1 values ( 1 );
insert into tab1 values ( 2 );
savepoint a;
insert into tab1 values ( 3 );
savepoint b;
insert into tab1 values ( 4 );
rollback to a;
insert into tab1 values ( 5 );
commit;
rollback;
select * from tab1;

-- 1, 2, 5 -- PRETOZE inserty pred savepointom (1, 2) + insert po rollback(5) nasledny commit. Potom uz rollback nespravi nic ked bol COMMIT

-- 90.	Aký výsledok bude vypísaný?
create table pom ( id integer );
begin
    insert into pom values ( 1 );
    insert into pom values ( 2 );
    commit;
    insert into pom values ( 3 );
    rollback;
    insert into pom values ( 4 );
end;
/
select count(*) from pom;

-- 3

-- 91.	Aký výsledok bude vypísaný?
create table pom ( id integer );
begin
for i in 1..5 loop
insert into pom values ( i );
end loop;
rollback;
insert into pom values ( 100 );
commit;
end;
/
select max(id) from pom;
-- 100

-- 92.	Aký výsledok bude vypísaný?
set autocommit on;
create table pom ( id integer );
insert into pom values ( 1 );
insert into pom values ( 2 );
insert into pom values ( 3 );
rollback;
insert into pom values ( 10 );
commit;
select count(*) from pom;
-- 4


-- 93.	Aký výsledok bude vypísaný?
create table pom ( id integer );
begin
for i in 1..6 loop
    insert into pom values ( i );
    if i = 3 then
    savepoint sp_mid;
    end if;
end loop;
rollback to sp_mid;
insert into pom values ( 100 );
commit;
end;
select max(id) from pom;
--100


-- 94.	Čo vráti posledný select??
create table tab1 ( id integer );
insert into tab1 values ( 10 );
insert into tab1 values ( 20 );
savepoint s1;
insert into tab1 values ( 30 );
create table tab2 ( x integer );
insert into tab1 values ( 40 );
rollback to s1;
insert into tab1 values ( 50 );
commit;
select * from tab1;
-- [10, 20, 30, 40, 50]
-- COMMITOM sa ZMAZU vsetky savepointy takze rollback to s1 vrati ERROR

-- 95.	Aký výsledok bude vypísaný?
create table pom ( id integer );
begin
for i in 1..5 loop
    insert into pom values ( i );
    if mod(i,2) = 1 then
        commit;
    else
        rollback;
    end if;
end loop;
end;
select count(*) from pom;
-- [1 3 5]

-- 96.
Set autocommit off
Create table pom(id integer);
Create procedure proc1 AS
    Begin
        For i in 1..5 Loop
            Insert into pom values(i);
            Commit;
        End loop;
    End;
/

Create procedure proc2 AS
    Begin
        Proc1;
        Rollback;
        Insert into pom values(100);
    End;
/

Exec proc2;
Commit;

-- Aký výsledok vráti nasledovný príkaz Select?
Select count(*) from pom;
-- [1 2 3 4 5 100] --> 6

-- 97.
Set autocommit on

Create table pom(id integer);

Create procedure proc1 AS
    Begin
        For i in 1..5 Loop
            Insert into pom values(i);
        End loop;
        Rollback;
    End;

Create procedure proc2 AS
    Begin
        Proc1;
        Insert into pom values(50);
        Commit;
    End;

Exec proc2;
Rollback;

-- Aký výsledok vráti nasledovný príkaz Select?
Select max(id) from pom;
-- 50 - pretoze autocommit pri pl/sql blokoch funguje az po skonceni celeho bloku. Cize ked sa da na konci bloku rollback prideme o vsetky vlozene data

-- 98.
Set autocommit off
Create table pom(id integer);

Create procedure proc1 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    Begin
        Insert into pom values(1);
        Insert into pom values(2);
        Commit;
    End;
/

Create procedure proc2 AS
    Begin
        Proc1;
        Rollback;
        Insert into pom values(10);
    End;
/

Exec proc2;
Commit;

-- Aký výsledok vráti nasledovný príkaz Select?
Select count(*) from pom;
-- 3 --> [1 2 10]

-- 99.
Set autocommit off
Create table pom(id integer);
Create procedure proc1 AS
    Begin
        For i in 1..5 Loop
        Insert into pom values(i);
        If i = 3 then
            Savepoint sp_mid;
        End if;
        End loop;
        Rollback to sp_mid;
        Commit;
    End;
/

Create procedure proc2 AS
    Begin
        Proc1;
        Insert into pom values(100);
        Rollback;
    End;
/
Exec proc2;
Commit;
-- Aký výsledok vráti nasledovný príkaz Select?
Select count(*) from pom;
--[1 2 3] --> 3

-- 100.
Set autocommit off
Create table pom(id integer);

Create procedure proc1 AS
    Begin
        Insert into pom values(5);
        Rollback;
        Insert into pom values(10);
        Commit;
    End;
/

Create procedure proc2 AS
    Begin
        Proc1;
        Rollback;
        Insert into pom values(20);
        Commit;
    End;
/

Exec proc2;

-- Aký výsledok vráti nasledovný príkaz Select?
Select count(*) from pom;
--[10 20] --> 2

-- 101.
Set autocommit off

Create table pom(id integer);
Create procedure proc1 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    Begin
        For i in 1..3 Loop
            Insert into pom values(i);
        End loop;
        Rollback;
    End;
/

Create procedure proc2 AS
    Begin
        Proc1;
        Insert into pom values(99);
        Commit;
    End;
/

Exec proc2;
Rollback;

-- Aký výsledok vráti nasledovný príkaz Select?
Select count(*) from pom;
-- [99] --> 1
