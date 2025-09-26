--Vypiste pocet pozicanii bicykla cislo 325
select ID_BICYKEL, count(ID_BICYKEL) from BIKESHARING.B_POZICANIE
where ID_BICYKEL = 325
group by ID_BICYKEL;

--Vymazte opravy ktore este neskoncili - ano, fakt to je len delete from b_oprava where do is null.
delete from BIKESHARING.B_OPRAVA where do is null;

--Trigger - nemozte vlozit do b_stojan ak je nedela a mesto je Puchov
create or replace trigger mestoNedelaPuchov
    before insert on VYHNAL1.B_STOJAN
    for each row
    declare
    mesto varchar2(15);
    begin
        select nazov into mesto from B_MESTO where psc = :new.psc;
        if to_char(sysdate, 'D') = 7 and mesto like 'Puchov' then raise_application_error(-20000, 'Puchov nedela');
        end if;
    end;

-- Vypiste vsetkych ludi + ak je zamestanec tak ID a odkedy
select meno, priezvisko, ID_ZAMESTNANEC, od from VYHNAL1.B_OS_UDAJE
left join VYHNAL1.B_ZAMESTNANEC using (rod_cislo);

--Vypiste najdlhsie trvajucu ukoncenu opravu tento rok
select * from B_OPRAVA
where do-od = (select max(do-od) from VYHNAL1.B_OPRAVA where do is not null);

create view v1 as select rod_cislo, meno, PRIEZVISKO from VYHNAL1.B_OS_UDAJE where meno = 'Michal';
create view v2 as select * from v1 where PRIEZVISKO like 'M%' with check option;
insert into v2 values ('551204/1254', 'Karol', 'Matiasko');
-- NEPREJDE TO!!!


--Ku kazdemu bicyklu, kolko roznych zakaznikov si ho pozicalo. Ak si ho nikto nepozical nikto vypisat id_zakaznik
select ID_BICYKEL,
    case
        when count(ID_ZAKAZNIK) = 0 then 'ID_ZAKAZNIK'
        else to_char(count(ID_ZAKAZNIK))
    end as pocet
from VYHNAL1.B_BICYKEL left join VYHNAL1.B_POZICANIE using (id_bicykel)
    group by ID_BICYKEL;

--Vypiste typ zamestnanca, z ktoreho sme minuly rok prijali najviac zamestnancov
select ID_TYP, nazov, count(*) from VYHNAL1.B_ZAMESTNANEC join VYHNAL1.B_TYP_ZAMESTNANCA using (id_typ)
    having count(*) in (select max(count(id_typ)) from VYHNAL1.B_ZAMESTNANEC where OD >= add_months(sysdate, -12)
                                                                             group by B_ZAMESTNANEC.ID_TYP)
group by ID_TYP, NAZOV;

with rocny_ubytok as ( select extract(year from DO) as rok, count(*) as pocet_prepustenych from VYHNAL1.B_ZAMESTNANEC
                                                                               where do is not null
                                                                               group by DO)
select avg(pocet_prepustenych) as priemer from rocny_ubytok;

select nazov, psc, listagg(ID_STOJAN, ', ') within group ( order by ID_STOJAN) from VYHNAL1.B_MESTO
left join VYHNAL1.B_STOJAN using (psc)
group by nazov, psc;







