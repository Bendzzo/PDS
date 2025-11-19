grant all privileges to blob_manager;

create table blob_table (
    id integer,
    nazov varchar2(50),
    obrazok BLOB,
    pripona varchar2(3)
);

CREATE DIRECTORY vyhnal1_dir AS 'C:\Bloby_student\vyhnal1\';

grant read, write on directory vyhnal1_dir to vyhnal1;

DECLARE
v_source_blob BFILE := BFILENAME('vyhnal1', 'oracle.jpg');
    v_size_blob integer;
    v_blob BLOB := EMPTY_BLOB();
BEGIN
DBMS_LOB.OPEN(v_source_blob, DBMS_LOB.LOB_READONLY);
v_size_blob := DBMS_LOB.GETLENGTH(v_source_blob);
 
INSERT INTO blob_table(id, nazov, obrazok, pripona)
    values(5, 'model', EMPTY_BLOB(), '.jpg')
        returning obrazok into v_blob;
 
DBMS_LOB.LOADFROMFILE(v_blob, v_source_blob, v_size_blob);
DBMS_LOB.CLOSE(v_source_blob);
UPDATE blob_table
    SET obrazok=v_blob
WHERE ID=5;
END;
/

select * from blob_table;
