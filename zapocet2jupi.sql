-- POHĽADY (VIEW) 
-- 1.  Vytvorte pohľad, ktorý bude obsahovať osoby a ich prislúchajúce poistenie (aj ak 
-- žiadne nemajú). 

CREATE OR REPLACE VIEW osoby_s_poistenim AS
SELECT
    o.rod_cislo,
    o.meno,
    o.priezvisko,
    p.id_poistenca,
    p.id_platitela,
    p.oslobodeny,
    p.dat_od,
    p.dat_do
FROM
    p_osoba o
LEFT JOIN
    p_poistenie p ON o.rod_cislo = p.rod_cislo;

SELECT * FROM osoby_s_poistenim;

-- 2.  Vytvorte pohľad, ktorý bude obsahovať mestá a počet osôb s trvalým pobytom.
CREATE OR REPLACE VIEW mesta_a_pocet_osob AS
SELECT 
    m.n_mesta,
    COUNT(o.rod_cislo) AS pocet_osob
FROM
    p_mesto m
LEFT JOIN
    p_osoba o ON m.PSC = o.PSC
GROUP BY
    m.n_mesta;

SELECT * FROM mesta_a_pocet_osob;

-- 3.  Vytvorte pohľad, ktorý bude obsahovať zamestnancov a ich zamestnávateľov s 
-- dátumom začiatku pracovného pomeru. 
CREATE OR REPLACE VIEW zamestnanci_a_zamestnavatelia AS
SELECT
    o.meno,
    o.priezvisko,
    z.id_zamestnavatela,
    zam.nazov AS zamestnavatel,
    z.dat_od AS datum_nastupu
FROM
    p_zamestnanec z
JOIN
    p_osoba o ON z.rod_cislo = o.rod_cislo
JOIN
    p_zamestnavatel zam ON z.id_zamestnavatela = zam.ICO;
    
SELECT * FROM zamestnanci_a_zamestnavatelia;

-- 4.  Vytvorte pohľad, ktorý bude obsahovať poistencov spolu s počtom ich 
-- odvodových platieb.

CREATE OR REPLACE VIEW poistenci_s_poctom_odvodovych_platieb AS
SELECT p.id_poistenca, o.meno, o.priezvisko, COUNT(op.cis_platby) AS pocet_platieb
FROM p_poistenie p
JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
LEFT JOIN p_odvod_platba op ON p.id_poistenca = op.id_poistenca
GROUP BY p.id_poistenca, o.meno, o.priezvisko;

CREATE OR REPLACE VIEW poistenci_s_poctom_odvodovych_platieb AS
SELECT
    p.id_poistenca,
    o.meno,
    o.priezvisko,
    COUNT(op.cis_platby) AS pocet_platieb
FROM
    p_poistenie p
JOIN
    p_osoba o ON p.rod_cislo = o.rod_cislo
LEFT JOIN 
    p_odvod_platba op ON p.id_poistenca = op.id_poistenca
GROUP BY
    p.id_poistenca, o.meno, o.priezvisko;
    
SELECT * FROM poistenci_s_poctom_odvodovych_platieb;

-- 5.  Vytvorte pohľad, ktorý bude obsahovať osoby a typ ich postihnutia (ak existuje).
CREATE OR REPLACE VIEW osoby_a_postihnutia AS
SELECT
    o.rod_cislo,
    o.meno,
    o.priezvisko,
    tp.nazov_postihnutia
FROM
    p_osoba o
LEFT JOIN
    p_ZTP z ON o.rod_cislo = z.rod_cislo
LEFT JOIN
    p_typ_postihnutia tp ON z.id_postihnutia = tp.id_postihnutia;

CREATE OR REPLACE VIEW osoby_a_postihnutia AS
SELECT
    o.rod_cislo,
    o.meno,
    o.priezvisko,
    tp.nazov_postihnutia
FROM p_osoba o
LEFT JOIN p_ZTP z ON o.rod_cislo = z.rod_cislo
LEFT JOIN p_typ_postihnutia tp ON z.id_postihnutia = tp.id_postihnutia;
    
SELECT * FROM osoby_a_postihnutia;

-- 6.  Vytvorte pohľad, ktorý bude obsahovať zamestnávateľov a počet ich aktívnych 
-- zamestnancov.
CREATE OR REPLACE VIEW zamestnavatelia_a_aktivni_zamestnanci AS
SELECT
    z.ICO,
    z.nazov,
    COUNT(zam.rod_cislo) AS pocet_aktivnych
FROM
    p_zamestnavatel z
LEFT JOIN
    p_zamestnanec zam ON z.ICO = zam.id_zamestnavatela AND zam.dat_do IS NULL
GROUP BY
    z.ICO, z.nazov;

SELECT * FROM zamestnavatelia_a_aktivni_zamestnanci;

-- 7.  Vytvorte pohľad, ktorý bude obsahovať osoby, ktoré sú zároveň poistencami aj 
-- zamestnancami.
CREATE OR REPLACE VIEW osoby_poistenci_aj_zamestnanci AS
SELECT 
    o.rod_cislo,
    o.meno,
    o.priezvisko
FROM p_osoba o
WHERE
    EXISTS (SELECT 1 FROM p_poistenie p WHERE p.rod_cislo = o.rod_cislo)
    AND EXISTS (SELECT 1 FROM p_zamestnanec z WHERE z.rod_cislo = o.rod_cislo);

SELECT * FROM osoby_poistenci_aj_zamestnanci;

-- 8.  Vytvorte pohľad, ktorý bude obsahovať typy príspevkov a počet osôb, ktoré ich 
-- poberajú. 
CREATE OR REPLACE VIEW v_pocet_poberatelov_typov AS
SELECT
    t.id_typu,
    t.popis,
    COUNT(DISTINCT pb.rod_cislo) AS pocet_osob
FROM
    p_prispevky pr
JOIN 
    p_poberatel pb ON pr.id_poberatela = pb.id_poberatela
JOIN
    p_typ_prispevku t ON pr.id_typu = t.id_typu
GROUP BY
    t.id_typu, t.popis;

SELECT * FROM v_pocet_poberatelov_typov;

-- 9.  Vytvorte pohľad, ktorý bude obsahovať poistencov a dátum ich poslednej platby.
CREATE OR REPLACE VIEW v_posledna_platba_poistenca AS
SELECT
    o.rod_cislo,
    o.meno,
    o.priezvisko,
    MAX(ppl.dat_platby) AS posledna_platba
FROM 
    p_poistenie pp
JOIN
    p_osoba o ON pp.rod_cislo = o.rod_cislo
LEFT JOIN
    p_odvod_platba ppl ON pp.id_poistenca = ppl.id_poistenca
GROUP BY
    o.rod_cislo, o.meno, o.priezvisko;

SELECT * FROM v_posledna_platba_poistenca;

-- 10.  Vytvorte pohľad, ktorý bude obsahovať osoby a ich príspevky vrátane názvu typu 
--príspevku. 
CREATE OR REPLACE VIEW v_osoby_prispevky AS
SELECT
    o.rod_cislo,
    o.meno,
    o.priezvisko,
    t.popis AS typ_prispevku,
    pr.suma,
    pr.kedy
FROM 
    p_osoba o
JOIN 
    p_poberatel pb ON o.rod_cislo = pb.rod_cislo
JOIN
    p_prispevky pr ON pb.id_poberatela = pr.id_poberatela
JOIN 
    p_typ_prispevku t ON pr.id_typu = t.id_typu;
    
SELECT * FROM v_osoby_prispevky;


-- SELECT – GROUP BY, HAVING, EXISTS, JOIN
-- 11. Počet poistencov pre každého platiteľa. 
SELECT 
    id_platitela,
    COUNT(*) AS pocet_poistencov
FROM
    p_poistenie
GROUP BY
    id_platitela;
    
-- 12. Počet osôb podľa mesta.
SELECT
    m.n_mesta,
    COUNT(o.rod_cislo) AS pocet_osob
FROM
    p_mesto m
LEFT JOIN
    p_osoba o ON m.PSC = o.PSC
GROUP BY
    m.n_mesta;

-- 13. Počet záznamov v p_prispevky podľa typu.
SELECT
    id_typu,
    COUNT(*) AS pocet_zaznamov
FROM
    p_prispevky
GROUP BY
    id_typu;

-- 14. Priemerná výška príspevku podľa typu.
SELECT
    t.id_typu,
    t.popis,
    AVG(p.suma) AS priemerna_vyska
FROM
    p_prispevky p
JOIN
    p_typ_prispevku t ON p.id_typu = t.id_typu
GROUP BY
    t.id_typu, t.popis;

-- 15. Počet rôznych zamestnávateľov pre každé PSČ.
SELECT 
    PSC,
    COUNT(DISTINCT ICO) AS pocet_zamestnavatelov
FROM
    p_zamestnavatel
GROUP BY
    PSC;

-- 19. Osoby, ktoré nie sú poistencami (NOT EXISTS).
SELECT *
FROM p_osoba o
WHERE NOT EXISTS (
    SELECT 1 FROM p_poistenie p WHERE p.rod_cislo = o.rod_cislo);
    
-- Vypíšte menný zoznam držiteľov ZŤP preukazov, ktorí aktuálne nepoberajú príspevok,
-- ale v minulosti mohli poberať. 
SELECT DISTINCT o.meno, o.priezvisko, o.rod_cislo
FROM p_ZTP z
JOIN p_osoba o ON o.rod_cislo = z.rod_cislo

-- osoba MÁ v minulosti príspevok
WHERE EXISTS (
  SELECT 1
  FROM p_poberatel pb
  JOIN p_prispevky pr ON pr.id_poberatela = pb.id_poberatela
  WHERE pb.rod_cislo = z.rod_cislo
)

-- ALE NEMÁ žiadny aktuálny (napr. za posledný mesiac)
AND NOT EXISTS (
  SELECT 1
  FROM p_poberatel pb
  JOIN p_prispevky pr ON pr.id_poberatela = pb.id_poberatela
  WHERE pb.rod_cislo = z.rod_cislo
    AND pr.obdobie >= ADD_MONTHS(SYSDATE, -1)
);

-- Vypíšte menný zoznam aktuálnych zamestnancov firmy Lidl.
SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_zamestnanec z
JOIN p_osoba o ON z.rod_cislo = o.rod_cislo
JOIN p_zamestnavatel zam ON z.id_zamestnavatela = zam.ICO
WHERE LOWER(zam.nazov) = 'lidl'
AND z.dat_do IS NULL;

-- Vypíšte menný zoznam platných poistencov, ktorí nemajú zaplatený
-- ani jeden odvod za posledných 6 mesiacov.
SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_poistenie p
JOIN p_osoba o ON p.rod_cislo = p.rod_cislo
WHERE p.dat_do IS NULL AND NOT EXISTS (
SELECT 1 FROM p_odvod_platba op WHERE op.id_poistenca = p.id_poistenca
AND op.dat_platby >= ADD_MONTHS(SYSDATE, -6));

