--[1] Vyp�te, ak� je priemern� cena opravy. (Do priemeru ner�tajte opravy, ktor�ch cena bola 0�.)
select avg(CENA_OPRAVY) from VYHNAL1.B_OPRAVA
where CENA_OPRAVY > 0;

--[2] Ku ka�d�mu z�kazn�kovi vyp�te, ko�ko nahl�sil por�ch.

-- [4] Ku ka�d�mu zamestnancovi vyp�te, ko�ko vykonal opr�v po jednotliv�ch mesiacoch.
select ID_ZAMESTNANEC, count(ID_OPRAVA), nvl(extract(month from B_OPRAVA.od), 0) mesiac from VYHNAL1.B_ZAMESTNANEC
    left join VYHNAL1.B_OPRAVA using (id_zamestnanec)
    group by ID_ZAMESTNANEC, extract(month from B_OPRAVA.od)
    order by ID_ZAMESTNANEC desc;

-- [5] Ku ka�d�mu z�kazn�kovi star�iemu ako 30 rokov vyp�te, ko�kokr�t mal po�i�an� bicykel.
select rod_cislo, count(ID_BICYKEL)  from BIKESHARING.B_ZAKAZNIK
    left join BIKESHARING.B_POZICANIE using (id_zakaznik)
    where months_between(sysdate, to_date(substr(rod_cislo,5,2)|| '-' ||mod(substr(rod_cislo,3,2),50)||'-'||'19'||
                                 substr(rod_cislo,1,2),'DD-MM-YYYY')) > 30 * 12
    group by rod_cislo;

-- [6] -- Ku ka�d�mu z�kazn�kovi vyp�te, ko�ko m� aktu�lne po�i�an�ch bicyklov.
-- (= hodnota atrib�tu do v po�i�an� je pr�zdna)
select ID_ZAKAZNIK, count(B_POZICANIE.ID_BICYKEL) from VYHNAL1.B_ZAKAZNIK
    left join VYHNAL1.B_POZICANIE using (id_zakaznik)
    where B_POZICANIE.do is null
    group by ID_ZAKAZNIK;

-- [7] Vyp�te ID bicyklov, ktor� boli po�i�an� viac ako 10-kr�t.
select ID_BICYKEL, count(ID_BICYKEL) from VYHNAL1.B_POZICANIE
having count(B_POZICANIE.ID_BICYKEL) > 10
group by ID_BICYKEL;

-- [8] Vyp�te ID bicykla, ktor� bol po�i�an� najviackr�t zo v�etk�ch bicyklov.
select ID_BICYKEL, count(*) from VYHNAL1.B_POZICANIE
having count(*) in (select max(count(*)) from VYHNAL1.B_POZICANIE
                                         group by ID_BICYKEL)
group by ID_BICYKEL;

-- [9] Pre ka�d� mesto vyp�te jeho n�zov a po�et mu�ov.
select nazov, psc, count(ROD_CISLO) as pocet_muzov from VYHNAL1.B_MESTO
left join VYHNAL1.B_OS_UDAJE using (psc)
where substr(ROD_CISLO, 3, 2) < 13
group by nazov, psc
order by pocet_muzov desc;

-- [10] Pre ka�d� �enu vyp�te jej meno, priezvisko, rodn� ��slo a ko�kokr�t si po�i�ala bicykel.
select meno, PRIEZVISKO, ROD_CISLO, count(B_POZICANIE.ID_BICYKEL) as pocet from BIKESHARING.B_OS_UDAJE
    left join BIKESHARING.B_ZAKAZNIK using (rod_cislo)
    left join BIKESHARING.B_POZICANIE using (id_zakaznik)
    where substr(ROD_CISLO, 3, 2) > 12
    group by meno, PRIEZVISKO, ROD_CISLO;

-- [11] Vyp�te men� a priezvisk� z�kazn�kov, ktor� si po�i�ali aspo� 12-kr�t bicykel a nikdy nenahl�sili v janu�ri poruchu.
select MENO, PRIEZVISKO, count(ID_BICYKEL) from BIKESHARING.B_OS_UDAJE
    join BIKESHARING.B_ZAKAZNIK using (rod_cislo)
    join BIKESHARING.B_PORUCHA using (id_zakaznik)
    where ID_ZAKAZNIK not in (select ID_ZAKAZNIK from BIKESHARING.B_PORUCHA
                                                 where extract(month from BIKESHARING.B_PORUCHA.NAHLASENIE) = 1 and ID_ZAKAZNIK is not null)
    group by MENO, PRIEZVISKO
    having count(ID_BICYKEL) >= 12;

