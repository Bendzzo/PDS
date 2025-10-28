-- Vypíšte nasledovnú štatistiku.
-- K jednotlivým mestám Nitrianskeho okresu vypíšte pre obdobie od 16.6.2016 do 19.6.2016 celkovú sumu(eur), ktorá bola zaplatená poberateľom daného kraja.
select N_MESTA, sum(SUMA) from P_MESTO
                                   join p_osoba using (PSC)
                                   join P_POBERATEL using(ROD_CISLO)
                                   join p_prispevky using(id_poberatela)
where ID_OKRESU = 'NR' and
    OBDOBIE >= to_date('16.06.2016', 'DD.MM.YYYY') and kedy <= to_date('19.06.2016', 'DD.MM.YYYY')
group by N_MESTA;

-- Pomocou SQL generujte príkazy na zrušenie linuxového konta všetkých zamestnancov, ktorí ukončili pracovný pomer v posledný mesiac,
-- ak login je osobné číslo zamestnanca a syntax príkazu je:
-- userdel login

select 'userdel ' || ROD_CISLO from P_ZAMESTNANEC
where DAT_DO >= add_months(sysdate, -1);

-- Vytvorte XML dokument nasledujúceho formátu - poberatelia, ktorí dostali doteraz celkovo aspoň 1000Eur.
-- <osoby>
-- <clovek>Michal Kvet</clovek>
-- <clovek>Marek Kvet</clovek>
-- </osoby>
-- </mesto>

    select xmlroot(
              xmlelement(
                  "Osoby",
                  xmlagg(
                          xmlelement("Clovek", Meno || ' ' || PRIEZVISKO)
                  )
              ), version no value
    ) as xml from P_OSOBA
    join p_poberatel using(rod_cislo)
    join p_prispevky using(id_poberatela)
    having sum(suma) >= 1000;

--xmlagg
select xmlroot(
               xmlelement("osoba",
                          xmlattributes (rod_cislo as rc),
                          xmlforest(
                                  meno  "meno",
                                  priezvisko as "priezvisko",
                                  dat_zapisu as "dat_zapisu"
                          ),
                          xmlagg(xmlelement("Predmety", nazov))
               ), version no value --1.0
       ) as xml
from os_udaje join student using(rod_cislo)
              join zap_predmety using(os_cislo)
              join predmet using(cis_predm)
group by rod_cislo, meno, priezvisko, dat_zapisu;

--Aká hodnota bude vypísaná na obrazovke:

declare
    type t_pole IS VARRAY(4) OF integer;
    pole t_pole;
begin
    pole:=t_pole(10,20,30,40,50);
    pole.delete(4);
    dbms_output.put_line(pole.count);
end;

--ODPOVED: Bude vyvolana chyba, pretoze sa do pola pridava 5 prvkov aj ked je o velkosti 4. A delete vymaze cele pole, cize sa nepouziva s parametrom.
-- NIE pole.delete(4) ALE pole.delete

-- Zápočet 1 - 29.10.2024
-- ABCD - bola napísaná funkcia ktorá začínala XXXXX member function niečo a za XXXXX sa malo vybrať čo treba doplniť aby sa použila pri triedení - v tomto prípade to bol ORDER lebo bol parameter s tým istým typom
-- ABCD - bola daná nested table s prvkami 10, 20, …, 70 a bol zavolaný príkaz nad nested table pole.delete(10) a že čo vypíše pole.last
-- ABCD - pre select into platí a 4 možnosti
-- Vypísať štatistiku - riadky kraje, stĺpce prvé tri mesiace roku 2018 a pre každý kraj koľko bolo dokopy príspevkov
-- Vypísať 30% najbohatších poberateľov príspevkov za posledné 2 roky myslím
-- Vygenerujte príkazy na pridanie práv create any directory osobe, ktorá v nejakom roku študovala nejaký predmet
-- Veľmi jednoduchý select z tabuľky xml dokumentov kde sa malo vypísať mená a priezviská
-- Vypíšte okresy, v ktorých sa nenachádzajú postihnuté ženy
-- Vypíšte všetky poistenia (stĺpce id_poistenca, rod_cislo, id_platitela) a v prípade, že je platba nad 100€ tak aj info o platbe (stĺpce cis_platby, suma)


