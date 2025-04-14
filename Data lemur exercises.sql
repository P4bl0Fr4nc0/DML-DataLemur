/*1.This is the same question as problem #6 in the SQL Chapter of Ace the Data Science Interview!
Assume you're given a table Twitter tweet data, write a query to obtain a histogram of tweets posted per user in 2022. Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket.
In other words, group the users by the number of tweets they posted in 2022 and count the number of users in each group.
*/

WITH cte_tweets AS (
SELECT user_id , COUNT (*) as tweet_bucket FROM tweets WHERE tweet_date BETWEEN '01/01/2022 00:00:00' AND 
'12/30/2022 23:59:59' GROUP BY user_id)
SELECT tweet_bucket, COUNT(*) as users_num FROM cte_tweets GROUP BY tweet_bucket;

/*
2.Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.
Write a query to list the candidates who possess all of the required skills for the job. Sort the output by candidate ID in ascending order.
*/

SELECT candidate_id FROM candidates WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(*) > 2;

/*
3.	Tesla is investigating production bottlenecks and they need your help to extract the relevant data. Write a query to determine which parts have begun the assembly process but are not yet finished.
Assumptions:

parts_assembly table contains all parts currently in production, each at varying stages of the assembly process.
An unfinished part is one that lacks a finish_date.
This question is straightforward, so let's approach it with simplicity in both thinking and solution.

Effective April 11th 2023, the problem statement and assumptions were updated to enhance clarity.
*/

SELECT part, assembly_step FROM parts_assembly WHERE finish_date is NULL

/*
4.	Assume you're given two tables containing data about Facebook Pages and their respective likes (as in "Like a Facebook Page").
Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.
*/

SELECT page_id FROM  pages p WHERE NOT EXISTS (SELECT NULL FROM page_likes pl  WHERE p.page_id = pl.page_id );

/*
5.	This is the same question as problem #3 in the SQL Chapter of Ace the Data Science Interview!
Assume you're given the table on user viewership categorised by device type where the three types are laptop, tablet, and phone.
Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined as the sum of tablet and phone viewership. Output the total viewership for laptops as laptop_reviews and the total viewership for mobile devices as mobile_views.
Effective 15 April 2023, the solution has been updated with a more concise and easy-to-understand approach.
*/

SELECT (SELECT COUNT(*) FROM viewership  WHERE device_type = 'laptop') AS laptop_views,
(SELECT COUNT(*) FROM viewership  WHERE device_type IN ('phone', 'tablet') ) AS mobile_views;


/*
6.	Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021. Output the user and number of the days between each user's first and last post. 
p.s. If you've read the Ace the Data Science Interview and liked it, consider writing us a review?
*/

/* ---Soluciones probables no exitosas.
SELECT (EXTRACT(DAY FROM post_date),
EXTRACT(MONTH FROM post_date),
EXTRACT(YEAR FROM post_date)) AS date
 FROM posts WHERE user_id = 151652 ORDER BY post_date ASC LIMIT 1;
/*01/28/21
SELECT post_date::DATE AS dates FROM posts ORDER BY dates ASC limit 1; 

/*07/01/22
SELECT post_date::DATE AS dates FROM posts ORDER BY dates DESC limit 1; 

SELECT user_id, ((SELECT post_date::DATE AS dates FROM posts ORDER BY dates DESC limit 1)-
(SELECT post_date::DATE AS dates FROM posts ORDER BY dates ASC limit 1)) AS days_btween FROM posts;
---*/

SELECT user_id , EXTRACT (DAY FROM (MAX(post_date)-MIN(post_date)))
AS days_between FROM posts WHERE post_date BETWEEN '2021-01-01' AND '2021-12-31' GROUP BY user_id
HAVING COUNT(post_id) > 1;

/*
7.	Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. Display the IDs of these 2 users along with the total number of messages they sent. Output the results in descending order based on the count of the messages.
Assumption:
No two users have sent the same number of messages in August 2022.
*/

SELECT sender_id, COUNT(content) AS message_count FROM messages
WHERE sent_date BETWEEN '08/03/2022' AND '08/31/2022'
GROUP BY sender_id
HAVING COUNT(*)>1
ORDER BY message_count DESC;

