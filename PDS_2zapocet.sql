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
