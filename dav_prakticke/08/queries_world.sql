/* Aggregation queries over the world database (load world.sql first). The five queries together are worth 2 points.
   Use the working definitions below for the quantities being computed.

   The tables are described here only in the columns the queries use (each table has more columns):
   - city(id, name, countrycode, district, population): a city. countrycode refers to country.code.
     district is the region (province, state) the city lies in. population is the number of inhabitants.
   - country(code, name, surfacearea, population, capital): a country. surfacearea is in square kilometres
     (a real, i.e. floating-point, number), population is the number of inhabitants.
     capital is the id of a row in city (not the name); it may be NULL.
   - countrylanguage(countrycode, language, isofficial, percentage): one row per country and language.
     isofficial is true if the language is official in the country. countrycode refers to country.code.
   The database lists only some cities; it does not list all settlements or all inhabitants.
   When computing ratios, avoid integer division. ROUND(value, 2) expects a numeric value;
   cast floating-point expressions to numeric if needed. */

/* 1. Countries where English is an official language (see the table countrylanguage).
   For each such country print: country name, capital name, and the percentage of the country's population
   that lives in the capital, rounded to 2 decimals. The sample data is not fully consistent, so values above
   100 can occur; print them as computed.
   Countries with a NULL capital are excluded. Order by country name. */

/* 2. The 10 countries with the largest number of cities; ties broken by country name.
   Print: country name, number of cities, total population of those cities, and the percentage of the country's
   population living in rural areas, rounded to 2 decimals. The database lists only cities, so rural population
   is the country's population minus the total population of its listed cities. Because the sample data is not
   fully consistent, this value can be negative; print it as computed.
   Order by number of cities descending, then by country name. */

/* 3. The 3 countries with the largest population. For each of them, list its districts
   (a district is identified by its country and its name). Print: country name, district, number of cities
   in the district, and urban inhabitants = total population of the cities in the district.
   Order: countries by population descending; within a country, districts by urban inhabitants
   descending, then by district name. */

/* 4. Population density of a country is its population divided by its surface area.
   Return all countries with the highest density and all countries with the second-highest distinct density
   (include ties at either rank). Print: country name, density rounded to 2 decimals, rank.
   Rank by the unrounded density; rounding is only for display.
   Order by density descending, then by country name. */

/* 5. Non-ASCII characters. Work in a database with UTF-8 encoding (check with SHOW server_encoding).
   A city name is non-ASCII if it contains at least one character with a code point greater than 127.
   For each country that has at least one such city,
   count its city rows whose name is non-ASCII. Then group these countries by the first letter of their name, ignoring case.
   For each letter print: the letter, the number of such countries, and the total number of non-ASCII city names
   of those countries. Order by letter.
   Hint: compare character length and byte length with char_length and octet_length.
   Explain why they can differ in UTF-8 and why an ASCII apostrophe alone does not make a name non-ASCII. */
