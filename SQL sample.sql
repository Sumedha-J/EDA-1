--------------Select within Select examples--------------------------------
SELECT name FROM world
  WHERE continent='Europe' and gdp/population >
     (SELECT gdp/population FROM world
      WHERE name='United Kingdom')



SELECT name, population
FROM world
WHERE population > (SELECT population FROM world WHERE name='Canada')
AND 
population < (SELECT population FROM world WHERE name='Poland');


select name, concat(round((population / (select population from world where name='Germany')*100),0),'%') 
from world
where continent='Europe'

---------------Correlated sub query--------------------------------------

We can use the word ALL to allow >= or > or < or <=to act over a list. For example, you can find the largest country in the world, by population with this query:
You can use the words ALL or ANY where the right side of the operator might have multiple values.

SELECT continent, name, population FROM world x
  WHERE population >= ALL
    (SELECT population FROM world y
        WHERE y.continent=x.continent
          AND population>0)

Q. Some countries have populations more than three times that of all of their neighbours (in the same continent). Give the countries and continents.

Ans. 
SELECT name, continent 
FROM world x
  WHERE population > 
ALL(SELECT population*3 FROM world y
WHERE y.continent = x.continent
AND population > 0
AND y.name != x.name)

SELECT balance, keepplace, startdate
FROM placement, (
  SELECT balance AS B, MAX(startdate) AS S
   FROM placement
  GROUP BY balance) X
WHERE startdate = X.S

-----------Using SELECT in SELECT (subquery in SELECT)--------------
If subquery returns only 1 value then use this query else use IN keyword

SELECT name FROM world WHERE continent = 
  (SELECT continent FROM world WHERE name='Brazil') AS brazil_continent

Q. List each country and its continent in the same continent as 'Brazil' or 'Mexico'.
  SELECT name, continent FROM world
WHERE continent IN
 (SELECT continent FROM world WHERE name='Brazil'
                                 OR name='Mexico')

--------------------------subquery in FROM------------------------
SELECT a.employeeid, Allavgsalary FROM (select employeeid, salary, avg(salary) over () as Allavgsalary from world) a 
  order by a.employeeid
  

--------------------------subquery in WHERE--------------------------
SELECT employeeid, salary FROM world where salary in (select max(salary) from world)



Q. Show the population of China as a multiple of the population of the United Kingdom
 SELECT
 population/(SELECT population FROM world
             WHERE name='United Kingdom')
 FROM world
WHERE name = 'China'

 The HAVING clause is tested after the GROUP BY. You can test the aggregated values with a HAVING clause

 SELECT continent, SUM(population)
  FROM world
 GROUP BY continent
HAVING SUM(population)>500000000 -- having columns should be in SELECT statement 

------------JOIN condition----------------------------------------------
Often using join condition you get redundant records. Use DISTINCT to remove duplicate records



------------CASE WHEN --------------------------------------------------
List every match with the goals scored by each team. This will use "CASE WHEN".

SELECT mdate,
       team1,
       SUM(CASE WHEN teamid = team1 THEN 1 ELSE 0 END) AS score1,
       team2,
       SUM(CASE WHEN teamid = team2 THEN 1 ELSE 0 END) AS score2 FROM
    game LEFT JOIN goal ON (id = matchid)
GROUP BY
mdate,team1,team2
 ORDER BY
mdate, matchid, team1, team2;

SELECT 
  teacher.name, 
  CASE 
    WHEN teacher.dept IN (1,2) THEN 'Sci' 
    ELSE 'Art'
  END
FROM teacher;
----------------WINDOW FUNCTION---------------

SELECT party, votes,
       RANK() OVER (ORDER BY votes DESC) as posn
  FROM ge
 WHERE constituency = 'S14000024' AND yr = 2017
ORDER BY party asc;

SELECT yr,party, votes,
      RANK() OVER (PARTITION BY yr ORDER BY votes DESC) as posn
  FROM ge
 WHERE constituency = 'S14000021'
ORDER BY party,yr

Q. Show the parties that won for each Edinburgh constituency in 2017.

Ans. 
SELECT t_posn.constituency, t_posn.party
FROM  
 (SELECT constituency, party, votes, 
 RANK()OVER(PARTITION BY constituency ORDER BY votes DESC) posn
 FROM ge
 WHERE constituency BETWEEN 'S14000021' AND 'S14000026' AND yr  = 2017
 ORDER BY constituency ,votes DESC
)
t_posn
WHERE t_posn.posn = 1