/*
8.	This is the same question as problem #8 in the SQL Chapter of Ace the Data Science Interview!
Assume you're given a table containing job postings from various companies on the LinkedIn platform. Write a query to retrieve the count of companies that have posted duplicate job listings.
Definition:
Duplicate job listings are defined as two job listings within the same company that share identical titles and descriptions.
*/
WITH duplicates AS (SELECT  COUNT(*) AS duplicate
FROM job_listings
GROUP BY company_id
HAVING COUNT(*)>1
)
SELECT COUNT (*) AS duplicate_companies FROM duplicates ;


/*
9.	This is the same question as problem #2 in the SQL Chapter of Ace the Data Science Interview!
Assume you're given the tables containing completed trade orders and user details in a Robinhood trading system.
Write a query to retrieve the top three cities that have the highest number of completed trade orders listed in descending order. Output the city name and the corresponding number of completed trade orders.
In the given dataset, San Francisco has the highest number of completed trade orders with 3 orders. Boston holds the second position with 2 orders, and Denver ranks third with 1 order.
*/

WITH status AS (
SELECT a.order_id, a.user_id , a.status, b.city FROM trades a
JOIN users b
ON a.user_id = b.user_id
Where a.status = 'Completed'
)

SELECT city, COUNT(status) AS total_orders FROM status
GROUP BY city 
ORDER BY total_orders DESC
limit 3;

/*
10.	Given the reviews table, write a query to retrieve the average star rating for each product, grouped by month. The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places. Sort the output first by month and then by product ID.
P.S. If you've read the Ace the Data Science Interview, and liked it, consider writing us a review?
Explanation
Product 50001 received two ratings of 4 and 3 in the month of June (6th month), resulting in an average star rating of 3.5.
The dataset you are querying against may have different input & output - this is just an example!
*/
SELECT  EXTRACT(MONTH from submit_date) AS mtn, product_id as product, ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY mtn, product
ORDER BY mtn, product; 

/*
11.Companies often perform salary analyses to ensure fair compensation practices. One useful analysis is to check if there are any employees earning more than their direct managers.
As a HR Analyst, you're asked to identify all employees who earn more than their direct managers. The result should include the employee's ID and name.
The output shows that Olivia Smith earns $7,000, surpassing her manager, William David who earns $6,800.
*/
/* --- Posibles soluciones no exitosas----
SELECT employee_id, name FROM employee WHERE salary > (SELECT MIN(salary) from employee WHERE manager_id is NULL) 
AND manager_id IS NOT NULL limit 2;
*/

/*cuadro comparativo
SELECT  e.employee_id,  e.name, e.salary,  m.name, m.salary
FROM employee e
JOIN employee m
on e.manager_id = m.employee_id
 ;
------- */

SELECT  e.employee_id,  e.name
FROM employee e
JOIN employee m
on e.manager_id = m.employee_id
WHERE e.salary > m.salary;


/*
11.	This is the same question as problem #1 in the SQL Chapter of Ace the Data Science Interview! Assume you have an events table on Facebook app analytics. Write a query to calculate the click-through rate (CTR) for the app in 2022 and round the results to 2 decimal places.
Definition and note:
Percentage of click-through rate (CTR) = 100.0 * Number of clicks / Number of impressions
To avoid integer division, multiply the CTR by 100.0, not 100.
Explanation
Let's consider an example of App 123. This app has a click-through rate (CTR) of 50.00% because out of the 2 impressions it received, it got 1 click.
To calculate the CTR, we divide the number of clicks by the number of impressions, and then multiply the result by 100.0 to express it as a percentage. In this case, 1 divided by 2 equals 0.5, and when multiplied by 100.0, it becomes 50.00%. So, the CTR of App 123 is 50.00%.
*/
WITH temporal AS(
SELECT app_id,
COUNT (event_type) FILTER (WHERE event_type = 'impression' AND timestamp BETWEEN '01/01/2022 00:00:00' AND '12/31/2022 23:59:59')
AS impression,
COUNT(event_type) FILTER (WHERE event_type = 'click' AND timestamp BETWEEN '01/01/2022 00:00:00' AND '12/31/2022 23:59:59')
AS click 
FROM events
GROUP BY app_id)

SELECT app_id, ROUND(100.00* click/impression,2) AS ctr FROM temporal;


