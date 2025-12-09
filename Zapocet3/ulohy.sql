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
      AND index_name NOT IN (
        SELECT index_name
        FROM user_constraints
        WHERE table_name = 'P_MESTO'
          AND constraint_type IN ('U', 'P') -- U = Unique, P = Primary Key (tiež je unikátny)
          AND index_name IS NOT NULL
    );

    select * from user_indexes;

-- 13.	Vygenerujte príkazy (netreba spustiť) na rebuild všetkých indexov,
-- ktoré sú asociované s cudzími kľúčmi v schéme používateľa.
-- Použite pohľady user_constraints (constraint_type = 'R') a user_indexes.


-- Sada 2 – Otázky na návrh indexov

-- 14.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select rod_cislo, meno, priezvisko
-- from p_osoba
-- where lower(priezvisko) like 'nov%';
--
-- 15.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select meno, priezvisko, nazov_mesta
-- from p_osoba join p_mesto using (psc)
-- where psc between '01000' and '09999';


-- 16.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select suma
-- from p_prispevky
-- where kedy between to_date('01-01-2020','DD-MM-YYYY')
-- and to_date('31-12-2020','DD-MM-YYYY');


-- 17.	Vytvorte najvhodnejší index pre nasledujúci dotaz:
-- select nazov
-- from p_postihnutie
-- where lower(nazov) like '%sluch%'


-- 18.	Vytvorte najvhodnejší index (indexy) pre príkaz:
-- select meno, priezvisko
-- from zamestnanec
-- where datum_do is null;


-- 19.	Vytvorte najvhodnejší index pre dotaz:
-- select *
-- from p_osoba
-- where substr(rod_cislo,1,1) = '6';
