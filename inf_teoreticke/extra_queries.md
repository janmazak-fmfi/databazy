# Extra queries

Some of the queries have solutions. Click on a specific query language to reveal the solution.

Note: datalog uses syntax from Prolog, i.e. `:-` instead of arrow and `\+` for negation.

---

Database:
```
    wears(Person, Trousers, How_many_times)
    price(Trousers, Amount)
```

Queries:

* trousers that cost less than 20 and someone wore them at least twice

    <details>
    <summary>datalog</summary>

    ```
        answer(T) :- price(T, A), A < 20, wears(_, T, N), N >= 2.
    ```
    </details>

* people that wear at least two different trousers with price above 100

    <details>
    <summary>datalog</summary>

    ```
        answer(P) :-
            wears(P, T1, H1), H1 > 0, price(T1, A1), A1 > 100,
            wears(P, T2, H2), H2 > 0, price(T2, A2), A2 > 100,
            \+ T1 = T2.
    ```
    </details>

---

Database:
```
    cooks(Who, Meal)
    eats(Who, Meal)
```

Queries:

* people who cook, but not eat

    <details>
    <summary>datalog</summary>

    ```
        answer(A) :- cooks(A, _), \+ eats_something(A).
        eats_something(A) :- eats(A, _).
    ```
    </details>

* people cooking a unique meal that no one else cooks

    <details>
    <summary>datalog</summary>

    ```
        cooked_by_two(J) :- cooks(A, J), cooks(B, J), \+ A = B.
        answer(A) :- cooks(A, J), \+ cooked_by_two(J).
    ```
    </details>

* people cooking a meal that is cooked by everyone that cooks something

    <details>
    <summary>datalog</summary>

    ```
        not_cooked_by_someone(J) :- cooks(A, _), \+ cooks(A, J).
        answer(A) :- cooks(A, J), \+ not_cooked_by_someone(J).
    ```
    </details>

* meals that are cooked by someone, but eaten by no one who cooks

    <details>
    <summary>datalog</summary>

    ```
        answer(M) :- cooks(_, M), \+ eaten(M).
        eaten(M) :- eats(X, M), cooks(X, _).
    ```
    </details>

* meals that are eaten by everyone who does not cook anything but eats something (and are eaten by someone)

    <details>
    <summary>datalog</summary>

    ```
        answer(M) :- eats(_, M), \+ not_eaten(M).
        not_eaten(M) :- eats(X, _), \+ cooks_something(X), \+ eats(X, M), eats(_, M).
        cooks_something(X) :- cooks(X, _).
    ```
    </details>

* meals that are cooked, but not by Simon

    <details>
    <summary>datalog</summary>

    ```
        answer(M) :- cooks(_, M), \+ cooks(simon, M).
    ```
    </details>

* meals that are cooked by everyone who cooks except Simon

    <details>
    <summary>datalog</summary>

    ```
        answer(M) :- cooks(_, M), \+ cooks(simon, M), \+ not_cooked(M).
        not_cooked(M) :- cooks(_, M), \+ cooks(X, M), cooks(X, _), X != simon.
    ```
    </details>

* those that only cook meals that are eaten by at most one person (and have cooked at least one such meal)

    <details>
    <summary>datalog</summary>

    ```
        eaten_by_two(M) :- eats(X, M), eats(Y, M), \+ X = Y.
        cooks_wrong(A) :- cooks(A, M), eaten_by_two(M).
        answer(A) :- cooks(A, M), \+ eaten_by_two(M), \+ cooks_wrong(A).
    ```
    </details>

* those that eat all meals cooked by exactly one or two persons and eat at least something

    <details>
    <summary>datalog</summary>

    ```
        cooked_by_three(M) :-
            cooks(A1, M), cooks(A2, M), cooks(A3, M),
            \+ A1 = A2, \+ A2 = A3, \+ A3 = A1.
        fails_to_eat(A) :- eats(A, _), \+ eats(A, M), cooked(_, M), \+ cooked_by_three(M).
        answer(A) :- eats(A, _), \+ fails_to_eat(A).
    ```
    </details>

