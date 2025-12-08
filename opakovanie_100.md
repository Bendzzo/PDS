# ;DB link
## Sada 1 – INSERT cez DB link

1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu students\_pdb servera orion. Použitý používateľ je lenka, ktorá má prístup ku všetkým tabuľkám celej inštancie. Napíšte príkaz, ktorý vloží obsah lokálnej tabuľky p\_predmet do tabuľky backup\_predmet používateľa tomas na vzdialenom serveri. Predpokladajte, že tabuľka backup\_predmet má rovnakú štruktúru ako tabuľka p\_predmet.
1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu students\_pdb servera orion. Použitý používateľ je tomas, ktorý má prístup ku všetkým tabuľkám celej inštancie. Napíšte príkaz, ktorý vloží obsah lokálnej tabuľky p\_vzdelanie do tabuľky data\_vzdelanie používateľa lenka na vzdialenom serveri. Predpokladajte, že tabuľka data\_vzdelanie má rovnakú štruktúru ako p\_vzdelanie.
1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu students\_pdb servera orion. Použitý používateľ je tomas. Napíšte príkaz, ktorý vloží do tabuľky log\_osoby používateľa lenka na vzdialenom serveri všetky záznamy z lokálnej tabuľky p\_osoba, pre ktoré hodnota id\_osoby ešte neexistuje v tabuľke log\_osoby na vzdialenom serveri. Predpokladajte, že tabuľky majú rovnakú štruktúru.

## Sada 2 – UPDATE cez DB link
1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu orcl\_pdb.Použitý používateľ je dusan. Aktualizujte lokálnu tabuľku p\_poistenie tak, aby ste nastavili dátum ukončenia poistného pre všetky osoby, ktorých id\_osoby sa nachádza v tabuľke data\_osoby používateľa dusan na vzdialenom serveri.
1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu orcl\_pdb.Použitý používateľ je jana. Aktualizujte lokálnu tabuľku p\_zamestnanec a nastavte stav zamestnania na „NEAKTÍVNY“ pre všetkých zamestnancov, ktorých identifikátor je uložený v tabuľke inactive\_ids používateľa tomas na vzdialenom serveri.
1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu orcl\_pdb. Použitý používateľ je jana. Aktualizujte lokálnu tabuľku p\_student, kde ukončíte platnosť štúdia pre všetkých študentov, ktorých os\_cislo sa nachádza v tabuľke ukonceni\_studenti používateľa lenka na vzdialenom serveri.

## Sada 3 – INSERT na lokálny server (bez použitia vzdialeného INSERT)
1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu students\_pdb servera orion. Použitý používateľ je martin. Napíšte príkaz, ktorý vloží do lokálnej tabuľky p\_predmet obsah tabuľky predmet\_link používateľa martin na vzdialenom serveri.
1. Máme vytvorený databázový link remote\_link, ktorý sa odkazuje na inštanciu students\_pdb.Použitý používateľ je martin. Napíšte príkaz, ktorý vloží do lokálnej tabuľky p\_ucty záznamy z tabuľky backup\_ucty používateľa lenka na vzdialenom serveri.
## Sada 4 – DELETE cez DB link
1. Máme vytvorený databázový link remote\_link.Použitý používateľ je andrea, ktorá má prístup ku všetkým tabuľkám celej inštancie. Odstráňte z lokálnej tabuľky p\_poberatel všetkých poberateľov, ktorých id\_poberatela sa nachádza v tabuľke del\_ids používateľa andrea na vzdialenom serveri.
1. Máme vytvorený databázový link remote\_link. Použitý používateľ je andrea.Odstráňte z lokálnej tabuľky p\_nepritomnost všetky záznamy, ktorých id\_neprit sa nachádza v tabuľke del\_neprit používateľa tomas na vzdialenom serveri.
# Indexy
## Sada 1 – Generovanie SQL príkazov
1. Vygenerujte príkazy (netreba spustiť) na zrušenie všetkých B-tree indexov nad tabuľkou p\_poistenie. Použite pohľad user\_indexes (atribúty index\_name, table\_name, index\_type), pričom index\_type nadobúda hodnotu „NORMAL“.
1. Vygenerujte príkazy (netreba spustiť) na zrušenie všetkých indexov nad tabuľkou p\_mesto, okrem indexov, ktoré zabezpečujú unikátnosť. Použite pohľady user\_indexes a user\_constraints (constraint\_type = 'U').
1. Vygenerujte príkazy (netreba spustiť) na rebuild všetkých indexov, ktoré sú asociované s cudzími kľúčmi v schéme používateľa. Použite pohľady user\_constraints (constraint\_type = 'R') a user\_indexes.
## Sada 2 – Otázky na návrh indexov
1. Vytvorte najvhodnejší index (indexy) pre príkaz:

   select rod\_cislo, meno, priezvisko

   from p\_osoba

