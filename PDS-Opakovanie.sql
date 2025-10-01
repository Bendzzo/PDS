--pocet poistencov pre kazdeho platitela
select ID_PLATITELA, count(ID_POISTENCA) as pocetPlatitelov from P_PLATITEL
    left join P_POISTENIE using(id_platitela)
group by ID_PLATITELA
order by count(ID_POISTENCA) desc;

--pocet osob v meste
select PSC, N_MESTA, count(ROD_CISLO) as pocetObyvatelov from P_MESTO
    left join P_OSOBA using(PSC)
group by PSC, N_MESTA
order by count(ROD_CISLO) desc;

--triggre -nastavenie p_zamestnanec dat_do NULL - novy zaznam
create or replace trigger nastavDatumDo
    before insert on Vyhnal1.P_ZAMESTNANEC
    for each row
begin
    :new.dat_do := NULL;
end;

--funkcia / pre dane rodne cislo
--kolko rokov roznych dostaval prispevok
create or replace function Pocet_rokov_prispevkov (rod in char)
    return number
    is pocet number;
begin
    select count(distinct extract(year from kedy)) into pocet
    from P_PRISPEVKY
             join P_POBERATEL using(id_poberatela) where ROD_CISLO = rod;
    return (pocet);
end;

--select osoby ktore maju poistenie
--in / exists
select ROD_CISLO, meno, PRIEZVISKO from P_OSOBA po
where exists(select 'x' from P_POISTENIE pp
             where po.ROD_CISLO = pp.ROD_CISLO);

select meno, PRIEZVISKO, ROD_CISLO from P_OSOBA po
where ROD_CISLO in (select ROD_CISLO from P_POISTENIE);

--funkcia vypocet veku osoby z rod cisla
--RRMMDD + MM50
create or replace function Vek_osoby (rod in char)
    return number
    is
    vek number;
begin
    select months_between(to_date(substr(rod,1,2) || MOD(substr(rod,3,2),50) || substr(rod, 5,2), 'RRMMDD'), sysdate)
    into vek
    from P_OSOBA where rod = ROD_CISLO;
    return vek;
end;

--Vytvorte pohæad, ktor˝ bude obsahovaù osoby a ich prisl˙chaj˙ce poistenie (aj ak ûiadne nemaj˙).
create or replace view zobrazPoistenia as
    select id_poistenca, ROD_CISLO, MENO, PRIEZVISKO from P_OSOBA
        left join P_POISTENIE using(ROD_CISLO);

--Vytvorte pohæad, ktor˝ bude obsahovaù mest· a poËet osÙb s trval˝m pobytom.
create or replace view pocetOsobVMeste as
    select PSC, N_MESTA, count(ROD_CISLO) pocet_obyvatelov from P_MESTO
    left join P_OSOBA using(PSC)
    group by PSC, N_MESTA
    order by pocet_obyvatelov desc;

--Vytvorte pohæad, ktor˝ bude obsahovaù zamestnancov a ich zamestn·vateæov s d·tumom zaËiatku pracovnÈho pomeru.
create or replace view ZamestnanciAZamestnavatelia as
    select ROD_CISLO as zamestnanec, NAZOV as zamestnavatel, DAT_OD from P_ZAMESTNANEC pz
    join P_ZAMESTNAVATEL z on (pz.ID_ZAMESTNAVATELA = z.ICO);

--Vytvorte pohæad, ktor˝ bude obsahovaù poistencov spolu s poËtom ich odvodov˝ch platieb.
create or replace view poistenci_a_odvody as
    select ID_POISTENCA, ROD_CISLO, COUNT(CIS_PLATBY) pocet_odvodov_platby from P_POISTENIE
    left join P_ODVOD_PLATBA using (id_poistenca)
    group by ID_POISTENCA, ROD_CISLO;

