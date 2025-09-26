--[1] Vypíšte, aká je priemerná cena opravy. (Do priemeru nerátajte opravy, ktorých cena bola 0€.)
select avg(CENA_OPRAVY) from VYHNAL1.B_OPRAVA
where CENA_OPRAVY > 0;

--[2] Ku každému zákazníkovi vypíšte, ko¾ko nahlásil porúch.

-- [4] Ku každému zamestnancovi vypíšte, ko¾ko vykonal opráv po jednotlivých mesiacoch.
select ID_ZAMESTNANEC, count(ID_OPRAVA), nvl(extract(month from B_OPRAVA.od), 0) mesiac from VYHNAL1.B_ZAMESTNANEC
    left join VYHNAL1.B_OPRAVA using (id_zamestnanec)
    group by ID_ZAMESTNANEC, extract(month from B_OPRAVA.od)
    order by ID_ZAMESTNANEC desc;

-- [5] Ku každému zákazníkovi staršiemu ako 30 rokov vypíšte, ko¾kokrát mal požièaný bicykel.
select rod_cislo, count(ID_BICYKEL)  from BIKESHARING.B_ZAKAZNIK
    left join BIKESHARING.B_POZICANIE using (id_zakaznik)
    where months_between(sysdate, to_date(substr(rod_cislo,5,2)|| '-' ||mod(substr(rod_cislo,3,2),50)||'-'||'19'||
                                 substr(rod_cislo,1,2),'DD-MM-YYYY')) > 30 * 12
    group by rod_cislo;

-- [6] -- Ku každému zákazníkovi vypíšte, ko¾ko má aktuálne požièaných bicyklov.
-- (= hodnota atribútu do v požièaní je prázdna)
select ID_ZAKAZNIK, count(B_POZICANIE.ID_BICYKEL) from VYHNAL1.B_ZAKAZNIK
    left join VYHNAL1.B_POZICANIE using (id_zakaznik)
    where B_POZICANIE.do is null
    group by ID_ZAKAZNIK;

-- [7] Vypíšte ID bicyklov, ktoré boli požièané viac ako 10-krát.
select ID_BICYKEL, count(ID_BICYKEL) from VYHNAL1.B_POZICANIE
having count(B_POZICANIE.ID_BICYKEL) > 10
group by ID_BICYKEL;

-- [8] Vypíšte ID bicykla, ktorý bol požièaný najviackrát zo všetkých bicyklov.
select ID_BICYKEL, count(*) from VYHNAL1.B_POZICANIE
having count(*) in (select max(count(*)) from VYHNAL1.B_POZICANIE
                                         group by ID_BICYKEL)
group by ID_BICYKEL;

-- [9] Pre každé mesto vypíšte jeho názov a poèet mužov.
select nazov, psc, count(ROD_CISLO) as pocet_muzov from VYHNAL1.B_MESTO
left join VYHNAL1.B_OS_UDAJE using (psc)
where substr(ROD_CISLO, 3, 2) < 13
group by nazov, psc
order by pocet_muzov desc;

-- [10] Pre každú ženu vypíšte jej meno, priezvisko, rodné èíslo a ko¾kokrát si požièala bicykel.
select meno, PRIEZVISKO, ROD_CISLO, count(B_POZICANIE.ID_BICYKEL) as pocet from BIKESHARING.B_OS_UDAJE
    left join BIKESHARING.B_ZAKAZNIK using (rod_cislo)
    left join BIKESHARING.B_POZICANIE using (id_zakaznik)
    where substr(ROD_CISLO, 3, 2) > 12
    group by meno, PRIEZVISKO, ROD_CISLO;

-- [11] Vypíšte mená a priezviská zákazníkov, ktorí si požièali aspoò 12-krát bicykel a nikdy nenahlásili v januári poruchu.
select MENO, PRIEZVISKO, count(ID_BICYKEL) from BIKESHARING.B_OS_UDAJE
    join BIKESHARING.B_ZAKAZNIK using (rod_cislo)
    join BIKESHARING.B_PORUCHA using (id_zakaznik)
    where ID_ZAKAZNIK not in (select ID_ZAKAZNIK from BIKESHARING.B_PORUCHA
                                                 where extract(month from BIKESHARING.B_PORUCHA.NAHLASENIE) = 1 and ID_ZAKAZNIK is not null)
    group by MENO, PRIEZVISKO
    having count(ID_BICYKEL) >= 12;

-- [12] Ku každému mesiacu vypíšte, ko¾ko v òom bolo vykonaných opráv.
select extract(month from od), count(*) from VYHNAL1.B_OPRAVA
group by extract(month from od);