---

Database:
```
    enrolled(Student, Course)
    passed(Student, Course)
    failed(Student, Course)
    teaches(Professor, Course)
```

Queries:

* students that are enrolled in a course, but have not passed any course

    <details>
    <summary>datalog</summary>

    ```
        answer(A) :- enrolled(A, _), \+ passed_something(A).
        passed_something(A) :- passed(A, _).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT Student
        FROM enrolled e
        WHERE NOT EXISTS (
            SELECT 1
            FROM passed p
            WHERE p.Student = e.Student
        )

        /* another solution */
        SELECT Student FROM enrolled
        EXCEPT
        SELECT Student FROM passed
    ```
    </details>

* students who are enrolled in a course that no one else is enrolled in

    <details>
    <summary>datalog</summary>

    ```
        enrolled_by_two(C) :- enrolled(A, C), enrolled(B, C), \+ A = B.
        answer(S) :- enrolled(S, C), \+ enrolled_by_two(C).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT Student
        FROM enrolled e
        WHERE NOT EXISTS (
            SELECT 1
            FROM enrolled e2
            WHERE e2.Student <> e.Student
                AND e2.Course = e.Course
        )

        /* another solution */
        SELECT Student FROM enrolled e
        WHERE NOT EXISTS (
            SELECT 1 FROM enrolled e1, enrolled e2
            WHERE e1.Course = e.Course AND e1.Student <> e2.Student
        )
    ```
    </details>

* courses that are so far failed by no student except one (i.e. out of those students that received a grade from the course)

    <details>
    <summary>datalog</summary>

    ```
        answer(C) :- failed(_, C), \+ multiple_fails(C).
        multiple_fails(C) :- failed(S1, C), failed(S2, C), \+ S1 = S2.
    ```
    </details>

* courses that are failed by no student except one (of all students that are enrolled)

    <details>
    <summary>datalog</summary>

    ```
        failed_enrolled(S, C) :- failed(S, C), enrolled(S, C).
        multiple_enrolled_fails(C) :-
            failed_enrolled(S1, C),
            failed_enrolled(S2, C),
            \+ S1 = S2.
        answer(C) :- failed_enrolled(_, C), \+ multiple_enrolled_fails(C).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT f.Course
        FROM failed f
        JOIN enrolled e ON f.Student = e.Student AND f.Course = e.Course
        GROUP BY f.Course
        HAVING COUNT(f.Student) = 1;
    ```
    </details>

* courses that are passed by someone, and also everyone who does not teach anything but is enrolled in a course

    <details>
    <summary>datalog</summary>

    ```
        answer(C) :- passed(_, C), \+ not_passed_when_it_should(C).
        not_passed_when_it_should(C) :- enrolled(X, _), \+ teaches_something(X), \+ passed(X, C), passed(_, C).
        teaches_something(X) :- teaches(X, _).
    ```
    </details>

* courses (passed by someone) that are passed by everyone who does not teach anything but is enrolled in all courses

    <details>
    <summary>datalog</summary>

    ```
        answer(C) :- passed(_, C), \+ not_passed_when_it_should(C).
        not_passed_when_it_should(C) :-
            \+ not_enrolled_somewhere(X), \+ teaches_something(X),
            \+ passed(X, C), passed(_, C), enrolled(X, _).
        teaches_something(X) :- teaches(X, _).
        not_enrolled_somewhere(X) :- enrolled(X, _), \+ enrolled(X, C), enrolled(_, C).
    ```
    Notice how we had to include two positive contexts that were not mentioned in the original query
    (i.e. the query would need additional clarification to be precise, despite sounding complete).
    </details>