--5. Vytvorte pohæad, ktor˝ bude obsahovaù osoby a typ ich postihnutia (ak existuje).
create or replace view osoby_typ_poistenia as
    select MENO, PRIEZVISKO,
        LISTAGG(NAZOV_POSTIHNUTIA || ' - ' || DAT_DO || ' ')  within group ( order by MENO, PRIEZVISKO )  as Postihnutia from P_OSOBA
        left join P_ZTP using (ROD_CISLO)
        left join P_TYP_POSTIHNUTIA using (ID_POSTIHNUTIA)
    group by MENO, PRIEZVISKO, ROD_CISLO, NAZOV_POSTIHNUTIA;

--6. Vytvorte pohæad, ktor˝ bude obsahovaù zamestn·vateæov a poËet ich aktÌvnych zamestnancov.
create or replace view pocetZamestnancov as
    select NAZOV, count(ROD_CISLO) from P_ZAMESTNAVATEL zam
    left join P_ZAMESTNANEC pz on(zam.ICO = pz.ID_ZAMESTNAVATELA and DAT_DO is null)
    group by NAZOV;

--7. Vytvorte pohæad, ktor˝ bude obsahovaù osoby, ktorÈ s˙ z·roveÚ poistencami aj zamestnancami.
create or replace view poistenci_a_zamestnanci as
    select meno, PRIEZVISKO, ROD_CISLO from P_OSOBA
    where (ROD_CISLO in (select ROD_CISLO from P_ZAMESTNANEC) and
    ROD_CISLO IN (SELECT ROD_CISLO from P_POISTENIE));

--8. Vytvorte pohæad, ktor˝ bude obsahovaù typy prÌspevkov a poËet osÙb, ktorÈ ich poberaj˙.
create or replace view pocetPoberatelov as
    select ID_TYPU, POPIS, count(distinct ROD_CISLO) from P_TYP_PRISPEVKU
    left join P_POBERATEL using (id_typu)
    group by ID_TYPU, POPIS;

--9. Vytvorte pohæad, ktor˝ bude obsahovaù poistencov a d·tum ich poslednej platby.
create or replace view poistenci_posledna_platba as
    select meno, priezvisko, ROD_CISLO, id_poistenca, max(DAT_PLATBY) from P_ODVOD_PLATBA
    join p_poistenie using(id_poistenca)
    join P_OSOBA using (ROD_CISLO)
    group by MENO, PRIEZVISKO, id_poistenca, ROD_CISLO;

-- 10. Vytvorte pohæad, ktor˝ bude obsahovaù osoby a ich prÌspevky vr·tane n·zvu typu prÌspevku.
create or replace view osoby_a_ich_prispevky as
    select MENO, PRIEZVISKO, po.ROD_CISLO, count(*) pocetPrispevkov,
        LISTAGG(POPIS, ', ') within group ( order by POPIS ) as prispevky
        from P_OSOBA po
    join P_POBERATEL pp on (po.ROD_CISLO = pp.ROD_CISLO)
    join P_PRISPEVKY ppr on(pp.ID_POBERATELA = ppr.ID_POBERATELA)
    join P_TYP_PRISPEVKU pt on (pp.ID_TYPU = pt.ID_TYPU)
    group by MENO, PRIEZVISKO, po.ROD_CISLO
    order by MENO, PRIEZVISKO;


--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- SELECT ñ GROUP BY, HAVING, EXISTS, JOIN

-- 11. PoËet poistencov pre kaûdÈho platiteæa.
select ID_PLATITELA, count(ID_POISTENCA) pocetPoistencov from P_PLATITEL
    left join P_POISTENIE using(ID_PLATITELA)
    group by ID_PLATITELA;

--12. PoËet osÙb podæa mesta.
select PSC, N_MESTA, count(ROD_CISLO) from P_MESTO
    left join P_OSOBA using (PSC)
group by PSC, N_MESTA;

-- 13. PoËet z·znamov v p_prispevky podæa typu.
select ID_TYPU, count(*) from P_PRISPEVKY
    group by ID_TYPU;