where lower(priezvisko) like 'nov%';

1. Vytvorte najvhodnejší index (indexy) pre príkaz:

   select meno, priezvisko, nazov\_mesta

   from p\_osoba join p\_mesto using (psc)

where psc between '01000' and '09999';

1. Vytvorte najvhodnejší index (indexy) pre príkaz:

   select suma

   from p\_prispevky

where kedy between to\_date('01-01-2020','DD-MM-YYYY')

and to\_date('31-12-2020','DD-MM-YYYY');

1. Vytvorte najvhodnejší index pre nasledujúci dotaz:

   select nazov

   from p\_postihnutie

   where lower(nazov) like '%sluch%'

1. Vytvorte najvhodnejší index (indexy) pre príkaz:

select meno, priezvisko

from zamestnanec

where datum\_do is null;

1. Vytvorte najvhodnejší index pre dotaz:

   select \*

   from p\_osoba

where substr(rod\_cislo,1,1) = '6';
## Sada 3 – Prístupové metódy
1. Majme index v poradí atribútov: psc, meno, priezvisko. Akú prístupovú metódu by ste zvolili pre dotaz:

select meno, priezvisko

from p\_osoba

where psc = '01001';

Svoje rozhodnutie zdôvodnite.

1. Majme index v poradí atribútov: id\_typu, kedy. Akú prístupovú metódu by ste zvolili pre dotaz:

   select sum(suma)

   from p\_prispevky

where id\_typu = 4;

Odôvodnite.

1. Majme index v poradí atribútov: nazov, id\_postihnutia. Akú prístupovú metódu by ste zvolili pre dotaz:

   select id\_postihnutia

   from p\_postihnutie

where upper(nazov) = 'ZRAKOVA PORUCHA';

1. Majme index v poradí attribútov: datum\_do, datum\_od. Akú prístupovú metódu by ste zvolili pre:

select datum\_od

from p\_poberatel