* instructors whose classes consistently attract students with flawless academic records (i.e., find professors such that for every course they teach, there exists at least one student enrolled who has passed every course they have ever been enrolled in)

    <details>
    <summary>datalog</summary>

    ```
        % A student is imperfect if they are enrolled in any course they have not passed.
        imperfect_student(S) :- enrolled(S, C), \+ passed(S, C).

        % A course is "good" if it has at least one perfect student enrolled.
        has_perfect_student(C) :- enrolled(S, C), \+ imperfect_student(S).

        % A professor teaches a problematic course.
        problematic_course_for(P) :- teaches(P, C), \+ has_perfect_student(C).

        % The final answer is a professor who teaches something, but does not teach a problematic course.
        answer(P) :- teaches(P, _), \+ problematic_course_for(P).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        WITH perfect_students AS (
            -- those who have passed every course in which they have ever been enrolled.
            SELECT DISTINCT e1.Student
            FROM enrolled e1
            -- A student is perfect if there does NOT EXIST...
            WHERE NOT EXISTS (
                -- ...a course they were enrolled in...
                SELECT 1
                FROM enrolled e2
                WHERE e2.Student = e1.Student
                -- ...that they have NOT passed.
                AND NOT EXISTS (
                    SELECT 1
                    FROM passed p
                    WHERE p.Student = e2.Student AND p.Course = e2.Course
                )
            )
        )
        -- Select professors ...
        SELECT DISTINCT t1.Professor
        FROM teaches t1
        WHERE NOT EXISTS (
            -- ... which do not have a "problematic course".
            SELECT t2.Course
            FROM teaches t2
            WHERE t2.Professor = t1.Professor
            AND NOT EXISTS (
                -- problematic course, i.e. without a perfect student
                SELECT 1
                FROM enrolled e
                JOIN perfect_students ps ON e.Student = ps.Student
                WHERE e.Course = t2.Course
            )
        );
    ```
    </details>

---

Database:

`person(Who), furniture(Item), owns(Who, Item)` (it is possible that the same item is owned by several owners)

Queries:

* persons who own both a 'chair' and a 'sofa'

    <details>
    <summary>datalog</summary>

    ```
        answer(P) :- owns(P, 'chair'), owns(P, 'sofa').
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT o1.Who
        FROM owns o1
        WHERE o1.Item = 'chair'
        AND EXISTS (
            SELECT 1
            FROM owns o2
            WHERE o2.Who = o1.Who AND o2.Item = 'sofa'
        );
    ```
    </details>

* furniture that is not owned by anyone

    <details>
    <summary>datalog</summary>

    ```
        is_owned(I) :- owns(_, I).
        answer(I) :- furniture(I), \+ is_owned(I).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT f.Item
        FROM furniture f
        WHERE NOT EXISTS (
            SELECT 1
            FROM owns o
            WHERE o.Item = f.Item
        );
    ```
    </details>

* persons who own all furniture except 'table'

    <details>
    <summary>datalog</summary>

    ```
        fails_to_own(P) :- person(P), furniture(I), I != 'table', \+ owns(P, I).
        answer(P) :- person(P), \+ fails_to_own(P).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT p.Who
        FROM person p
        WHERE NOT EXISTS (
            SELECT 1
            FROM furniture f
            WHERE f.Item != 'table'
            AND NOT EXISTS (
                SELECT 1
                FROM owns o
                WHERE o.Who = p.Who AND o.Item = f.Item
            )
        );
    ```
    </details>

* persons who do not own any furniture as a sole owner of that furniture

    <details>
    <summary>datalog</summary>

    ```
        owned_by_another(P, I) :- owns(P, I), owns(Other, I), P != Other.
        owns_uniquely(P) :- furniture(I), owns(P, I), \+ owned_by_another(P, I).
        answer(P) :- person(P), \+ owns_uniquely(P).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT p.Who
        FROM person p
        WHERE NOT EXISTS (
            SELECT 1
            FROM furniture
            JOIN owns o ON o.Item = furniture.Item
            WHERE o.Who = p.Who AND NOT EXISTS (
                SELECT 1
                FROM owns o2
                WHERE o2.Item = o.Item AND o2.Who != o.Who
            )
        );
    ```
    </details>

