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

--Vytvorte poh�ad, ktor� bude obsahova� osoby a ich prisl�chaj�ce poistenie (aj ak �iadne nemaj�).
create or replace view zobrazPoistenia as
    select id_poistenca, ROD_CISLO, MENO, PRIEZVISKO from P_OSOBA
        left join P_POISTENIE using(ROD_CISLO);

--Vytvorte poh�ad, ktor� bude obsahova� mest� a po�et os�b s trval�m pobytom.
create or replace view pocetOsobVMeste as
    select PSC, N_MESTA, count(ROD_CISLO) pocet_obyvatelov from P_MESTO
    left join P_OSOBA using(PSC)
    group by PSC, N_MESTA
    order by pocet_obyvatelov desc;

--Vytvorte poh�ad, ktor� bude obsahova� zamestnancov a ich zamestn�vate�ov s d�tumom za�iatku pracovn�ho pomeru.
create or replace view ZamestnanciAZamestnavatelia as
    select ROD_CISLO as zamestnanec, NAZOV as zamestnavatel, DAT_OD from P_ZAMESTNANEC pz
    join P_ZAMESTNAVATEL z on (pz.ID_ZAMESTNAVATELA = z.ICO);

--Vytvorte poh�ad, ktor� bude obsahova� poistencov spolu s po�tom ich odvodov�ch platieb.
create or replace view poistenci_a_odvody as
    select ID_POISTENCA, ROD_CISLO, COUNT(CIS_PLATBY) pocet_odvodov_platby from P_POISTENIE
    left join P_ODVOD_PLATBA using (id_poistenca)
    group by ID_POISTENCA, ROD_CISLO;

--5. Vytvorte poh�ad, ktor� bude obsahova� osoby a typ ich postihnutia (ak existuje).
create or replace view osoby_typ_poistenia as
    select MENO, PRIEZVISKO,
        LISTAGG(NAZOV_POSTIHNUTIA || ' - ' || DAT_DO || ' ')  within group ( order by MENO, PRIEZVISKO )  as Postihnutia from P_OSOBA
        left join P_ZTP using (ROD_CISLO)
        left join P_TYP_POSTIHNUTIA using (ID_POSTIHNUTIA)
    group by MENO, PRIEZVISKO, ROD_CISLO, NAZOV_POSTIHNUTIA;

--6. Vytvorte poh�ad, ktor� bude obsahova� zamestn�vate�ov a po�et ich akt�vnych zamestnancov.
create or replace view pocetZamestnancov as
    select NAZOV, count(ROD_CISLO) from P_ZAMESTNAVATEL zam
    left join P_ZAMESTNANEC pz on(zam.ICO = pz.ID_ZAMESTNAVATELA and DAT_DO is null)
    group by NAZOV;

--7. Vytvorte poh�ad, ktor� bude obsahova� osoby, ktor� s� z�rove� poistencami aj zamestnancami.
create or replace view poistenci_a_zamestnanci as
    select meno, PRIEZVISKO, ROD_CISLO from P_OSOBA
    where (ROD_CISLO in (select ROD_CISLO from P_ZAMESTNANEC) and
    ROD_CISLO IN (SELECT ROD_CISLO from P_POISTENIE));

--8. Vytvorte poh�ad, ktor� bude obsahova� typy pr�spevkov a po�et os�b, ktor� ich poberaj�.
create or replace view pocetPoberatelov as
    select ID_TYPU, POPIS, count(distinct ROD_CISLO) from P_TYP_PRISPEVKU
    left join P_POBERATEL using (id_typu)
    group by ID_TYPU, POPIS;

--9. Vytvorte poh�ad, ktor� bude obsahova� poistencov a d�tum ich poslednej platby.
create or replace view poistenci_posledna_platba as
    select meno, priezvisko, ROD_CISLO, id_poistenca, max(DAT_PLATBY) from P_ODVOD_PLATBA
    join p_poistenie using(id_poistenca)
    join P_OSOBA using (ROD_CISLO)
    group by MENO, PRIEZVISKO, id_poistenca, ROD_CISLO;

-- 10. Vytvorte poh�ad, ktor� bude obsahova� osoby a ich pr�spevky vr�tane n�zvu typu pr�spevku.
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
-- SELECT � GROUP BY, HAVING, EXISTS, JOIN

