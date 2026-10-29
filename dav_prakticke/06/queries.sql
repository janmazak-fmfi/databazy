
/* Zadania v prirodzenom jazyku nie sú úplne formalizované. Súčasťou vašej práce je preložiť ich do presného
    zadania pre SQL. Ak nie je určené napr. zaokrúhlenie počtu ľudí pri percentuálnej hranici, spôsob prideľovania
    poradia pri rovnakých platoch alebo výber jedného z viacerých rovnocenných zamestnancov, zvoľte zmysluplnú
    konvenciu a stručne ju uveďte v komentári pri riešení. Dodržte pritom pravidlá výslovne uvedené v zadaní. */

/* 1. Pre každého zamestnanca nájdite jeho poradové číslo podľa jeho platu.
    Zoraďte výstup podľa mena zamestnanca. Zamestnanci s rovnakým platom majú mať rovnaké poradové číslo.
    Tip: ktorá z funkcií RANK, DENSE_RANK a ROW_NUMBER dáva rovnakým hodnotám rovnaké poradie? */

/* 2. Pre každého zamestnanca vypíšte jeho meno, plat a plat zamestnanca, ktorý je v poradí podľa platu hneď nad ním
    (usporiadanie vzostupne podľa platu, pri zhode vzostupne podľa emp_id). Pre posledného v tomto poradí vypíšte NULL.
    Tip: pozrite si LEAD a LAG. */

/* 3. Pre každého zamestnanca vypíšte počet ľudí s platom nie vyšším ako má on.
    Tip: zamyslite sa, ako rámec (frame) window function pri ORDER BY zaobchádza so zamestnancami s rovnakým platom. */

/* 4. (1 point) Pre každého zamestnanca vypíšte rozdiel jeho platu od priemerného platu v jeho oddelení.
Použite window functions, nie GROUP BY. */

/* 5. Pre každého zamestnanca (usporiadaného podľa emp_id) vypíšte jeho plat a priemerný plat z neho samého,
    dvoch predchádzajúcich a dvoch nasledujúcich zamestnancov (na okrajoch sa počíta s menším počtom riadkov).
    Tip: použite explicitný rámec ROWS BETWEEN ... . Aký rozdiel by tu spôsobilo RANGE BETWEEN 2 PRECEDING AND 2 FOLLOWING? */

/* 6. Pre každé oddelenie vypíšte zamestnancov s tretím najnižším platom (všetkých takých, ak ich je viac).
    Tip: ktorá funkcia pri zhode dáva rovnaké poradie a nepreskakuje čísla? */

/* 7. Pre každé oddelenie vypíšte dvoch zamestnancov s najvyšším platom (pri rovnakom plate rozhodne menší emp_id).
    Oddelenia bez zamestnancov nevypisujte.
    Tip: window function nemožno použiť priamo vo WHERE; výsledok najprv vypočítajte napr. vo WITH a až potom filtrujte. */

/* 8. Vypíšte zamestnancov, ktorí patria medzi 20 % najlepšie platených v celej firme.
    Tip: PERCENT_RANK() vracia (RANK() - 1) / (počet riadkov - 1). Filtrujte mimo window function. */

/* 9. Pre každého zamestnanca vypíšte násobok jeho platu oproti mediánovému platu v jeho oddelení.
    Tip: percentile_cont je agregát typu ordered-set a s OVER v PostgreSQL nefunguje. Medián počítajte agregovaním
    (GROUP BY) a výsledok pripojte k zamestnancom. */

/* 10. Pre každého zamestnanca vypíšte meno najlepšie plateného a meno najhoršie plateného zamestnanca v jeho oddelení
    (môže ísť o neho samého).
    Tip: FIRST_VALUE a LAST_VALUE; zamyslite sa nad predvoleným rámcom pri ORDER BY. */

/* 11. Vypíšte zamestnancov, ktorí patria do najnižšieho kvartilu platov vo svojom oddelení, t.j. ich plat je
    menší alebo rovný 25. percentilu platov v ich oddelení (percentil počítajte pomocou percentile_cont(0.25) ako v úlohe 9).
    Tip: percentil nie je window function; spočítajte ho v podselecte s GROUP BY a pripojte k zamestnancom. */

/* 12. Zobrazte najdlhší zoznam zamestnancov s najnižšími platmi, ktorých súčet platov je menší ako 8000.
    Zamestnancov usporiadajte podľa platu a pri zhode podľa emp_id. Zoznam tvoria prví zamestnanci v tomto poradí,
    pokiaľ je ich kumulatívny súčet platov menší ako 8000.
    Tip: kumulatívny súčet získate SUM() OVER (ORDER BY ... ROWS UNBOUNDED PRECEDING). */

/* 13. Zobrazte najkratší zoznam zamestnancov s najnižšími platmi (usporiadanie ako v úlohe 12), ktorého súčet platov
    je aspoň 8000. Zoznam tvoria prví zamestnanci v tomto poradí, až kým kumulatívny súčet platov dosiahne alebo
    prekročí 8000. */

/* 14. Pre každého zamestnanca vypíšte jeho poradové číslo v rámci zamestnancov z toho istého mesta
    (pri usporiadaní mien podľa abecedy), rozdiel od priemerného platu v danom meste a počet zamestnancov v tomto meste.
    Mesto zamestnanca je location jeho oddelenia. */

/* 15. Pre každý projekt vypíšte zamestnancov, ktorí na ňom pracujú, spolu s ich poradím podľa platu v rámci tohto
    projektu (zamestnanci s rovnakým platom majú rovnaké poradie). */

/* 16. (1 point) Pre každé oddelenie vypíšte, aký podiel na súčte platov tohto oddelenia tvoria platy pod celkovým
    mediánovým platom (nie medián pre jednotlivé oddelenia).
    Tip: celkový medián je agregát bez OVER, ten v PostgreSQL funguje. */