* persons who own every item that 'john' owns (and are not 'john')

    <details>
    <summary>datalog</summary>

    ```
        owns_something(P) :- owns(P, _).
        fails_to_own_johns_item(P) :- owns_something(P), owns('john', I), \+ owns(P, I).
        answer(P) :- owns_something(P), P != 'john', \+ fails_to_own_johns_item(P).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT DISTINCT p.Who
        FROM person p
        WHERE p.Who != 'john'
        AND EXISTS (SELECT 1 FROM owns o WHERE o.Who = p.Who) -- must own something
        AND NOT EXISTS (
            SELECT 1
            FROM owns johns_owns
            WHERE johns_owns.Who = 'john' AND NOT EXISTS (
                SELECT 1
                FROM owns p_owns
                WHERE p_owns.Who = p.Who AND p_owns.Item = johns_owns.Item
            )
        );
    ```
    </details>

* furniture that is owned by every person who owns something

    <details>
    <summary>datalog</summary>

    ```
        owns_something(P) :- owns(P, _).
        not_owned_by_all_owners(I) :- furniture(I), owns_something(P), \+ owns(P, I).
        answer(I) :- furniture(I), \+ not_owned_by_all_owners(I).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT f.Item
        FROM furniture f
        WHERE NOT EXISTS (
            SELECT 1
            FROM person p
            WHERE (EXISTS (SELECT 1 FROM owns WHERE Who = p.Who))
            AND NOT EXISTS (
                SELECT 1 FROM owns o WHERE o.Item = f.Item AND o.Who = p.Who
            )
        );
    ```
    </details>

---

Database:

`treats(Doctor, Patient, Disease)`

Queries:

* patients who have multiple diseases

    <details>
    <summary>datalog</summary>

    ```
        answer(P) :- treats(_, P, D1), treats(_, P, D2), \+ D1 = D2.
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT Patient
        FROM treats
        GROUP BY Patient
        HAVING COUNT(DISTINCT Disease) > 1;
    ```
    </details>

* doctors who treat only a single patient

    <details>
    <summary>datalog</summary>

    ```
        treats_multiple_patients(D) :- treats(D, P1, _), treats(D, P2, _), \+ P1 = P2.
        answer(D) :- treats(D, _, _), \+ treats_multiple_patients(D).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT Doctor
        FROM treats
        GROUP BY Doctor
        HAVING COUNT(DISTINCT Patient) = 1;
    ```
    </details>

* healthy doctors (not being treated for any disease)

    <details>
    <summary>datalog</summary>

    ```
        answer(D) :- treats(D, _, _), \+ treats(_, D, _).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        -- Solution using EXCEPT
        SELECT DISTINCT Doctor FROM treats
        EXCEPT
        SELECT DISTINCT Patient FROM treats;

        -- Solution using NOT EXISTS
        SELECT DISTINCT t1.Doctor
        FROM treats t1
        WHERE NOT EXISTS (
            SELECT 1
            FROM treats t2
            WHERE t2.Patient = t1.Doctor
        );
    ```
    </details>

* diseases that affect every patient (and at least one patient)

    <details>
    <summary>datalog</summary>

    ```
        fails_to_affect(D) :- treats(_, _, D), treats(_, P, _), \+ treats(_, P, D).
        answer(D) :- treats(_, _, D), \+ fails_to_affect(D).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        -- This query finds diseases where the count of distinct patients
        -- treated for that disease is equal to the total number of distinct patients.
        SELECT Disease
        FROM treats
        GROUP BY Disease
        HAVING COUNT(DISTINCT Patient) = (
            SELECT COUNT(DISTINCT Patient) FROM treats
        );
    ```
    </details>