-- ************************************************** OPAKOVANIE **********************************************************************************
-- 1. GENEROVANIE PRÍKAZOV
    -- 1. Pomocou SELECT vygenerujte DROP TABLE príkazy pre všetky tabuľky v aktuálnej
    -- schéme, ktoré obsahujú v názve reťazec 'ZALOHA'.
    select 'drop table ' || table_name from TABS
        where TABLE_NAME like 'P%';


    -- 2. Napíšte SELECT, ktorý na základe systémových metadát vygeneruje príkazy na
    -- zrušenie všetkých cudzích kľúčov v tabuľke p_prispevky.
    select 'alter table p_prispevky drop constraint ' || constraint_name from USER_CONSTRAINTS
        where TABLE_NAME = 'P_PRISPEVKY';

    -- 3. Pomocou SELECT vygenerujte príkazy na pridelenie práv SELECT pre všetky
    -- tabuľky používateľovi student. Využite systémové tabuľky so zoznamom tabuliek.
    select 'grant select ' || table_name || ' to student' from tabs;

    -- 4. Vytvorte SELECT, ktorý pre každý stĺpec v schéme začínajúci na id_ a dátového
    -- typu NUMBER vygeneruje CREATE SEQUENCE s názvom seq_<table_name>-
    -- _<column_name>.
    select 'create sequence seq_' || table_name || '_' || column_name from USER_TAB_COLUMNS
        where COLUMN_NAME like 'ID_%'
        and DATA_TYPE = 'NUMBER';

    -- 5. Pomocou SELECT vygenerujte príkazy na vypnutie všetkých triggerov vo všetkých
    -- tabuľkách aktuálnej schémy.
    select 'alter trigger ' || trigger_name || ' disable;' from USER_TRIGGERS;

set serveroutput on;

-- 3. KOLEKCIE
    -- 1. Majme kód:
    declare
    type t_pole IS VARRAY(4) OF integer;
     i integer;
     pole t_pole;
     j integer;
    begin
     pole := t_pole(1,2,3,4);
     j := pole.first;
     for i in 1 .. XXXXXXX loop
     dbms_output.put_line(pole(j));
     j := pole.next(j);
     end loop;
    end;
    /
    -- Čo je potrebné doplniť namiesto XXXXXX, aby boli vypísané všetky prvky poľa.
    --ODPOVED: pole.count

    -- 2. Majme:
    declare
     type t_pole is table of integer;
     pole t_pole;
    begin
     pole := t_pole(1,2,3,4,5,6,7,8);
     pole.delete(2);
     FOR i in 1 .. pole.count LOOP
         if pole.exists(i) then
            dbms_output.put_line(pole(i));
         end if;
     END LOOP;
    end;
    /
    -- Akú deklaráciu musíme definovať namiesto XXXXXXXXXX, aby výpis prebehol úspešne aj
    -- pri dierach v indexoch po DELETE(2).

    -- 3. Potrebujeme mapovať rodné číslo (VARCHAR2) ? počet poistení (INTEGER) s
    -- rýchlym prístupom podľa kľúča a bez požiadavky na súvislé indexy.
    -- Doplňte vyznačené časti:
    declare
     type t_map is table of number XXXXXXXX; -- index by varchar2(11);
     m t_map;
     k XXXXXXXXXX -- varchar2(11);
    begin
     m('010101/0001') := 3;
     m('990101/1234') := 0;
     k := m.first;
     while k is not null loop
     dbms_output.put_line(k || ' => ' || m(k));
     k := m.next(k);
     end loop;
    end;
    /
    -- Doplňte (a) a (b) tak, aby kód fungoval pre pole s textovým kľúčom.


    -- 4. Majme anonymný blok, v ktorom sú použité rôzne typy kolekcií. Určte, ktoré z
    -- nasledujúcich tvrdení o kolekciách platí:
    -- VARRAY má vlastnosť LIMIT, vnorená tabuľka (TABLE OF) ju nemá. -- PRAVDA
    -- Po DELETE(i) vo vnorenej tabuľke môžu vznikať diery v indexoch. -- PRAVDA
    -- Iterácia FOR i IN 1..COUNT je bezpečná pre vnorenú tabuľku aj po DELETE(i). --NEPRAVDA, pretoze sa uz neprejdu vsetky prvky
    -- Asociatívne pole podporuje textové kľúče a iteráciu cez FIRST/NEXT. -- PRAVDA



    -- 5. Doplňte telo cyklu tak, aby iterácia bezpečne vypísala všetky existujúce
    -- prvky vo vnorenej tabuľke po viacerých DELETE(i) (kolekcia môže mať diery):
    declare
     type t_tab is table of varchar2(50);
     t t_tab := t_tab('A','B','C','D','E');
     idx pls_integer;
    begin
     t.delete(2); t.delete(4);
     idx := t.FIRST;
     while idx is not null loop
         dbms_output.put_line(t(idx));
         idx := t.NEXT(idx);
     end loop;
    end;
    /
    -- Doplňte (a) a (b) tak, aby sa použila správna iterácia nad kolekciou so schodmi v
    -- indexoch.

