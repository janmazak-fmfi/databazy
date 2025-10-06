# Domáca úloha č. 1 (15 bodov)

Daná je databáza
```
	lubi(Pijan, Alkohol),
	capuje(Krcma, Alkohol, Cena),
	navstivil(Id, Pijan, Krcma, Od),
	vypil(Id, Alkohol, Mnozstvo).
```
Atribút `Id` v reláciách `navstivil` a `vypil` je identifikátorom návštevy; každá návšteva zahŕňa práve jedného pijana a práve jednu krčmu. Atribút `Od` udáva čas, kedy návšteva začala. V každom momente môže byť pijan v nanajvýš jednej krčme.

Atribút `Cena` udáva cenu daného alkoholu v danej krčme (ceny sa nemenia). Každá krčma čapuje aspoň jeden alkohol.
Atribút `Mnozstvo` je celkové množstvo jedného alkoholu vypitého pri danej návšteve (pre každú dvojicu `Id, Alkohol` je vo `vypil` nanajvýš jeden záznam); platí `Mnozstvo > 0`.
Vo `vypil` sú zaznamenané len alkoholy, ktoré čapuje navštívená krčma.

Môžete predpokladať, že databáza neobsahuje žiaden spor (napr. rôzni pijani pre jednu hodnotu `Id` v `navstivil`).

Vašou úlohou je napísať nasledujúce štyri dotazy.

(a) Pijan je *lojálny* ku krčme K, ak v nej pil aspoň raz a žiaden z alkoholov, ktorý
kedykoľvek pil v K, už potom nikde inde nepil.
Nájdite všetky dvojice P, K také, že pijan P je lojálny ku krčme K. Usporiadajte ich podľa P a K.

(b) Pijan je *silne závislý* na alkohole A vtedy, ak
alkohol A pil aspoň raz a konzumuje ho pri každej návšteve krčmy, ktorá A čapuje; a zároveň platí, že
množstvá A, ktoré pije pri takých návštevách, tvoria s rastúcim časom neklesajúcu
postupnosť. Nájdite všetky dvojice P, A také, že pijan P je silne
závislý na alkohole A. Usporiadajte ich podľa P a A.

(c) Pijan je *jediným rekordérom v pití alkoholu A na jedno posedenie* v
krčme K, ak vypil počas niektorej svojej návštevy krčmy K viac
alkoholu A ako ktorýkoľvek iný pijan počas ktorejkoľvek svojej
návštevy v K (a aspoň raz v krčme K pil). Nájdite dvojice P, A také, že pijan P ľúbi alkohol A a
v každej krčme, ktorá čapuje alkohol A, je P jediným rekordérom v pití A na
jedno posedenie. Usporiadajte ich podľa P a A.

(d) *Držgroš* je pijan, ktorý pri ľubovoľnej návšteve krčmy je ochotný vypiť len najlacnejší alkohol z tých, ktoré tá krčma čapuje a ktoré on zároveň ľúbi (ak je takých viac, môže piť ľubovoľný), a aj to len vtedy, ak zatiaľ nepozná (t.j. predtým nenavštívil) krčmu, ktorá ten alkohol čapuje lacnejšie (piť však nemusí vôbec). Nájdite všetkých držgrošov a usporiadajte ich podľa abecedy. (Patria medzi nich aj abstinenti. Vo výsledku chceme len pijanov, ktorí aspoň raz navštívili krčmu. Predpokladáme, že ceny alkoholov sa nikdy nemenia.)

_Vyhýbajte sa korelovaným vnoreným dotazom (radšej použite antijoin, čiže WHERE NOT EXISTS), zväčša sú pomalé!_

### Technické pokyny

* Termín na odovzdanie: **3. 11. 2025**
* Používajte korektnú syntax SQL podporovanú databázou SQLite 3.34 (overiť si to môžete trebárs na serveri `cvika.dcs.fmph.uniba.sk`). Riešenia so syntaktickými chybami budú hodnotené len minimálnym počtom bodov.
* Každý dotaz aj s pomocnými reláciami zapíšte do osobitného súboru s príponou `.sql` pomenovaného písmenom zodpovedajúcim zadanému dotazu (napr. `a.sql`). **Okrem komentárov by v ňom nemalo byť nič navyše** (napr. žiadne príkazy ako `.mode`).
* Súbory `a.sql`, `b.sql`, `c.sql`, `d.sql` odošlite ako prílohu e-mailu zo školskej adresy na adresu `jan.mazak@fmph.uniba.sk` s predmetom `DAV-DU1`.
* Na usporiadaní výsledku dotazu síce zásadne nezáleží, ale robí výsledok deterministickým, preto nezabudnite na príslušný `ORDER BY`.

### Overenie správnosti riešení

Správnosť riešenia si môžete overiť pre databázu [pijani.sql](testdata/pijani.sql).
Správne odpovede na dotazy nájdete v súbore [pijani_answers.txt](testdata/pijani_answers.txt).
