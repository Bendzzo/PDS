--pocet poistencov pre kazdeho platitela
select ID_PLATITELA, count(ID_POISTENCA) as pocetPlatitelov from P_PLATITEL left join P_POISTENIE using(id_platitela)
group by ID_PLATITELA
order by count(ID_POISTENCA) desc;

--pocet osob v meste
select PSC, N_MESTA, count(ROD_CISLO) as pocetObyvatelov from P_MESTO left join P_OSOBA using(PSC)
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
    select MENO, PRIEZVISKO, po.ROD_CISLO,
        LISTAGG(POPIS, ', ') within group ( order by POPIS ) as prispevky
        from P_OSOBA po
    join P_POBERATEL pp on (po.ROD_CISLO = pp.ROD_CISLO)
    join P_PRISPEVKY ppr on(pp.ID_POBERATELA = ppr.ID_POBERATELA)
    join P_TYP_PRISPEVKU pt on (pp.ID_TYPU = pt.ID_TYPU)
    group by MENO, PRIEZVISKO, po.ROD_CISLO
    order by MENO, PRIEZVISKO;