-- KURZORY
    -- 1. Napíšte anonymný PL/SQL blok, ktorý pomocou implicitného kurzora FOR vypíše
    -- mená a priezviská všetkých osôb spolu s počtom poistení, ktoré majú v tabuľke
    -- p_poistenie. Zobrazte aj osoby, ktoré nemajú žiadne poistenie (počet = 0).
        begin
            for rec in (
                select meno, priezvisko, count(ID_POISTENCA) poistenie from P_OSOBA
                left join p_poistenie using(rod_cislo)
                group by meno, priezvisko, ROD_CISLO
            )
            loop
                 DBMS_OUTPUT.PUT_LINE('Meno: ' || rec.MENO);
                 DBMS_OUTPUT.PUT_LINE('Priezvisko: ' || rec.PRIEZVISKO);
                 DBMS_OUTPUT.PUT_LINE('Pocet: ' || rec.poistenie);
            end loop;
        end;



    -- 2. Doplňte anonymný blok, ktorý pomocou explicitného kurzora prejde všetky
    -- poistné záznamy v tabuľke p_poistenie s dátumom začiatku pred 1. 1. 2020. V
    -- slučke vypíšte identifikátor poistenca a dátum začiatku. Počet spracovaných
    -- riadkov uložte do premennej a vypíšte ho po ukončení slučky.
        declare
            cursor cur_poistenie IS
                select id_poistenca, dat_od from P_POISTENIE
                    where DAT_OD < to_date('01.01.2020', 'DD.MM.YYYY');

            v_pocet_riadkov number := 0;
        begin
                for zoznam in cur_poistenie loop
                    DBMS_OUTPUT.PUT_LINE('ID: ' || zoznam.ID_POISTENCA || ', OD: ' || zoznam.DAT_OD);
                    v_pocet_riadkov := v_pocet_riadkov + 1;
                end loop;
                DBMS_OUTPUT.PUT_LINE('Pocet riadkov: ' || v_pocet_riadkov);
        end;


    -- 3. Napíšte PL/SQL blok, ktorý použije parametrizovaný kurzor, ktorý prijíma ako
    -- parameter identifikátor zamestnávateľa. Pre každého zamestnávateľa vypíše
    -- čísla a sumy platieb, ktoré uhradil svojim poistencom v aktuálnom roku.

    --ZLEE TO MAM
        declare
            cursor cur_1(p_ICO P_ZAMESTNAVATEL.ICO%type) is
                select CIS_PLATBY, SUMA, ICO from P_ZAMESTNAVATEL z
                join P_PLATITEL p on (z.ICO = p.ID_PLATITELA)
                join P_POISTENIE pp on (p.ID_PLATITELA = pp.ID_PLATITELA)
                join p_odvod_platba op on (pp.ID_POISTENCA = op.ID_POISTENCA)
                where p_ICO = ICO and
                    extract(year from OBDOBIE) = extract(year from sysdate);
        begin
            for zaznam in cur_1('%') loop
                DBMS_OUTPUT.PUT_LINE('ICO: ' || zaznam.ICO || ', cislo platby: ' || zaznam.CIS_PLATBY || ', suma: ' || zaznam.SUMA);
            end loop;
        end;

    -- 4. Doplňte PL/SQL blok, ktorý pomocou kurzora s klauzulou FOR UPDATE prejde
    -- všetky záznamy poistencov, ktorým končí platnosť poistenia v tomto mesiaci, a
    -- nastaví ich stĺpec oslobodeny na 'A'.

    declare
        cursor cur_poistenci is
            select * from P_POISTENIE
                where extract(month from DAT_DO) = extract(month from sysdate)
            for update of OSLOBODENY;
    begin
        for zaznam in cur_poistenci loop
            DBMS_OUTPUT.PUT_LINE('Aktualizujeme ' || zaznam.ROD_CISLO);

            update P_POISTENIE set OSLOBODENY = 'A'
                where current of cur_poistenci;
        end loop;
    end;



    -- 5. Napíšte anonymný blok s vnorenými kurzormi: vonkajší kurzor spracuje všetky
    -- kraje, vnútorný kurzor spracuje okresy patriace do daného kraja. Vypíšte názov
    -- kraja a zoznam názvov okresov, ktoré do neho patria.

    declare
        cursor cur_kraje is
            select * from p_kraj;

        cursor cur_okresy(p_id_kraja p_kraj.ID_KRAJA%type) is
            select * from p_okres
                     where ID_KRAJA = p_id_kraja;
    begin
        for kraje in cur_kraje loop
            DBMS_OUTPUT.PUT_LINE('Kraj: ' || kraje.n_kraja);
            for okresy in cur_okresy(kraje.ID_KRAJA) loop
                DBMS_OUTPUT.PUT_LINE(okresy.N_OKRESU);
            end loop;
        end loop;
    end;

    select n_kraja, listagg(n_okresu, ' ') within group ( order by N_OKRESU ) from P_KRAJ
        join P_OKRES using(id_kraja)
    group by n_kraja;

