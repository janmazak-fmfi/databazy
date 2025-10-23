
/*  1. Vypiste nazvy vsetkych knih, ktore su prave teraz pozicane (t.j. neexistuje zaznam o ich vrateni). */

/*  2. Vypiste meno, datum registracie, den v tyzdni (v den registracie) pre vsetkych citatelov, ktori sa registrovali pocas poslednych 365 dni.
Na vypis dna v tyzdni v ludsky citatelnom formate pouzite CASE statement. */

/*  3. Vypiste vsetky trojice [C, K, DatumPozicania], kde K je nazov knihy, ktoru si citatel s menom C pozical, ale este ju nevratil. */

/*  4. Najdite mena citatelov, ktori vratili do 30 dni kazdu z knih, ktore si pozicali. (Vratane citatelov, ktori si nikdy nepozicali nic.) */

/*  5. Vypiste mena citatelov, ktori si pozicali aspon tri rozne knihy, a pritom vsetky ich pozicane knihy boli od toho isteho autora. */

/*  6. Ku kazdemu citatelovi vypiste nazov prvej knihy, ktoru si pozical, alebo null, ak si nikdy nepozical nic. */

/*  7. Najdite citatelov, ktori si nepozicali nic pocas prveho roka od registracie. */

/*  8. Najdite citatelov, ktori si od kazdeho autora (od ktoreho sa v kniznici nachadza kniha) precitali aspon 1 knihu. */

/*  9. Najdite autorov knih, ktore ak si niekto pozical, tak vzdy aspon na 40 dni (alebo ich este vobec nevratil). Zistite, ci tito autori napisali viac ako polovicu vsetkych knih z kniznice. (Na presnom formate vystupu nezalezi. Autorom sa zapodievame, ak napisal aspon jednu taku knihu, nemusia take byt vsetky jeho knihy.) */

/* 10. (1 point) Pre kazdeho citatela vypiste dobu jeho najdlhsej vypozicky v dnoch (zahrna aj knihy, ktore este nevratil; pre tie vypocitajte rozdiel medzi aktualnym dnom a dnom pozicania). Pre citatelov, ktori si nikdy nic nepozicali, vratte NULL. */

/* Data modification */

/* 11. Zmente meno prvemu registrovanemu citatelovi pomocou UPDATE. */

/* 12. Zmazte knihy, ktore napisal 'Adolf'. */

/* 13. Zmazte knihy, ktore si uz pozical kazdy registrovany citatel. */

/* 14. Zmazte vsetkych citatelov, ktori si pozicali presne tie iste knihy ako citatel s id 47. */

/* 15. (1 point) Upravte v databaze meno kazdeho citatela, ktory mal v kazdom momente pozicanu nanajvys jednu knihu: pripiste k nemu retazec ' Read more!'.
Navod: https://www.postgresql.org/docs/current/functions-string.html */