-- Vypíšte zoznam typov príspevkov, ktoré poberá menej ako 20 osôb.
SELECT t.id_typu, t.popis, COUNT(DISTINCT pb.rod_cislo) AS pocet_osob
FROM p_prispevky pr
JOIN p_poberatel pb ON pr.id_poberatela = pb.id_poberatela
JOIN p_typ_prispevku t ON pr.id_typu = t.id_typu
GROUP BY t.id_typu, t.popis
HAVING COUNT(DISTINCT pb.rod_cislo) < 20;

-- Vypiste menný zoznam ludi, ktori budu mat ku koncu roka viac ako 18 rokov.
SELECT os.meno, os.priezvisko
FROM p_osoba os
WHERE (EXTRACT(YEAR FROM TO_DATE('31.12.2017', 'DD.MM.YYYY'))
	- EXTRACT(YEAR FROM TO_DATE((SUBSTR(os.rod_cislo, 1, 2) ||
	MOD(TO_NUMBER(SUBSTR(os.rod_cislo, 3, 1)), 5) || 
	SUBSTR(os.rod_cislo, 4, 3)), 'YYMMDD')))) > 18;

-- Vypíšte zoznam zamestnávateľov, 
--ktorí za minuly rok odviedli dane vo výške minimálne 2000 eur.

SELECT z.ICO, z.nazov, SUM(op.suma) AS odvody_spolu
FROM p_zamestnavatel z
JOIN p_poistenie p ON z.ICO = p.id_platitela
JOIN p_odvod_platba op ON p.id_poistenca = op.id_poistenca
WHERE EXTRACT(YEAR FROM op.obdobie) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY z.ICO, z.nazov
HAVING SUM(op.suma) >= 2000;

--Vypíšte menny zoznam osôb, ktoré súčasne poberajú viac ako jeden typ príspevku.
SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_osoba o
JOIN p_poberatel p ON o.rod_cislo = p.rod_cislo
WHERE p.dat_do IS NULL OR p.dat_do > sysdate
GROUP BY o.meno, o.priezvisko, o.rod_cislo
HAVING COUNT(p.id_typu) > 2;

DELETE FROM p_odvod_platba
WHERE cis_platby IN(SELECT cis_platby FROM p_poistenie
    JOIN p_odvod_platba USING(id_poistenca)
    WHERE
        SUBSTR(rod_cislo, 3, 1) IN (5, 6)
        AND
        ADD_MONTHS(SYSDATE, -24) < dat_platby);

INSERT INTO p_odvod_platba(cis_platby, id_poistenca, suma, dat_platby, obdobie)
SELECT cis_platby, id_poistenca, suma, ADD_MONTHS(dat_platby, 1), ADD_MONTHS(obdobie, 1)
FROM p_odvod_platba
    JOIN p_poistenie USING(id_poistenca)
    JOIN p_zamestnanec USING(rod_cislo)
    JOIN p_zamestnavatel ON (p_zamestnavatel.ICO = p_zamestnanec.id_zamestnavatela)
WHERE
    dat_platby = ADD_MONTHS(SYSDATE, -1)
    AND
    nazov LIKE 'ZU'
    AND
    ((p_zamestnanec.dat_do IS NULL) OR (p_zamestnanec.dat_do > SYSDATE));

SELECT meno, priezvisko, AVG(suma) as priemer_prispevkov
FROM p_osoba
JOIN p_poberatel USING(rod_cislo)
JOIN p_prispevky USING(id_poberatela)
GROUP BY rod_cislo, meno, priezvisko
HAVING AVG(suma) > 20;

SELECT 
  o.meno, 
  o.priezvisko, 
  ROUND(NVL(AVG(pr.suma), 0), 2) AS priemerna_suma
FROM 
  p_osoba o
LEFT JOIN 
  p_poberatel pb ON o.rod_cislo = pb.rod_cislo
LEFT JOIN 
  p_prispevky pr ON pb.id_poberatela = pr.id_poberatela
GROUP BY 
  o.rod_cislo, o.meno, o.priezvisko
HAVING 
  NVL(AVG(pr.suma), 0) < 300;
  
CREATE TABLE TAB_CATEGORY (
    ID_CATEGORY INTEGER NOT NULL PRIMARY KEY,
    NAME VARCHAR2(20) NULL
);

CREATE TABLE TAB_COMPONENT (
    ID_COMPONENT INTEGER NOT NULL PRIMARY KEY,
    CATEGORY INTEGER NOT NULL,
    INFO VARCHAR2(50) NULL,
    FOREIGN KEY (CATEGORY) REFERENCES TAB_CATEGORY (ID_CATEGORY)
);

-- 20. Osoby s najvyšším počtom odvodov (GROUP BY + ORDER BY + LIMIT v poddotaze 
-- alebo IN a MAX). 
SELECT *
FROM (
    SELECT
        o.rod_cislo,
        o.meno,
        o.priezvisko,
        COUNT(op.cis_platby) AS pocet_odvodov
    FROM 
        p_odvod_platba op
    JOIN 
        p_poistenie p ON op.id_poistenca = p.id_poistenca
    JOIN 
        p_osoba o ON p.rod_cislo = o.rod_cislo
    GROUP BY
        o.rod_cislo, o.meno, o.priezvisko
    ORDER BY
        COUNT(op.cis_platby) DESC
)
WHERE ROWNUM = 1;

-- FUNKCIE 
-- 21. Funkcia: počet príspevkov pre poberateľa. 

CREATE OR REPLACE FUNCTION pocet_prispevkov(p_id_poberatela IN NUMBER)
RETURN NUMBER
IS
    v_pocet NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_prispevky
    WHERE id_poberatela = p_id_poberatela;
    
    RETURN v_pocet;
END;
/

SELECT  * from p_poberatel;

SELECT pocet_prispevkov(737) FROM dual;

-- 22. Funkcia: celková suma platieb pre poistenca.
CREATE OR REPLACE FUNCTION celkova_suma_platieb(p_id_poistenca IN NUMBER)
RETURN NUMBER
IS
    v_suma NUMBER := 0;
BEGIN
    SELECT NVL(SUM(suma), 0)
    INTO v_suma
    FROM p_odvod_platba
    WHERE id_poistenca = p_id_poistenca;
    
    RETURN v_suma;
END;
/

SELECT * from p_odvod_platba;

SELECT celkova_suma_platieb(4461) FROM dual;

-- 23. Funkcia: zistí, či má osoba aspoň 1 príspevok (TRUE/FALSE).
CREATE OR REPLACE FUNCTION ma_prispevok(p_rod_cislo IN CHAR)
RETURN NUMBER
IS
    v_existuje NUMBER := 0;
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 
            FROM p_prispevky pr
            JOIN p_poberatel pb ON pr.id_poberatela = pb.id_poberatela
            WHERE pb.rod_cislo = p_rod_cislo
        ) THEN 1
        ELSE 0
       END
    INTO v_existuje
    FROM dual;
    
    RETURN v_existuje;
END;
/

SELECT * from p_osoba;

SELECT ma_prispevok('810224/7604') FROM dual;

-- 24. Funkcia: zistí, či osoba žije v Nitrianskom kraji.
CREATE OR REPLACE FUNCTION je_z_nitrianskeho_kraja(p_rod_cislo IN CHAR)
RETURN BOOLEAN
IS
    v_pocet NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_osoba o
    JOIN p_mesto m ON o.PSC = m.PSC
    JOIN p_okres ok ON m.id_okresu = ok.id_okresu
    JOIN p_kraj k ON ok.id_kraja = k.id_kraja
    WHERE o.rod_cislo = p_rod_cislo AND LOWER(k.n_kraja) = 'nitriansky kraj';
    
    RETURN v_pocet > 0;
END;
/

DECLARE
  vysledok BOOLEAN;
BEGIN
  vysledok := je_z_nitrianskeho_kraja('810224/7604');

  IF vysledok THEN
    DBMS_OUTPUT.PUT_LINE('Osoba je z Nitrianskeho kraja.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Osoba NIE je z Nitrianskeho kraja.');
  END IF;
END;
/

-- 25. Funkcia: vráti počet rôznych rokov, v ktorých osoba poberala príspevok.
CREATE OR REPLACE FUNCTION pocet_rokov_prispevok(p_rod_cislo IN CHAR)
RETURN NUMBER
IS
    v_pocet NUMBER := 0;
BEGIN
    SELECT COUNT(DISTINCT EXTRACT(YEAR FROM pr.obdobie))
    INTO v_pocet
    FROM p_prispevky pr
    JOIN p_poberatel pb ON pr.id_poberatela = pb.id_poberatela
    WHERE pb.rod_cislo = p_rod_cislo;
    
    RETURN v_pocet;
END;
/

SELECT * FROM p_osoba;
SELECT * FROM p_prispevky;

SELECT pocet_rokov_prispevok('816121/7889') FROM dual;

-- 29. Funkcia: počet zamestnaní, ktoré osoba absolvovala.
CREATE OR REPLACE FUNCTION pocet_zamestnani(p_rod_cislo IN CHAR)
RETURN NUMBER
IS
    v_pocet NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_zamestnanec
    WHERE rod_cislo = p_rod_cislo;
    
    RETURN v_pocet;
END;
/

SELECT * FROM p_zamestnanec;

SELECT pocet_zamestnani('585602/7496') FROM dual;

-- 30. Funkcia: celková výška základnej sumy pre všetky typy príspevkov, ktoré osoba 
-- dostala. 
CREATE OR REPLACE FUNCTION suma_zakladov(p_rod_cislo IN CHAR)
RETURN NUMBER
IS
    v_suma NUMBER := 0;
BEGIN
  SELECT SUM(h.zakl_vyska)
  INTO v_suma
  FROM p_prispevky pr
  JOIN p_poberatel pb ON pr.id_poberatela = pb.id_poberatela
  JOIN p_historia h ON pr.id_typu = h.id_typu
                   AND pr.kedy BETWEEN h.dat_od AND NVL(h.dat_do, pr.kedy)
  WHERE pb.rod_cislo = p_rod_cislo;

  RETURN NVL(v_suma, 0);
END;
/

SELECT suma_zakladov('585602/7496') FROM dual;

CREATE OR REPLACE PROCEDURE vypis_osobu(p_rod_cislo IN CHAR)
IS
    CURSOR osoba_cur IS
        SELECT meno, priezvisko, PSC, ulica
        FROM p_osoba
        WHERE rod_cislo = p_rod_cislo;
    
    v_osoba osoba_cur%ROWTYPE