-- 14. Priemern· v˝öka prÌspevku podæa typu.
select ID_TYPU, POPIS, AVG(suma) from P_PRISPEVKY
    join P_TYP_PRISPEVKU using (id_typu)
    group by ID_TYPU, POPIS;

-- 15. PoËet rÙznych zamestn·vateæov pre kaûdÈ PS».
select PSC, count(distinct ICO) from P_ZAMESTNAVATEL
    group by PSC;

-- 16. Osoby, ktorÈ s˙ z·roveÚ poistencami (EXISTS).
select MENO, PRIEZVISKO, ROD_CISLO from P_OSOBA po
    where exists(select 'x' from P_POISTENIE pp
                    where po.ROD_CISLO = pp.ROD_CISLO);


-- 17. Poistenci s aspoÚ dvoma z·znamami v p_odvod_platba (EXISTS).
select ID_POISTENCA, MENO, PRIEZVISKO from P_POISTENIE pp
    join P_OSOBA using(ROD_CISLO)
    where exists(select 'x' from P_ODVOD_PLATBA po
                    where pp.ID_POISTENCA = po.ID_POISTENCA
                    group by po.ID_POISTENCA
                    having count(CIS_PLATBY) > 1)
    group by ID_POISTENCA, MENO, PRIEZVISKO;

-- 18. Typy prÌspevkov pouûitÈ aspoÚ 3-kr·t (IN).
select ID_TYPU, POPIS from P_TYP_PRISPEVKU
    where ID_TYPU in (select ID_TYPU
                        from P_PRISPEVKY
                        group by ID_TYPU
                        having count(*) >= 3);

-- 19. Osoby, ktorÈ nie s˙ poistencami (NOT EXISTS).
select meno, priezvisko, ROD_CISLO from P_OSOBA po
    where not exists(select 'x' from P_POISTENIE pp
                        where po.ROD_CISLO = pp.ROD_CISLO)

--20. Osoby s najvyööÌm poËtom odvodov (GROUP BY + ORDER BY + LIMIT).
select MENO, PRIEZVISKO, count(CIS_PLATBY) from P_OSOBA
    join p_poistenie using(ROD_CISLO)
    join P_ODVOD_PLATBA using(id_poistenca)
    group by MENO, PRIEZVISKO, ROD_CISLO
    order by count(CIS_PLATBY) desc
    fetch first 1 rows with ties;

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Funkcie

-- 21. Funkcia: poËet prÌspevkov pre poberateæa.
create or replace function getPocetPrispevkov(p_id_poberatela in number)
    return number
    is v_pocetPrispevkov number;
    begin
        select count(*) as pocetPrispevkov into v_pocetPrispevkov from P_PRISPEVKY
        where id_poberatela = p_id_poberatela;
        return v_pocetPrispevkov;
    end;


select getPocetPrispevkov(737) from dual;

-- 22. Funkcia: celkov· suma platieb pre poistenca.
    create or replace function f_getSumaPlatieb(p_id_poistenca in number)
    return number
    is v_suma number;
    begin
        select nvl(sum(suma), 0) into v_suma from P_ODVOD_PLATBA
            where p_id_poistenca = ID_POISTENCA;
        return v_suma;
    end;

select F_GETSUMAPLATIEB(0)  sumaPLatieb from dual;

-- Funkcia: zistÌ, Ëi m· osoba aspoÚ 1 prÌspevok (TRUE/FALSE).
    create or replace function maAsponJedenPrispevok(p_rod_cislo in Char)
        return number
    is v_existuje number;
        begin
            select case
                when exists(select 'x' from P_POBERATEL p
                            join p_prispevky using(id_poberatela)
                            where p.ROD_CISLO = p_rod_cislo)
                then 1
                else 0
            end
        into v_existuje from dual;
            return v_existuje;
        end;

SELECT maAsponJedenPrispevok('910224/7604')  FROM dual;