SELECT name, DAY(whn), confirmed,
   LAG(confirmed, 1) OVER (partition by name ORDER BY whn) AS lag
 FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3
ORDER BY whn;

--Q. For each country that has had at last 1000 new covid cases in a single day, show the date of the peak number of new cases.
WITH temp1 AS (
  SELECT *, (confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)) day_count
  FROM covid
), temp2 AS (
  SELECT name, MAX(day_count) peak_cases
  FROM temp1
  GROUP BY name
  HAVING MAX(day_count) > 1000
)
SELECT temp2.name, DATE_FORMAT(whn, '%Y-%m-%d') date, peak_cases
FROM temp2 LEFT JOIN temp1 ON (temp2.name = temp1.name) AND (temp2.peak_cases = temp1.day_count)
ORDER BY date;

---------------Date format--------------------------------


 SELECT DATE_FORMAT(call_date,'%Y-%m-%d %H:%i:%S') AS call_date, call_ref 
  FROM Issue
  WHERE Detail LIKE '%Oracle%' 
  AND Detail LIKE '%index%'


  select extract(Year from colname)
  select extract(month from colname)
  select extract(week from colname)
  select extract(day from colname)
  select CAST(EXTRACT(DAY FROM colname) AS VARCHAR(2))

 SELECT * FROM totp 
 WHERE DATE '1976-05-20' BETWEEN wk - INTERVAL '7' DAY AND wk -- to subtract dates

 DATEDIFF(): It finds the difference between two dates passed to it.


 ------------Self join------------------------------------

 select distinct a.company, a.num 
  from route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
  JOIN stops stopa ON (a.stop=stopa.id)
  JOIN stops stopb ON (b.stop=stopb.id)
where stopa.name = ('Haymarket') and stopb.name=('Leith')

SELECT r1.num, r1.company, s1.name, r4.num, r4.company
FROM route r1 JOIN route r2 ON (r1.num = r2.num) AND (r1.company = r2.company)
JOIN stops s1 ON r2.stop = s1.id
JOIN route r3 ON s1.id = r3.stop
JOIN route r4 ON (r3.num = r4.num) AND (r3.company = r4.company)
WHERE (r1.stop = (SELECT id FROM stops WHERE name = 'Craiglockhart')) AND
      (r4.stop = (SELECT id FROM stops WHERE name = 'Lochend'))
ORDER BY r1.num, s1.name, r4.num;

------------union----------------------------------

select a,b from table1
union
select a,b from table2; -- it do not have duplicates

select a,b from table1
intersect 
select a,b from table2; -- it do not have duplicates


------------rank------------------------------------
select *,row_number() over (partition by colname order by salary) salaryrank from employee ; -- gets different rank for the rows having similar values

select *, rank() over (partition by colname order by anycolname desc) salaryrank from employee order by colname,salaryrank ;-- using partition by
select *, rank() over (order by colname desc) salaryrank from employee order by salaryrank; ---- without partition by gets same rank for row having similar values
select *, dense_rank() over (order by anycolname desc) salaryrank from employee order by salaryrank;
rank() skips a rank if having similar values. eg rank will be given as 1,2,2,4
DENSE_RANK() maintains the rank and does not give any gap for the values. eg rank will be given as 1,2,2,3
SELECT duration_seconds,
       SUM(duration_seconds) OVER (ORDER BY start_time) AS running_total
  FROM tutorial.dc_bikeshare_q1_2012; -- rolling sum similarly avg function works

-------------Rolling average-----------------------------------
SELECT
    sale_date,
    SUM(sales_amount) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM
    sales; -- this means window will include the current row and the 6 rows preceding it based on the ordering by “sale_date”. this code calculates a rolling average of sales amounts over a window of seven days for each sale date. 
    --It’s a way to see how the sales are trending over a one-week period for each transaction date.

SELECT
    salesperson_id,
    SUM(sales_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS sales_rank
FROM
    sales
GROUP BY
    salesperson_id;-- this code calculates the total sales for each salesperson and ranks them based on their total sales. The salesperson with the highest total sales gets a rank of 1, and the ranking continues based on descending sales amounts

------------------------------------------------------------

select substring(colname,1,charindex(',',colname)-1) as abc
select parsename(replace(address,',','.'),3) from abc
parsename(object_name,object_piece) -- numbering works from right to left
ISNULL (colname1,colname2) ; -- if colname1 is null then fill values with colname2


 