BEGIN
    OPEN osoba_cur;
    FETCH osoba_cur INTO v_osoba
    
    IF osoba_cur%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Meno: ' || v_osoba.meno);
        DBMS_OUTPUT.PUT_LINE('Priezvisko: ' || v_osoba.priezvisko);
        DBMS_OUTPUT.PUT_LINE('PSC: ' || v_osoba.PSC);
        DBMS_OUTPUT.PUT_LINE('Ulica: ' || v_osoba.ulica);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Osoba s rodným číslom ' || p_rod_cislo || ' neexistuje.');
    END IF;
    
    CLOSE osoba_cur;
END;
/

-- PROCEDÚRY - kurzory
-- 31. Vypíš informácie o osobe podľa rodného čísla. 

CREATE OR REPLACE PROCEDURE vypis_osobu(p_rod_cislo IN CHAR)
IS
    CURSOR osoba_cur IS
        SELECT meno, priezvisko, PSC, ulica
        FROM p_osoba
        WHERE rod_cislo = p_rod_cislo;
    
    v_osoba osoba_cur%ROWTYPE;
BEGIN
    OPEN osoba_cur;
    FETCH osoba_cur INTO v_osoba;
    
    IF osoba_cur%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Meno: ' || v_osoba.meno);
        DBMS_OUTPUT.PUT_LINE('Priezvisko: ' || v_osoba.priezvisko);
        DBMS_OUTPUT.PUT_LINE('PSC: ' || v_osoba.PSC);
        DBMS_OUTPUT.PUT_LINE('Ulica: ' || v_osoba.ulica);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Osoba s rodným číslom ' || p_rod_cislo || ' neexistuje.');
    END IF;
    
    CLOSE osoba_cur;
END;
/

SELECT * from p_osoba;

BEGIN
  vypis_osobu('790705/8379');
END;
/

-- 32. Vypíš históriu typu príspevku podľa ID typu.
CREATE OR REPLACE PROCEDURE vypis_historiu_typu(p_id_typu IN NUMBER)
IS
    CURSOR hist_cur IS
        SELECT dat_od, dat_do, zakl_vyska
        FROM p_historia
        WHERE id_typu = p_id_typu
        ORDER BY dat_od;
    
    v_dat_od DATE;
    v_dat_do DATE;
    v_zaklad NUMBER;
BEGIN
    OPEN hist_cur;
    LOOP
        FETCH hist_cur INTO v_dat_od, v_dat_do, v_zaklad;
        EXIT WHEN hist_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Od: ' || v_dat_od || ' | Do: ' || 
        NVL(TO_CHAR(v_dat_do), 'trvá') || ' | Základná výška: ' || v_zaklad);
    END LOOP;
    CLOSE hist_cur;
END;
/

BEGIN
  vypis_historiu_typu(2);
END;
/

CREATE OR REPLACE PROCEDURE pocet_osob_a_poistencov(p_psc IN CHAR)
IS
    v_pocet_osob NUMBER := 0;
    v_pocet_poistencov NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet_osob
    FROM p_osoba
    WHERE PSC = p_psc;
    
    SELECT COUNT(DISTINCT p.rod_cislo)
    INTO v_pocet_poistencov
    FROM p_poistenie p
    JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
    WHERE o.PSC = p_psc;
    
    DBMS_OUTPUT.PUT_LINE('PSC: ' || p_psc);
    DBMS_OUTPUT.PUT_LINE('Počet osôb: ' || v_pocet_osob);
    DBMS_OUTPUT.PUT_LINE('Počet poistencov: ' || v_pocet_poistencov);
END;
/

-- 33. Vypíš počet osôb a poistencov v zadanom PSČ.
CREATE OR REPLACE PROCEDURE pocet_osob_a_poistencov(p_psc IN CHAR)
IS
    v_pocet_osob NUMBER := 0;
    v_pocet_poistencov NUMBER :=0;
BEGIN
--pocet osob s danym psc
    SELECT COUNT(*)
    INTO v_pocet_osob
    FROM p_osoba
    WHERE PSC = p_psc;
    
--pocet poistencov s danym psc
    SELECT COUNT(DISTINCT p.rod_cislo)
    INTO v_pocet_poistencov
    FROM p_poistenie p
    JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
    WHERE o.PSC = p_psc;
    
    DBMS_OUTPUT.PUT_LINE('PSC: ' || p_psc);
    DBMS_OUTPUT.PUT_LINE('Počet osôb: ' || v_pocet_osob);
    DBMS_OUTPUT.PUT_LINE('Počet poistencov: ' || v_pocet_poistencov);
END;
/

CREATE OR REPLACE PROCEDURE pocet_osob_a_poistencov(p_psc IN CHAR)
IS
    v_pocet_osob NUMBER := 0;
    v_pocet_poistencov NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet_osob
    FROM p_osoba
    WHERE PSC = p_psc;
    
    SELECT COUNT(DISTINCT p.rod_cislo)
    INTO v_pocet_poistencov
    FROM p_poistenie p
    JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
    WHERE o.PSC = p_psc
        AND(
            FLOOR(MONTHS_BETWEEN(SYSDATE,
            TO_DATE(SUBSTR(p.rod_cislo, 1, 2) ||
            LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(p.rod_cislo, 3, 2)), 50)), 2, '0') ||
            SUBSTR(p.rod_cislo, 5, 2),
            'RRMMDD')) / 12) > 40);
    
    DBMS_OUTPUT.PUT_LINE('PSC: ' || p_psc);
    DBMS_OUTPUT.PUT_LINE('Počet osôb: ' || v_pocet_osob);
    DBMS_OUTPUT.PUT_LINE('Počet poistencov: ' || v_pocet_poistencov);
END;
/

SELECT PSC from p_osoba;

BEGIN
  pocet_osob_a_poistencov('01841');
END;
/

-- 34. Vypíš mená zamestnancov pre každého zamestnávateľa vrátane info o poistení.
CREATE OR REPLACE PROCEDURE zamestnanci_a_poistenie
IS
  CURSOR zamestnavatel_cur IS
    SELECT ICO, nazov FROM p_zamestnavatel;

  CURSOR zamestnanci_cur(p_ico p_zamestnavatel.ICO%TYPE) IS
    SELECT o.meno, o.priezvisko, z.rod_cislo
    FROM p_zamestnanec z
    JOIN p_osoba o ON z.rod_cislo = o.rod_cislo
    WHERE z.id_zamestnavatela = p_ico;

  v_ico p_zamestnavatel.ICO%TYPE;
  v_nazov p_zamestnavatel.nazov%TYPE;
  v_meno p_osoba.meno%TYPE;
  v_priezvisko p_osoba.priezvisko%TYPE;
  v_rc p_osoba.rod_cislo%TYPE;
  v_ma_poistenie VARCHAR2(3);
BEGIN
  OPEN zamestnavatel_cur;
  LOOP
    FETCH zamestnavatel_cur INTO v_ico, v_nazov;
    EXIT WHEN zamestnavatel_cur%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('Zamestnávateľ: ' || v_nazov || ' (ICO: ' || v_ico || ')');

    OPEN zamestnanci_cur(v_ico);
    LOOP
      FETCH zamestnanci_cur INTO v_meno, v_priezvisko, v_rc;
      EXIT WHEN zamestnanci_cur%NOTFOUND;

      -- Zistí, či má daný zamestnanec záznam v p_poistenie
      SELECT CASE
               WHEN EXISTS (
                 SELECT 1 FROM p_poistenie WHERE rod_cislo = v_rc
               ) THEN 'Áno'
               ELSE 'Nie'
             END
      INTO v_ma_poistenie
      FROM dual;

      DBMS_OUTPUT.PUT_LINE('  - ' || v_meno || ' ' || v_priezvisko || ' | Poistený: ' || v_ma_poistenie);
    END LOOP;
    CLOSE zamestnanci_cur;

    DBMS_OUTPUT.PUT_LINE(''); -- prázdny riadok medzi zamestnávateľmi
  END LOOP;
  CLOSE zamestnavatel_cur;
END;
/

BEGIN
  zamestnanci_a_poistenie;
END;
/

-- 40. Vypíš poistencov, ktorým poistenie začalo pred rokom 2020.
CREATE OR REPLACE PROCEDURE poistenci_pred_2020
IS
    CURSOR poistenie_cur IS
        SELECT o.meno, o.priezvisko, p.dat_od
        FROM p_poistenie p
        JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
        WHERE p.dat_od < DATE '2020-01-01'
        ORDER BY p.dat_od;
    
    v_meno p_osoba.meno%TYPE;
    v_priezvisko p_osoba.priezvisko%TYPE;
    v_datum_od p_poistenie.dat_od%TYPE;
    
BEGIN
    OPEN poistenie_cur;
    LOOP
        FETCH poistenie_cur INTO v_meno, v_priezvisko, v_datum_od;
        EXIT WHEN poistenie_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(v_meno || ' ' || v_priezvisko ||
        ' | Poistený od: ' || TO_CHAR(v_datum_od, 'DD.MM.YYYY'));
    END LOOP;
    CLOSE poistenie_cur;
END;
/

BEGIN
    poistenci_pred_2020;
END;
/

SET SERVEROUTPUT ON;

-- TRIGGRE 
-- 41. Trigger: nastav dat_do na NULL pri vklade do p_zamestnanec.

CREATE OR REPLACE TRIGGER trg_dat_do_null
BEFORE INSERT ON p_zamestnanec
FOR EACH ROW
BEGIN
    :NEW.dat_do := NULL;
END;
/

-- 42. Trigger: zákaz vložiť zápornú sumu do p_odvod_platba.
CREATE OR REPLACE TRIGGER trg_zakaz_zapornych_sum
BEFORE INSERT OR UPDATE ON p_odvod_platba
FOR EACH ROW
BEGIN
    IF :NEW.suma < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Záporná suma nie je povolená v p_odvod_platba.');
    END IF;
END;
/

-- 43. Trigger: kontrola existencie osoby pri vklade do p_poistenie. 
CREATE OR REPLACE TRIGGER trg_kontrola_osoby
BEFORE INSERT ON p_poistenie
FOR EACH ROW
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_exists
    FROM p_osoba
    WHERE rod_cislo = :NEW.rod_cislo;
    
    IF v_exists = 0 THEN
       RAISE_APPLICATION_ERROR(-20002, 'Osoba s týmto rodným číslom neexistuje.');
    END IF;
END;
/

-- 44. Trigger: zmazanie poistenia a zamestnaní po zmazaní osoby. 
CREATE OR REPLACE TRIGGER trg_mazanie_poisteni_a_zamestnani
AFTER DELETE ON p_osoba
FOR EACH ROW
BEGIN
    DELETE FROM p_poistenie
    WHERE rod_cislo = :OLD.rod_cislo;
    
    DELETE FROM p_zamestnanec
    WHERE rod_cislo = :OLD.rod_cislo;
