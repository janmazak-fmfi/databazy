# Témy na skúšku

Tieto témy zodpovedajú štátnicovým požiadavkám (až na transakcie; tie prvé tri okruhy sú dôležitejšie, ako vidno aj z príkladov otázok nižšie).

1. Jazyk SQL --- dotazy, join, antijoin, vyjadrenie negácie a všeobecného kvantifikátora, agregácia, CTE, rekurzia, DDL, DML.
2. Výpočet dotazov v relačnom modeli --- relačná algebra, fyzické operátory (podrobne merge sort a hash join), plán výpočtu dotazu, základné princípy optimalizácie výpočtu dotazu (rozdiely oproti bežnej algoritmickej zložitosti), indexy (B-tree, hash index).
3. Teória navrhovania a normálne formy --- atribúty, funkčné závislosti, uzáver a pokrytie množiny funkčných závislostí, kľúče a nadkľúče, 3NF, BCNF, bezstratovosť dekompozície a zachovanie funkčných závislostí, redundancia a súvisiace anomálie (pri vkladaní, mazaní či zmene dát), entitno-relačný model.
4. Transakcie --- ACID, rozvrhy, úrovne sériovateľnosti, obnoviteľnosť (dirty read/write, kaskádový abort, algoritmus obnovy), dvojfázové zamykanie, generovanie striktných rozvrhov a riešenie deadlocku.


# Otázky na skúšku

Príklady otázok:

---

* životný cyklus dotazu --- podrobne popíšte, čo sa deje v DBMS medzi prijatím dotazu a odoslaním výsledkov
* normalizácia --- čo a prečo je cieľom, či sa to dá vždy dosiahnuť, v akých situáciách je vhodné zľaviť z požiadaviek na normalizáciu; uveďte príklad nevhodne navrhnutých tabuliek a vysvetlite, ako to napraviť

---

* transakcie --- ako umožniť paralelné spracovanie, za čo je zodpovedný DBMS a ako to DBMS dosahuje
* čo možno a nemožno vyjadriť v dotazovacích jazykoch; ako sa vyjadruje negácia, všeobecný kvantifikátor, rekurzia
* čo neželané sa môže stať, ak relácie nie sú v BCNF; uveďte príklady

---

* obnoviteľnosť: ako zabezpečiť spoľahlivé permanentné uloženie dát (aj pri paralelnom spracovaní); dirty read a kaskádové aborty
* ako databáza optimalizuje výpočty a aký vplyv na rýchlosť výpočtu má množstvo operačnej pamäti (vysvetliť na príklade mergesortu)
* čo sú funkčné závislosti, prečo ich chceme zachovať pri dekompozícii relácií (diskutujte zachovanie aj nezachovanie na príklade), čo robiť, ak sa zachovať nedajú

---

* akými rôznymi spôsobmi možno počítať join na úrovni fyzických operátorov (aj mimo relačnej databázy)
* akými prostriedkami možno zabezpečiť konzistentnosť databázy v PostgreSQL
* princípy riešenia deadlocku v transakčných systémoch

---

* relačná algebra --- čo to je a na čo slúži; súvislosť s fyzickými operátormi
* teoretické a praktické možnosti pre úroveň sériovateľnosti transakcií
* rozdiel medzi 3NF a BCNF (ideálne aj uviesť príklad relácie), kedy existuje dekompozícia do týchto NF a kedy nie

---

* relačný model --- čo sú atribúty, relácie a funkčné závislosti; bezstratové spájanie dekompozície
* čo nemožno vyjadriť v dotazoch bez rekurzie a ako sa rekurzia počíta v bežných DBMS
* dvojfázové zamykanie (princíp, vlastnosti generovaných rozvrhov)

# Úlohy na skúške

Na skúške sa, podobne ako na štátniciach, môžu vyskytnúť úlohy, ktorých riešenie následne bude slúžiť ako podklad pre diskusiu.
Zvyčajne ide o jednoduché úlohy týkajúce sa normalizácie, môže sa však vyskytnúť aj schematický prepis nie veľmi zložitého dotazu v SQL do relačnej algebry a diskusia o súvisiacich fyzických operátoroch. Príklady:

---

Na príklade vysvetlite, že dekompozícia relácie sa nemusí spájať bezstratovo, hoci sú všetky funkčné závislosti zachované.
Ukážte tiež, že bezstratová dekompozícia nemusí zachovávať všetky FZ.

---

Uvažujme nasledujúcu databázovú schému pre evidenciu študentov a predmetov, ktoré navštevujú (študent si môže zapísať viacero predmetov):

    student(id_student, meno, rocnik)
    predmet(id_predmet, nazov, katedra)
    zapis(id_student, id_predmet)

Čo by ste v relácii `zapis` zvolili ako primárny kľúč a prečo? Je táto schéma v BCNF? Zdôvodnite na základe funkčných závislostí.

---

V databázovej relácii

    R(RoomID, Capacity, CourseID, TimeSlot)

platia dve netriviálne funkčné závislosti:

    RoomID -> Capacity,
    {CourseID, TimeSlot} -> RoomID.

Nájdite všetky kľúče, dekomponujte R vhodným spôsobom do BCNF a zdôvodnite správnosť svojho postupu. Stručne vysvetlite pojmy FZ, zachovanie FZ pri dekompozícii, bezstratová dekompozícia, normálna forma. Prečo reláciu R normalizujeme?

---

Prepíšte dotaz

    SELECT DISTINCT s.name
    FROM student s
    WHERE NOT EXISTS (
        SELECT 1
        FROM exam e
        WHERE e.id_student = s.id_student
        AND e.course = 'Python'
    );

pomocou operátorov relačnej algebry (napr. v podobe operátorového stromu) a navrhnite indexy (jeden či viacero, vysvetlite vhodnosť btree či hash indexu), ktoré zrýchlia výpočet tohto dotazu.
