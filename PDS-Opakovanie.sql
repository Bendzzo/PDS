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
