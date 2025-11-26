-- transakcie, insert, savepoint, rollback

--prakticky json - tie si treba prejst z uloh

-- prakticke indexy, otzky typu vytvorte vhodny index nad danym..., STROMY, B+ tree, rozne typy pristupov, Sposoby spajania tabuliek

-- pokrocila statistika a analytika -- case, sum, ...

-- DBLINK -- vytvorenie dblinku, alebo bude vyvoreny a pomocou neho pristupte k inej DB

-- Teoria na BLOB, CLOB, BFILE

-- ABCD - 10. prednaska - aky je hardware - treba pozriet obidve prednasky, merge join, hash join, transakcie...

-- budu aj teoreticke doplnovacky typu co je to transakcia...

-- ******** Kurzory ani generovanie prikazov NEBUDU!! ******
-- kolekcie NEBUDU, XML tiez, outer join ani exists ani objekty


create table del_tab(
    os_cislo int primary key
);

insert into del_tab select os_cislo from student
where st_odbor = 'Informatika';


-- POkracovanie Cvika
create table kontakty
(id_kontaktu integer, 
 rod_cislo char(11), 
 typ char(1) check (typ in ('E', 'M')),
 hodnota varchar(50));

exec kvet3.vloz_kontakty;

create table rodokmen
(id integer primary key, 
 meno varchar(50), 
 priezvisko varchar(50), 
 id_matky integer, 
 id_otca integer, 
 foreign key(id_matky) references rodokmen(id),
 foreign key(id_otca) references rodokmen(id)
); 

-- vybrat vsetkych z os_udaje kt. rod_cislo sa nenachadza v tabulke kontakty

--not in porovnanie s null - sql vrati unkown 
select meno, priezvisko, rod_cislo from os_udaje 
    where rod_cislo not in(select nvl(rod_cislo, 'XXX') from kontakty); -- da sa nahradit null hodnota, popripade where rod_cislo is not null
    
-- istejsie je to pisat s exists, pretoze vrati TRUE ak existuje aspon jeden riadok
select meno, priezvisko, rod_cislo from os_udaje 
    where not exists(select 'x' from kontakty where os_udaje.rod_cislo = kontakty.rod_cislo);
    
-- surodenci
-- rovnake id matky sa spoja
select dieta.meno, dieta.priezvisko, rodic.meno, rodic.priezvisko
from rodokmen dieta join rodokmen rodic using(id_matky)
where dieta.id > rodic.id; -- nespaja surodencov aj naopak, napr. 3 a 4 A 4 a 3, a takisto nespaja mna ako surodenca

--ku kazdej osobe vypise matku
select d.meno, d.priezvisko, m.meno, m.priezvisko
from rodokmen d left join rodokmen m on (d.matka = m.matka);

select rpad(' ', level) || meno || ' ' || priezvisko
from rodokmen
 connect by prior id = case when id=id_matky then null
                            else id_matky
                            end
start with id = 2;

-- INDEX - struktura co pomaha rychlejsie vyhladavat v datach
    -- B+strom, bitmap
    create table osoba_tab as select * from kvet3.osoba_tab;
    select meno, priezvisko
        from osoba_tab;
        
    create index ind1 on osoba_tab(priezvisko, meno);
    
    select meno, priezvisko from osoba_tab where meno='Michal';
    
    select count(*), count(distinct priezvisko) from osoba_tab;
    
    create index ind2 on osoba_tab(meno, priezvisko);
    
    select /*+index(osoba_tab ind2 )*/ meno, priezvisko from osoba_tab; -- prinutime ho pouzit prave tento index, 
                                                                        --aj ked si optimilizator mysli ze to neni najlepsia volba









