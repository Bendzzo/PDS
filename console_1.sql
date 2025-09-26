select id_zakaznik as id_s_intersect from VYHNAL1.B_ZAKAZNIK
    intersect select ID_ZAKAZNIK from VYHNAL1.B_PORUCHA;
        --order by meno;

select * from VYHNAL1.B_ZAKAZNIK;

select ID_ZAKAZNIK from VYHNAL1.B_ZAKAZNIK
    natural join VYHNAL1.B_PORUCHA
     order by ID_ZAKAZNIK;

select * from VYHNAL1.B_OS_UDAJE
                  natural join VYHNAL1.B_ZAKAZNIK
order by MENO, PRIEZVISKO;

insert into VYHNAL1.OS_UDAJE (rod_cislo, meno, priezvisko, ulica, psc, OBEC)
values ('51518', 'JOZO', 'Kvet', null, null, null);

select meno, PRIEZVISKO from OS_UDAJE where meno in (select meno from B_OS_UDAJE) and PRIEZVISKO in (select PRIEZVISKO from B_OS_UDAJE)
    union all
select meno, PRIEZVISKO from B_OS_UDAJE where meno in (select meno from OS_UDAJE) and  PRIEZVISKO in (select PRIEZVISKO from OS_UDAJE);

select meno, PRIEZVISKO from OS_UDAJE where meno in (select meno from B_OS_UDAJE) and PRIEZVISKO in (select PRIEZVISKO from B_OS_UDAJE)
difference
select meno, PRIEZVISKO from B_OS_UDAJE where meno in (select meno from OS_UDAJE) and  PRIEZVISKO in (select PRIEZVISKO from OS_UDAJE);

select meno, PRIEZVISKO from OS_UDAJE where meno in (select meno from B_OS_UDAJE) and PRIEZVISKO in (select PRIEZVISKO from B_OS_UDAJE)
intersect
select meno, PRIEZVISKO from B_OS_UDAJE where meno in (select meno from OS_UDAJE) and  PRIEZVISKO in (select PRIEZVISKO from OS_UDAJE);

SELECT meno, PRIEZVISKO
FROM (
         SELECT meno, PRIEZVISKO
         FROM OS_UDAJE
         WHERE meno IN (SELECT meno FROM B_OS_UDAJE) AND PRIEZVISKO IN (SELECT PRIEZVISKO FROM B_OS_UDAJE)
         UNION ALL
         SELECT meno, PRIEZVISKO
         FROM B_OS_UDAJE
         WHERE meno IN (SELECT meno FROM OS_UDAJE) AND PRIEZVISKO IN (SELECT PRIEZVISKO FROM OS_UDAJE)
     )
GROUP BY meno, PRIEZVISKO
HAVING COUNT(*) > 1;

SELECT A.MENO, A.PRIEZVISKO
FROM OS_UDAJE A
WHERE NOT EXISTS (
    SELECT 1
    FROM B_OS_UDAJE B
    WHERE A.meno = B.meno AND A.PRIEZVISKO = B.PRIEZVISKO
);
SELECT A.MENO, A.PRIEZVISKO
FROM OS_UDAJE A
UNION ALL
SELECT B.MENO, B.PRIEZVISKO
FROM B_OS_UDAJE B;

select MENO, PRIEZVISKO
from OS_UDAJE
minus
(select meno, PRIEZVISKO from OS_UDAJE minus select MENO, PRIEZVISKO from B_OS_UDAJE);