-- 11. Po�et poistencov pre ka�d�ho platite�a.
select ID_PLATITELA, count(ID_POISTENCA) pocetPoistencov from P_PLATITEL
    left join P_POISTENIE using(ID_PLATITELA)
    group by ID_PLATITELA;

--12. Po�et os�b pod�a mesta.
select PSC, N_MESTA, count(ROD_CISLO) from P_MESTO
    left join P_OSOBA using (PSC)
group by PSC, N_MESTA;

-- 13. Po�et z�znamov v p_prispevky pod�a typu.
select ID_TYPU, count(*) from P_PRISPEVKY
    group by ID_TYPU;


-- 14. Priemern� v��ka pr�spevku pod�a typu.
select ID_TYPU, POPIS, AVG(suma) from P_PRISPEVKY
    join P_TYP_PRISPEVKU using (id_typu)
    group by ID_TYPU, POPIS;

-- 15. Po�et r�znych zamestn�vate�ov pre ka�d� PS�.
select PSC, count(distinct ICO) from P_ZAMESTNAVATEL
    group by PSC;

-- 16. Osoby, ktor� s� z�rove� poistencami (EXISTS).
select MENO, PRIEZVISKO, ROD_CISLO from P_OSOBA po
    where exists(select 'x' from P_POISTENIE pp
                    where po.ROD_CISLO = pp.ROD_CISLO);


-- 17. Poistenci s aspo� dvoma z�znamami v p_odvod_platba (EXISTS).
select ID_POISTENCA, MENO, PRIEZVISKO from P_POISTENIE pp
    join P_OSOBA using(ROD_CISLO)
    where exists(select 'x' from P_ODVOD_PLATBA po
                    where pp.ID_POISTENCA = po.ID_POISTENCA
                    group by po.ID_POISTENCA
                    having count(CIS_PLATBY) > 1)
    group by ID_POISTENCA, MENO, PRIEZVISKO;

-- 18. Typy pr�spevkov pou�it� aspo� 3-kr�t (IN).
select ID_TYPU, POPIS from P_TYP_PRISPEVKU
    where ID_TYPU in (select ID_TYPU
                        from P_PRISPEVKY
                        group by ID_TYPU
                        having count(*) >= 3);

-- 19. Osoby, ktor� nie s� poistencami (NOT EXISTS).
select meno, priezvisko, ROD_CISLO from P_OSOBA po
    where not exists(select 'x' from P_POISTENIE pp
                        where po.ROD_CISLO = pp.ROD_CISLO)

--20. Osoby s najvy���m po�tom odvodov (GROUP BY + ORDER BY + LIMIT).
select MENO, PRIEZVISKO, count(CIS_PLATBY) from P_OSOBA
    join p_poistenie using(ROD_CISLO)
    join P_ODVOD_PLATBA using(id_poistenca)
    group by MENO, PRIEZVISKO, ROD_CISLO
    order by count(CIS_PLATBY) desc
    fetch first 1 rows with ties;

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Funkcie

-- 21. Funkcia: po�et pr�spevkov pre poberate�a.
create or replace function getPocetPrispevkov(p_id_poberatela in number)
    return number
    is v_pocetPrispevkov number;
    begin
        select count(*) as pocetPrispevkov into v_pocetPrispevkov from P_PRISPEVKY
        where id_poberatela = p_id_poberatela;
        return v_pocetPrispevkov;
    end;


select getPocetPrispevkov(737) from dual;

-- 22. Funkcia: celkov� suma platieb pre poistenca.
    create or replace function f_getSumaPlatieb(p_id_poistenca in number)
    return number
    is v_suma number;
    begin
        select nvl(sum(suma), 0) into v_suma from P_ODVOD_PLATBA
            where p_id_poistenca = ID_POISTENCA;
        return v_suma;
    end;

select F_GETSUMAPLATIEB(0)  sumaPLatieb from dual;

-- Funkcia: zist�, �i m� osoba aspo� 1 pr�spevok (TRUE/FALSE).
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


-- Funkcia: zist�, �i osoba �ije v Nitrianskom kraji.

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

-- Funkcia: vr�ti po�et r�znych rokov, v ktor�ch osoba poberala pr�spevok.
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

-- Funkcia: priemern� v��ka pr�spevku pod�a typu pre dan�ho poberate�a. CO TO JE BRO????
    --create or replace function f_priemerny_prispevok_typ(p_id_poberatel in P_POBERATEL.ID_POBERATELA%type, p_typ in P_POBERATEL.ID_TYPU%type)
    --return

