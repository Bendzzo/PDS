-- ku kazdej osobe zoznam studentskych id 
    --listagg
    --json_array_agg
    
select meno, priezvisko, json_arrayagg(os_cislo) as ids from os_udaje
    join student using(rod_cislo)
        group by meno, priezvisko, rod_cislo;

-- left join sa podmienkou premenil na inner join        
select meno, priezvisko, json_arrayagg(os_cislo) as ids from os_udaje
    left join student using(rod_cislo)
    where os_cislo is not null
        group by meno, priezvisko, rod_cislo;

-- listagg        
select meno, priezvisko, listagg(os_cislo, ',') within group(order by os_cislo) as ids from os_udaje
    left join student using(rod_cislo)
    where os_cislo is not null
        group by meno, priezvisko, rod_cislo;
        
-- osoby ktori nestudovali informatiku
-- not in, not exists, join a where
-- s not in moze byt problem kedze ignoruje null hodnoty
select * from os_udaje left join student using(rod_cislo)
where st_odbor not in(select st_odbor from st_odbory where popis_odboru = 'Informatika');

-- rod_cislo
select * from os_udaje where rod_cislo not in 
(
    select s.rod_cislo from student s 
    join st_odbory o on(s.st_odbor = o.st_odbor and s.st_zameranie = o.st_zameranie)
    where o.popis_odboru = 'Informatika'
);

-- osoby a ak student tak len druhak
select * from os_udaje
left join (select * from student where rocnik = 2) using(rod_cislo)
order by rocnik;

    -- left join student s podmienkou
    select meno, priezvisko, rocnik from os_udaje o
    left join student s on(o.rod_cislo = s.rod_cislo and (rocnik = 2) or (rocnik is null))
    order by rocnik;
    
    
--****************************** SKLAD ******************************************
desc objednavky;

select * from objednavky;
desc skladove_zasoby;

select * from skladove_zasoby;

-- kumulativny sucet produktov
select id_prod, o.mnozstvo as o_qty,
        s.mnozstvo s_qty,
        s.datum_nakupu,
        s.sklad,
        s.regal,
        s.pozicia,
        sum(s.mnozstvo)
            over (partition by s.produkt_id order by s.datum_nakupu, s.mnozstvo) agg_mnozstvo -- zoskupime podla id_produktu;
            from skladove_zasoby s join objednavky o on (id_prod = produkt_id);

-- chceme zabezpecit aby sme nepresiahli pozadovane mnozstvo
select * from (select id_prod, o.mnozstvo as o_qty,
                s.mnozstvo s_qty,
                s.datum_nakupu,
                s.sklad,
                s.regal,
                s.pozicia,
                sum(s.mnozstvo)
                    over (partition by s.produkt_id order by s.datum_nakupu, s.mnozstvo) agg_mnozstvo -- zoskupime podla id_produktu;
                    from skladove_zasoby s join objednavky o on (id_prod = produkt_id)
) where agg_mnozstvo <= o_qty;

-- rows between
select * from (select id_prod, o.mnozstvo as o_qty,
                s.mnozstvo s_qty,
                s.datum_nakupu,
                s.sklad,
                s.regal,
                s.pozicia,
                sum(s.mnozstvo)
                    over (partition by s.produkt_id 
                            order by s.datum_nakupu, s.mnozstvo 
                            rows between unbounded preceding and 1 preceding) agg_mnozstvo -- zoskupime podla id_produktu;
                    from skladove_zasoby s join objednavky o on (id_prod = produkt_id)
) where agg_mnozstvo <= o_qty;

-- vypis celkoveho mnozstva
select nested.*, least(s_qty, o_qty - agg_mnozstvo) pick_qty from (select id_prod, o.mnozstvo as o_qty, -- least berie mensie z dvoch cisel
                s.mnozstvo s_qty,
                s.datum_nakupu,
                s.sklad,
                s.regal,
                s.pozicia,
                sum(s.mnozstvo)
                    over (partition by s.produkt_id 
                            order by s.datum_nakupu, s.mnozstvo 
                            rows between unbounded preceding and 1 preceding) agg_mnozstvo -- zoskupime podla id_produktu;
                    from skladove_zasoby s join objednavky o on (id_prod = produkt_id)
) nested where agg_mnozstvo <= o_qty;


--realne zoberie
select nested.*, least(s_qty, o_qty - agg_mnozstvo) pick_qty, agg_mnozstvo + least(s_qty, o_qty - agg_mnozstvo) total_qty from (select id_prod, o.mnozstvo as o_qty, -- least berie mensie z dvoch cisel
                s.mnozstvo s_qty,
                s.datum_nakupu,
                s.sklad,
                s.regal,
                s.pozicia,
                sum(s.mnozstvo)
                    over (partition by s.produkt_id 
                            order by s.datum_nakupu, s.mnozstvo 
                            rows between unbounded preceding and 1 preceding) agg_mnozstvo -- zoskupime podla id_produktu;
                    from skladove_zasoby s join objednavky o on (id_prod = produkt_id)
) nested where agg_mnozstvo <= o_qty;

-- prechadzanie regalov na striedacku
select nested.*, least(s_qty, o_qty - agg_mnozstvo) pick_qty, 
                agg_mnozstvo + least(s_qty, o_qty - agg_mnozstvo) total_qty, 
                dense_rank() over (order by sklad, regal) as drank from (select id_prod, o.mnozstvo as o_qty, -- least berie mensie z dvoch cisel
                s.mnozstvo s_qty,
                s.datum_nakupu,
                s.sklad,
                s.regal,
                s.pozicia,
                nvl(sum(s.mnozstvo)
                    over (partition by s.produkt_id 
                            order by s.datum_nakupu, s.mnozstvo 
                            rows between unbounded preceding and 1 preceding), 0) agg_mnozstvo -- zoskupime podla id_produktu;
                    from skladove_zasoby s join objednavky o on (id_prod = produkt_id)
) nested where agg_mnozstvo <= o_qty
    order by sklad, regal, case when mod(drank, 2) = 1
                            then +pozicia
                            else -pozicia
                        end;














