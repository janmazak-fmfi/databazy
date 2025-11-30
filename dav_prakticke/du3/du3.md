# Domáca úloha č. 3 (15 bodov)

Úloha pozostáva z dvoch častí: rozšírenie tabuľky evidujúcej vyriešené testy o skóre a napísanie programu, pomocou ktorého budú študenti cez konzolu vypĺňať test. Budeme používať databázu popísanú v [druhej domácej úlohe](../du2/du2.md).

### Skóre

Do tabuľky, kde evidujete vypracovania testov študentmi, pridajte stĺpec pre _skóre_, t.j. podiel správnych odpovedí k celkovému počtu otázok testu, zaokrúhlený na celé percentá (číslo typu DECIMAL s dvomi desatinnými miestami). Skóre určujeme ako podiel, kde menovateľ je vždy celkový počet otázok testu, bez ohľadu na počet zatiaľ zodpovedaných otázok (pre test s 0 otázkami nastavte skóre na NULL).

Konzistenciu dát v databáze zabezpečíme pomocou triggrov.
1. Napíšte SQL funkciu `calculate_student_score`, ktorá preráta príslušné skóre. (Pozor: nechceme rátať všetky skóre v databáze, len tie, čo sa týkajú jedného vypracovania testu.)
2. Vytvorte trigger, ktorý pri _vložení_, _zmene_ a _zmazaní_ odpovede prepočíta skóre príslušného žiaka (pre zodpovedajúce vypracovanie testu). Na výpočet skóre použite funkciu `calculate_student_score`.
3. Vytvorte trigger, ktorý pri _vložení_ a _zmene_ záznamu, ktorý zodpovedá vypracovaniu testu (obsahuje hodnotu skóre), overí pomocou `calculate_student_score`, že hodnota skóre je správna. Ak nie je, vyhoďte chybu. Návod: použitie RAISE v
[SQLite](https://www.sqlitetutorial.net/sqlite-trigger/) a
[PostgreSQL](https://www.postgresql.org/docs/current/plpgsql-errors-and-messages.html).
Trigger pre zmazanie vypracovania testu nepotrebujeme, lepšie je riešiť ho na úrovni cudzích kľúčov: spolu s vypracovaním testu zmazať všetky odpovede, alebo naopak nedovoliť zmazanie vypracovania testu, ak sa naň odkazujú nejaké odpovede.

Tieto triggre a funkcie by nemali k svojej činnosti vyžadovať kompletnú sadu odpovedí na daný test (aby bolo možné vložiť nulové skóre a vyhli sme sa tak kruhovej závislosti, keď do jednej tabuľky nič nemožno vložiť, lebo v inej chýba záznam, a naopak --- na rozdiel od cudzích kľúčov spustenie triggrov nemožno odložiť na koniec transakcie). Vzhľadom na požadované triggre bude potrebné najprv vložiť nové vypracovanie testu, až potom jednotlivé odpovede.

Požadované funkcie a triggre pridajte do súboru `testy.sql`, v ktorom máte vytváranie databázových tabuliek.

Poznámka:
V PostgreSQL možno použiť jazyk PL/pgSQL.
V SQLite sú možnosti pre triggre obmedzené, preto sa vám možno nepodarí spraviť jednu univerzálnu funkciu `update_student_score`.
Jednotlivé databázové systémy ponúkajú aj iné mechanizmy na automatické prepočty,
napr. [generated columns](https://www.postgresql.org/docs/current/ddl-generated-columns.html).
Tým sa v tejto DÚ vyhneme.

### Program

Rozšírte tabuľku študentov o unikátne prihlasovacie meno, t.j. nejaký textový identifikátor študenta (heslo pre jednoduchosť nezavedieme).

Vytvorte program v Pythone (v jedinom súbore `testy.py`) s nasledovnou funkcionalitou:
* Interaktívne komunikuje s užívateľom cez terminál (konzolu).
* Po spustení si vyžiada prihlasovacie meno študenta; ak sa nenašlo, opakovane si ho bude pýtať znovu.
* Po zadaní existujúceho prihlasovacieho mena program vypíše zoznam testov pridelených študentovi vrátane doteraz najlepšieho vypracovania ku každému testu (t.j. s najvyšším skóre) a študent zadaním poradového čísla vyberie test, ktorý ide vypracovať.
* Následne program bude zadávať jednotlivé otázky zvoleného testu. Študent si zakaždým vyberie odpoveď (napísaním jedného z písmen a, b, c, d) a program ju zaznamená do _pomocnej_ tabuľky v databáze. Ide o *perzistentné* uloženie: po vypnutí a zapnutí programu sa program nepýta na už zodpovedané otázky z testu, ale pokračuje nezodpovedanými. Program a pomocná tabuľka by mali umožnovať mať naraz viacero rozpracovaných testov.
* Otázky treba zadávať v náhodnom poradí. Randomizáciu riešte priamo v databáze, nie v Pythone. Hoci to v tomto prípade nepotrebujeme, prečítajte si niečo o [`TABLESAMPLE BERNOULLI`](https://jetrockets.com/blog/how-to-quickly-get-a-random-set-of-rows-from-a-postgres-table) a [`TABLESAMPLE system_rows`](https://www.redpill-linpro.com/techblog/2021/05/07/getting-random-rows-faster.html).
* Po zodpovedaní všetkých otázok testu program (_v rámci jedinej transakcie_!) presunie všetky študentove odpovede z pomocnej tabuľky medzi trvalé záznamy, zaeviduje čas vypracovania a vypíše skóre.

#### Ďalšie požiadavky

Nezabudnite na detekciu a spracovanie databázových chýb a súvisiacich výnimiek. Vo všeobecnosti v reálnej situácii si treba podrobnejšie naštudovať, aké rôzne chyby konkrétny DBMS reportuje, napr. [SQLite](https://www.sqlite.org/rescode.html), ale program v tejto domácej úlohe sa v princípe nevie z chýb zmysluplne spamätať a asi najrozumnejšie je proste ukončiť pri akejkoľvek chybe databázy jeho činnosť. Rozlišujte však medzi databázovými a inými chybami --- ak napr. dôjde k TypeError, lebo ste zabudli ošetriť nejaký okrajový prípad, je to čosi výrazne iné, ako keď používateľ zmaže súbor s SQLite databázou.

Váš programovací štýl nemusí byť zďaleka dokonalý, ale snažte sa držať aspoň základných zásad: zmysluplné pomenovanie premenných, oddelenie častí kódu do funkcií, využitie `?` pri vytváraní databázových dotazov miesto lepenia reťazcov, konzistentné formátovanie atď. Možno sa to nezdá, ale už z prvého pohľadu na kód možno usúdiť nie málo o kvalite vašej práce, a veľká časť schopnosti písať čitateľný kód spočíva vo vytvorení návykov, nestojí to zväčša ani čas navyše (dokonca možno čas aj ušetríte, až budete v programe hľadať prípadné chyby).

Na formátovanie kódu použite nástroj [black](https://black.readthedocs.io/en/stable/getting_started.html#installation).

Na kontrolu chýb skúste [flake8](https://flake8.pycqa.org/en/latest/) alebo [pylint](https://pylint.readthedocs.io/en/stable/).

#### Dáta na vyskúšanie

Do súboru `testy.sql` doplňte pridanie testu s názvom `Trivia` a nasledovnými otázkami (správna odpoveď je označená hviezdičkou):
```
Which of the following is not an international organisation?
A. FIFA
B. NATO
C. ASEAN
*D. FBI

Which of the following disorders is the fear of being alone?
A. agoraphobia
B. aerophobia
C. acrophobia
*D. none of the above

In which country is Transylvania?
A. Bulgaria
*B. Romania
C. Croatia
D. Serbia
```

Tento test prideľte študentovi s prihlasovacím menom `xyz`.

### Technické pokyny

* Termín na odovzdanie: **23. 12. 2025**.
* Používajte korektnú syntax SQL podporovanú databázou SQLite 3.34 alebo Postgresql 13.17 (overiť si to môžete trebárs na serveri `cvika.dcs.fmph.uniba.sk`).
* Používajte len základné štandardné knižnice jazyka Python vo verzii 3.9.
* Riešenia so syntaktickými chybami budú hodnotené len malým počtom bodov.
* Odovzdajte kód formátovaný nástrojom `black`.
* Súbory `testy.sql` a `testy.py` odošlite ako prílohy e-mailu s predmetom `DAV-DU3` na adresu `jan.mazak@fmph.uniba.sk`.

### Poznámky

Atribút _skóre_ popísaný v zadaní je redundantný, lebo jeho hodnotu možno zistiť z jednotlivých zodpovedaných otázok.
Všimnite si, že nejde o redundanciu vzhľadom na funkčné závislosti. Táto redundancia sa nedá odstrániť normalizovaním do BCNF.
Konzistentnosť strážime pomocou triggrov, lebo ju nechceme nechať na klientske programy pracujúce s databázou.

Pridaný atribút umožňuje rýchlejšie spracovanie dotazov zahŕňajúcich skóre.
Vo všeobecnosti existujú aj iné mechanizmy na zvýšenie výkonu, napr.
[MATERIALIZED VIEW](https://www.postgresql.org/docs/current/rules-materializedviews.html).
To môže byť užitočné v prípade, že nám neprekáža, že dáta vo view nie sú úplne aktuálne (view necháme periodicky prerátať napr. pomocou cron job).
Tu sa nám však veľmi nehodí.
