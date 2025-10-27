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

    -- 3. Potrebujeme mapovať rodné číslo (VARCHAR2) → počet poistení (INTEGER) s
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
    -- VARRAY má vlastnosť LIMIT, vnorená tabuľka (TABLE OF) ju nemá.
    -- Po DELETE(i) vo vnorenej tabuľke môžu vznikať diery v indexoch.
    -- Iterácia FOR i IN 1..COUNT je bezpečná pre vnorenú tabuľku aj po DELETE(i).
    -- Asociatívne pole podporuje textové kľúče a iteráciu cez FIRST/NEXT.
    -- 5. Doplňte telo cyklu tak, aby iterácia bezpečne vypísala všetky existujúce
    -- prvky vo vnorenej tabuľke po viacerých DELETE(i) (kolekcia môže mať diery):
    -- declare
    --  type t_tab is table of varchar2(50);
    --  t t_tab := t_tab('A','B','C','D','E');
    --  idx pls_integer;
    -- begin
    --  t.delete(2); t.delete(4);
    --  idx := XXXXXX;
    --  while idx is not null loop
    --  dbms_output.put_line(t(idx));
    --  idx := XXXXXX;
    --  end loop;
    -- end;
    -- /
    -- Doplňte (a) a (b) tak, aby sa použila správna iterácia nad kolekciou so schodmi v
    -- indexoch.