-- [12] Ku ka�d�mu mesiacu vyp�te, ko�ko v �om bolo vykonan�ch opr�v.
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

-- [13] Vyp�te mesto, v ktorom m�me najviac umiestnen�ch stojanov.
select NAZOV, PSC, count(*) from VYHNAL1.B_MESTO
join VYHNAL1.B_STOJAN using (PSC)
having count(*) in (select max(count(*)) from VYHNAL1.B_STOJAN
                                         group by PSC)
group by NAZOV, PSC;

-- [14] Ku ka�d�mu stojanu vyp�te, ko�ko m� v sebe miest. Zoznam utrie�te pod�a ID stojanu.
select ID_STOJAN, count(*) from BIKESHARING.B_STOJAN
left join BIKESHARING.B_MIESTO using (id_stojan)
group by ID_STOJAN
order by ID_STOJAN desc;

-- [15] Ku ka�d�mu mesiacu vyp�te, ko�ko z�kazn�kov m� v �om narodeniny.
select extract(month from to_date('2000' || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.' ||'16', 'YYYY.MM.DD')) as mesiac, count(ID_ZAKAZNIK)
    from VYHNAL1.B_ZAKAZNIK
group by extract(month from to_date('2000' || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.' ||'16', 'YYYY.MM.DD'))
order by mesiac;

-- [16] Vyp�te, ak� je v cenn�ku najmen�ia cena za po�i�anie pre d�chodcu.
select min(CENA_DOCHODCA) from VYHNAL1.B_CENNIK;

-- [17] Vyp�te ID najdrah�ej opravy.
select ID_OPRAVA, CENA_OPRAVY from BIKESHARING.B_OPRAVA
where CENA_OPRAVY in (select max(CENA_OPRAVY) from BIKESHARING.B_OPRAVA);

-- [18] Vyp�te ko�ko najviac po�i�an� vykonal z�kazn�k.
select ID_ZAKAZNIK, count(B_POZICANIE.ID_ZAKAZNIK) from VYHNAL1.B_POZICANIE
    having count(B_POZICANIE.ID_ZAKAZNIK) in (select max(count(*)) from VYHNAL1.B_POZICANIE
                                                                   group by ID_ZAKAZNIK)
group by ID_ZAKAZNIK;

-- [19] Vyp�te inform�cie o z�kazn�koch(meno, priezvisko, rodn� ��slo), ktor� si po�i�ali bicykel najviackr�t.
select MENO,PRIEZVISKO,ROD_CISLO, count(ID_ZAKAZNIK) from BIKESHARING.B_OS_UDAJE
join BIKESHARING.B_ZAKAZNIK using (rod_cislo)
join BIKESHARING.B_POZICANIE using (id_zakaznik)
having count(ID_ZAKAZNIK) in (select max(count(ID_ZAKAZNIK)) from BIKESHARING.B_POZICANIE
                                                             group by ID_ZAKAZNIK)
group by MENO, PRIEZVISKO, ROD_CISLO;

--[20] Vyp�te ID stojanov, v ktor�ch aktu�lne parkuje (= hodnota atrib�tu do je pr�zdna) menej ako 10 bicyklov.
select ID_STOJAN, count(*) from BIKESHARING.B_MIESTO m
where exists(select 'x' from BIKESHARING.B_PARKOVANIE p
                        where m.ID_STOJAN = p.ID_STOJAN and m.ID_MIESTO = p.ID_MIESTO and DO is null)
group by ID_STOJAN
having count(*) < 10;

-- [21] Pre ka�d� mesto vyp�te priemern� vek z�kazn�kov.
select nazov, psc, avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12)
from VYHNAL1.B_OS_UDAJE
join VYHNAL1.B_MESTO using (psc)
group by psc, nazov;

-- [22] Vyp�te najni��� priemern� vek z�kazn�kov v jednotliv�ch mest�ch.
select nazov, psc, avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12)
from VYHNAL1.B_OS_UDAJE
join VYHNAL1.B_MESTO using (psc)
having avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12)
           in (select
                     min(avg(months_between(sysdate, to_date(substr(ROD_CISLO, 5, 2) || '.' || mod(substr(ROD_CISLO, 3, 2), 50) || '.19' || substr(ROD_CISLO, 1, 2), 'DD.MM.YYYY')) / 12))
               from VYHNAL1.B_OS_UDAJE
               group by psc, NAZOV)
group by psc, nazov;