* patients with a single doctor

    <details>
    <summary>datalog</summary>

    ```
        has_multiple_doctors(P) :- treats(D1, P, _), treats(D2, P, _), \+ D1 = D2.
        answer(P) :- treats(_, P, _), \+ has_multiple_doctors(P).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT Patient
        FROM treats
        GROUP BY Patient
        HAVING COUNT(DISTINCT Doctor) = 1;
    ```
    </details>

* doctors, who treat all diseases

    <details>
    <summary>datalog</summary>

    ```
        fails_to_treat(D) :- treats(D, _, _), treats(_, _, S), \+ treats(D, _, S).
        answer(D) :- treats(D, _, _), \+ fails_to_treat(D).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        -- This query finds doctors where the count of distinct diseases
        -- they treat is equal to the total number of distinct diseases in the database.
        SELECT Doctor
        FROM treats
        GROUP BY Doctor
        HAVING COUNT(DISTINCT Disease) = (
            SELECT COUNT(DISTINCT Disease) FROM treats
        );
    ```
    </details>

* doctors whose every patient has at least two diseases

    <details>
    <summary>datalog</summary>

    ```
        has_at_least_two_diseases(P) :- treats(_, P, D1), treats(_, P, D2), \+ D1 = D2.
        bad_doctor(D) :- treats(D, P, _), \+ has_at_least_two_diseases(P).
        answer(D) :- treats(D, _, _), \+ bad_doctor(D).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        -- Select doctors for whom there does not exist a patient
        -- they treat who has fewer than two diseases.
        SELECT DISTINCT t1.Doctor
        FROM treats t1
        WHERE NOT EXISTS (
            SELECT 1
            FROM treats t2
            WHERE t2.Doctor = t1.Doctor AND t2.Patient IN (
                -- This subquery identifies all patients with only one disease.
                SELECT Patient
                FROM treats
                GROUP BY Patient
                HAVING COUNT(DISTINCT Disease) < 2
            )
        );
    ```
    </details>

---

Database:
```
    involved(Who, Project, Salary)
```

Queries:

* people who are the only ones involved in a particular project

    <details>
    <summary>datalog</summary>

    ```
        involved_by_two(P) :- involved(A, P, _), involved(B, P, _), \+ A = B.
        answer(A) :- involved(A, P, _), \+ involved_by_two(P).
    ```
    </details>

* people involved in all projects where someone earns 1000 (and are involved somewhere)

    <details>
    <summary>datalog</summary>

    ```
        works_on(A, P) :- involved(A, P, _).
        misses_project(A) :- involved(_, P, 1000), \+ works_on(A, P).
        answer(A) :- involved(A, _, _), \+ misses_project(A).
    ```
    </details>

* people such that on every project they are involved in, there is someone earning more than them (and are involved somewhere)

    <details>
    <summary>datalog</summary>

    ```
        answer(A) :- involved(A, _, _), \+ wrong_project_for(A).
        wrong_project_for(A) :- involved(A, P, _), \+ someone_earns_more_than(A, P).
        someone_earns_more_than(A, P) :- involved(A, P, SA), involved(B, P, SB), SB > SA.
    ```
    </details>

* people who are involved in projects where everyone earns the same salary

    <details>
    <summary>datalog</summary>

    ```
        different_salaries(P) :- involved(_, P, S1), involved(_, P, S2), \+ S1 = S2.
        answer(A) :- involved(A, P, _), \+ different_salaries(P).
    ```
    </details>

* people who are only involved in projects where everyone earns the same salary (and are involved somewhere)

    <details>
    <summary>datalog</summary>

    ```
        different_salaries(P) :- involved(_, P, S1), involved(_, P, S2), S1 \= S2.
        works_in_wrong_project(A) :- involved(A, P, _), different_salaries(P).
        answer(A) :- involved(A, _, _), \+ works_in_wrong_project(A).
    ```
    </details>