END;
/

CREATE OR REPLACE TRIGGER trg_mazanie_poisteni_a_zamestnani
AFTER DELETE ON p_osoba
FOR EACH ROW
BEGIN
    DELETE FROM p_poistenie
    WHERE rod_cislo = :OLD.rod_cislo;
    
    DELETE FROM p_zamestnanec
    WHERE rod_cislo = :OLD.rod_cislo;
END;
/

-- 45. Trigger: zákaz duplicitného aktívneho poistenia jednej osoby. 
CREATE OR REPLACE TRIGGER trg_zakaz_duplicity_poistenia
BEFORE INSERT OR UPDATE ON p_poistenie
FOR EACH ROW
DECLARE
    v_pocet NUMBER;
BEGIN
    IF :NEW.dat_do IS NULL THEN
        SELECT COUNT(*)
        INTO v_pocet
        FROM p_poistenie
        WHERE rod_cislo = :NEW.rod_cislo
            AND dat_do IS NULL
            AND (:NEW.id_poistenca IS NULL OR id_poistenca != :NEW.id_poistenca);
        
        IF v_pocet > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Osoba už má aktívne poistenie.');
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_zakz_duplicity_poistenia
BEFORE INSERT OR UPDATE ON p_poistenie
FOR EACH ROW
DECLARE 
    v_pocet NUMBER;
BEGIN
    IF :NEW.dat_do IS NULL THEN
        SELECT COUNT(*)
        INTO v_pocet
        FROM p_poistenie
        WHERE rod_cislo = :NEW.rod_cislo
            AND dat_do IS NULL
            AND (:NEW.id_poistenca IS NULL

-- 46. Trigger: zákaz pridania zamestnanca staršieho ako 70 rokov.
CREATE OR REPLACE TRIGGER trg_max_vek_zamestnanca
BEFORE INSERT OR UPDATE ON p_zamestnanec
FOR EACH ROW
DECLARE
    v_rc p_zamestnanec.rod_cislo%TYPE;
    v_datum_nar DATE;
    v_vek NUMBER;
BEGIN
    SELECT rod_cislo
    INTO v_rc
    FROM p_osoba
    WHERE rod_cislo = :NEW.rod_cislo;
    
    v_datum_nar := TO_DATE(SUBSTR(v_rc, 1, 6), 'RRMMDD');
    
    v_vek := FLOOR(MONTHS_BETWEEN(SYSDATE, v_datum_nar) / 12);
    
    IF v_vek > 70 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Zamestnanec nesmie byť starší ako 70 rokov.');
    END IF;
END;
/

-- 47. Trigger: pri vložení príspevku overiť, že suma pri nezamestnanosti nie je vyššia než 
-- 1000 EUR. 
CREATE OR REPLACE TRIGGER trg_kontrola_suma_nezamestnanost
BEFORE INSERT OR UPDATE ON p_prispevky
FOR EACH ROW
DECLARE
  v_popis p_typ_prispevku.popis%TYPE;
BEGIN
  -- Zisti názov typu príspevku
  SELECT popis
  INTO v_popis
  FROM p_typ_prispevku
  WHERE id_typu = :NEW.id_typu;

  IF LOWER(v_popis) = 'nezamestnanosť' AND :NEW.suma > 1000 THEN
    RAISE_APPLICATION_ERROR(-20005, 'Suma pre príspevok pri nezamestnanosti nesmie byť vyššia ako 1000 EUR.');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_kontrola_suma_nezamestnanost
BEFORE INSERT OR UPDATE ON p_prispevky
FOR EACH ROW
DECLARE
    v_popis p_typ_prispevku.popis%TYPE;
BEGIN
    SELECT popis
    INTO v_popis
    FROM p_typ_prispevku
    WHERE id_typu = :NEW.id_typu
    
    if LOWER(v_popis) = 'nezamestnanosť' AND :NEW.suma > 1000 THEN
        RAISE_APPLICATION_ERROR(-20005, 'BLABLA');
    END IF;
END;
/

-- 48. Trigger: aktualizácia počtu zamestnancov v pomocnej tabuľke pri novom vklade.
CREATE TABLE zamestnavatel_stats (
    id_zamestnavatela CHAR(11) PRIMARY KEY,
    pocet_zamestnancov NUMBER
);

CREATE OR REPLACE TRIGGER trg_update_pocet_zamestnancov
AFTER INSERT ON p_zamestnanec
FOR EACH ROW
BEGIN
    UPDATE zamestnavatel_stats
    SET pocet_zamestnancov = pocet_zamestnancov + 1
    WHERE id_zamestnavatela = :NEW.id_zamestnavatela;
    
    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO zamestnavatel_stats (id_zamestnavatela, pocet_zamestnancov)
        VALUES (:NEW.id_zamestnavatela, 1);
    END IF;
END;
/

-- DML 
-- 51. Vlož novú osobu, ktorá má nastavený aj trvalý pobyt a poistenie.
INSERT INTO p_osoba (
  rod_cislo, meno, priezvisko, PSC, ulica
) VALUES (
  '990101/0001', 'Anna', 'Nováková', '05201', 'Hlavná 123'
);

INSERT INTO p_poistenie (
  id_poistenca, rod_cislo, id_platitela, oslobodeny, dat_od, dat_do
) VALUES (
  2001,               -- unikátne ID poistenca
  '990101/0001',      -- zhodné s rodným číslom osoby
  1001,               -- existujúce ID platiteľa (musí byť v p_platitel)
  'N',                -- nie je oslobodený
  DATE '2024-01-01',
  NULL
);

-- 52. Zmeň zamestnávateľa pre konkrétneho zamestnanca.
UPDATE p_zamestnanec
SET id_zamestnavatela = 'NOVY_ICO'
WHERE rod_cislo = 'KONKRETNE_RC';

-- 53. Odstráň všetky príspevky staršie než 5 rokov. 
DELETE FROM p_prispevky
WHERE kedy < ADD_MONTHS(SYSDATE, -60);

-- 54. Vlož nový typ príspevku a pridaj záznam o jeho použití pre osobu. 
INSERT INTO p_typ_prispevku (id_typu, popis)
VALUES (999, 'Energetický príspevok');

SELECT id_poberatela
FROM p_poberatel
WHERE rod_cislo = '900101/1234';

INSERT INTO p_prispevky (id_poberatela, id_typu, suma, obdobie, kedy)
VALUES (123, 999, 150, SYSDATE, SYSDATE);

INSERT INTO p_osoba (rod_cislo, meno, priezvisko)
SELECT rod_cislo, meno, priezvisko
FROM p_osoba
WHERE LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') <= 06;

--PETER SEDLACEK - SEQUENCE

CREATE SEQUENCE seq_poistenie_id
START WITH 1000
INCREMENT BY 1;

INSERT INTO p_poistenie (
    id_poistenca,
    rod_cislo,
    id_platitela,
    oslobodeny,
    dat_od,
    dat_do
)
SELECT
    seq_poistenie_id.NEXTVAL,
    o.rod_cislo,
    1,
    'N',
    SYSDATE,
    NULL
FROM p_osoba o
WHERE o.meno = 'Peter' AND o.priezvisko = 'Sedláček';
    

-- 55. Vymažte všetkých poistencov, ktorí majú ukončené poistenie (dat_do nie je 
-- NULL) a zároveň nemajú žiadne odvodové platby.
DELETE FROM p_poistenie p
WHERE p.dat_do IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 
        FROM p_odvod_platba op
        WHERE op.id_poistenca = p.id_poistenca
    );
    
-- 56. Odstráň osoby, ktoré nemajú žiadne poistenie, zamestnanie ani príspevok. 
DELETE FROM p_osoba o
WHERE NOT EXISTS (
    SELECT 1 FROM p_poistenie p WHERE p.rod_cislo = o.rod_cislo
)
AND NOT EXISTS (
    SELECT 1 FROM p_zamestnanec z WHERE z.rod_cislo = o.rod_cislo
)
AND NOT EXISTS (
    SELECT 1 FROM p_poberatel pb
    JOIN p_prispevky pr ON pr.id_poberatela = pb.id_poberatela
    WHERE pb.rod_cislo = o.rod_cislo
);
 

-- VZŤAHY A  CHECK 
-- 61. Vytvorte vzťah medzi p_osoba a p_poistenie (cudzí kľúč). 
ALTER TABLE p_poistenie
ADD CONSTRAINT fk_poistenie_osoba
FOREIGN KEY (rod_cislo)
REFERENCES p_osoba (rod_cislo);

ALTER TABLE p_poistenie
ADD CONSTRAINT fk_poistenie_osoba
FOREIGN KEY (rod_cislo)
REFERENCES p_osoba (rod_cislo);

-- 62. Vytvorte vzťah medzi p_osoba a p_zamestnanec (cudzí kľúč).
ALTER TABLE p_zamestnanec
ADD CONSTRAINT fk_zamestnanec_osoba
FOREIGN KEY (rod_cislo)
REFERENCES p_osoba (rod_cislo);

-- 63. Vytvorte CHECK, ktorý zakáže príspevok s nulovou sumou. 
ALTER TABLE p_prispevky
ADD CONSTRAINT chk_prispevok_suma
CHECK (suma > 0);

ALTER TABLE p_prispevky
ADD CONSTRAINT chk_prispevok_suma
CHECK (suma > 0);

-- 64. Vytvorte CHECK, ktorý povolí odvod len do výšky 500 EUR
ALTER TABLE p_odvod_platba
ADD CONSTRAINT chk_max_odvod_suma
CHECK (suma <= 500 AND suma > 0);

-- 65. Vytvorte CHECK, ktorý overí, že dátum ukončenia zamestnania je po dátume 
-- začiatku.
ALTER TABLE p_zamestnanec
ADD CONSTRAINT chk_datum_od_do
CHECK (dat_do IS NULL OR dat_do > dat_od);

-- 66. Vytvorte tabuľku p_dieta, kde každé dieťa má rodiča v p_osoba ako cudzí kľuč.
CREATE TABLE p_dieta (
    rod_cislo_dietata CHAR(11) PRIMARY KEY,
    meno VARCHAR2(50),
    priezvisko VARCHAR2(50),
    rod_cislo_rodica CHAR(11),
    datum_narodenia DATE,
    
    CONSTRAINT fk_rodic
        FOREIGN KEY (rod_cislo_rodica)
        REFERENCES p_osoba(rod_cislo)
);

-- 67. Vytvorte tabuľku p_adresa a naviaž ju na osobu pomocou cudzích kľúčov. 
CREATE TABLE p_adresa (
    id_adresy NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    rod_cislo CHAR(11),
    ulica VARCHAR2(100),
    cislo_domu VARCHAR2(10),
    PSC CHAR(5),
    typ_adresy VARCHAR(20),
    
    CONSTRAINT fk_adresa_osoba
        FOREIGN KEY (rod_cislo)
        REFERENCES p_osoba(rod_cislo)
);

