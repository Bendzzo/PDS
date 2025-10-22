    declare
        v_student student%rowtype;
    begin
        select * into v_student
            from student
                where os_cislo = 501512;
        dbms_output.put_line('Osobne cislo: ' || v_student.os_cislo);
        dbms_output.put_line('Rocnik: ' || v_student.rocnik);

    end;/

--vkladat pomocou recordu
--%rowtype
 
declare
    v_student student%rowtype
begin
    v_student.os_cislo := 3005; --poradie stlpcov rovnake ako v tabulke
    v_student.rod_cislo := '005523/1234';
    v_student.rocnik := 3;
    insert into student(os_cislo, rod_cislo, rocnik) values (v_student.os_cislo, v_student.rod_cislo, v_student.rocnik);
end;
/
 
 
--update --cely riadok rowtype
--len niektore stlpce
 
declare
    v_student student%rowtype
begin
    select * into v_student from student where os_cislo=3005;
    update student set row = v_student where os_cislo = 1025;
end;
/
 
declare
    is record ...
begin
    select * into v_student from student where os_cislo=3005;
    update student set rocnik = record.rocnik where os_cislo=record.os_cislo;
end;
/
 
 
 
--kolekcie
--pole/zoznam prvkov rovnakeho charakter
--plsql alebo klasicke sql
--- tri hlavne kolekcie (nested table, varray, index by table)
--prednaska 2- obrazok porovnania
--rozdiel 
--varray pevna velkost, ----kratke usporiadane zoznami, kde zalezi na poradi
---NT nemusime vediet
--- index by table vyuziva sa len v pl/sql integer alebo varchar ---------nepodporuje extend, trip
 
declare 
    type t_map is table of varchar2(50) index by varchar2;
    m t_map;
begin
    m(1) := 'A';
    m(2) := 'C';
    m(10) := 'J'
end;
/


-- json
-- varchar2/blob/clob
-- check (is json)

-- pozor na zatvorky {}, [], a ciarky a medzery
select '{"meno": "Jana", "vek": 22}' as json_text from dual;

--case sensitive
select json_value('{"Name": "Marek"}', '$.Name') from dual;

--json path - navigacia kde $ je korenovy element, . -> podkluce, [] a v poli sa pouzivaju indexy
-- json value vracia skalarny retazec, cize to vrati text alebo number...
select json_value('{"osoba":{"Name": "Marek"}}', '$.osoba.Name') from dual;

-- polia -- cisluje sa od 0
select json_value('{"osoba":{"Name": "Marek"}}', '$.osoba.Name[0]') from dual;

-- $.pole[*] - rozbali cele pole

-- json_value - skalarna
-- json_query - vracia objekt/pole v json texte - clov/varchar2 -- formatovy objekt ako json
-- json_table - rozbali json do riadkov/stlpcov - ako bezna tabulka v databazach

select json_query('{"Predmety": ["DB1", "DB2", "XML kod"]}', '$.Predmety') as cele_pole from dual;

-- virtualna tabulka
select jt.meno, jt.predmet from json_table(
    '{"meno": "Zuzana", "Predmety": ["DB1", "DB2", "XML kod"]}', '$'
        columns (meno varchar2(50) path '$.meno',
                    nested path '$.Predmety[*]'
                        columns (predmet varchar2(5) path '$')
                  )
) jt;

-- json_exists - ci existuje cesta
select json_exists('{"Vek": 25}', '$.Vek') from dual;
-- pouziva sa vo where alebo case


-- json_object - objekt : kluc a hodnota
-- json_array - pole
-- json_objectagg - viac riadkov do jedneho objektu
-- json_arrayagg - agreguje viac riadkov do jedneho pola


select json_object (
    'os_cislo' value os_cislo, -- 2 je nazov stlpca
    'rocnik' value rocnik absent on null -- alebo null on null/ V pripade absent on null tak bude iba os_cislo ak je null on null tak bude null 
) from student;

-- json_array
-- pole
select json_array (meno, priezvisko) from os_udaje;