where datum\_od > sysdate – 30;
## Sada 4 – Teoretické otázky 
1. Vysvetlite princíp metódy Index Range Scan a uveďte, aké podmienky musí spĺňať WHERE klauzula, aby ju bolo možné použiť.
1. Za akých okolností optimalizátor použije metódu Index Unique Scan?
1. Čo je podstatou metódy Bitmap Index Combine?
1. Čo spôsobuje vznik chained row a kedy sa tento jav zhoršuje?
1. Aký je rozdiel medzi function-based indexom a normálnym B-tree indexom?
1. Akú hodnotu selektivity preferuje optimalizátor pre B-tree index a prečo?
1. Vysvetlite, čo vyjadruje klauzula parallel n pri definícii indexu.
# LOBY 
1. Aký je rozdiel medzi dátovým typom BLOB a BFILE z hľadiska uloženia dát?
1. Aké sú hlavné rozdiely medzi interným a externým LOB-om?
1. Vysvetlite pojem LOB locator a jeho úlohu pri práci s LOB objektmi.
1. Ktoré operácie nad LOBmi spôsobujú implicitné alokovanie nového segmentu?
1. Aký je rozdiel medzi SecureFile LOB a BasicFile LOB z hľadiska výkonu?
1. Vymenujte aspoň tri výhody SecureFile LOBov oproti BasicFile LOBom.
1. Kedy Oracle automaticky komprimuje obsah SecureFile LOBu?
1. Čo vyjadruje hodnota RETENTION pri definícii SecureFile LOBu?
1. Čo predstavuje parameter CACHE / NOCACHE pri práci s LOB atribútmi?
1. Aký je maximálny počet BFILE objektov, ktoré môže jedna databázová relácia súčasne otvoriť?
1. Prečo dátový typ LONG nemožno použiť vo viacerých stĺpcoch jednej tabuľky?
1. Vysvetlite rozdiel medzi funkciami DBMS\_LOB.SUBSTR a SUBSTR pri čítaní LOB údajov.
1. Aký je účel funkcie DBMS\_LOB.FILEEXISTS?
1. Aká je úloha funkcie DBMS\_LOB.OPEN pri práci s BFILE objektom?
1. Čo predstavuje parametrovo riadená funkcia DBMS\_LOB.COMPARE?
1. Aký je rozdiel medzi režimom READ ONLY a READ WRITE pri volaní DBMS\_LOB.OPEN?
1. Prečo nie je možné aktualizovať obsah BFILE pomocou SQL príkazu UPDATE?
1. Vysvetlite princíp funkcie DBMS\_CRYPTO.ENCRYPT pri práci s LOBmi.
1. Čo je podstatou funkcie DBMS\_CRYPTO.HASH a na čo sa používa pri práci s LOBmi?
## JSON
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým knihám z tabuľky kniha\_json, ktorých autor začína na písmeno M (atribút autor). Jednotlivé knihy sú vo formáte JSON.
   1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým názvom kníh z tabuľky kniha\_json, ktoré boli vydané po roku 2010 (atribúty nazov, rok\_vydania). Jednotlivé knihy sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým študentom z tabuľky student\_json, ktorých ročník je väčší ako 2 (atribút rocnik). Jednotliví študenti sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým menám študentov z tabuľky student\_json, ktorí majú priemer známok menší než 2.0 (atribúty meno, priemer). Jednotliví študenti sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým produktom z tabuľky produkt\_json, ktorých cena je vyššia ako 20 eur (atribút cena). Jednotlivé produkty sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým názvom produktov z tabuľky produkt\_json, ktoré patria do kategórie Elektronika (atribúty nazov, kategoria). Jednotlivé produkty sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým zamestnancom z tabuľky zamestnanec\_json, ktorí pracujú na pozícii manager (atribút pozicia). Jednotliví zamestnanci sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým platom zamestnancov z tabuľky zamestnanec\_json, ktoré sú vyššie než 1500 eur (atribúty plat). Jednotliví zamestnanci sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým objednávkam z tabuľky objednavka\_json, ktorých počet položiek je väčší ako 3 (atribút pocet\_poloziek). Jednotlivé objednávky sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým celkovým cenám objednávok z tabuľky objednavka\_json, ktorých suma presahuje 100 eur (atribúty celkova\_cena). Jednotlivé objednávky sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým zákazníkom z tabuľky zakaznik\_json, ktorí majú vek väčší ako 30 rokov (atribút vek). Jednotliví zákazníci sú vo formáte JSON.
1. Napíšte príkaz SELECT, pomocou ktorého pristúpite ku všetkým názvom filmov z tabuľky film\_json, ktorých hodnotenie (atribút rating) je vyššie než 7.5. Jednotlivé filmy sú vo formáte JSON.


