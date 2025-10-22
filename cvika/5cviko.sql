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
/
create table student_json (
    id number primary key;
    document clob check(doc is json);
);
/

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