-- IN / EXISTS
    -- 1. Vypíšte mená a priezviská poistencov, ktorí majú aspoň jedno aktívne poistenie
    -- (t. j. dat_do IS NULL).
        select meno, priezvisko from p_osoba
            where ROD_CISLO in (select rod_cislo from P_POISTENIE
                                    where dat_do is null);


    -- 2. Zobrazte všetkých poistencov, ktorí nemajú evidovanú žiadnu platbu v tabuľke
    -- p_odvod_platba.
        select * from P_POISTENIE
            where ID_POISTENCA not in(select id_poistenca from P_ODVOD_PLATBA);
    -- 3. Zobrazte mená a priezviská poistencov, ktorí sa vyskytujú v oboch tabuľkách
    -- p_poistenie a p_poberatel.
        select meno, priezvisko from P_OSOBA
            where ROD_CISLO in (select ROD_CISLO from P_POISTENIE)
            and ROD_CISLO in (select ROD_CISLO from P_POBERATEL);

    -- 4. Vypíšte mená všetkých osôb, ktoré sú zároveň zamestnancami aj poistencami (v
    -- oboch tabuľkách p_zamestnanec a p_poistenie).
        select meno, priezvisko from P_OSOBA o
            where exists(select 'x' from P_ZAMESTNANEC z
                            where z.ROD_CISLO = o.ROD_CISLO)
                and exists(select 'x' from P_POISTENIE p
                                where o.ROD_CISLO = p.ROD_CISLO);

    -- 5. Zobrazte názvy miest, v ktorých nežije žiadna osoba s postihnutím „zrakové
    -- postihnutie“.
        select N_MESTA from P_MESTO m
            where not exists(select 'x' from P_OSOBA o
                                join p_ZTP using (rod_cislo)
                                join p_typ_postihnutia using(id_postihnutia)
                                where m.PSC = o.PSC and
                                NAZOV_POSTIHNUTIA = 'Zrakove Postihnutie');