-- 68. Vytvorte CHECK, ktorý overí, že kód postihnutia je medzi 1 a 10.
ALTER TABLE p_ZTP
ADD CONSTRAINT chk_id_postihnutia_rozsah
CHECK (id_postihnutia BETWEEN 1 AND 10);

-- 69. Vytvorte vzťah medzi príspevkom a typom príspevku (p_prispevok_typ).
ALTER TABLE p_prispevky
ADD CONSTRAINT fk_prispevok_typ
FOREIGN KEY (id_typu)
REFERENCES p_typ_prispevku(id_typu);

-- 70. Vytvorte kompozitný primárny kľúč na tabuľke, kde kombinácia osoby a príspevku 
--je unikátna. 
ALTER TABLE p_prispevky
ADD CONSTRAINT pk_prispevky_kompozitny
PRIMARY KEY (id_poberatela, id_typu);

-- ČAS
-- 71. Vypočítajte vek každej osoby na základe dátumu narodenia.
SELECT 
  rod_cislo,
  meno,
  priezvisko,
  FLOOR(MONTHS_BETWEEN(SYSDATE, TO_DATE(SUBSTR(rod_cislo, 1, 6), 'RRMMDD')) / 12) AS vek
FROM 
  p_osoba;

-- 72. Vypíšte všetky osoby, ktoré sa narodili v nedeľu.
SELECT 
  rod_cislo,
  meno,
  priezvisko,
  TO_DATE(SUBSTR(rod_cislo, 1, 6), 'RRMMDD') AS datum_narodenia
FROM 
  p_osoba
WHERE 
  TO_CHAR(TO_DATE(SUBSTR(rod_cislo, 1, 6), 'RRMMDD'), 'D') = '1';

--73. Vypíšte počet osôb, ktoré sa narodili v priestupný rok.
SELECT COUNT(*) AS pocet_priestupnych
FROM p_osoba
WHERE 
  MOD(
    TO_NUMBER(
      CASE 
        WHEN TO_NUMBER(SUBSTR(rod_cislo, 1, 2)) <= TO_NUMBER(TO_CHAR(SYSDATE, 'YY')) 
          THEN 2000 + TO_NUMBER(SUBSTR(rod_cislo, 1, 2))
        ELSE 1900 + TO_NUMBER(SUBSTR(rod_cislo, 1, 2))
      END
    ), 4
  ) = 0
  AND (
    MOD(
      CASE 
        WHEN TO_NUMBER(SUBSTR(rod_cislo, 1, 2)) <= TO_NUMBER(TO_CHAR(SYSDATE, 'YY')) 
          THEN 2000 + TO_NUMBER(SUBSTR(rod_cislo, 1, 2))
        ELSE 1900 + TO_NUMBER(SUBSTR(rod_cislo, 1, 2))
      END, 100
    ) != 0
    OR
    MOD(
      CASE 
        WHEN TO_NUMBER(SUBSTR(rod_cislo, 1, 2)) <= TO_NUMBER(TO_CHAR(SYSDATE, 'YY')) 
          THEN 2000 + TO_NUMBER(SUBSTR(rod_cislo, 1, 2))
        ELSE 1900 + TO_NUMBER(SUBSTR(rod_cislo, 1, 2))
      END, 400
    ) = 0
  );
  
--71. Vypočítajte vek každej osoby na základe dátumu narodenia.
SELECT rod_cislo, meno, priezvisko,
    FLOOR(MONTHS_BETWEEN(
        SYSDATE, TO_DATE(SUBSTR(rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(rod_cislo, 5, 2),
        'RRMMDD')
    ) / 12) AS vek
FROM p_osoba;
  
-- 72. Vypíšte všetky osoby, ktoré sa narodili v nedeľu. 
SELECT meno, priezvisko, rod_cislo
FROM p_osoba
WHERE TO_CHAR(TO_DATE(SUBSTR(rod_cislo, 1, 2) ||
    LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
    SUBSTR(rod_cislo, 5, 2),
    'RRMMDD'), 'D') = '1';

-- 74. Vypíšte kvartál (štvrťrok), v ktorom sa narodilo najviac osôb. 
SELECT kvartal
FROM (SELECT TO_CHAR(TO_DATE(SUBSTR(rod_cislo, 1, 2) ||
    LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
    SUBSTR(rod_cislo, 5, 2),
    'RRMMDD'), 'Q') AS kvartal, COUNT(*) AS pocet
    FROM p_osoba
    GROUP BY
        TO_CHAR(TO_DATE(
        SUBSTR(rod_cislo, 1, 2) || 
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') || 
        SUBSTR(rod_cislo, 5, 2),
        'RRMMDD'), 'Q')
    ORDER BY
        pocet DESC
)
WHERE ROWNUM = 1;

-- 75. Vypíšte všetkých poistencov, ktorí boli poistení pred svojimi 18. narodeninami 
SELECT o.meno, o.priezvisko, o.rod_cislo, p.dat_od AS datum_poistenia
FROM p_poistenie p
JOIN p_osoba o ON o.rod_cislo = p.rod_cislo
WHERE
    p.dat_od < (
        TO_DATE(SUBSTR(p.rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(p.rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(p.rod_cislo, 5, 2),
        'RRMMDD') + INTERVAL '18' YEAR);

-- 76. Zistite, v ktorý deň v týždni sa narodilo najviac osôb.    
SELECT den, pocet
FROM (
  SELECT 
    TO_CHAR(
      TO_DATE(
        SUBSTR(rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(rod_cislo, 5, 2),
        'RRMMDD'
      ), 'DAY', 'NLS_DATE_LANGUAGE = ENGLISH'
    ) AS den,
    COUNT(*) AS pocet
  FROM p_osoba
  GROUP BY 
    TO_CHAR(
      TO_DATE(
        SUBSTR(rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(rod_cislo, 5, 2),
        'RRMMDD'
      ), 'DAY', 'NLS_DATE_LANGUAGE = ENGLISH'
    )
  ORDER BY pocet DESC
)
WHERE ROWNUM = 1;

-- 77. Vypíšte osoby, ktoré dnes oslavujú narodeniny. 
SELECT meno, priezvisko, rod_cislo
FROM p_osoba
WHERE
    TO_CHAR(
        TO_DATE(
            SUBSTR(rod_cislo, 1, 2) ||
            LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
            SUBSTR(rod_cislo, 5, 2),
            'RRMMDD'), 'MMDD') = TO_CHAR(SYSDATE, 'MMDD');
            
SELECT
    o.meno,
    o.priezvisko,
    o.rod_cislo,
    TO_DATE(
        SUBSTR(o.rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(o.rod_cislo, 5, 2), 'RRMMDD') AS datum_narodenia,
    FLOOR(MONTHS_BETWEEN(SYSDATE,
        TO_DATE(
            SUBSTR(o.rod_cislo, 1, 2) ||
            LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)), 50)), 2, '0') ||
            SUBSTR(o.rod_cislo, 5, 2), 'RRMMDD')) / 12) AS vek,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM p_poistenie p
            WHERE p.rod_cislo = o.rod_cislo
        ) THEN 'áno'
        ELSE 'nie'
    END AS ma_poistenie
FROM p_osoba o
ORDER BY vek ASC;

            
-- 78. Vytvorte pohľad, ktorý bude obsahovať poistencov a počet dní, počas ktorých boli 
-- poistení (dat_do - dat_od). 
CREATE OR REPLACE VIEW v_poistenci_dni_poistenia AS
SELECT 
  p.rod_cislo,
  o.meno,
  o.priezvisko,
  p.dat_od,
  p.dat_do,
  NVL(p.dat_do, TRUNC(SYSDATE)) - p.dat_od AS pocet_dni_poistenia
FROM 
  p_poistenie p
JOIN 
  p_osoba o ON o.rod_cislo = p.rod_cislo;

SELECT * FROM v_poistenci_dni_poistenia;

--79. Vypíšte všetky osoby, ktoré sa narodili v pracovný deň (pondelok až piatok).
SELECT meno, priezvisko, rod_cislo
FROM p_osoba
WHERE
    TO_CHAR(
        TO_DATE(
            SUBSTR(rod_cislo, 1, 2) ||
            LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(3, 2)), 50)), 2, '0') ||
            SUBSTR(rod_cislo, 5, 2),
            'RRMMDD'), 'D') BETWEEN '2' AND '6';

-- 80. Vytvorte pohľad, ktorý bude obsahovať osoby a počet dní do ich najbližších 
-- narodenín.
CREATE OR REPLACE VIEW v_osoby_dni_do_narodenin AS
SELECT 
  o.meno,
  o.priezvisko,
  o.rod_cislo,
  birth_date,
  next_birthday,
  next_birthday - TRUNC(SYSDATE) AS dni_do_narodenin
FROM (
  SELECT 
    o.meno,
    o.priezvisko,
    o.rod_cislo,
    -- dátum narodenia
    TO_DATE(
      SUBSTR(o.rod_cislo, 1, 2) ||
      LPAD(
        TO_CHAR(
          CASE 
            WHEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) > 50 
            THEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) - 50
            ELSE TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2))
          END
        ), 2, '0'
      ) ||
      SUBSTR(o.rod_cislo, 5, 2),
      'RRMMDD'
    ) AS birth_date,
    
    -- najbližšie narodeniny (tento alebo budúci rok)
    CASE
      WHEN TO_DATE(
        TO_CHAR(SYSDATE, 'YYYY') ||
        LPAD(
          TO_CHAR(
            CASE 
              WHEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) > 50 
              THEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) - 50
              ELSE TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2))
            END
          ), 2, '0'
        ) ||
        SUBSTR(o.rod_cislo, 5, 2),
        'YYYYMMDD'
      ) >= TRUNC(SYSDATE)
      THEN TO_DATE(
        TO_CHAR(SYSDATE, 'YYYY') ||
        LPAD(
          TO_CHAR(
            CASE 
              WHEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) > 50 
              THEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) - 50
              ELSE TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2))
            END
          ), 2, '0'
        ) ||
        SUBSTR(o.rod_cislo, 5, 2),
        'YYYYMMDD'
      )
      ELSE TO_DATE(
        TO_CHAR(SYSDATE + INTERVAL '1' YEAR, 'YYYY') ||
        LPAD(
          TO_CHAR(
            CASE 
              WHEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) > 50 
              THEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) - 50
              ELSE TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2))
            END
          ), 2, '0'
        ) ||
        SUBSTR(o.rod_cislo, 5, 2),
        'YYYYMMDD'
      )
    END AS next_birthday
  FROM p_osoba o
);