* people who are involved in all projects where everyone earns the same salary (and are involved somewhere)

    <details>
    <summary>datalog</summary>

    ```
        different_salaries(P) :- involved(_, P, S1), involved(_, P, S2), S1 \= S2.
        project_with_same_salaries(P) :- involved(_, P, _), \+ different_salaries(P).
        works_on(A, P) :- involved(A, P, _).
        not_involved_in_same_salaries_projects(A) :- project_with_same_salaries(P), \+ works_on(A, P), involved(A, _, _).
        answer(A) :- involved(A, _, _), \+ not_involved_in_same_salaries_projects(A).
    ```
    </details>

---

Database:
```
    lubi(P, A)
    capuje(K, A)
    navstivil(I, P, K)
    vypil(I, A, M)
```
Abbreviated attributes: `P = Pijan, A = Alkohol, K = krcma, I = Id_navstevy, M = Mnozstvo`. Assume that `Mnozstvo` is always positive. In `navstivil` and `vypil`, the attribute `I` uniquely identifies the visit of a particular `Pijan` in a particular `Krcma` (there are no group visits). There are no NULLs in the database.

Queries:

* pijani, ktorí niečo ľúbia, ale nikdy v krčme nepijú

    <details>
    <summary>datalog</summary>

    ```
        has_drunk(P) :- navstivil(I, P, _), vypil(I, _, _).
        answer(P) :- lubi(P, _), \+ has_drunk(P).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        SELECT l.P
        FROM lubi l
        WHERE NOT EXISTS (
            SELECT 1
            FROM navstivil n, vypil v
            WHERE n.I = v.I AND n.P = l.P
        )
    ```
    </details>

* krčmy, kde niečo čapujú a bol tam vypitý každý alkohol, čo ľúbia aspoň dvaja pijani

    <details>
    <summary>datalog</summary>

    ```
        answer(K) :- capuje(K, _), \+ nevypity_spravny_alkohol(K).
        nevypity_spravny_alkohol(K) :- lubi(P1, A), lubi(P2, A), \+ P1 = P2,
                                       capuje(K, _), \+ vypity(K, A).
        vypity(K, A) :- navstivil(I, _, K), vypil(I, A, _).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        WITH special_alcohols AS (
            -- This CTE finds "special" alcohols liked by at least two drinkers
            SELECT A
            FROM lubi
            GROUP BY A
            HAVING COUNT(P) >= 2
        )
        SELECT DISTINCT c.K
        FROM capuje c
        WHERE NOT EXISTS (
            -- Check if there is any special alcohol...
            SELECT 1
            FROM special_alcohols sa
            -- ...that was NOT drunk in pub K
            WHERE NOT EXISTS (
                SELECT 1
                FROM navstivil n
                JOIN vypil v ON n.I = v.I
                WHERE n.K = c.K AND v.A = sa.A
            )
        );

        /* another solution */
        WITH special_alcohols AS (
            -- 1. Find all alcohols liked by at least two drinkers
            SELECT A
            FROM lubi
            GROUP BY A
            HAVING COUNT(P) >= 2
        ),
        pub_special_drinks AS (
            -- 2. Find each time a "special" alcohol was served in any pub
            SELECT DISTINCT n.K, v.A
            FROM navstivil n
            JOIN vypil v ON n.I = v.I
            JOIN special_alcohols sa ON v.A = sa.A
        )
        -- 3. Find pubs where the count of distinct special drinks served
        --    is equal to the total number of special drinks that exist.
        SELECT K
        FROM pub_special_drinks
        GROUP BY K
        HAVING COUNT(A) = (SELECT COUNT(A) FROM special_alcohols);
    ```
    </details>

