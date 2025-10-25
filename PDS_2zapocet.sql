-- Vypíšte nasledovnú štatistiku.
-- K jednotlivým mestám Nitrianskeho okresu vypíšte pre obdobie od 16.6.2016 do 19.6.2016 celkovú sumu(eur), ktorá bola zaplatená poberateľom daného kraja.
select N_MESTA, sum(SUMA) from P_MESTO
                                   join p_osoba using (PSC)
                                   join P_POBERATEL using(ROD_CISLO)
                                   join p_prispevky using(id_poberatela)
where ID_OKRESU = 'NR' and
    OBDOBIE >= to_date('16.06.2016', 'DD.MM.YYYY') and kedy <= to_date('19.06.2016', 'DD.MM.YYYY')
group by N_MESTA;

-- Pomocou SQL generujte príkazy na zrušenie linuxového konta všetkých zamestnancov, ktorí ukončili pracovný pomer v posledný mesiac,
-- ak login je osobné číslo zamestnanca a syntax príkazu je:
-- userdel login

select 'userdel ' || ROD_CISLO from P_ZAMESTNANEC
where DAT_DO >= add_months(sysdate, -1);

-- Vytvorte XML dokument nasledujúceho formátu - poberatelia, ktorí dostali doteraz celkovo aspoň 1000Eur.
-- <osoby>
-- <clovek>Michal Kvet</clovek>
-- <clovek>Marek Kvet</clovek>
-- </osoby>
-- </mesto>

    select xmlroot(
              xmlelement(
                  "Osoby",
                  xmlagg(
                          xmlelement("Clovek", Meno || ' ' || PRIEZVISKO)
                  )
              ), version no value
    ) as xml from P_OSOBA
    join p_poberatel using(rod_cislo)
    join p_prispevky using(id_poberatela)
    having sum(suma) >= 1000;

--xmlagg
select xmlroot(
               xmlelement("osoba",
                          xmlattributes (rod_cislo as rc),
                          xmlforest(
                                  meno  "meno",
                                  priezvisko as "priezvisko",
                                  dat_zapisu as "dat_zapisu"
                          ),
                          xmlagg(xmlelement("Predmety", nazov))
               ), version no value --1.0
       ) as xml
from os_udaje join student using(rod_cislo)
              join zap_predmety using(os_cislo)
              join predmet using(cis_predm)
group by rod_cislo, meno, priezvisko, dat_zapisu;

-- Zápočet 1 - 29.10.2024
-- ABCD - bola napísaná funkcia ktorá začínala XXXXX member function niečo a za XXXXX sa malo vybrať čo treba doplniť aby sa použila pri triedení - v tomto prípade to bol ORDER lebo bol parameter s tým istým typom
-- ABCD - bola daná nested table s prvkami 10, 20, …, 70 a bol zavolaný príkaz nad nested table pole.delete(10) a že čo vypíše pole.last
-- ABCD - pre select into platí a 4 možnosti
-- Vypísať štatistiku - riadky kraje, stĺpce prvé tri mesiace roku 2018 a pre každý kraj koľko bolo dokopy príspevkov
-- Vypísať 30% najbohatších poberateľov príspevkov za posledné 2 roky myslím
-- Vygenerujte príkazy na pridanie práv create any directory osobe, ktorá v nejakom roku študovala nejaký predmet
-- Veľmi jednoduchý select z tabuľky xml dokumentov kde sa malo vypísať mená a priezviská
-- Vypíšte okresy, v ktorých sa nenachádzajú postihnuté ženy
-- Vypíšte všetky poistenia (stĺpce id_poistenca, rod_cislo, id_platitela) a v prípade, že je platba nad 100€ tak aj info o platbe (stĺpce cis_platby, suma)
