-- budu tam kurzory
--  parametrizovane kurzory
-- anonymny blok kurzora
-- generovanie prikazov
-- rand, constraint, drop
-- objekty, vytvorenie, map a order funkcie ake su medzi nimi rozdiely, vediet ich vytvorit
-- rozdiel tabulka s objektami
-- vediet napisat select s xml, aky element, atribut
-- vediet co je xml forest, aky je rozdiel medzi xml forestom a elementom
-- vediet ako vybrat hodnotu s xml dokumentu
-- vediet urboti update xml
-- vediet vlozit do takej tabulky v oboch pripadoch

-- json
-- aky je rozdiel od xml
-- vediet co to je
-- akym sposobom vytvarat tabulku s tym ze ma v sebe tabulku json
-- to iste co s xml vediet aj s json, update, insert, xpath
-- connect - by na teste nemal byt

-- z kazdeho tyzdna by mala byt 1 otazka - minuly rok mali 9 otazok - xml, generovanie, statistika v ramci agregacie, polia 

-- kolekcie

--****************************************************XML dokument******************************************************
--vzdy tam bude xmlroot
select xmlroot(
    xmlelement("osoba",
        xmlattributes (rod_cislo as rc),
        xmlelement("meno", meno),
        xmlelement("priezvisko", priezvisko),
        xmlelement("datum_zapisu", dat_zapisu)
    ), version no value --1.0
) as xml
from os_udaje join student using(rod_cislo);

--xml forest
select xmlroot(
    xmlelement("osoba",
        xmlattributes (rod_cislo as rc),
        xmlforest(
            meno  "meno",
            priezvisko as "priezvisko",
            dat_zapisu as "dat_zapisu"
        )
    ), version no value --1.0
) as xml
from os_udaje join student using(rod_cislo);

--formatovanie datumu
select xmlroot(
    xmlelement("osoba",
        xmlattributes (rod_cislo as rc),
        xmlforest(
            meno  "meno",
            priezvisko as "priezvisko",
            to_char(dat_zapisu, 'DD.MM.YYYY') as "dat_zapisu"
        )
    ), version no value --1.0
) as xml
from os_udaje join student using(rod_cislo);

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

--xmltype
create table stud_xml of xmltype;

insert into stud_xml values (
    xmlroot(
        xmlelement("student",
            xmlattributes('1' as "id", '005523/1234' as rod_cislo), 
            xmlelement("meno", 'Stano'), 
            xmlelement("priezvisko", 'Mudry')
        ), version '1.0'
    )
);

select * from stud_xml;

-- vlozenie xml z inej tabulky pomocou selectu
insert into stud_xml
select xmlroot(
    xmlelement("osoba",
        xmlattributes (rod_cislo as rc),
        xmlelement("meno", meno),
        xmlelement("priezvisko", priezvisko),
        xmlelement("datum_zapisu", dat_zapisu)
    ), version no value --1.0
) as xml
from os_udaje join student using(rod_cislo);


-- 
create table predmet_xml (
    predmet_id int primary key,
    nazov varchar2(50),
    ucitel_xml xmltype
);

insert into predmet_xml (predmet_id, nazov, ucitel_xml)
    values (1, 'Databazy', 
        xmlroot(
            xmlelement("ucitel",
                xmlattributes('1' as "id"),
                xmlelement("meno", 'Jozef'),
                xmlelement("priezvisko", 'Takac')
            ), version '1.0'
        )
    );
    
select * from predmet_xml;

--value(x), x.getClobVal(), extract()

select value(x) from stud_xml x order by 1;

--clob text
select x.getClobVal() from stud_xml x;

--extract/extractvalue
-- extract -  vracia xml podstrom
-- xmlextract -- skalarny typ text
-- xmltable

select x.krstne_meno from predmet_xml p,
xmltable('/ucitel' passing p.ucitel_xml columns krstne_meno varchar2(50) path 'meno') x;

--value(x) v pripade ak pracujeme s tabulkou ktorej cely obsah je dokument
--object_value()
--//, @ v pripade ak je to atribut, [] - pristup k atributu podla poradia

select extractValue(ucitel_xml, '/ucitel/meno') as meno from predmet_xml;

select extractValue(ucitel_xml, '//@id') as id from predmet_xml;

--of xmltype
select extractValue(value(x), '//@id') as id from stud_xml x;
select extractValue(value(x), '//@id[1]') as id from stud_xml x;

--updatexml

update predmet_xml set ucitel_xml = updatexml(ucitel_xml, '//meno/text()', 'Karol') --ak dame 'text()' tak menime len text a nie strukturu
    where predmet_id = 1; --extractvalue

    -- pseudo stlpec object_value alebo value(x)
update stud_xml set object_value = updatexml(object_value, '//osoba/meno/text()', 'Stevko')
    where extractValue(object_value, '//osoba/meno') = 'Rastislav';
    
-- katedra  fk --> zamestnanec fk --> katedra ****** na okaslanie cyklenia sa cudzich klucov
-- constraint deferred zapina sa tymto prikazom
set constraints all deferred;

constraint ---nazov ---nieco odkazuje references()
    deferrable initially deferred;
    
    
--DU
select xmlroot(
    xmlelement("osoby",
        xmlagg(xmlelement("osoba",
            xmlattributes (rod_cislo as rc),
            xmlelement("meno", meno),
            xmlelement("priezvisko", priezvisko),
            xmlelement("ulica", xmlattributes(PSC as "PSC"), ulica),
            xmlelement("datum_zapisu", to_char(dat_zapisu, 'DD.month.YYYY'))
    )
    )), version no value --1.0
) as xml
from os_udaje join student using(rod_cislo);