/*
12.	Assume you're given tables with information about TikTok user sign-ups and confirmations through email and text. New users on TikTok sign up using their email addresses, and upon sign-up, each user receives a text message confirmation to activate their account.
Write a query to display the user IDs of those who did not confirm their sign-up on the first day, but confirmed on the second day.
*/

WITH temporal AS(
SELECT a.user_id, a.signup_date, b.action_date  from emails a
FULL JOIN 
texts b
 ON a.email_id = b.email_id)
 
 SELECT user_id FROM temporal WHERE signup_date + INTERVAL '1 day' = action_date;

/*
13.	IBM is analyzing how their employees are utilizing the Db2 database by tracking the SQL queries executed by their employees. The objective is to generate data to populate a histogram that shows the number of unique queries run by employees during the third quarter of 2023 (July to September). Additionally, it should count the number of employees who did not run any queries during this period.
Display the number of unique queries as histogram categories, along with the count of employees who executed that number of unique queries.
*/
/*----------Posibles soluciones no exitosas---------
WITH temporal AS (
SELECT employee_id, COUNT(query_id) AS unique_queries
FROM queries
WHERE query_starttime BETWEEN '07/01/2023' AND '09/30/2023'
GROUP BY employee_id)


SELECT unique_queries, COUNT(employee_id) AS employee_count
FROM  temporal
GROUP BY unique_queries
ORDER BY  unique_queries ASC ;
*/

/*
WITH temporal AS(

SELECT e.employee_id, COALESCE(COUNT(DISTINCT q.query_id),0)
AS unique_queries 
FROM employees e
LEFT JOIN  queries q
on e.employee_id = q.employee_id
WHERE query_starttime BETWEEN '07/01/2023' AND '09/30/2023'
GROUP BY e.employee_id )

SELECT unique_queries,
COUNT (employee_id) as employe_count
FROM temporal 
GROUP BY unique_queries
ORDER BY unique_queries;
---------------*/

WITH temporal AS (
  SELECT * FROM employees e
  LEFT JOIN queries q
  USING(employee_id)
)

,temporal2 AS (
  SELECT employee_id, SUM(CASE WHEN DATE(query_starttime) BETWEEN '07/01/2023' AND '09/30/2023' THEN 1 ELSE 0 END) AS test
  FROM temporal
  GROUP BY 1
 )

SELECT test AS unique_queries, COUNT(employee_id) AS employee_count
FROM temporal2
GROUP BY test
ORDER BY unique_queries ASC;


/*
14.	Your team at JPMorgan Chase is preparing to launch a new credit card, and to gain some insights, you're analyzing how many credit cards were issued each month.
Write a query that outputs the name of each credit card and the difference in the number of issued cards between the month with the highest issuance cards and the lowest issuance. Arrange the results based on the largest disparity.
*/

WITH temporal AS (
SELECT card_name, MIN(issued_amount) AS minimum, MAX (issued_amount) AS maximum
FROM monthly_cards_issued 
GROUP BY card_name)
Select card_name, (maximum - minimum) as difference FROM temporal ORDER BY difference DESC


/*
15.	 You're trying to find the mean number of items per order on Alibaba, rounded to 1 decimal place using tables which includes information on the count of items in each order (item_count table) and the corresponding number of orders for each item count (order_occurrences table).
*/

WITH calculus AS(
SELECT  SUM((item_count:: DECIMAL)*(order_occurrences::DECIMAL)) AS total_items,
SUM(order_occurrences::DECIMAL) AS total_orders
FROM
items_per_order)
SELECT  ROUND(total_items/ total_orders,1) AS mean FROM calculus;

/*
16.	CVS Health is trying to better understand its pharmacy sales, and how well different products are selling. Each drug can only be produced by one manufacturer.
Write a query to find the top 3 most profitable drugs sold, and how much profit they made. Assume that there are no ties in the profits. Display the result from the highest to the lowest total profit.

Definition: cogs stands for Cost of Goods Sold which is the direct cost associated with producing the drug.
Total Profit = Total Sales - Cost of Goods Sold
*/

SELECT drug, (total_sales - cogs) AS total_profit FROM pharmacy_sales ORDER BY total_profit DESC LIMIT 3;