-- Funkcia: zistÌ, Ëi osoba ûije v Nitrianskom kraji.

    create or replace function zijeVNitrianskom(p_rod_cislo in char)
    return number
    is  v_jeZNitry number;
        begin
            select count(*) into v_jeZNitry from p_osoba
                join P_MESTO using(PSC)
                join P_OKRES using(id_okresu)
                join P_KRAJ using(id_kraja)
            where n_kraja like 'Nitr%'
            and ROD_CISLO = p_rod_cislo;
            if v_jeZNitry > 0
                then return 1;
            else
                return 0;
            end if;
        end;

        select zijeVNitrianskom('965607/8343') from dual;

--14875 965608/8343

-- Funkcia: vr·ti poËet rÙznych rokov, v ktor˝ch osoba poberala prÌspevok.
create or replace function getPocetRokovPrispevkov(p_rod_cislo in P_OSOBA.ROD_CISLO%type)
return number
is v_pocet_rokov number;
begin
    select count(distinct extract(year from OBDOBIE)) into v_pocet_rokov from P_PRISPEVKY
        join P_POBERATEL using(id_poberatela)
        join P_OSOBA using(rod_cislo)
        where p_rod_cislo = ROD_CISLO;
    return v_pocet_rokov;
end;

select getPocetRokovPrispevkov('800704/7675') from dual;

-- Funkcia: priemern· v˝öka prÌspevku podæa typu pre danÈho poberateæa. CO TO JE BRO????
    --create or replace function f_priemerny_prispevok_typ(p_id_poberatel in P_POBERATEL.ID_POBERATELA%type, p_typ in P_POBERATEL.ID_TYPU%type)
    --return

-- Funkcia: poËet zamestn·vateæov pre danÈ rodnÈ ËÌslo.

    create or replace function f_getPocetZamestnavatelov(p_rod_cislo in P_ZAMESTNANEC.ROD_CISLO%type)
    return number
    is v_pocet number;
        begin
            select count(distinct ID_ZAMESTNAVATELA) into v_pocet from P_ZAMESTNANEC
                where ROD_CISLO = p_rod_cislo;
            return v_pocet;
        end;

    select f_getPocetZamestnavatelov('965608/8343') from dual;


-- Funkcia: vr·ti TRUE, ak osoba m· aktÌvne poistenie.

-- Funkcia: poËet zamestnanÌ, ktorÈ osoba absolvovala.
    create or replace function f_getPocetZamestnani(p_rod_cislo in P_OSOBA.ROD_CISLO%type)
    return number
    is v_pocet_rokov number;
        begin
            select count(id_zamestnavatela) into v_pocet_rokov from P_OSOBA
                left join P_ZAMESTNANEC using(rod_cislo)
            where ROD_CISLO = p_rod_cislo;
            return v_pocet_rokov;
        end;

        select f_getPocetZamestnani('965608/8343') from dual;

-- Funkcia: celkov· v˝öka z·kladnej sumy pre vöetky typy prÌspevkov, ktorÈ osoba dostala.
    create or replace function f_vyska_sumy_prispevkov(p_rod_cislo in P_OSOBA.rod_cislo%type)
    return number
    is v_suma number;
        begin
            select sum(SUMA) into v_suma from P_PRISPEVKY
            join P_POBERATEL using(id_poberatela)
            join P_OSOBA using(ROD_CISLO)
            where ROD_CISLO = p_rod_cislo;
            return v_suma;
        end;

        select f_vyska_sumy_prispevkov('800704/7675') from dual;

--KONECNE FUNKCIE DONE!!!!

