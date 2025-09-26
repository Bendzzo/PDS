-- Vytvorte funkciu, ktor· vr·ti poËet, koækokr·t bol dan˝ bicykel poûiËan˝.
create or replace function pocetPozicani(f_id_bicykel in B_POZICANIE.id_bicykel%type)
return integer
as
    pocet integer;
    begin
        select count(*) into pocet from VYHNAL1.B_POZICANIE
        where id_bicykel = f_id_bicykel;
        return pocet;
    end;

select POCETPOZICANI(57) as pocet from dual;

select ID_BICYKEL,count(*) pocet from VYHNAL1.B_POZICANIE
    group by ID_BICYKEL;

--Vytvorte pohæad, ktor˝ bude obsahovaù vöetky vyradenÈ bicykle spolu s inform·ciou, koækokr·t bola nahl·sen· porucha danÈho bicykla.
create or replace view vyradeneBicykle as
    select ID_BICYKEL, count(*) as pocetPoruch from B_PORUCHA
        where exists(select 'x' from B_BICYKEL
                                where VYRADENIE is not null)
    group by ID_BICYKEL
    order by pocetPoruch desc, ID_BICYKEL;

select * from vyradeneBicykle;

-- VypÌöte koækokr·t bol v oprave bicykel Ë. 325.
select ID_BICYKEL, count(*) as pocet from VYHNAL1.B_OPRAVA
    where ID_BICYKEL= 325
    group by ID_BICYKEL;

-- NapÌöte trigger, ktor˝m zabezpeËÌte, aby sa nepridal stojan do mesta 'P˙chov' v nedeæu.
create or replace trigger triggerNedelaPuchov
    before insert on B_STOJAN
    for each row
    declare
        v_mesto varchar2(20);
begin
    select nazov into v_mesto from VYHNAL1.B_MESTO
    where psc = :new.psc;

    if  to_char(:new.vybudovanie, 'D') = 7 and v_mesto = 'P˙chov' then
            raise_application_error(-20000, 'Bicykle sa do stojanu v nedelu nedavaju');
    end if;
end;

select * from VYHNAL1.B_MESTO;

insert into VYHNAL1.B_MESTO (PSC, NAZOV) values ('02001', 'P˙chov');
insert into VYHNAL1.B_STOJAN (id_stojan, psc, ulica, vybudovanie, zrusenie, info) values (778, '02001', 'HOLDOVA', to_date('12.05.2024', 'DD.MM.YYYY'), null, null);
-- ---------------------------------------------------NESPRAVNE-------------------------------------------------------------

--VypÌöte meno, priezvisko, rodnÈ ËÌslo vöetk˝ch osÙb a ak s˙ zamestnancami tak aj ich id a d·tum, oodkedy s˙ zamestnanÌ.
select MENO, PRIEZVISKO, ROD_CISLO, ID_ZAMESTNANEC, od from VYHNAL1.B_OS_UDAJE
    left join VYHNAL1.B_ZAMESTNANEC using (rod_cislo)
        order by ID_ZAMESTNANEC;


-- Pre vöetky mest· vypÌöte koæko bicyklov je zaparkovan˝ch na danom stojane, ak tam nebol zaparkovan˝ ani jeden tak vypÌöte 0.
select nazov, psc, p.ID_STOJAN,count(p.id_bicykel) as POCET_BICYKLOV
from BIKESHARING.B_MESTO m
    left join BIKESHARING.B_STOJAN s using (psc)
    left join BIKESHARING.B_PARKOVANIE p on (s.ID_STOJAN = p.ID_STOJAN)
group by nazov, PSC, p.ID_STOJAN
    order by psc desc;

SELECT ID_STOJAN,  COUNT(*)
FROM BIKESHARING.b_stojan
         left JOIN BIKESHARING.b_parkovanie p using(id_stojan)
where ZRUSENIE is not null
GROUP BY ID_STOJAN,psc;

select * from VYHNAL1.B_MIESTO
    where ID_STOJAN = 70;
---------------------------------------------------- Zapocet PON 10:00 --------------------------------------------------------------------------------------------------------
-- Trigger, ktory zabezpeci aby vyradenie (update) bicykla mohol vykonavat len pouzivatel 'kmat'
create or replace trigger checkKmat
    before update on VYHNAL1.B_BICYKEL
    for each row

begin
    if user <> 'kmat' then
        raise_application_error(-20000, 'Iba kmat moze upravovat');
        return;
    end if;
end;

-- Vypis bicyklov, ktore boli pozicane viac ako jedenkrat
select ID_BICYKEL, count(*) from VYHNAL1.B_POZICANIE
    having count(*) > 1
    group by ID_BICYKEL;

-- Funkcia, ktora vrati priemerny pocet oprav za rok zadaneho bicykla za poslednych 10 rokov
create or replace function pocetOpravZaRok(f_id_bicykel in B_BICYKEL.id_bicykel%type)
return number
as
    priemer number;
    begin
        select count(*) / 10 into priemer from VYHNAL1.B_OPRAVA
            where ID_BICYKEL = f_id_bicykel and do >= add_months(sysdate, -120)
        group by priemer;
        return priemer;
    end;
-- ???????????????????????????????????????????????????????????????????????????????????
select pocetOpravZaRok(2) from dual;

-- Pre kazdy bicykel vypiste pocet pozicani, ktore boli vykonane v prvom kvartali minuleho roka
select ID_BICYKEL, count(*) pocet_Pozicani from VYHNAL1.B_POZICANIE
    where extract(month from od) <= 3 and months_between(OD, sysdate) <= 12
    group by ID_BICYKEL;