# Teoria
1. LOB typy a ukladanie dát
1. Fyzická štruktúra databázy (bloky, extenty, ROWID)
1. Transakcie, logovanie, zotavenie
1. Pamäťová architektúra (SGA, buffer cache)
1. Optimalizácia dotazov a prístupové metódy
1. XML špecifikácie a validácia
1. Databázové prepojenia a práca s externými zdrojmi
# CONNECT BY LEVEL
1. Pre KAŽDÝ mesiac minulého roka uveďte počet poistencov, ktorým v danom mesiaci vzniklo poistenie (atribút dat\_od v tabuľke p\_poistenie).
1. Pre KAŽDÝ mesiac minulého roka uveďte počet poistencov, ktorým v danom mesiaci poistenie zaniklo (atribút dat\_do v tabuľke p\_poistenie). Dbajte na univerzálnosť dotazu.
1. Pre KAŽDÝ mesiac minulého roka vypíšte počet zamestnávateľov, ktorým v danom mesiaci pribudol nový zamestnanec (atribút dat\_nastupu v p\_zamestnanec).
1. Pre KAŽDÝ mesiac minulého roka uveďte počet poistencov, ktorí mali v danom mesiaci platný záznam v tabuľke p\_poistenie (čiže dat\_od ≤ deň a zároveň (dat\_do je NULL alebo ≥ deň)).
1. Pre KAŽDÝ deň minulého roka vypíšte celkový počet príspevkov vyplatených v danom dni (atribút kedy v p\_prispevky).
1. Pre KAŽDÝ deň v mesiaci APRÍL minulého roka vypíšte počet zamestnancov, ktorým v daný deň vznikol pracovný pomer.
1. Pre KAŽDÝ deň v treťom štvrťroku minulého roka vypíšte počet poistencov, ktorým v daný deň zaniklo poistenie.
1. Pre KAŽDÝ deň minulého roka vypíšte počet osôb z tabuľky p\_osoba, ktoré mali v daný deň narodeniny (iba podľa dňa a mesiaca, rok ignorujte).
1. Pre KAŽDÝ mesiac minulého roka vypíšte počet poberateľov, ktorí mali v danom mesiaci aktívne poberanie (dat\_od ≤ posledný deň mesiaca AND (dat\_do je NULL OR dat\_do ≥ prvý deň mesiaca)).
1. Pre KAŽDÝ deň v mesiaci MÁJ minulého roka vypíšte počet príspevkov, ktoré boli vyplatené sumou vyššou ako 100 €.
1. Pre KAŽDÝ mesiac minulého roka vypíšte počet osôb z tabuľky p\_osoba, ktoré sa narodili v danom mesiaci.
1. Pre KAŽDÝ mesiac minulého roka vypíšte počet poistencov, ktorí mali v danom mesiaci zmenu poistenia (t. j. buď dat\_od alebo dat\_do spadá do mesiaca).
1. Pre KAŽDÝ deň v januári minulého roka vypíšte počet poistencov, ktorí mali v daný deň platné poistenie.
1. Pre KAŽDÝ mesiac minulého roka vypíšte celkový počet nových ZTP evidovaných v tabuľke p\_ztp.
1. Pre KAŽDÝ deň v mesiaci DECEMBER minulého roka vypíšte počet poberateľov, ktorí v daný deň prestali byť poberateľmi.
1. Pre KAŽDÝ mesiac minulého roka vypíšte počet zamestnancov, ktorí mali v danom mesiaci platnú pracovnú zmluvu (dat\_nastupu ≤ posledný deň mesiaca AND (dat\_ukoncenia je NULL alebo ≥ prvý deň mesiaca)).
1. Pre KAŽDÝ deň minulého roka vypíšte počet poistencov, ktorým v daný deň vzniklo poistenie.
1. Pre KAŽDÝ mesiac minulého roka vypíšte priemernú dennú sumu príspevkov vyplatenú v danom mesiaci.
# Transakcie
1. Čo vráti posledný select??

create table tab1 ( id integer );

insert into tab1 values ( 10 );

insert into tab1 values ( 20 );

savepoint sp1;

insert into tab1 values ( 30 );

rollback;

insert into tab1 values ( 40 );

commit;

select \* from tab1;

1. Čo vráti posledný select??

create table tab1 ( id integer );

insert into tab1 values ( 1 );

insert into tab1 values ( 2 );

savepoint a;

insert into tab1 values ( 3 );

savepoint b;

insert into tab1 values ( 4 );

rollback to a;

insert into tab1 values ( 5 );

commit;

rollback;

select \* from tab1;

1. Aký výsledok bude vypísaný?

create table pom ( id integer );

begin

insert into pom values ( 1 );

insert into pom values ( 2 );

commit;

insert into pom values ( 3 );

rollback;

insert into pom values ( 4 );

end;

/

select count(\*) from pom;

1. Aký výsledok bude vypísaný?

create table pom ( id integer );