/*
17.	CVS Health is analyzing its pharmacy sales data, and how well different products are selling in the market. Each drug is exclusively manufactured by a single manufacturer.
Write a query to identify the manufacturers associated with the drugs that resulted in losses for CVS Health and calculate the total amount of losses incurred.
Output the manufacturer's name, the number of drugs associated with losses, and the total losses in absolute value. Display the results sorted in descending order with the highest losses displayed at the top.
If you like this question, try out Pharmacy Analytics (Part 3)!
*/
/*---Posible solucion no exitosa----
SELECT manufacturer, COUNT(drug) AS drug_count, (cogs-total_sales) AS total_loss  FROM pharmacy_sales 
GROUP BY manufacturer, total_loss ORDER BY  drug_count DESC ; 
----*/

SELECT manufacturer, COUNT(drug) AS drug_count, SUM(cogs-total_sales)AS total_loss
FROM pharmacy_sales WHERE cogs > total_sales
GROUP BY manufacturer
ORDER BY total_loss DESC


/*
18.	CVS Health wants to gain a clearer understanding of its pharmacy sales and the performance of various products.
Write a query to calculate the total drug sales for each manufacturer. Round the answer to the nearest million and report your results in descending order of total sales. In case of any duplicates, sort them alphabetically by the manufacturer name.
Since this data will be displayed on a dashboard viewed by business stakeholders, please format your results as follows: "$36 million".
*/

SELECT manufacturer, ('$'||ROUND(SUM(total_sales/1000000))||' million') AS sale FROM pharmacy_sales
GROUP BY manufacturer ORDER BY SUM(total_sales) DESC;

/*
19.	UnitedHealth Group (UHG) has a program called Advocate4Me, which allows policy holders (or, members) to call an advocate and receive support for their health care needs – whether that's claims and benefits support, drug coverage, pre- and post-authorisation, medical records, emergency assistance, or member portal services.
Write a query to find how many UHG policy holders made three, or more calls, assuming each call is identified by the case_id column.
*/

WITH temporal AS(
SELECT COUNT(case_id) as policy_holder_count FROM callers 
GROUP BY policy_holder_id
ORDER BY  policy_holder_count ASC
)

SELECT COUNT(policy_holder_count) AS policy_holder_count FROM temporal WHERE policy_holder_count >= 3;

/*
20.	This is the same question as problem #11 in the SQL Chapter of Ace the Data Science Interview! Assume you are given the table below on Uber transactions made by users. Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.

*/
WITH temporal AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY user_id
ORDER BY transaction_date ASC) AS rn
FROM transactions
)
SELECT user_id,	spend,	transaction_date FROM temporal WHERE rn = 3;


/*
21.	Imagine you're an HR analyst at a tech company tasked with analyzing employee salaries. Your manager is keen on understanding the pay distribution and asks you to determine the second highest salary among all employees.
It's possible that multiple employees may share the same second highest salary. In case of duplicate, display the salary only once.
*/

SELECT salary AS second_highest_salary
FROM employee 
ORDER BY salary DESC
LIMIT 1 OFFSET 1

/*
22.	This is the same question as problem #25 in the SQL Chapter of Ace the Data Science Interview!
Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening snaps.
Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.
Notes:

Calculate the following percentages:
time spent sending / (Time spent sending + Time spent opening)
Time spent opening / (Time spent sending + Time spent opening)
To avoid integer division in percentages, multiply by 100.0 and not 100.
Effective April 15th, 2023, the solution has been updated and optimised.
*/

WITH temporal AS(
SELECT age_bucket,
(CASE WHEN activity_type ='send' THEN time_spent ELSE 0 end) AS send,
(CASE WHEN activity_type ='open' THEN time_spent ELSE 0 end) AS open
FROM activities a
INNER JOIN
age_breakdown  ab on a.user_id = ab.user_id
)

SELECT age_bucket, ROUND(SUM(send)/(SUM(send)+SUM(open))*100,2) AS send_perc, ROUND(SUM(open)/(SUM(open)+SUM(send))*100,2) 
AS open_perc FROM temporal
GROUP BY age_bucket;