* pijani, čo ľúbia aspoň jeden alkohol a ľúbia všetky alkoholy, čo niekde čapujú a nikto ich nepil v žiadnej krčme

    <details>
    <summary>datalog</summary>

    ```
        answer(P) :- lubi(P, _), \+ nelubi_co_ma(P).
        nelubi_co_ma(P) :- capuje(_, A), \+ vypity(A), \+ lubi(P, A), lubi(P, _).
        vypity(A) :- vypil(_, A, _).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        -- First, create a view or CTE for the special alcohols
        WITH UnpopularAlcohol AS (
            SELECT DISTINCT A FROM capuje
            EXCEPT
            SELECT DISTINCT A FROM vypil
        )
        -- Now, find the drinkers who like all of them
        SELECT DISTINCT l.P
        FROM lubi l
        WHERE NOT EXISTS (
            -- Find an unpopular alcohol...
            SELECT 1
            FROM UnpopularAlcohol ua
            -- ...that this drinker does NOT like
            WHERE NOT EXISTS (
                SELECT 1
                FROM lubi l2
                WHERE l2.P = l.P AND l2.A = ua.A
            )
        );
    ```
    </details>

* pijani, čo ľúbia aspoň jeden alkohol a ľúbia všetky alkoholy, čo v nejakej krčme čapujú, ale nikto ich v nej nepil

    <details>
    <summary>datalog</summary>

    ```
        % 1. Helper rule: Identify which alcohols (A) were drunk in which pubs (K).
        drunk_in_pub(K, A) :- navstivil(I, _, K), vypil(I, A, _).

        % 2. Helper rule: Define a "special" alcohol (A).
        %    An alcohol is special if it's served in some pub K,
        %    but has NOT been drunk in that same pub K.
        special_alcohol(A) :- capuje(K, A), \+ drunk_in_pub(K, A).

        % 3. Helper rule: Identify drinkers (P) who FAIL the main condition.
        %    A drinker fails if there exists a special alcohol A that they do not like.
        fails_condition(P) :- special_alcohol(A), lubi(P, _), \+ lubi(P, A).

        answer(P) :- lubi(P, _), \+ fails_condition(P).
    ```
    </details>

    <details>
    <summary>SQL</summary>

    ```sql
        WITH
          -- 1. Find the set of all "special" alcohols. A special alcohol is one that is served
          -- in at least one pub where it has never been consumed.
          special_alcohols AS (
            SELECT DISTINCT c.A
            FROM capuje c
            WHERE NOT EXISTS (
              SELECT 1
              FROM navstivil n
              JOIN vypil v ON n.I = v.I
              WHERE n.K = c.K AND v.A = c.A
            )
          )
        -- 2. Find drinkers who like EVERY alcohol from the special_alcohols set.
        SELECT l.P
        FROM lubi l
            JOIN special_alcohols sa ON l.A = sa.A
        GROUP BY l.P
        -- The HAVING clause is the key: it ensures the drinker likes ALL of them.
        HAVING COUNT(l.A) = (
            SELECT COUNT(A)
            FROM special_alcohols
        );
    ```
    </details>

* pijani, čo už pili, a pri každej návšteve krčmy vypijú aspoň liter jedného alkoholu (pri rôznych návštevách môže byť ten alkohol rôzny)

    <details>
    <summary>datalog</summary>

    ```
        drank_a_liter(I) :- vypil(I, _, M), M >= 1.
        bad_visit(P) :- navstivil(I, P, _), \+ drank_a_liter(I).
        answer(P) :- navstivil(_, P, _), \+ bad_visit(P).
    ```
    </details>


    <details>
    <summary>SQL</summary>

    ```sql
        SELECT n.P
        FROM navstivil n, vypil v
        WHERE n.I = v.I AND NOT EXISTS (
            SELECT 1
            FROM navstivil n2
            WHERE n2.P = n.P AND NOT EXISTS (
                SELECT 1
                FROM vypil v2
                WHERE v2.I = n2.I and v2.M >= 1
            )
        )

        /* another solution */
        SELECT n.P
        FROM navstivil n, vypil v
        WHERE n.I = v.I AND NOT EXISTS (
            -- funguje za predpokladu, ze pri kazdej navsteve bol vypity aspon 1 alkohol
            SELECT 1
            FROM navstivil n2 JOIN vypil v2 ON n2.I = v2.I
            WHERE n2.P = n.P
            GROUP BY n2.I
            HAVING MAX(v2.M) < 1
        )
    ```
    </details>

