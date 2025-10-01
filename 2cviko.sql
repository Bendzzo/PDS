create or replace function Vek_osoby (rod in char)
    return number
    is
    vek number;
begin
    select trunc(months_between(sysdate, to_date(substr(rod,1,2) || '-' || MOD(substr(rod,3,2),50) || '-' || substr(rod, 5,2), 'RR-MM-DD')) / 12)
    into vek
    from P_OSOBA where rod = ROD_CISLO;
    return vek;
end;
/
select meno, priezvisko, vek_osoby(ROD_CISLO) as vek,
    row_number() over (order by vek_osoby(rod_cislo) desc) rn,
    rank() over (order by vek_osoby(rod_cislo) desc) rnk,
    dense_rank() over (order by vek_osoby(ROD_CISLO) desc) rnk
    from p_osoba;
    
    
--druhy najstarsi
    select * from (
        select meno, priezvisko, vek_osoby(ROD_CISLO), 
            row_number() over (order by vek_osoby(ROD_CISLO) desc) vek
        from p_osoba
    ) where vek = 2;
    
--druhy najstarsi student
select * from(select meno, priezvisko, vek_osoby(rod_cislo), rocnik,
    row_number() over (partition by rocnik --zvlast poradie pre kazdy rocnik
    order by vek_osoby(ROD_CISLO) desc) as poradie
    from os_udaje join student using(rod_cislo))
    where poradie = 2;
    
select * from student;

declare cursor cur_os is(
    select meno, priezvisko, vek_osoby(ROD_CISLO) from os_udaje
);
data cur_os%rowtype;
    begin
        open cur_os;
            loop
                fetch cur_os into data;
                exit when cur_os%notfound;
                dbms_output.put_line(data.meno || ' ' || data.priezvisko);
            end loop;
        close cur_os;
    end;
/    
    
    
select meno, priezvisko, cursor(select os_cislo from student
                                where os_udaje.rod_cislo = student.rod_cislo) from os_udaje;
                                
select meno, priezvisko, listagg(os_cislo, ', ') within group (order by priezvisko)
from os_udaje 
left join student using(rod_cislo)
group by meno, priezvisko, rod_cislo;
                                
                                
                                
                                
                                