SELECT * FROM v_osoby_dni_do_narodenin;

-- Vypíšte osoby, ktorým končí poistenie v najbližších 3 mesiacoch.

SELECT
    o.meno,
    o.priezvisko,
    o.rod_cislo,
    p.dat_od,
    p.dat_do
FROM p_poistenie p
JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
WHERE p.dat_do IS NOT NULL
AND p.dat_do >= SYSDATE
AND p.dat_do <= ADD_MONTHS(SYSDATE, 3);

--osoby narodene v 2. kvartaly
SELECT COUNT(*)
FROM p_osoba
WHERE TO_NUMBER(LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0')) BETWEEN 4 AND 6;

        
SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_osoba o
JOIN p_zamestnanec z ON o.rod_cislo = z.rod_cislo
JOIN p_zamestnavatel zam ON z.id_zamestnavatela = zam.ICO
WHERE LOWER(zam.nazov) = 'tesco' AND z.dat_do IS NULL AND z.dat_do > SYSDATE;

SELECT
    o.meno,
    o.priezvisko,
    o.rod_cislo,
    p.dat_od,
    p.dat_do,
    ROUND(MONTHS_BETWEEN(p.dat_do, p.dat_od) / 12, 1) AS roky_poistenia
FROM p_poistenie p
JOIN p_osoba o ON o.rod_cislo = p.rod_cislo
WHERE p.dat_do IS NOT NULL AND MONTHS_BETWEEN(p.dat_do, p.dat_od) > 60
ORDER BY roky_poistenia DESC;

SELECT 
  o.meno,
  o.priezvisko,
  o.rod_cislo,
  p.dat_od,
  p.dat_do,
  ROUND(MONTHS_BETWEEN(p.dat_do, p.dat_od) / 12, 1) AS roky_poistenia
FROM p_poistenie p
JOIN p_osoba o ON o.rod_cislo = p.rod_cislo
GROUP BY 
  o.meno, o.priezvisko, o.rod_cislo, p.dat_od, p.dat_do
HAVING 
  p.dat_do IS NOT NULL AND MONTHS_BETWEEN(p.dat_do, p.dat_od) > 60
ORDER BY roky_poistenia DESC;

SELECT 
  o.meno,
  o.priezvisko,
  o.rod_cislo,
  COUNT(*) AS pocet_poisteni
FROM 
  p_poistenie p
JOIN 
  p_osoba o ON p.rod_cislo = o.rod_cislo
GROUP BY 
  o.meno, o.priezvisko, o.rod_cislo
HAVING 
  COUNT(*) > 1
ORDER BY 
  pocet_poisteni DESC;
  
DELETE FROM p_prispevky
WHERE id_poberatela IN (
  SELECT pb.id_poberatela
  FROM p_poberatel pb
  JOIN p_osoba o ON pb.rod_cislo = o.rod_cislo
  WHERE o.meno = 'Peter' AND o.priezvisko = 'Novák'
);

DELETE FROM p_poberatel
WHERE rod_cislo IN (
  SELECT rod_cislo
  FROM p_osoba
  WHERE meno = 'Peter' AND priezvisko = 'Novák'
);

DELETE FROM p_poistenie
WHERE rod_cislo IN (
  SELECT rod_cislo
  FROM p_osoba
  WHERE meno = 'Peter' AND priezvisko = 'Novák'
);


SELECT 
  EXTRACT(DAY FROM dat_od) AS rok,
  COUNT(*) AS pocet_poisteni
FROM 
  p_poistenie
GROUP BY 
  EXTRACT(DAY FROM dat_od)
ORDER BY 
  pocet_poisteni DESC;
  
SELECT 
  meno,
  priezvisko,
  rod_cislo,
  psc
FROM 
  p_osoba
WHERE 
  psc IN ('01001', '02001', '04001');
  
SELECT o.meno, o.priezvisko, o.rod_cislo, p.id_platitela
FROM p_poistenie p
JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
WHERE p.id_platitela IN (
SELECT z.id_zamestnavatela
FROM p_zamestnanec z
WHERE z.dat_do IS NULL 
GROUP BY z.id_zamestnavatela
HAVING COUNT(*) >= 5);
  
--Vypíš osoby, ktoré poberajú príspevok, pričom typ tohto príspevku poberá menej ako 10 rôznych osôb.

SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_osoba o
JOIN p_poberatel pb ON o.rod_cislo = pb.rod_cislo
JOIN p_prispevky pp ON pb.id_poberatela = pp.id_poberatela
JOIN p_typ_prispevku pt ON pb.id_typu = pt.id_typu
WHERE pt.id_typu IN (
SELECT pp.id_typu
FROM p_prispevky pp
JOIN p_poberatel pb ON pp.id_poberatela = pb.id_poberatela
GROUP BY pp.id_typu
HAVING COUNT(DISTINCT pb.rod_cislo) < 10);

-- vypis osoby ktore nepoberaju ziaden prispevok
SELECT meno, priezvisko, rod_cislo
FROM p_osoba
WHERE rod_cislo NOT IN (
SELECT rod_cislo
FROM p_poberatel
WHERE dat_do IS NULL OR dat_do > SYSDATE);

SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_poistenie p
JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
WHERE p.id_poistenca NOT IN (
SELECT id_poistenca
FROM p_odvod_platba);

SET SERVEROUTPUT ON;

DECLARE
    v_pocet_oslobodenych NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet_oslobodenych
    FROM p_poistenie
    WHERE oslobodeny = 'a';
    
    DBMS_OUTPUT.PUT_LINE('Počet oslobodenych poistencov: ' || v_pocet_oslobodenych);
END;
/

SELECT
    m.n_mesta AS mesto,
    COUNT(DISTINCT p.rod_cislo) AS pocet_poistencov
FROM p_poistenie p
JOIN p_osoba o ON p.rod_cislo = o.rod_cislo
JOIN p_mesto m ON o.PSC = m.PSC
WHERE EXTRACT(YEAR FROM p.dat_od) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY m.n_mesta
ORDER BY pocet_poistencov DESC;

SELECT o.meno, o.priezvisko, o.rod_cislo, COUNT(DISTINCT pp.id_typu) AS pocet_typov
FROM p_osoba o
JOIN p_poberatel pb ON o.rod_cislo = pb.rod_cislo
JOIN p_prispevky pp ON pb.id_poberatela = pp.id_poberatela
GROUP BY o.meno, o.priezvisko, o.rod_cislo
HAVING COUNT(DISTINCT pp.id_typu) > 1;

-- Vytvorte trigger, ktorý zabezpečí, že pre jednu osobu nebude možné vložiť viacero aktívnych 
-- poistných záznamov naraz – teda také, ktoré majú nevyplnený stĺpec dat_do.

CREATE OR REPLACE TRIGGER trg_check_aktivne_poistenie
BEFORE INSERT OR UPDATE ON p_poistenie
FOR EACH ROW
DECLARE
v_pocet INTEGER;
BEGIN
    IF :NEW.dat_do IS NULL THEN
        SELECT COUNT(*) INTO v_pocet
        FROM p_poistenie
        WHERE rod_cislo = :NEW.rod_cislo
        AND dat_do IS NULL
        AND id_poistenca != :NEW.id_poistenca;
        IF v_pocet > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Osoba už má aktívne poistenie');
        END IF;
    END IF;
END;
/

SELECT o.meno, o.priezvisko, o.rod_cislo, COUNT(op.cis_platby) AS pocet_platieb,
SUM(op.suma) AS suma_spolu
FROM p_osoba o
JOIN p_poistenie p ON o.rod_cislo = p.rod_cislo
JOIN p_odvod_platba op ON p.id_poistenca = op.id_poistenca
WHERE op.dat_platby >= ADD_MONTHS(SYSDATE, -120)
GROUP BY o.meno, o.priezvisko, o.rod_cislo
ORDER BY suma_spolu DESC;

SELECT 
    meno,
    priezvisko,
    rod_cislo,
    FLOOR(MONTHS_BETWEEN(SYSDATE,
        TO_DATE(
            SUBSTR(rod_cislo, 1, 2) ||
            LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
            SUBSTR(rod_cislo, 5, 2), 'RRMMDD')) / 12) AS vek
FROM p_osoba;

SELECT 
    meno,
    priezvisko,
    rod_cislo,
    FLOOR(MONTHS_BETWEEN(SYSDATE,
        TO_DATE(
            SUBSTR(rod_cislo, 1, 2) ||
            LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
            SUBSTR(rod_cislo, 5, 2), 'RRMMDD')) / 12) AS vek
FROM p_osoba
WHERE

-- Dotaz: dátum narodenia a vek osoby podľa rodného čísla + info o poistení
SELECT
    o.meno,
    o.priezvisko,
    o.rod_cislo,
    TO_DATE(
        SUBSTR(o.rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(o.rod_cislo, 5, 2), 'RRMMDD') AS datum_narodenia,
    FLOOR(MONTHS_BETWEEN(SYSDATE,
        TO_DATE(
            SUBSTR(o.rod_cislo, 1, 2) ||
            LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)), 50)), 2, '0') ||
            SUBSTR(o.rod_cislo, 5, 2), 'RRMMDD')) / 12) AS vek,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM p_poistenie p
            WHERE p.rod_cislo = o.rod_cislo
        ) THEN 'áno'
        ELSE 'nie'
    END AS ma_poistenie
FROM p_osoba o
ORDER BY vek ASC;

-- Vypíš všetky osoby, ktoré bývajú v kraji, ktore ma id kraja 'BA' 
-- a zároveň sú zamestnancami a narodili sa v 3. kvártaly roku
-- a majú narodeniny v nedelu

SELECT
    o.meno,
    o.priezvisko,
    o.rod_cislo,
    m.n_mesta,
    kr.n_kraja,
    TO_DATE(
        SUBSTR(o.rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(o.rod_cislo, 5, 2), 'RRMMDD') AS datum_narodenia
FROM o_osoba o
JOIN p_mesto m ON o.PSC = m.PSC
JOIN p_okres ok ON m.id_okresu = ok.id_okresu
JOIN p_kraj kr ON ok.id_kraja = kr.id_kraja
JOIN p_zamestnanec z ON o.rod_cislo = z.rod_cislo
WHERE kr.id_kraja = 'BA' AND
(TO_NUMBER(LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)), 50)), 2, '0')) BETWEEN 7 AND 9) AND
TO_CHAR(
    TO_DATE(
        SUBSTR(o.rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(o.rod_cislo, 5, 2), 'RRMMDD'), 'D') = '1' -- nedela
ORDER BY datum_narodenia;

SELECT
    o.meno,
    o.priezvisko,
    o.rod_cislo,
    m.n_mesta,
    kr.n_kraja,
    TO_DATE(
        SUBSTR(o.rod_cislo, 1, 2) ||
        LPAD(
            TO_CHAR(
                CASE 
                    WHEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) > 50 
                    THEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) - 50 
                    ELSE TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2))
                END
            ), 2, '0'
        ) ||
        SUBSTR(o.rod_cislo, 5, 2), 
        'RRMMDD'
    ) AS datum_narodenia