/*
23.	This is the same question as problem #10 in the SQL Chapter of Ace the Data Science Interview!
Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.
Notes:
A rolling average, also known as a moving average or running mean is a time-series technique that examines trends in data over a specified period of time.
In this case, we want to determine how the tweet count for each user changes over a 3-day period.
*/

SELECT user_id, tweet_date, 
ROUND(AVG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date ROWS BETWEEN 2 PRECEDING
AND CURRENT ROW),2) AS rolling_avg_3d
FROM tweets;


/*
24.	This is the same question as problem #12 in the SQL Chapter of Ace the Data Science Interview!
Assume you're given a table containing data on Amazon customers and their spending on products in different category, write a query to identify the top two highest-grossing products within each category in the year 2022. The output should include the category, product, and total spend.
*/

WITH temporal AS (
SELECT category, product, sum(spend)
AS total_spend FROM product_spend 
WHERE EXTRACT (YEAR FROM transaction_date) = 2022
GROUP BY category, product
ORDER BY category , total_spend DESC )

SELECT category, product, total_spend
FROM ( SELECT category, product, total_spend, RANK() OVER (PARTITION BY category ORDER BY total_spend DESC)
AS ranking
FROM temporal) AS sub WHERE  ranking <= 2;


/*
25.	As part of an ongoing analysis of salary distribution within the company, your manager has requested a report identifying high earners in each department. A 'high earner' within a department is defined as an employee with a salary ranking among the top three salaries within that department.
You're tasked with identifying these high earners across all departments. Write a query to display the employee's name along with their department name and salary. In case of duplicates, sort the results of department name in ascending order, then by salary in descending order. If multiple employees have the same salary, then order them alphabetically.

Note: Ensure to utilize the appropriate ranking window function to handle duplicate salaries effectively.

As of June 18th, we have removed the requirement for unique salaries and revised the sorting order for the results.
*/

WITH temporal AS(

SELECT d.department_id, d.department_name, e.name, e.salary,
DENSE_RANK () OVER (PARTITION BY d.department_name
ORDER BY e.salary DESC) as ranking
FROM employee e
JOIN 
department d
ON  e.department_id = d.department_id
ORDER BY department_name, salary  DESC
)

SELECT department_name, name, salary FROM temporal 
WHERE ranking  BETWEEN 1 AND 3
ORDER BY  department_name, salary DESC

/*
26.	Assume there are three Spotify tables: artists, songs, and global_song_rank, which contain information about the artists, songs, and music charts, respectively.
Write a query to find the top 5 artists whose songs appear most frequently in the Top 10 of the global_song_rank table. Display the top 5 artist names in ascending order, along with their song appearance ranking.

If two or more artists have the same number of song appearances, they should be assigned the same ranking, and the rank numbers should be continuous (i.e. 1, 2, 2, 3, 4, 5). If you've never seen a rank order like this before, do the rank window function tutorial.
*/
/* -----posible solucion no exitosa---
WITH ranking_canciones AS (
SELECT song_id , COUNT(*) AS veces_top_10
FROM global_song_rank 
WHERE rank <= 10
GROUP BY song_id
),

 ranking_artistas AS (
SELECT artist_id, SUM(veces_top_10) AS veces_top_10, 
DENSE_RANK() OVER (ORDER BY SUM(veces_top_10) DESC) AS artist_rank
FROM ranking_canciones
JOIN songs
ON 
songs.song_id = ranking_canciones.song_id
GROUP BY artist_id
ORDER BY veces_top_10 DESC
)

SELECT a.artist_name, ra.artist_rank 
FROM  ranking_artistas ra
JOIN artists a
ON  a.artist_id = ra.artist_id
WHERE ra.artist_rank <= 5
ORDER BY artist_rank ASC, ra.artist_id
;
-----*/

WITH top_10 AS (
  SELECT 
    artists.artist_name,
    DENSE_RANK() OVER (
      ORDER BY COUNT(songs.song_id) DESC) AS artist_rank
  FROM artists
  INNER JOIN songs
    ON artists.artist_id = songs.artist_id
  INNER JOIN global_song_rank AS ranking
    ON songs.song_id = ranking.song_id
  WHERE ranking.rank <= 10
  GROUP BY artists.artist_name
)

SELECT artist_name, artist_rank
FROM top_10
WHERE artist_rank <= 5;