-- Funkcia: po�et zamestn�vate�ov pre dan� rodn� ��slo.

    create or replace function f_getPocetZamestnavatelov(p_rod_cislo in P_ZAMESTNANEC.ROD_CISLO%type)
    return number
    is v_pocet number;
        begin
            select count(distinct ID_ZAMESTNAVATELA) into v_pocet from P_ZAMESTNANEC
                where ROD_CISLO = p_rod_cislo;
            return v_pocet;
        end;

    select f_getPocetZamestnavatelov('965608/8343') from dual;


-- Funkcia: vr�ti TRUE, ak osoba m� akt�vne poistenie.

-- Funkcia: po�et zamestnan�, ktor� osoba absolvovala.
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

-- Funkcia: celkov� v��ka z�kladnej sumy pre v�etky typy pr�spevkov, ktor� osoba dostala.
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

--Proced�ry � kurzory ************************************************************************************
-- 31. Vyp� inform�cie o osobe pod�a rodn�ho ��sla.
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

-- Vyp� hist�riu typu pr�spevku pod�a ID typu.
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

-- Vyp� po�et os�b a poistencov v zadanom PS�.
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
-- Vyp� men� zamestnancov pre ka�d�ho zamestn�vate�a vr�tane info o poisten�.
-- Vyp� osoby, ktor� nemaj� �iadne pr�spevky.
-- Vyp� sumu odvodov za zvolen� obdobie a poistenca.
-- Vyp� v�etk�ch poistencov, ktor� nemaj� �iadne platby.
-- Vyp� osoby s najvy���m po�tom r�znych typov pr�spevkov.
-- Vyp� pre ka�d� mesto po�et zamestnancov.
-- Vyp� poistencov, ktor�m poistenie za�alo pred rokom 2020.

--*******************************TRIGGRE***************************************************

-- Trigger: nastav dat_do na NULL pri vklade do p_zamestnanec.
-- Trigger: z�kaz vlo�i� z�porn� sumu do p_odvod_platba. (Ako to zabezpe�i� inak bez triggra?)
-- Trigger: kontrola existencie osoby pri vklade do p_poistenie.
-- Trigger: zmazanie poistenia a zamestnan� po zmazan� osoby.
-- Trigger: z�kaz duplicitn�ho akt�vneho poistenia jednej osoby.
-- Trigger: z�kaz pridania zamestnanca star�ieho ako 70 rokov.
-- Trigger: pri vlo�en� pr�spevku overi�, �e suma pri nezamestnanosti nie je vy��ia ne� 1000 EUR.
-- Trigger: aktualiz�cia po�tu zamestnancov v pomocnej tabu�ke pri novom vklade.
-- Trigger: ak sa vlo�� nov� typ pr�spevku, automaticky sa vlo�� do p_historia s aktu�lnym d�tumom.
-- Trigger: ktor� zabran� vyplni� d�tum sk��ky s hodnotou v��ou ako 20:00.


--******************************DML**********************************************************
-- Vlo� nov� osobu, ktor� m� nastaven� aj trval� pobyt a poistenie.
-- Zme� zamestn�vate�a pre konkr�tneho zamestnanca.
-- Odstr�� v�etky pr�spevky star�ie ne� 5 rokov.
-- Vlo� nov� typ pr�spevku a pridaj z�znam o jeho pou�it� pre osobu.
-- Vyma�te v�etk�ch poistencov, ktor� maj� ukon�en� poistenie (dat_do nie je NULL) a z�rove� nemaj� �iadne odvodov� platby.
-- Odstr�� osoby, ktor� nemaj� �iadne poistenie, zamestnanie ani pr�spevok.
-- Vlo� nov�ho poistenca so v�etk�mi povinn�mi �dajmi a priradenou platbou.
-- Zme�te mesto trval�ho pobytu na 'Bratislava' pre v�etky osoby, ktor� maj� moment�lne PS� za��naj�ce na '9'.
-- Pridajte nov�ho poistenca na z�klade existuj�cej osoby. Nastavte d�tum za�iatku poistenia na dne�n� d�tum.
-- Aktualizuj typ postihnutia pre osoby, ktor� maj� len jeden pr�spevok.