--Proced˙ry ñ kurzory ************************************************************************************
-- 31. VypÌö inform·cie o osobe podæa rodnÈho ËÌsla.
    create or replace procedure vypisInfoOsoba(p_rod_cislo in P_OSOBA.ROD_CISLO%type)
    is cursor osoba_cur is
        select * from P_OSOBA
            where ROD_CISLO = p_rod_cislo;

        v_osoba osoba_cur%ROWTYPE;
    begin
        open osoba_cur;
        fetch osoba_cur into v_osoba;
            if osoba_cur%found then
                dbms_output.PUT_LINE('Meno: ' || v_osoba.MENO);
                dbms_output.PUT_LINE('Priezvisko: ' || v_osoba.PRIEZVISKO);
                dbms_output.PUT_LINE('ROD CISLO: ' || v_osoba.ROD_CISLO);
                else
                dbms_output.PUT_LINE('Dana osoba neexistuje!');
            end if;
        close osoba_cur;
    end;

    --V sql developer funguje aj tento prikaz, neviem preco tu nie
        exec vypisInfoOsoba('800704/7675');
        call vypisInfoOsoba('800704/7675');

    begin
        vypisInfoOsoba('800704/7675');
    end;

-- VypÌö histÛriu typu prÌspevku podæa ID typu.
    create or replace procedure vypisHistoriuTypu(p_id_typu in P_HISTORIA.id_typu%type)
    is cursor historia_cur
        is select * from P_HISTORIA
            where ID_TYPU = p_id_typu
        order by dat_od;

    begin
--         open historia_cur;
--         fetch historia_cur into v_historia;
--         if historia_cur%found then
            for zaznam in historia_cur loop
                dbms_output.PUT_LINE('ID: ' || zaznam.ID_TYPU);
                dbms_output.PUT_LINE('Od: ' || zaznam.DAT_OD);
                dbms_output.PUT_LINE('Do: ' || zaznam.DAT_DO);
                dbms_output.PUT_LINE('$: ' || zaznam.ZAKL_VYSKA );
                dbms_output.PUT_LINE('');
            end loop;


--         else
--             dbms_output.PUT_LINE('Tento typ neexistuje!');
--         end if;
    end;

select *
from P_HISTORIA;

-- VypÌö poËet osÙb a poistencov v zadanom PS».
    create or replace procedure pocet_osob_a_poistencov(p_PSC in P_OSOBA.PSC%type)
    is  v_pocet_osob number;
        v_pocet_poistencov number;
    begin
        select count(ROD_CISLO) into v_pocet_osob from P_OSOBA
        where PSC = p_PSC;

        select count(distinct ROD_CISLO) into v_pocet_poistencov from P_OSOBA
            join P_POISTENIE using(ROD_CISLO)
        where PSC = p_PSC;

        dbms_output.put_line('Pocet osob: ' || v_pocet_osob);
        dbms_output.put_line('Pocet poistencov: ' || v_pocet_poistencov);
    end;
-- VypÌö men· zamestnancov pre kaûdÈho zamestn·vateæa vr·tane info o poistenÌ.
-- VypÌö osoby, ktorÈ nemaj˙ ûiadne prÌspevky.
-- VypÌö sumu odvodov za zvolenÈ obdobie a poistenca.
-- VypÌö vöetk˝ch poistencov, ktorÌ nemaj˙ ûiadne platby.
-- VypÌö osoby s najvyööÌm poËtom rÙznych typov prÌspevkov.
-- VypÌö pre kaûdÈ mesto poËet zamestnancov.
-- VypÌö poistencov, ktor˝m poistenie zaËalo pred rokom 2020.

--*******************************TRIGGRE***************************************************

