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


--***************************** DDU ************************************
-- 10 zaznamov rokov s odchylkou +- 10, connect by level <= 10

    
