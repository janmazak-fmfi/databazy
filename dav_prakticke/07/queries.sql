
/* 1. Pre každého zamestnanca nájdite jeho poradové číslo podľa jeho platu.
    Zoraďte výstup podľa mena zamestnanca. Zamestnanci s rovnakým platom majú mať rovnaké poradové číslo. */

/* 2. Pre každého zamestnanca vypíšte počet ľudí s platom nie vyšším ako má on. */

/* 3. (1 point) Pre každého zamestnanca vypíšte rozdiel jeho platu od priemerného platu v jeho oddelení.
Použite window functions, nie GROUP BY. */

/* 4. Pre každé oddelenie vypíšte zamestnanca s tretím najnižším platom (všetkých takých, ak ich je viac). */

/* 5. Vypíšte 20% najlepšie zarábajúcich zamestnancov. */

/* 6. Pre každého zamestnanca vypíšte násobok jeho platu oproti mediánovému platu v jeho oddelení.
    [Kombinácia percentile_cont a OVER nie je v PostgreSQL podporovaná.] */

/* 7. Vypíšte zamestnancov, ktorých plat je v najnižšom kvartile v ich oddelení. */

/* 8. Zobrazte najdlhší možný zoznam zamestnancov s najnižším platom, ktorých súčet platov je menší ako 8000
    (t.j. počínajúc zamestnancom s najmenším platom, až po zamestnanca,
    ktorého plat spolu s predošlými zamestnancami je najbližšie pod hranicou 8000). */

/* 9. Zobrazte najkratší možný zoznam zamestnancov s najnižším platom, ktorých súčet platov je aspoň 8000
    (t.j. počínajúc zamestnancom s najmenším platom, až po zamestnanca,
    ktorého plat spolu s predošlými zamestnancami je nad 8000, a pri jeho vynechaní súčet platov bude pod 8000). */

/* 10. Pre každého zamestnanca vypíšte jeho poradové číslo v rámci zamestnancov z toho istého mesta
    (pri usporiadaní mien podľa abecedy), rozdiel od priemerného platu v danom meste a počet zamestnancov v tomto meste. */

/* 11. (1 point) Pre každé oddelenie vypíšte, aký podiel na súčte platov tohto oddelenia
    tvoria platy pod celkovým mediánovým platom (nie medián pre jednotlivé oddelenia). */