FROM p_osoba o
JOIN p_mesto m ON o.PSC = m.PSC
JOIN p_okres ok ON m.id_okresu = ok.id_okresu
JOIN p_kraj kr ON ok.id_kraja = kr.id_kraja
JOIN p_zamestnanec z ON o.rod_cislo = z.rod_cislo

WHERE kr.id_kraja = ''
  AND (
    CASE 
      WHEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) > 50 
      THEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) - 50 
      ELSE TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2))
    END
  ) BETWEEN 7 AND 9

  AND TO_CHAR(
        TO_DATE(
            SUBSTR(o.rod_cislo, 1, 2) ||
            LPAD(
                TO_CHAR(
                    CASE 
                        WHEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) > 50 
                        THEN TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2)) - 50 
                        ELSE TO_NUMBER(SUBSTR(o.rod_cislo, 3, 2))
                    END
                ), 2, '0'
            ) ||
            SUBSTR(o.rod_cislo, 5, 2), 
            'RRMMDD'
        ), 'D'
    ) = '1'

ORDER BY datum_narodenia;

SELECT meno, priezvisko, rod_cislo
FROM p_osoba 
WHERE rod_cislo IN (SELECT rod_cislo FROM p_poistenie);

SELECT meno, priezvisko, rod_cislo
FROM p_osoba 
WHERE rod_cislo NOT IN (SELECT rod_cislo FROM p_poistenie);

SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_osoba o
WHERE EXISTS( SELECT 1 FROM p_poberatel p WHERE p.rod_cislo = o.rod_cislo);

SELECT 
    o.meno,
    o.priezvisko,
    o.rod_cislo
FROM p_osoba o
WHERE NOT EXISTS (
    SELECT 1 
    FROM p_poberatel p
    WHERE p.rod_cislo = o.rod_cislo
);

CREATE OR REPLACE PROCEDURE vypis_info_o_prispevkoch(p_rod_cislo IN VARCHAR2)
IS
    v_meno p_osoba.meno%TYPE;
    v_priezvisko p_osoba.priezvisko%TYPE;
    v_pocet INTEGER;
BEGIN
    SELECT meno, priezvisko
    INTO v_meno, v_priezvisko
    FROM p_osoba
    WHERE rod_cislo = p_rod_cislo;
    
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_poberatel
    WHERE rod_cislo = p_rod_cislo;
    
    DBMS_OUTPUT.PUT_LINE('Osoba: ' || v_meno || ' ' || v_priezvisko);
    DBMS_OUTPUT.PUT_LINE('Počet príspevkov: ' || v_pocet);
END;
/

CREATE SEQUENCE seq_poistenec_id
    START WITH 1
    INCREMENT BY 1;

-- Vloží poistenca do p_poistenie pre existujúcu osobu, skontroluje či osoba nemá aktívne poistenie
INSERT INTO p_poistenie
(id_poistenca, rod_cislo, id_platitela, oslobodeny, dat_od)
SELECT 
    seq_poistenec_id.NEXTVAL,
    o.rod_cislo,
    100,
    'N',
    SYSDATE
FROM p_osoba o
WHERE o.rod_cislo = '910101/1234'
AND NOT EXISTS (SELECT 1 FROM p_poistenie p
    WHERE p.rod_cislo = o.rod_cislo AND p.dat_do IS NULL);

-- Aktualizuj záznamy v p_poistenie tak, že pre všetkých poistencov, 
-- ktorí nemali žiadne odvody za posledných 6 mesiacov, sa nastaví 
-- dat_do = SYSDATE — teda ukončí sa ich poistenie.
UPDATE p_poistenie p
SET dat_do = SYSDATE
WHERE dat_do IS NULL 
 AND NOT EXISTS (SELECT 1 FROM p_odvod_platba op
    WHERE op.id_poistenca = p.id_poistenca AND op.dat_platby >= ADD_MONTHS(SYSDATE, -6));

DELETE FROM p_odvod_platba
WHERE id_poistenca IN (SELECT id_poistenca
    FROM p_poistenie
    WHERE dat_do IS NOT NULL);
ROLLBACK;

DELETE FROM p_poistenie p
WHERE p.dat_do IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM p_odvod_platba o
    WHERE o.id_poistenca = p.id_poistenca
);

SELECT *
FROM p_poistenie p
WHERE p.dat_do IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 
    FROM p_odvod_platba o
    WHERE o.id_poistenca = p.id_poistenca
  );

--funkcia parameter rod_cislo, z rodneho cisla zisti rok a
-- vrat pocet aktualnych poberatelov ktory sa narodili v tom istom roku

CREATE OR REPLACE FUNCTION pocet_poberatelov_v_roku(p_rod_cislo IN VARCHAR2)
RETURN NUMBER
IS
    v_rok_rod NUMBER;
    v_pocet NUMBER;
BEGIN
    v_rok_rod := TO_NUMBER(
        CASE
            WHEN SUBSTR(p_rod_cislo, 1, 2) BETWEEN '00' AND '25'
                THEN '20' || SUBSTR(p_rod_cislo, 1, 2)
            ELSE '19' || SUBSTR(p_rod_cislo, 1, 2)
        END
    );
    
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_poberatel pb
    JOIN p_osoba o ON pb.rod_cislo = o.rod_cislo
    WHERE pb.dat_do IS NULL
        AND TO_NUMBER(
            CASE
                WHEN SUBSTR(pb.rod_cislo, 1, 2) BETWEEN '00' AND '25'
                    THEN '20' || SUBSTR(pb.rod_cislo, 1, 2)
                ELSE '19' || SUBSTR(pb.rod_cislo, 1, 2)
            END
        ) = v_rok_rod;
    RETURN v_pocet;
END;
/

SELECT pocet_poberatelov_v_roku('740517/1234') FROM dual;

SELECT o.meno, o.priezvisko, o.rod_cislo, COUNT(DISTINCT p.id_typu) AS pocet_typov
FROM p_osoba o
JOIN p_poberatel p ON o.rod_cislo = p.rod_cislo
GROUP BY o.rod_cislo, o.meno, o.priezvisko
HAVING COUNT(DISTINCT p.id_typu) >= 3
ORDER BY pocet_typov DESC;

--vypis mesta v ktorych sa nenachadzaju poberatelia prispevku v nezamestnanosti
SELECT m.n_mesta, m.PSC
FROM p_mesto m
WHERE NOT EXISTS( SELECT 1 FROM p_osoba o
    JOIN p_poberatel p ON o.rod_cislo = p.rod_cislo
    JOIN p_typ_prispevku t ON p.id_typu = t.id_typu
    WHERE o.PSC = m.PSC
        AND LOWER(t.popis) = 'nezamest');
        
CREATE TABLE produkt (
    id_produktu   NUMBER PRIMARY KEY,
    nazov         VARCHAR2(100),
    cena          NUMBER(10,2)
);

CREATE TABLE zakaznik (
    id_zakaznika  NUMBER PRIMARY KEY,
    meno          VARCHAR2(50),
    mesto         VARCHAR2(50)
);

-- vytvára sa 1:N neidentifikačný vzťah
ALTER TABLE produkt
ADD id_zakaznika NUMBER;

ALTER TABLE produkt
ADD CONSTRAINT fk_produkt_zakaznik
FOREIGN KEY (id_zakaznika)
REFERENCES zakaznik(id_zakaznika);

-- povinne členstvo
ALTER TABLE produkt
MODIFY id_zakaznika NUMBER NOT NULL;

-- ak chceme 1:1
ALTER TABLE produkt
ADD CONSTRAINT uq_produkt_id_zakaznika
UNIQUE (id_zakaznika);

-- vytvára sa 1:N identifikačný vzťah
ALTER TABLE produkt
ADD id_zakaznika NUMBER;

ALTER TABLE produkt
DROP PRIMARY KEY;

ALTER TABLE produkt
ADD CONSTRAINT pk_produkt
-- 1:N
PRIMARY KEY (id_zakaznika, id_produktu);
-- 1:1
PRIMARY KEY (id_zakaznika)

ALTER TABLE produkt
ADD CONSTRAINT fk_produkt_zakaznik
FOREIGN KEY (id_zakaznika)
REFERENCES zakaznik(id_zakaznika);

-- Zamedz duplikovanému príspevku rovnakého typu v rovnakom období pre jedného poberateľa.
CREATE OR REPLACE TRIGGER trg_check_duplicate_prispevok
BEFORE INSERT OR UPDATE ON p_prispevky
FOR EACH ROW
DECLARE
    v_pocet INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_prispevky
    WHERE id_poberatela = :NEW.id_poberatela
        AND id_typu = :NEW.id_typu
        AND obdobie = :NEW.obdobie
        AND ROWID != :NEW.ROWID;
    IF v_pocet > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Poberateľ už má tento typ príspevku v danom období.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_default_oslobodeny
BEFORE INSERT ON p_poistenie
FOR EACH ROW
BEGIN
    IF :NEW.oslobodeny IS NOT NULL THEN
        :NEW.oslobodeny := 'N';
    END IF;
END;
/

-- 44. Trigger: zmazanie poistenia a zamestnaní po zmazaní osoby. 
CREATE OR REPLACE TRIGGER trg_delete_poistenie
AFTER DELETE ON p_osoba
FOR EACH ROW
BEGIN
    DELETE FROM p_poistenie
    WHERE rod_cislo = :OLD.rod_cislo;
    
    DELETE FROM p_zamestnanec
    WHERE rod_cislo = :OLD.rod_cislo;
END;
/

-- 43. Trigger: kontrola existencie osoby pri vklade do p_poistenie. 
CREATE OR REPLACE TRIGGER trg_kontrola_existencie
BEFORE INSERT ON p_poistenie
FOR EACH ROW
DECLARE
    v_pocet INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_osoba
    WHERE rod_cislo = :NEW.rod_cislo;
    
    IF v_pocet = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Osoba s týmto rodným číslom neexistuje');
    END IF;
END;
/

-- 49. Trigger: ak sa vloží nový typ príspevku, automaticky sa vloží do p_historia s 
-- aktuálnym dátumom.
CREATE OR REPLACE TRIGGER trg_automaticky_historia
AFTER INSERT ON p_typ_prispevku
FOR EACH ROW
BEGIN
    INSERT INTO p_historia (id_typu, dat_od, dat_do, zakl_vyska)
    VALUES(:NEW.id_typu, SYSDATE, SYSDATE + INTERVAL '2' YEAR, :NEW.zakl_vyska);
