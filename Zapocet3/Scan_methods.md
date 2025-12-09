### A. Prístup priamo k tabuľke (Table Access)

#### 1. TABLE ACCESS FULL (Full Table Scan)
*   **Čo robí:** Číta celú tabuľku, blok po bloku, až po posledný zapísaný blok (High Water Mark).
*   **Kedy nastane:**
    *   Neexistuje žiadny vhodný index.
    *   Dopyt používa funkciu na stĺpci, ktorý nie je funkcionálne indexovaný (napr. `WHERE UPPER(meno) = ...`).
    *   Podmienka je typu `IS NULL` (ak stĺpec nie je súčasťou vhodného indexu).
    *   Výber veľkého množstva dát (Oracle usúdi, že je rýchlejšie prečítať všetko naraz než skákať cez index).
    *   Použiješ `LIKE '%nieco'`.

#### 2. TABLE ACCESS BY INDEX ROWID
*   **Čo robí:** Toto je **krok č. 2**. Najprv sa indexom získa adresa riadku (ROWID) a následne sa podľa tejto adresy siahne do tabuľky pre zvyšné dáta.
*   **Kedy nastane:**
    *   Index sa použil na vyhľadanie, ale v `SELECT` klauzule pýtaš stĺpce, ktoré v indexe nie sú (index **nie je** pokrývajúci).

---

### B. Prístup cez B-Tree Index (Index Access)

#### 1. INDEX UNIQUE SCAN
*   **Čo robí:** Prejde stromom a nájde **maximálne jeden** riadok.
*   **Kedy nastane:**
    *   Podmienka rovnosti (`=`) na **Primárny kľúč** (Primary Key).
    *   Podmienka rovnosti (`=`) na **Unikátny index** (Unique Index).
*   **Rýchlosť:** Najrýchlejšia možná metóda.

#### 2. INDEX RANGE SCAN
*   **Čo robí:** Prejde stromom na začiatok rozsahu a potom číta listové bloky "do boku", kým platí podmienka. Môže vrátiť 0, 1 alebo veľa riadkov.
*   **Kedy nastane:**
    *   Podmienka rovnosti (`=`) na **neunikátnom** indexe.
    *   Rozsahové podmienky (`<`, `>`, `BETWEEN`, `LIKE 'A%'`).
    *   Podmienka na **vodiaci** (prvý) stĺpec kompozitného indexu.
*   **Poznámka:** Vrátené dáta sú automaticky zoradené podľa kľúča indexu.

#### 3. INDEX FULL SCAN
*   **Čo robí:** Prečíta **celý** index, ale v logickom poradí (prechádza listové bloky zľava doprava).
*   **Kedy nastane:**
    *   Nepoužívame filter (`WHERE`), ale chceme dáta zoradené (`ORDER BY`).
    *   Index obsahuje všetky potrebné stĺpce, takže nemusíme ísť do tabuľky, ale potrebujeme triedenie.
    *   Je to pomalšie ako Fast Full Scan, lebo číta po jednom bloku ("single block read").

#### 4. INDEX FAST FULL SCAN
*   **Čo robí:** Prečíta celý index, ale ignoruje stromovú štruktúru. Číta ho ako tabuľku (multiblock read), len aby získal dáta.
*   **Kedy nastane:**
    *   Chceme len spočítať riadky (`COUNT(*)`).
    *   Index obsahuje všetky potrebné stĺpce, ale **nezáleží nám na poradí** (nie je tam `ORDER BY`).
*   **Výhoda:** Je to veľmi rýchle, lebo index je menší ako tabuľka a číta sa efektívne.

#### 5. INDEX SKIP SCAN
*   **Čo robí:** "Preskočí" prvý stĺpec kompozitného indexu a hľadá podľa druhého (alebo ďalšieho).
*   **Kedy nastane:**
    *   Máš kompozitný index `(A, B)`.
    *   Vo `WHERE` podmienke máš len `B = ...` (chýba vodiaci stĺpec A).
    *   **Podmienka:** Vodiaci stĺpec A má veľmi málo unikátnych hodnôt (napr. Pohlavie M/Z), zatiaľ čo B ich má veľa. Oracle si index logicky rozdelí na dva pod-indexy (pre M a pre Z) a prehľadá oba.

---

### Rýchly rozhodovací strom (ako uvažovať pri úlohe):

1.  Mám vo `WHERE` podmienke stĺpec, ktorý je na **prvom mieste** v indexe?
    *   **Áno** a je to **Primary Key / Unique** (`=`) -> `INDEX UNIQUE SCAN`.
    *   **Áno** a je to **Non-unique** alebo rozsah (`<, >`) -> `INDEX RANGE SCAN`.
    *   **Nie**, ale pýtam sa na stĺpec, ktorý je v indexe druhý a prvý má málo hodnôt -> `INDEX SKIP SCAN`.
    *   **Nie** -> Pravdepodobne `FULL TABLE SCAN`.

2.  Sú v indexe obsiahnuté **všetky** stĺpce, ktoré sú v `SELECT` aj vo `WHERE`?
    *   **Áno** -> Databáza nepoužije `TABLE ACCESS BY INDEX ROWID` (ušetrí krok).
    *   **Nie** -> Databáza po použití indexu musí skočiť do tabuľky.

3.  Mám `SELECT count(*)` alebo vyberám všetko z indexu bez `WHERE`?
    *   Ak treba triediť -> `INDEX FULL SCAN`.
    *   Ak netreba triediť -> `INDEX FAST FULL SCAN`.
