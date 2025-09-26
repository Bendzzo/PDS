select * from VYHNAL1.B_PARKOVANIE;

insert into VYHNAL1.B_PARKOVANIE select * from BIKESHARING.B_PARKOVANIE;


SELECT osoba1.name || ' ' || osoba1.surname AS osoba,
       LISTAGG(osoba2.name || ' ' || osoba2.surname, ', ') WITHIN GROUP (ORDER BY osoba2.name, osoba2.surname) AS surodenci
FROM person_rec osoba1
         JOIN person_rec osoba2 ON osoba1.mother_rc = osoba2.mother_rc
WHERE (osoba1.rod_cislo != osoba2.rod_cislo)
GROUP BY osoba1.name, osoba1.surname
ORDER BY osoba1.surname, osoba1.name;

SELECT os1.name || ' ' || os1.surname AS osoba,
       (SELECT STRING_AGG(os2.name || ' ' || os2.surname, ', ') WITHIN GROUP (ORDER BY os2.name, os2.surname)
FROM person_rec os2
WHERE os1.mother_rc = os2.mother_rc AND os1.rod_cislo != os2.rod_cislo) AS súrodenci FROM person_rec os1 ORDER BY os1.surname, os1.name;

select * from person_rec;