END;
/

SELECT z.nazov, COUNT(DISTINCT o.rod_cislo) AS pocet_zamestnancov, COUNT(DISTINCT m.PSC) AS pocet_miest
FROM p_zamestnanec zam
JOIN p_osoba o ON zam.rod_cislo = o.rod_cislo
JOIN p_mesto m ON o.PSC = m.PSC
JOIN p_zamestnavatel z ON zam.id_zamestnavatela = z.ICO
GROUP BY z.nazov
HAVING COUNT(DISTINCT o.rod_cislo) >= 3
    AND COUNT(DISTINCT m.PSC) >= 2;

ALTER TABLE p_zamestnanec
ADD CONSTRAINT pk_p_zamestnanec
PRIMARY KEY (id_zamestnavatela, rod_cislo, dat_od);

ALTER TABLE p_poistenie
ADD CONSTRAINT chk_oslobodeny
CHECK (oslobodeny IN ('A', 'N', 'Z'));

CREATE OR REPLACE FUNCTION vypocitaj_pocet_poisteni(p_rod_cislo IN VARCHAR2)
RETURN NUMBER
IS
    v_pocet NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_poistenie
    WHERE rod_cislo = p_rod_cislo;
    RETURN v_pocet;
END;
/

select rod_cislo from p_poistenie;

SELECT vypocitaj_pocet_poisteni('850325/8731') AS pocet
FROM dual;

--25. Funkcia: vráti počet rôznych rokov, v ktorých osoba poberala príspevok.
CREATE OR REPLACE FUNCTION vypocitaj_roky_prispevkov(p_rod_cislo IN VARCHAR2)
RETURN NUMBER
IS
    v_pocet NUMBER;
BEGIN
    SELECT COUNT(DISTINCT EXTRACT(YEAR FROM dat_od))
    INTO v_pocet
    FROM p_poberatel
    WHERE rod_cislo = p_rod_cislo;
    
    RETURN v_pocet;
END;
/

SELECT vypocitaj_roky_prispevkov('850325/8731') AS pocet
FROM dual;

-- 35. Vypíš osoby, ktoré nemajú žiadne príspevky. 
CREATE OR REPLACE PROCEDURE vypis_osoby_bez_prispevkov
IS
    CURSOR c_osoby IS
        SELECT o.rod_cislo, o.meno, o.priezvisko
        FROM p_osoba o
        WHERE NOT EXISTS (SELECT 1 FROM p_poberatel p
            WHERE p.rod_cislo = o.rod_cislo);
    v_osoba c_osoby%ROWTYPE;
    
BEGIN
    OPEN c_osoby;
    LOOP
        FETCH c_osoby INTO v_osoba;
        EXIT WHEN c_osoby%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'Rodné číslo: ' || v_osoba.rod_cislo ||
            ', Meno: ' || v_osoba.meno ||
            ', Priezvisko: ' || v_osoba.priezvisko
        );
    END LOOP;
    CLOSE c_osoby;
END;
/

SET SERVEROUTPUT ON;

BEGIN
    vypis_osoby_bez_prispevkov;
END;

-- vypíše všetkých zamestnávateľov
-- a zároveň počet zamestnancov, ktorí u nich pracujú

BEGIN
    FOR r IN (
        SELECT z.nazov, COUNT(zm.rod_cislo) AS pocet_zamestnancov
        FROM p_zamestnavatel z
        LEFT JOIN p_zamestnanec zm ON z.ICO = zm.id_zamestnavatela
        GROUP BY z.nazov
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Zamestnávateľ: ' || r.nazov || 
            ' | Počet zamestnancov: ' || r.pocet_zamestnancov
        );
    END LOOP;
END;
/

DECLARE
    v_celkovy_pocet NUMBER;
    v_priemerna_suma NUMBER(10,2);
BEGIN
    -- Zisti celkovy pocet platieb a priemernu sumu v tabulke p_odvod_platba
    SELECT COUNT(*), AVG(suma)
    INTO v_celkovy_pocet, v_priemerna_suma
    FROM p_odvod_platba;

    DBMS_OUTPUT.PUT_LINE('Celkovy pocet platieb: ' || v_celkovy_pocet);
    DBMS_OUTPUT.PUT_LINE('Priemerna suma platby: ' || TO_CHAR(v_priemerna_suma, '9990.99'));
END;
/

SELECT rod_cislo, 'Poberatel' AS status
FROM p_poberatel

UNION

SELECT rod_cislo, 'Zamestnanec' AS status
FROM p_zamestnanec;

--58. Zmeňte mesto trvalého pobytu na 'Bratislava' pre všetky osoby, ktoré majú 
-- momentálne PSČ začínajúce na '9'. 

UPDATE p_osoba
SET PSC = (SELECT PSC from p_mesto
    WHERE n_mesta = 'Bratislava' AND ROWNUM = 1)
WHERE PSC LIKE '9%';
ROLLBACK;

SELECT o.meno, o.priezvisko, o.rod_cislo, COUNT(DISTINCT p.id_typu) AS pocet_prispevkov
FROM p_osoba o
JOIN p_poberatel p ON o.rod_cislo = p.rod_cislo
GROUP BY o.meno, o.priezvisko, o.rod_cislo
HAVING COUNT(DISTINCT p.id_typu) >= 2
ORDER BY pocet_prispevkov DESC;

SELECT o.meno, o.priezvisko, o.rod_cislo
FROM p_osoba o
WHERE EXISTS ( SELECT 1 FROM p_poberatel p
    WHERE p.rod_cislo = o.rod_cislo);
    
SELECT o.meno, o.priezvisko, o.rod_cislo, tp.nazov_postihnutia
FROM p_osoba o
JOIN p_ZTP z ON o.rod_cislo = z.rod_cislo
JOIN p_typ_postihnutia tp ON z.id_postihnutia = tp.id_postihnutia
WHERE tp.nazov_postihnutia IN ('Zrakove Postihnutie', 'Sluchove Postihnutie');

na dieta
SELECT o.rod_cislo, o.meno, o.priezvisko
FROM p_osoba o
WHERE o.rod_cislo IN( 
    SELECT p.rod_cislo
    FROM p_poberatel p
    WHERE p.id_typu IN (
        SELECT tp.id_typu
        FROM p_typ_prispevku tp
        WHERE tp.popis = 'na dieta'));
        
SELECT 
    meno,
    priezvisko,
    rod_cislo
FROM p_osoba
WHERE 
TO_CHAR(
    TO_DATE(
        SUBSTR(rod_cislo, 1, 2) ||
        LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
        SUBSTR(rod_cislo, 5, 2), 'RRMMDD'), 'D') = '1';

SELECT 
  meno,
  priezvisko,
  rod_cislo,
  TO_CHAR(
    TO_DATE(
      SUBSTR(rod_cislo, 1, 2) ||
      LPAD(TO_CHAR(MOD(TO_NUMBER(SUBSTR(rod_cislo, 3, 2)), 50)), 2, '0') ||
      SUBSTR(rod_cislo, 5, 2),
      'RRMMDD'
    ),
    'Day',
    'NLS_DATE_LANGUAGE = SLOVAK'
  ) AS den_narodenia
FROM 
  p_osoba;
  
SELECT m.n_mesta, COUNT(DISTINCT o.rod_cislo) AS pocet_nezamestnanych
FROM p_osoba o
JOIN p_mesto m ON o.PSC = m.PSC
LEFT JOIN p_zamestnanec z ON o.rod_cislo = z.rod_cislo
WHERE z.rod_cislo IS NULL
GROUP BY m.n_mesta
ORDER BY pocet_nezamestnanych DESC;

SELECT 
  o.meno,
  o.priezvisko,
  o.rod_cislo,
  COUNT(op.cis_platby) AS pocet_platieb
FROM 
  p_poistenie p
JOIN 
  p_osoba o ON o.rod_cislo = p.rod_cislo
LEFT JOIN 
  p_odvod_platba op ON p.id_poistenca = op.id_poistenca
GROUP BY 
  o.meno, o.priezvisko, o.rod_cislo
ORDER BY 
  pocet_platieb DESC;
  
ALTER TABLE p_poistenie
ADD CONSTRAINT fk_poistenie_osoba
FOREIGN KEY (rod_cislo)
REFERENCES p_osoba(rod_cislo);

CREATE OR REPLACE TRIGGER trg_zaporna_suma
BEFORE INSERT OR UPDATE ON p_odvod_platba
FOR EACH ROW
BEGIN
    IF :NEW.suma < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Suma nesmie byť záporná.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_existencia_osoby
BEFORE INSERT ON p_poistenie
FOR EACH ROW
DECLARE v_pocet INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_pocet
    FROM p_osoba
    WHERE rod_cislo = :NEW.rod_cislo;
    
    IF v_pocet = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Osoba s daným rodným číslom neexistuje.');
    END IF;
END;
/

37. Vypíš všetkých poistencov, ktorí nemajú žiadne platby.
CREATE OR REPLACE PROCEDURE poistenci_bez_platieb IS
  CURSOR c_bez_platieb IS
    SELECT o.meno, o.priezvisko, o.rod_cislo
    FROM p_poistenie p
    JOIN p_osoba o ON o.rod_cislo = p.rod_cislo
    WHERE NOT EXISTS (
        SELECT 1
        FROM p_odvod_platba op
        WHERE op.id_poistenca = p.id_poistenca
    );

  v_meno       p_osoba.meno%TYPE;
  v_priezvisko p_osoba.priezvisko%TYPE;
  v_rod_cislo  p_osoba.rod_cislo%TYPE;
BEGIN
  OPEN c_bez_platieb;
  LOOP
    FETCH c_bez_platieb INTO v_meno, v_priezvisko, v_rod_cislo;
    EXIT WHEN c_bez_platieb%NOTFOUND;
    
    DBMS_OUTPUT.PUT_LINE('Poistenec: ' || v_meno || ' ' || v_priezvisko || ', RČ: ' || v_rod_cislo);
  END LOOP;
  CLOSE c_bez_platieb;
END;
/

BEGIN
  poistenci_bez_platieb;
END;
/

DELETE FROM p_odvod_platba
WHERE id_poistenca IN (
  SELECT p.id_poistenca
  FROM p_poistenie p
  WHERE p.dat_od < DATE '2010-01-01'
    AND p.id_poistenca NOT IN (
      SELECT id_poistenca
      FROM p_odvod_platba
      WHERE dat_platby > DATE '2015-01-01'
    )
);

DELETE FROM p_poistenie
WHERE dat_od < DATE '2010-01-01'
  AND id_poistenca NOT IN (
    SELECT DISTINCT id_poistenca FROM p_odvod_platba
  );

rollback;
    
    