-- Trigger: nastav dat_do na NULL pri vklade do p_zamestnanec.
-- Trigger: z·kaz vloûiù z·porn˙ sumu do p_odvod_platba. (Ako to zabezpeËiù inak bez triggra?)
-- Trigger: kontrola existencie osoby pri vklade do p_poistenie.
-- Trigger: zmazanie poistenia a zamestnanÌ po zmazanÌ osoby.
-- Trigger: z·kaz duplicitnÈho aktÌvneho poistenia jednej osoby.
-- Trigger: z·kaz pridania zamestnanca staröieho ako 70 rokov.
-- Trigger: pri vloûenÌ prÌspevku overiù, ûe suma pri nezamestnanosti nie je vyööia neû 1000 EUR.
-- Trigger: aktualiz·cia poËtu zamestnancov v pomocnej tabuæke pri novom vklade.
-- Trigger: ak sa vloûÌ nov˝ typ prÌspevku, automaticky sa vloûÌ do p_historia s aktu·lnym d·tumom.
-- Trigger: ktor˝ zabranÌ vyplniù d·tum sk˙öky s hodnotou v‰Ëöou ako 20:00.


--******************************DML**********************************************************
-- Vloû nov˙ osobu, ktor· m· nastaven˝ aj trval˝ pobyt a poistenie.
    insert into P_PLATITEL values ('030616/1212');

    insert into P_OSOBA (ROD_CISLO, MENO, PRIEZVISKO, PSC, ULICA)
        values ('030616/1212', 'Jozko', 'Mrkva', '05801', 'Nova 274');

    insert into P_POISTENIE (ID_POISTENCA, ROD_CISLO, OSLOBODENY, DAT_OD)
        values(8561, '030616/1212', 'n', sysdate);


-- ZmeÚ zamestn·vateæa pre konkrÈtneho zamestnanca.
    update p_zamestnanec
    set ID_ZAMESTNAVATELA = '85794515'
    where ROD_CISLO = '900711/0497';

    select * from P_ZAMESTNANEC;

-- Odstr·Ú vöetky prÌspevky staröie neû 5 rokov.
    delete P_PRISPEVKY
    where kedy < add_months(sysdate, -(12*5));

-- Vloû nov˝ typ prÌspevku a pridaj z·znam o jeho pouûitÌ pre osobu.
    insert into P_TYP_PRISPEVKU values(5, 250, 'homos');
    insert into P_PRISPEVKY values(737, sysdate, 5, sysdate, 250);

    select * from P_TYP_PRISPEVKU;
    select * from P_POBERATEL;

-- Vymaûte vöetk˝ch poistencov, ktorÌ maj˙ ukonËenÈ poistenie (dat_do nie je NULL) a z·roveÚ nemaj˙ ûiadne odvodovÈ platby.
    delete P_POISTENIE
    where DAT_DO IS NOT NULL
      and id_poistenca not in(select id_poistenca from P_ODVOD_PLATBA);

-- Odstr·Ú osoby, ktorÈ nemaj˙ ûiadne poistenie, zamestnanie ani prÌspevok.
    delete P_OSOBA
        where ROD_CISLO not in (select ROD_CISLO from P_POISTENIE)
            and ROD_CISLO not in (select ROD_CISLO from P_ZAMESTNANEC)
            and ROD_CISLO not in (select ROD_CISLO from P_POBERATEL);

-- Vloû novÈho poistenca so vöetk˝mi povinn˝mi ˙dajmi a priradenou platbou.

-- ZmeÚte mesto trvalÈho pobytu na 'Bratislava' pre vöetky osoby, ktorÈ maj˙ moment·lne PS» zaËÌnaj˙ce na '9'. MAM TO ZMENIT NA PSC BLAVY? CI, AKO??
    update P_OSOBA
        set psc = (select psc from P_MESTO where N_MESTA like 'Brat%' and rownum = 1)
            where psc like '9%';
-- Pridajte novÈho poistenca na z·klade existuj˙cej osoby. Nastavte d·tum zaËiatku poistenia na dneön˝ d·tum.
-- Aktualizuj typ postihnutia pre osoby, ktorÈ maj˙ len jeden prÌspevok.
    update P_ZTP
        set id_postihnutia = 5
           where ROD_CISLO in (select p.ROD_CISLO from P_POBERATEL p
                                    join P_PRISPEVKY  using (id_poberatela)
                                    group by p.ROD_CISLO
                                    having count(ID_POBERATELA) = 1);








