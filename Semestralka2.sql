select *
from ZAMESTNANEC;

grant select, insert, update, delete on LIEK to FRONC3;

select * from BELIANCINOVA8.zamestnanec;

alter table LIEK modify (
    doplatok_pacienta NUMBER(2, 2)
    )

ALTER TABLE zamestnanec
    ADD CONSTRAINT  XPKzamestnanec PRIMARY KEY (id_zamestnanec);

create or replace trigger trigger_expiracia_liek
    before insert on TRANSAKCIA
    for each row
    declare
        expiracia_lieku DATE;
    begin
        select EXPIRACIA into expiracia_lieku from LIEK
            where ID_LIEK = :new.id_liek;

        if expiracia_lieku < trunc(sysdate)
            then raise_application_error(-20000, 'Lieku skoncila trvanlivost!');
        end if;
    end;

CREATE OR REPLACE TRIGGER trigger_expiracia_lieku
    BEFORE INSERT ON VYDANE_LIEKY
    FOR EACH ROW
DECLARE
    expiracia_lieku DATE;
BEGIN
    SELECT l.EXPIRACIA INTO expiracia_lieku
    FROM LIEK l
             join SKLAD s ON l.id_liek = s.id_liek
    WHERE s.id_naskladnenia = :NEW.id_naskladnenia;

    IF expiracia_lieku < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20000, 'Lieku skoncila trvanlivost!');
    END IF;
END;

select * from VYDANE_LIEKY;

CREATE OR REPLACE PROCEDURE VymazZamestnanca (p_ID_ZAMESTNANEC IN ZAMESTNANEC.id_zamestnanec%type) AS
BEGIN
    DELETE FROM zamestnanec
    WHERE ID_ZAMESTNANEC = p_ID_ZAMESTNANEC;

    COMMIT;
END VymazZamestnanca;

CREATE OR REPLACE PROCEDURE VymazLiek (p_id_liek IN LIEK.id_liek%type) AS
BEGIN
    DELETE FROM LIEK
    WHERE ID_LIEK = p_id_liek;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE vymazOsobu (p_rod_cislo IN OSOBNE_UDAJE.ROD_CISLO%type) AS
BEGIN
    DELETE FROM OSOBNE_UDAJE
    WHERE ROD_CISLO = p_rod_cislo;

    COMMIT;
END;

CREATE OR REPLACE PROCEDURE vymazPacienta (p_id_pacient IN PACIENT.ID_PACIENT%type) AS
BEGIN
    DELETE FROM PACIENT
    WHERE ID_PACIENT = p_id_pacient;

    COMMIT;
END;

create or replace function najlepsi_zamestnanec
    return integer
as
    suma integer;
    zamestnanec integer;
    begin
        select ID_ZAMESTNANEC into ZAMESTNANEC from TRANSAKCIA
        where ID_ZAMESTNANEC in (select ID_ZAMESTNANEC from TRANSAKCIA where cena in (select max(sum(cena)) from TRANSAKCIA)
                                                                       group by ID_ZAMESTNANEC);
        return zamestnanec;
    end;


    select * from OSOBNE_UDAJE;

insert into ZAMESTNANEC (ID_ZAMESTNANEC, POZICIA, UVAZOK, PLAT, OD, DO, ROD_CISLO) VALUES (6, 'AN', 'A', 150, sysdate, null, '7562550123');
select *
from ZAMESTNANEC;

begin
    VymazZamestnanca(6);
end;

SELECT
    o.rod_cislo,
    o.meno AS meno_zakaznika,
    o.priezvisko AS priezvisko_zakaznika,
    l.id_liek,
    l.nazov,
    l.davkovanie,
    l.expiracia,
    l.cena,
    l.doplatok_pacienta,
    CASE WHEN r.id_recept IS NULL THEN 'Bez receptu' ELSE 'S receptom' END AS typ_nakupu
FROM
    pacient p
        JOIN osobne_udaje o ON p.rod_cislo = o.rod_cislo
        JOIN vydane_lieky vl ON p.id_pacient = vl.id_transakcia
        JOIN sklad s ON vl.id_naskladnenia = s.id_naskladnenia
        JOIN liek l ON s.id_liek = l.id_liek
        LEFT JOIN lieky_na_recept lr ON l.id_liek = lr.id_liek
        LEFT JOIN recept r ON lr.id_recept = r.id_recept
        JOIN transakcia t ON vl.id_transakcia = t.id_transakcia
        JOIN zamestnanec z ON t.id_zamestnanec = z.id_zamestnanec
        JOIN osobne_udaje o_zam ON z.rod_cislo = o_zam.rod_cislo
WHERE
    p.id_pacient = 6;

ALTER TABLE transakcia
    ADD (ID_PACIENT integer);

ALTER TABLE transakcia
    ADD CONSTRAINT fk_transakcia_pacient
        FOREIGN KEY (ID_PACIENT)
            REFERENCES Pacient (ID_PACIENT);

CREATE OR REPLACE PROCEDURE ZobrazTransakciePacienta (f_id_pacient IN NUMBER) AS
BEGIN
    FOR rec IN (
        SELECT
            o.rod_cislo,
            o.meno AS meno_zakaznika,
            o.priezvisko AS priezvisko_zakaznika,
            l.id_liek,
            l.nazov,
            l.davkovanie,
            l.expiracia,
            l.cena,
            l.doplatok_pacienta,
            CASE WHEN r.id_recept IS NULL THEN 'Bez receptu' ELSE 'S receptom' END AS typ_nakupu
        FROM
            pacient p
                JOIN osobne_udaje o ON p.rod_cislo = o.rod_cislo
                JOIN vydane_lieky vl ON p.id_pacient = vl.id_transakcia
                JOIN sklad s ON vl.id_naskladnenia = s.id_naskladnenia
                JOIN liek l ON s.id_liek = l.id_liek
                LEFT JOIN lieky_na_recept lr ON l.id_liek = lr.id_liek
                LEFT JOIN recept r ON lr.id_recept = r.id_recept
                JOIN transakcia t ON vl.id_transakcia = t.id_transakcia
                JOIN zamestnanec z ON t.id_zamestnanec = z.id_zamestnanec
                JOIN osobne_udaje o_zam ON z.rod_cislo = o_zam.rod_cislo
        WHERE
            p.id_pacient = f_id_pacient
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Rodné číslo: ' || rec.rod_cislo);
            DBMS_OUTPUT.PUT_LINE('Meno zákazníka: ' || rec.meno_zakaznika);
            DBMS_OUTPUT.PUT_LINE('Priezvisko zákazníka: ' || rec.priezvisko_zakaznika);
            DBMS_OUTPUT.PUT_LINE('ID lieku: ' || rec.id_liek);
            DBMS_OUTPUT.PUT_LINE('Názov lieku: ' || rec.nazov);
            DBMS_OUTPUT.PUT_LINE('Dávkovanie: ' || rec.davkovanie);
            DBMS_OUTPUT.PUT_LINE('Expirácia: ' || rec.expiracia);
            DBMS_OUTPUT.PUT_LINE('Cena: ' || rec.cena);
            DBMS_OUTPUT.PUT_LINE('Doplatok pacienta: ' || rec.doplatok_pacienta);
            DBMS_OUTPUT.PUT_LINE('Typ nákupu: ' || rec.typ_nakupu);
            DBMS_OUTPUT.PUT_LINE('------------------------------');
        END LOOP;
END ZobrazTransakciePacienta;

BEGIN
    DBMS_OUTPUT.ENABLE;

    ZobrazTransakciePacienta(8);
END;








