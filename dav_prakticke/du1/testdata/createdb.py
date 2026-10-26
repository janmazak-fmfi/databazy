import random
import sys


POCET_PIJANOV = 20
POCET_ALKOHOLOV = 12
POCET_KRCIEM = 10
POCET_NAVSTEV = 10

lubi = []
pijani = []
alkoholy = []
cenyAlkoholov = {}
cenyKrciem = {}  # (krcma, alkohol) -> cena, only for pubs whose price differs from the global one
krcmy = []
navstevy = []

nextid = 1

random.seed(0)
# separate seeded generator for the sub-second part, so the output is reproducible
usec_random = random.Random(0)

def random_time():
	return 1000000 * random.randint(1, 100) + usec_random.randint(0, 999999)

def prepare_default():
    for i in range(1, POCET_PIJANOV+1):
        pijani.append('default_p' + str(i).zfill(2))
    for i in range(1, POCET_ALKOHOLOV+1):
        a = 'default_a' + str(i).zfill(2)
        alkoholy.append(a)
        cenyAlkoholov[a] = random.randint(1, 5)
    for i in range(1, POCET_KRCIEM+1):
        krcmy.append(('default_k' + str(i).zfill(2), sorted(random.sample(alkoholy, POCET_ALKOHOLOV // 2))))
    
    for i in range(POCET_PIJANOV):
        lubene = sorted(random.sample(alkoholy, len(alkoholy) // 2))
        for alkohol in lubene:
            lubi.append((pijani[i], alkohol))

    for i in range(POCET_PIJANOV):
        pijan = pijani[i]
        if i == 8: # drzgros
            krcma, alkoholykrcmy = krcmy[0]
            najlacnejsiAlkohol = alkoholykrcmy[0]
            for a in alkoholykrcmy:
                if cenyAlkoholov[a] < cenyAlkoholov[najlacnejsiAlkohol]:
                    najlacnejsiAlkohol = a
            for k in range(i):
                navstevy.append((None, pijan, krcma, najlacnejsiAlkohol, random.randint(1, 100), random_time()))            
        else:
            for j in range(POCET_KRCIEM):
                krcma, alkoholykrcmy = krcmy[j]
                for k in range(i):
                    vypite = sorted(random.sample(alkoholykrcmy, len(alkoholykrcmy) // 2))
                    for l in range(len(vypite)):
                        navstevy.append((None, pijan, krcma, vypite[l], random.randint(1, 100), random_time()))

def prepare_a():
    newpijani = ['a_p1', 'a_p2']
    pijani.extend(newpijani)
    krcma, alkoholykrcmy = krcmy[0]
    for k in range(50):
        vypite = sorted(random.sample(alkoholykrcmy, len(alkoholykrcmy) // 2))
        for l in range(len(vypite)):
            navstevy.append((None, 'a_p1', krcma, vypite[l], random.randint(1, 100), random_time()))
    for alkohol in alkoholy:        
        for (krcma, alkoholykrcmy) in krcmy:
            if alkohol in alkoholykrcmy:
                navstevy.append((None, 'a_p2', krcma, alkohol, random.randint(1, 10), random_time()))
                break


def prepare_b():
    pijani.extend(['b_p1'])
    mnozstvo = 1
    od = 1
    for alkohol in alkoholy:        
        for (krcma, alkoholykrcmy) in krcmy:
            if alkohol in alkoholykrcmy:
                # b_p1 drinks alkoholy[0] only where the pub serves it; elsewhere the visit has no drink
                vypite = alkoholy[0] if alkoholy[0] in alkoholykrcmy else None
                navstevy.append((None, 'b_p1', krcma, vypite, mnozstvo, od))
                mnozstvo += random.randint(0, 1)
                od += 1
    for i in range(5):
        pijan = 'b_p00' + str(i)
        pijani.append(pijan)
        krcma, alkoholykrcmy = krcmy[random.randint(0, len(krcmy)-1)]
        navstevy.append((None, pijan, krcma, alkoholykrcmy[random.randint(0, len(alkoholykrcmy)-1)], 47, 47))


def prepare_c():
    for (pijan, alkohol) in lubi:
        if pijan != 'default_p' + str(POCET_PIJANOV):
            continue
        for (krcma, alkoholykrcmy) in krcmy:
            if alkohol in alkoholykrcmy:
                navstevy.append((None, pijan, krcma, alkohol, random.randint(101, 200), random_time()))
    singlefail = False
    for (pijan, alkohol) in lubi:
        if pijan != 'default_p' + str(POCET_PIJANOV-1):
            continue        
        for (krcma, alkoholykrcmy) in krcmy:
            if alkohol in alkoholykrcmy:
                if not singlefail:       
                    maxmnozstvo = -1
                    for (ident, p, k, a, m, od) in navstevy:
                        if a == alkohol and k == krcma:
                            if m > maxmnozstvo:
                                maxmnozstvo = m
                    mnozstvo = maxmnozstvo
                    singlefail = True
                else:
                    mnozstvo = random.randint(101, 200)
                navstevy.append((None, pijan, krcma, alkohol, mnozstvo, random_time()))


def cena(krcma, alkohol):
    return cenyKrciem.get((krcma, alkohol), cenyAlkoholov[alkohol])

def prepare_d():
    alkohol = list(cenyAlkoholov.keys())[0]
    # d_k2 serves the same alcohol as d_k1, but more expensively
    cenyKrciem[("d_k1", alkohol)] = 2
    cenyKrciem[("d_k2", alkohol)] = 4
    krcmy.append(("d_k1", [alkohol]))
    krcmy.append(("d_k2", [alkohol]))
    navstevy.append((None, "d_p1", "d_k1", None, None, 5))
    # d_p2 likes only alkohol. He first visits the expensive pub d_k2 and drinks there, then the cheap
    # pub d_k1 (where he drinks it again). For d_k1 he drank it elsewhere before and never after, so he
    # is loyal to d_k1 in (a). In (d) he is ok: he has not visited a cheaper pub before the visit to d_k2.
    lubi.append(("d_p2", alkohol))
    pijani.append("d_p2")
    navstevy.append((None, "d_p2", "d_k2", alkohol, 3, 10))
    navstevy.append((None, "d_p2", "d_k1", alkohol, 2, 20))
    # d_p3 first visits the cheap pub d_k1 (no drink), then drinks at d_k2. He is not ok in (d), since he
    # visited the cheaper pub before; a reading that ignores the visit history would accept him.
    lubi.append(("d_p3", alkohol))
    pijani.append("d_p3")
    navstevy.append((None, "d_p3", "d_k1", None, None, 10))
    navstevy.append((None, "d_p3", "d_k2", alkohol, 3, 20))


def print_db_datalog():
    for i in range(len(lubi)):
        print("lubi(" + lubi[i][0] + ", " + lubi[i][1] + ").")
    for i in range(len(krcmy)):
        krcma, alkoholykrcmy = krcmy[i]
        for j in range(len(alkoholykrcmy)):
            print("capuje(" + krcma + ", " + alkoholykrcmy[j] + ", " + str(cena(krcma, alkoholykrcmy[j])) + ").")
    navstivil = []
    vypil = []
    for (ident, p, k, a, m, od) in navstevy:
        if ident is None:
            global nextid
            ident = nextid
            nextid += 1
        navstivil.append("navstivil(" + str(ident) + ", " + p + ", " + k + ", " + str(od) + ").")
        if a != None:
            vypil.append("vypil(" + str(ident) + ", " + a + ", " + str(m) + ").")
    for s in navstivil:
        print(s)
    print("\n")
    for s in vypil:
        print(s)

def qqq(x):
    return "'" + x + "'"

HEADER = """-- Test data for DU1. Load with: sqlite3 pijani.db < pijani.sql, or: psql -f pijani.sql
--
-- The script runs in a single transaction. If DROP TABLE fails in PostgreSQL because you created
-- views on these tables, the database stays unchanged. In that case drop those views (DROP VIEW ...)
-- or add CASCADE to the DROP TABLE statements below (this drops the dependent views too) and rerun."""

def insert_sql(table, rows):
    return "INSERT INTO " + table + " VALUES\n" + ",\n".join("    (" + r + ")" for r in rows) + ";\n"

def print_db_sql():
    print(HEADER)
    print()
    print("BEGIN;")
    print()
    for t in ["vypil", "navstivil", "capuje", "lubi"]:
        print("DROP TABLE IF EXISTS " + t + ";")
    print("""
CREATE TABLE lubi (
    Pijan TEXT,
    Alkohol TEXT
);

CREATE TABLE capuje (
    Krcma TEXT,
    Alkohol TEXT,
    Cena DECIMAL
);

CREATE TABLE navstivil (
    Id INTEGER PRIMARY KEY,
    Pijan TEXT,
    Krcma TEXT,
    Od INTEGER
);

CREATE TABLE vypil (
    Id INTEGER,
    Alkohol TEXT,
    Mnozstvo DECIMAL
);
""")

    print(insert_sql("lubi", [qqq(p) + ", " + qqq(a) for (p, a) in lubi]))

    capuje = []
    for krcma, alkoholykrcmy in krcmy:
        for a in alkoholykrcmy:
            capuje.append(qqq(krcma) + ", " + qqq(a) + ", " + str(cena(krcma, a)))
    print(insert_sql("capuje", capuje))

    navstivil = []
    vypil = []
    for (ident, p, k, a, m, od) in navstevy:
        if ident is None:
            global nextid
            ident = nextid
            nextid += 1
        navstivil.append(str(ident) + ", " + qqq(p) + ", " + qqq(k) + ", " + str(od))
        if a != None:
            vypil.append(str(ident) + ", " + qqq(a) + ", " + str(m))
    print(insert_sql("navstivil", navstivil))
    print(insert_sql("vypil", vypil))
    print("COMMIT;")

prepare_default()
prepare_a()
prepare_b()
prepare_c()
prepare_d()

print_db_sql()

# (a)
"""
WITH nv AS (
	SELECT *
	FROM navstivil
	NATURAL JOIN vypil
)
SELECT DISTINCT nv.Pijan, nv.Krcma
FROM nv
WHERE NOT EXISTS (
	SELECT nv2.Alkohol
	FROM nv nv2, nv nv3
	WHERE nv2.Pijan = nv.Pijan AND nv2.Krcma = nv.Krcma
	AND nv3.Pijan = nv2.Pijan AND nv3.Alkohol = nv2.Alkohol AND nv3.Krcma <> nv2.Krcma AND nv3.Od > nv2.Od
)
ORDER BY nv.Pijan, nv.Krcma;
"""