-- OBJEKTY
    -- 1. Doplňte MAP MEMBER FUNCTION v objektovom type t_poistenie tak, aby kľúčom
    -- bolo id_platitela || '|' || TO_CHAR(dat_od,'YYYYMMDD').
    -- Následne utrieďte tabuľku (alebo tabuľku „OF object type“) podľa tohto objektu.
    create or replace type t_poistenie as object (
      id_poistenca P_POISTENIE.ID_POISTENCA%type,
      rod_cislo P_POISTENIE.ROD_CISLO%type,
      id_platitela P_POISTENIE.ID_PLATITELA%type,
      oslobodeny P_POISTENIE.OSLOBODENY%type,
      dat_od DATE,
      dat_do DATE,

      map member function tried return varchar2
    );

    create type body t_poistenie as
        map member function tried return varchar2 is
        begin
            return id_platitela || '|' || to_char(dat_od,'YYYYMMDD');
        end tried;
    end;


    -- 2. Doplňte ORDER MEMBER FUNCTION v type t_osoba, ktorá porovnáva najprv
    -- podľa priezvisko, potom podľa meno, a pri úplnej rovnosti zaradí rod_cislo
    -- vzostupne.Utrieďte záznamy podľa tejto metódy.
        create type body t_osoba as
        order member function porovnaj(p_osoba t_osoba) return integer is
        begin
            if priezvisko < p_osoba.priezvisko then
                return -1;
            elsif priezvisko > p_osoba.priezvisko then
                return 1;
            end if;

            if meno < p_osoba.meno then
                return -1;
            elsif meno > p_osoba.meno then
                return 1;
            end if;

            if rod_cislo < p_osoba.rod_cislo then
                return -1;
            elsif rod_cislo > p_osoba.rod_cislo then
                return 1;
            end if;

            return 0;
        end porovnaj;
    end;


    -- 3. Vytvorte typ t_zamestnavatel a doplňte MAP tak, aby triedil najprv podľa psc,
    -- sekundárne podľa nazov.
    -- Následne utrieďte tabuľku obsahujúcu tieto objekty.
        create or replace type t_zamestnavatel as object (
            ICO char(11),
            nazov varchar2(30),
            PSC CHAR(5),
            ulica varchar2(50),

            map member function tried return char
        );

        create or replace type body t_zamestnavatel as
            map member function tried return char is
            begin
                return PSC || '|' || NAZOV;
            end tried;
        end;


    -- 4. Doplňte ORDER MEMBER FUNCTION pre t_prispevok_hist, ktorá porovnáva
    -- primárne zakl_vyska zostupne a pri rovnosti dat_od vzostupne.
    -- Potom vykonajte triedenie nad tabuľkou s týmto typom.
        create or replace type body t_prispevok_hist as
            order member function tried(other t_prispevok_hist) return integer is
            begin
                if zakl_vyska < other.zakl_vyska then
                    return 1;
                elsif zakl_vyska > other.zakl_vyska then
                    return -1;
                end if;

                if dat_od < other.dat_od then
                    return -1;
                elsif dat_od > other.dat_od then
                    return 1;
                end if;

                return 0;
            end tried;
        end;



    -- 5. Definujte typ t_poberatel s atribútmi (rod_cislo, id_typu, dat_od, dat_do) a
    -- doplňte MAP na kľúč dat_od; pripravte aj Variant B s ORDER, ktorý dáva NULL
    -- dat_do až na koniec. Pre oba varianty vykonajte triedenie nad dátami.
    create or replace type t_poberatel as object(
        rod_cislo char(11),
        id_typu integer,
        dat_od date,
        dat_do date,

        map member function tried return varchar2
    );

    create or replace type t_poberatel as object(
        rod_cislo char(11),
        id_typu integer,
        dat_od date,
        dat_do date,

        order member function tried return varchar2
    );

--map
    create or replace type body t_poberatel as
        map member function tried return date is
        begin
            return dat_od;
        end tried;
    end;

--order
        create or replace type body t_poberatel as
        order member function tried(other t_poberatel) return integer is
        begin
            if dat_do is null and other.dat_do is not null then
                return 1;
            elsif dat_do is not null and other.dat_do is null then
                return -1;
            end if;

            if dat_do < other.dat_do then
                return -1;
            elsif dat_do > other.dat_do then
                return 1;
            end if;

            return 0;
        end tried;
    end;


-- OUTER JOIN
    -- 1. Vypíšte mená, priezviská a počet poistení pre všetky osoby vrátane tých, ktoré
    -- nemajú žiadne poistenie.
    
    -- 2. Vypíšte mená a priezviská poistencov spolu s dátumom poslednej platby, ak
    -- existuje. Ak poistenec nemá žiadnu platbu, zobrazte namiesto dátumu text bez
    -- platby.
    -- 3. Zobrazte všetkých zamestnávateľov a k nim priraďte zoznam poistencov, ktorí sú
    -- u nich aktuálne zamestnaní.
    -- 4. Vypíšte zoznam všetkých miest a pri každom z nich počet poistencov, ktorí tam
    -- majú trvalé bydlisko.Ak v niektorom meste žiadny poistenec nebýva, zobrazte
    -- počet ako 0.
    -- 5. Zobrazte názvy všetkých krajov spolu s priemerným počtom poistencov v nich.




