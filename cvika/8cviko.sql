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
    
select count(*) from p_logy;

declare 
begin
    insert into p_logy(id, datum, text)
        values (2, sysdate, 'Priamo vlozeny zaznam');
    log_vynimky('Autonomna');
    rollback;
end;
--V tabulke bude id 1, pretoze je autonomna a je jej jedno ci si id 2 robi rollback

-- deferrable constraints
-- kontrola integritneho obmedzenia hned alebo neskor
-- immediate a deferred

set constraints nazov immediate; -- bude platit pre 'nazov'
set constraints all immediate; --bude platit pre vsetky

--***************************** DDU ************************************
-- 10 zaznamov rokov s odchylkou +- 10, connect by level <= 10

    