-- Pohlad, ktory obsahuje informacie o vsetkych zakaznikoch, ktori este nenahlasili ziadnu poruchu
create or replace view nenahlasujuci_zakaznici
as
    select * from VYHNAL1.B_ZAKAZNIK where
    not exists(select 'x' from VYHNAL1.B_PORUCHA
                          where B_PORUCHA.ID_ZAKAZNIK = B_ZAKAZNIK.ID_ZAKAZNIK);

select * from nenahlasujuci_zakaznici
    order by ID_ZAKAZNIK;

select ID_ZAKAZNIK from VYHNAL1.B_PORUCHA
    where ID_ZAKAZNIK is not null ;
    --where ID_ZAKAZNIK = 2434;

-- Ku kazdemu typu zamestnanca vypiste jeho ID, nazov a zoznam vsetkych zamestnancov tohto typu. Vypiste aj typy zamestnanca ku ktorym neevidujeme ziadneho zamestnanca
select ID_TYP, NAZOV, LISTAGG(z.ID_ZAMESTNANEC, ', ') WITHIN GROUP (ORDER BY z.ID_ZAMESTNANEC) AS zamestnanci from B_TYP_ZAMESTNANCA
    left join B_ZAMESTNANEC z using (id_typ)
    group by ID_TYP, NAZOV;

select * from VYHNAL1.B_TYP_ZAMESTNANCA;
insert into VYHNAL1.B_TYP_ZAMESTNANCA (id_typ, nazov) VALUES (3, 'upratovac');

-- TEST 3 -----------------------------------------------------------------------
--Funkcia ktora vrati pocet, kolkokrat bol bicykel pozicany
create or replace function bicykel_pocet_pozicani(f_id_bicykel B_POZICANIE.id_bicykel%type)
return integer
as
    pocet integer;
 begin
       select count(*) as pocet_pozicani into pocet from VYHNAL1.B_POZICANIE
        where id_bicykel = f_id_bicykel;
       return pocet;
 end;

select BICYKEL_POCET_POZICANI(12) as pocet from dual;

--Pohlad ktory obsahuje vsetky vyradene bicykle spolu s informaciou, kolkokrat bola nahlasena porucha daneho bicykla
create or replace view vyradene_bicykle
as
    select ID_BICYKEL, count(*) pocet from VYHNAL1.B_POZICANIE
        where exists(select 'X' from VYHNAL1.B_BICYKEL where VYRADENIE is not null)
    group by ID_BICYKEL;

select *
from vyradeneBicykle;

-- Pre kazde mesto vypiste kolko bicyklov bolo zaparkovanych na stojane v danom meste. V pripade ze ziaden, vypiste 0
select NAZOV, psc, count(id_bicykel) from BIKESHARING.B_MESTO
left join BIKESHARING.B_STOJAN using (psc)
left join BIKESHARING.B_PARKOVANIE using (id_stojan)
group by NAZOV, psc;

select nazov, psc from VYHNAL1.B_MESTO;

-- Trigger, ktory zabezpeci ze sa neprida stojan do mesta 'Puchov' v nedelu
create or replace trigger stojan_nedela_puchov
    before insert on VYHNAL1.B_STOJAN
    for each row
    declare
        v_mesto varchar2(30);
    begin
        select NAZOV into v_mesto from VYHNAL1.B_MESTO
            where PSC = :new.psc;

        if to_char(:new.VYBUDOVANIE, 'D') = 7 and v_mesto = 'Puchov' then
            raise_application_error(-20000, 'V nedelu sa nepridava');
        end if;
    end;

insert into VYHNAL1.B_MESTO (psc, nazov) VALUES ('11111', 'Puchov');

insert into VYHNAL1.B_STOJAN (id_stojan, psc, ulica, vybudovanie, zrusenie, info)
values (1, '11111', 'Namorska', to_date('12.05.2024', 'DD.MM.YYYY'), null, 'BLBASFSF');

-- pocet oprav bicykla 325
select ID_BICYKEL, count(*) from VYHNAL1.B_OPRAVA
    where ID_BICYKEL = 325
 group by ID_BICYKEL;

-- Vytvorte funkciu, ktor· vr·ti celkov˙ sumu, ktor˙ minul zadan˝ z·kaznÌk za svoje poûiËania.
create or replace function minuta_suma_pozicania(f_id_zakaznik B_POZICANIE.id_zakaznik%type)
return integer
as
    suma integer;
begin
    select sum(CENA) into suma from VYHNAL1.B_POZICANIE
        where f_id_zakaznik = ID_ZAKAZNIK;
    return suma;
end;

select MINUTA_SUMA_POZICANIA(2) as suma from dual;

select MENO, PRIEZVISKO, ROD_CISLO, ID_ZAKAZNIK, OD from B_OS_UDAJE
left join B_ZAKAZNIK using (rod_cislo);

select ID_BICYKEL from Vyhnal1.B_OPRAVA
where do is not null;

select ID_BICYKEL, ZARADENIE, VYRADENIE, listagg(ID_ZAKAZNIK, ',') within group ( order by ID_BICYKEL)
    from VYHNAL1.B_BICYKEL
    left join VYHNAL1.B_POZICANIE using (id_bicykel)
group by ID_BICYKEL, ZARADENIE, VYRADENIE;



