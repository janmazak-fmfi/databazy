
/*  1. Vypiste nazvy vsetkych knih, ktore su prave teraz pozicane (t.j. neexistuje zaznam o ich vrateni). */

/*  2. Vypiste meno, datum registracie, den v tyzdni (v den registracie) pre vsetkych citatelov, ktori sa registrovali pocas poslednych 365 dni.
Na vypis dna v tyzdni v ludsky citatelnom formate pouzite CASE statement. */

/*  3. Najdite mena citatelov, ktori vratili do 30 dni kazdu z knih, ktore si pozicali. Kniha, ktoru citatel este nevratil, ho diskvalifikuje len vtedy, ak od jej pozicania uplynulo aspon 30 dni (kniha pozicana napr. pred 5 dnami a stale nevratena citatela nediskvalifikuje). (Vratane citatelov, ktori si nikdy nepozicali nic.) */

/*  4. Vypiste mena citatelov, ktori si pozicali aspon tri rozne knihy, a pritom vsetky ich pozicane knihy boli od toho isteho autora. */

/*  5. Ku kazdemu citatelovi vypiste nazov prvej knihy, ktoru si pozical, alebo null, ak si nikdy nepozical nic. (Ak si v ten den pozical viac knih, vypiste vsetky.) */

/*  6. Pre kazdu vypozicku vypiste meno citatela, nazov knihy, poradie vypozicky daneho citatela (1 = prva) a pocet dni od jeho predchadzajucej vypozicky (NULL pre prvu). Ak ma citatel dve vypozicky v ten isty den, ich poradie medzi sebou je lubovolne. Tip: vypozicky kazdeho citatela ocislujte pomocou ROW_NUMBER; predchadzajucu vypozicku potom najdete joinom vysledku so sebou samym (rovnaky citatel, poradie o 1 mensie). */

/*  7. Pre kazdy mesiac, v ktorom bola aspon jedna vypozicka, vypiste pocet vypoziciek v tom mesiaci a kumulativny pocet vypoziciek od zaciatku. Tip: kumulativny pocet sa da ziskat pomocou window function. */

/*  8. Najdite citatelov, ktori si nepozicali nic pocas prveho roka od registracie. */

/*  9. Najdite citatelov, ktori si od kazdeho autora (od ktoreho sa v kniznici nachadza kniha) pozicali aspon 1 knihu. */

/* 10. Najdite autorov, ktorych kazda kniha bola aspon raz pozicana a ziadna ich kniha nebola nikdy vratena skor ako po 40 dnoch (nevratene knihy podmienku splnaju). Vypiste aj pocet knih takeho autora. */

/* 11. (1 point) Pre kazdeho citatela vypiste dobu jeho najdlhsej vypozicky v dnoch (zahrna aj knihy, ktore este nevratil; pre tie vypocitajte rozdiel medzi aktualnym dnom a dnom pozicania). Pre citatelov, ktori si nikdy nic nepozicali, vratte NULL. */

/* Data modification */

/* 12. Zmazte knihy, ktore napisal 'Adolf', aj s ich vypozickami. */

/* 13. Zmazte knihy, ktore si uz pozical kazdy registrovany citatel. */

/* 14. Zmazte vsetkych citatelov (okrem citatela s id 47), ktori si pozicali presne tie iste knihy ako citatel s id 47. Predpokladajte, ze citatel s id 47 existuje, ale nemusel si nic pozicat. */

/* 15. (1 point) Upravte v databaze meno kazdeho citatela, ktory mal v kazdom momente pozicanu nanajvys jednu knihu: pripiste k nemu retazec ' Read more!'.
Navod: https://www.postgresql.org/docs/current/functions-string.html
Tip: da sa to vyriesit aj pomocou window function. */
