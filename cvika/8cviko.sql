select * from p_osoba;

exec dbms_stats.gather_table_stats(user, 'p_osoba');

-- dobrat si ake su typy joinov. Hash...

-- dbms_random na nahodne generovanie

create table random_table as 
    select rownum as id,
    -- U -- velke pismena, -- L male, A - alfanumericke, X - hexadecimalne
    dbms_random.string('U', 5) as kod,
    trunc(dbms_random.value(18, 80)) as vek
    from dual
    connect by level <= 10;
    
select * from random_table;

-- dbms_random.normal generuje gausove rozdelenie
select to_date('2024.01.01', 'YYYY.MM.DD') + 
    trunc(dbms_random.value(0, 365)) as datum from dual
connect by level <= 5;

-- ACID - atomicita - bud sa vykona transakcia cela alebo vobec, 
-- konzistencia - transakcia musi ist z platneho stavu do dalsieho platneho stavu, 
-- izolovanost - viacero transakcii co idu naraz sa nesmu , 
-- trvalost(durability)- ak dojde napr elektrika a data uz su v DB tak to tam musi zostat

-- commit/rollback/savepoint - zaciatok/koniec transakcie

select * from p_prispevky where id_poberatela = 7751;
insert into p_prispevky values(7751, sysdate, 3, sysdate, 300);
savepoint krok1;
select sum(suma) from p_prispevky where id_poberatela = 7751;
--1547

update p_prispevky set suma = suma + 10 
    where id_poberatela = 7751;
--1557

rollback to krok1;
select sum(suma) from p_prispevky where id_poberatela = 7751;
--1547

--ak spravime commit tak sa vsetky doterajsie savepointy vymazu !!!!


-- hniezdene - transakcia v transakcii a autonomne transakcie - uplne nezavisle transakcie

create table p_logy(
    id number primary key,
    datum date default sysdate not null,
    text varchar2(400)
);

create or replace procedure log_vynimku(p_text varchar2) is
pragma autonomous_transaction;
    begin
        insert into p_logy(id, datum, text) values (1, sysdate, p_text);
        commit; -- nezavisly commit
    end;
/    
select count(*) from p_logy;

declare 
begin
    insert into p_logy(id, datum, text)
        values (2, sysdate, 'Priamo vlozeny zaznam');
    log_vynimky('Autonomna');
    rollback;
end;
/
--V tabulke bude id 1, pretoze je autonomna a je jej jedno ci si id 2 robi rollback

-- deferrable constraints
-- kontrola integritneho obmedzenia hned alebo neskor
-- immediate a deferred

set constraints nazov immediate; -- bude platit pre 'nazov'
set constraints all immediate; --bude platit pre vsetky

--recyclebin a flashback
create table test_dal as select * from p_osoba where rownum <= 3;
drop table test_dal;
show parameter recyclebin;
flashback table test_dal to before drop;
purge recyclebin;


--flashback
select * from p_osoba where rod_cislo = '790705/8379';
update p_osoba set meno = 'Zmenene' where rod_cislo = '790705/8379';
select * from p_osoba as of timestamp (systimestamp - interval '5' minute) where rod_cislo = '790705/8379';
flashback table p_osoba to timestamp (systimestamp - interval '5' minute);

--connect by level - co to je?
-- oracle mechanizmus na prechadzanie stromovej struktury
-- napr. zamestnanec - nadriadeny
-- root je vzdy 1 ak nedefinujeme inak

select level as poradie from dual connect by level <= 10;

create table emp_demo(
    id number primary key,
    meno varchar2(50) not null,
    manazer_id number null
);

insert into emp_demo values(1, 'Jana', null);
insert into emp_demo values(2, 'Boris', 1);
insert into emp_demo values(3, 'Cyril', 2);
insert into emp_demo values(4, 'Dana', 3);
insert into emp_demo values(5, 'Martin', 4);

-- level ukazuje hlbku, 1 - koren, 2 dieta, 3 vnuk...
select meno, manazer_id, level from emp_demo start with manazer_id is null -- zacni od korena (bez sefa)
    connect by prior id = manazer_id;

-- with  -virtualna tabulka s ktorou vieme nasledne pracovat
with studenti as (
    select os_cislo, rocnik from student where rocnik = 1
)
select * from studenti;

with mesiace as(
    select level mesiac from dual
    connect by level <= 12
) select mesiac, to_char(to_date(mesiac, 'MM'), 'Month', 'NLS_DATE_LANGUAGE=ENGLISH') as nazov from mesiace;


-- pre kazdeho zamestnavatela vypis pocet poistenych zien a muzov
select nazov, sum(case when to_number(substr(rod_cislo, 3, 2)) >= 50 then 1 else 0 end) pocet_zien,
    sum(case when to_number(substr(rod_cislo, 3, 2)) < 50 then 1 else 0 end) pocet_muzov
from p_zamestnavatel
join p_zamestnanec on (id_zamestnavatela = ico)
join p_osoba using(rod_cislo)
group by nazov, ICO;

-- zadanie na DOMA
--pocet poistencov narodenych v jednotlivych mesiacoch, roztriedenych podla stavu oslobodenia (A, A/N, N)
-- with, connect by level a case

--***************************** DDU ************************************
-- 10 zaznamov rokov s odchylkou +- 10, connect by level <= 10

    