begin

for i in 1..5 loop

insert into pom values ( i );

end loop;

rollback;

insert into pom values ( 100 );

commit;

end;

/

select max(id) from pom;

1. Aký výsledok bude vypísaný?

set autocommit on;

create table pom ( id integer );

insert into pom values ( 1 );

insert into pom values ( 2 );

insert into pom values ( 3 );

rollback;

insert into pom values ( 10 );

commit;

select count(\*) from pom;





1. Aký výsledok bude vypísaný?

create table pom ( id integer );

begin

for i in 1..6 loop

insert into pom values ( i );

if i = 3 then

savepoint sp\_mid;

end if;

end loop;

rollback to sp\_mid;

insert into pom values ( 100 );

commit;

end;

select max(id) from pom;

1. Čo vráti posledný select??

create table tab1 ( id integer );

insert into tab1 values ( 10 );

insert into tab1 values ( 20 );

savepoint s1;

insert into tab1 values ( 30 );

create table tab2 ( x integer );

insert into tab1 values ( 40 );

rollback to s1;

insert into tab1 values ( 50 );

commit;

select \* from tab1;

1. Aký výsledok bude vypísaný?

create table pom ( id integer );

begin

for i in 1..5 loop

insert into pom values ( i );

if mod(i;2) = 1 then

commit;

else

rollback;

end if;

end loop;

end

select count(\*) from pom;



Set autocommit off

Create table pom(id integer);

Create procedure proc1 AS 

Begin 

For i in 1..5 Loop

Insert into pom values(i);

Commit;

End loop;

End;	

/

Create procedure proc2 AS

Begin

Proc1;

Rollback;

Insert into pom values(100);

End;

/

Exec proc2;

Commit;

Aký výsledok vráti nasledovný príkaz Select?

Select count(\*) from pom;


Set autocommit on

Create table pom(id integer);

Create procedure proc1 AS 

Begin 

For i in 1..5 Loop

Insert into pom values(i);

End loop;

Rollback;

End;

/

Create procedure proc2 AS

Begin

Proc1;

Insert into pom values(50);

Commit;

End;

/

Exec proc2;

Rollback;

Aký výsledok vráti nasledovný príkaz Select?

Select max(id) from pom;


Set autocommit off

Create table pom(id integer);

Create procedure proc1 AS 

PRAGMA AUTONOMOUS\_TRANSACTION;

Begin 

Insert into pom values(1);

Insert into pom values(2);

Commit;

End;

/

Create procedure proc2 AS

Begin

Proc1;

Rollback;

Insert into pom values(10);

End;

/

Exec proc2;

Commit;

Aký výsledok vráti nasledovný príkaz Select?

Select count(\*) from pom;


Set autocommit off

Create table pom(id integer);

Create procedure proc1 AS 

Begin 

For i in 1..5 Loop

Insert into pom values(i);

If i = 3 then

Savepoint sp\_mid;

End if;

End loop;

Rollback to sp\_mid;

Commit;

End;

/

Create procedure proc2 AS

Begin

Proc1;

Insert into pom values(100);

Rollback;

End;

/

Exec proc2;

Commit;

Aký výsledok vráti nasledovný príkaz Select?

Select count(\*) from pom;


Set autocommit off

Create table pom(id integer);

Create procedure proc1 AS 

Begin 

Insert into pom values(5);

Rollback;

Insert into pom values(10);

Commit;

End;

/

Create procedure proc2 AS

Begin

Proc1;

Rollback;

Insert into pom values(20);

Commit;

End;

/

Exec proc2;

Aký výsledok vráti nasledovný príkaz Select?

Select count(\*) from pom;


Set autocommit off

Create table pom(id integer);

Create procedure proc1 AS 

PRAGMA AUTONOMOUS\_TRANSACTION;

Begin 

For i in 1..3 Loop

Insert into pom values(i);

End loop;

Rollback;

End;

/

Create procedure proc2 AS

Begin

Proc1;

Insert into pom values(99);

Commit;

End;

/

Exec proc2;

Rollback;

Aký výsledok vráti nasledovný príkaz Select?

Select count(\*) from pom;