----- ????????????????????????????????????????????????????????????????
SELECT
    months.month,
    COALESCE(COUNT(B_OPRAVA.ID_OPRAVA), 0) AS pocet_oprav
FROM (
         SELECT EXTRACT(month FROM (SYSDATE - (LEVEL - 1) * INTERVAL '1' MONTH)) AS month
         FROM DUAL
         CONNECT BY LEVEL <= 12
     ) months
         LEFT JOIN VYHNAL1.B_OPRAVA ON EXTRACT(month FROM VYHNAL1.B_OPRAVA.od) = months.month
GROUP BY months.month
ORDER BY months.month;
----- ????????????????????????????????????????????????????????????????

-- [13] Vypíšte mesto, v ktorom máme najviac umiestnených stojanov.
select NAZOV, PSC, count(*) from VYHNAL1.B_MESTO
join VYHNAL1.B_STOJAN using (PSC)
having count(*) in (select max(count(*)) from VYHNAL1.B_STOJAN
                                         group by PSC)
group by NAZOV, PSC;

-- [14] Ku každému stojanu vypíšte, ko¾ko má v sebe miest. Zoznam utrieïte pod¾a ID stojanu.
select ID_STOJAN, count(*) from BIKESHARING.B_STOJAN
left join BIKESHARING.B_MIESTO using (id_stojan)
group by ID_STOJAN
order by ID_STOJAN desc;

-- [15] Ku každému mesiacu vypíšte, ko¾ko zákazníkov má v òom narodeniny.
select extract(month from to_date('2000' || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.' ||'16', 'YYYY.MM.DD')) as mesiac, count(ID_ZAKAZNIK)
    from VYHNAL1.B_ZAKAZNIK
group by extract(month from to_date('2000' || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.' ||'16', 'YYYY.MM.DD'))
order by mesiac;

-- [16] Vypíšte, aká je v cenníku najmenšia cena za požièanie pre dôchodcu.
select min(CENA_DOCHODCA) from VYHNAL1.B_CENNIK;

-- [17] Vypíšte ID najdrahšej opravy.
select ID_OPRAVA, CENA_OPRAVY from BIKESHARING.B_OPRAVA
where CENA_OPRAVY in (select max(CENA_OPRAVY) from BIKESHARING.B_OPRAVA);

-- [18] Vypíšte ko¾ko najviac požièaní vykonal zákazník.
select ID_ZAKAZNIK, count(B_POZICANIE.ID_ZAKAZNIK) from VYHNAL1.B_POZICANIE
    having count(B_POZICANIE.ID_ZAKAZNIK) in (select max(count(*)) from VYHNAL1.B_POZICANIE
                                                                   group by ID_ZAKAZNIK)
group by ID_ZAKAZNIK;

-- [19] Vypíšte informácie o zákazníkoch(meno, priezvisko, rodné èíslo), ktorí si požièali bicykel najviackrát.
select MENO,PRIEZVISKO,ROD_CISLO, count(ID_ZAKAZNIK) from BIKESHARING.B_OS_UDAJE
join BIKESHARING.B_ZAKAZNIK using (rod_cislo)
join BIKESHARING.B_POZICANIE using (id_zakaznik)
having count(ID_ZAKAZNIK) in (select max(count(ID_ZAKAZNIK)) from BIKESHARING.B_POZICANIE
                                                             group by ID_ZAKAZNIK)
group by MENO, PRIEZVISKO, ROD_CISLO;

--[20] Vypíšte ID stojanov, v ktorých aktuálne parkuje (= hodnota atribútu do je prázdna) menej ako 10 bicyklov.
select ID_STOJAN, count(*) from BIKESHARING.B_MIESTO m
where exists(select 'x' from BIKESHARING.B_PARKOVANIE p
                        where m.ID_STOJAN = p.ID_STOJAN and m.ID_MIESTO = p.ID_MIESTO and DO is null)
group by ID_STOJAN
having count(*) < 10;

-- [21] Pre každé mesto vypíšte priemerný vek zákazníkov.
select nazov, psc, avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12)
from VYHNAL1.B_OS_UDAJE
join VYHNAL1.B_MESTO using (psc)
group by psc, nazov;

-- [22] Vypíšte najnižší priemerný vek zákazníkov v jednotlivých mestách.
select nazov, psc, avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12)
from VYHNAL1.B_OS_UDAJE
join VYHNAL1.B_MESTO using (psc)
having avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12)
           in (select
                     min(avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12))
               from VYHNAL1.B_OS_UDAJE
               group by psc, NAZOV)
group by psc, nazov;
