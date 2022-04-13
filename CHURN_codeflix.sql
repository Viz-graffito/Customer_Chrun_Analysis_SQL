create table codeflix(
id integer primary key,
subscription_start date,
subscription_end date,
segement integer
);
SHOW VARIABLES LIKE "secure_file_priv";
SET GLOBAL local_infile=1;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Book1.csv'
INTO TABLE codeflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,subscription_start,@subscription_end,segement)
SET subscription_end = IF(@subscription_end = '', NULL, @subscription_end);

-- Lets check top 100 rows of this data

SELECT 
    *
FROM
    codeflix
LIMIT 100;

-- Range of the months we are going to calcuate the CHURN rate

SELECT 
    MIN(subscription_start), MAX(subscription_start)
FROM
    codeflix;

-- create a temporary table as months which contains 3 months 'jan', 'feb' and 'march' 

WITH months As
(select 
'2017-01-01' as 'first-day',
'2017-01-31' as 'last-day'
union
select 
'2017-02-01' as 'first-day',
'2017-02-21' as 'last-day'
union
select 
'2017-03-01' as 'first-day',
'2017-03-31' as 'last-day')
select * from months;

-- create another temporary name as cross_join which is the cross join of the table 'codeflix' and temporary table 'months'
WITH months As
( select 
'2017-01-01' as 'first-day',
'2017-01-31' as 'last-day'
union
select 
'2017-02-01' as 'first-day',
'2017-02-21' as 'last-day'
union
select 
'2017-03-01' as 'first-day',
'2017-03-31' as 'last-day'
),
cross_join AS
(SELECT 
    *
FROM
    codeflix
        CROSS JOIN
    months) select * from cross_join limit 6;


-- created 3rd temporary table name 'status' which have 4 columns 'id','month','is_active87','is_active30'
WITH months As
( select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last-day'
union
select 
'2017-02-01' as 'first_day',
'2017-02-21' as 'last-day'
union
select 
'2017-03-01' as 'first_day',
'2017-03-31' as 'last-day'
),

cross_join AS -- 2nd
(SELECT * FROM codeflix
CROSS JOIN months),

status as  -- 3rd
(select id, first_day AS month,
Case when
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 87) 
then 1
else 0
end as is_active_87,
case when 
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 30) 
then 1
else 0
end as is_active_30
from cross_join)
select * from status limit 10;

-- added more columns in status table with case statement 'is_canceld87' and 'is_canceled30'
-- now status table shows 1 if cx is active 0 if not

WITH months As
( select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select 
'2017-02-01' as 'first_day',
'2017-02-21' as 'last_day'
union
select 
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'
),

cross_join AS -- 2
(SELECT * FROM codeflix
CROSS JOIN months),

status as -- 3
(select id, first_day AS month,
Case when
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 87) 
then 1
else 0
end as is_active_87,
case when 
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 30) 
then 1
else 0
end as is_active_30,
case when 
(subscription_end Between First_day and last_day) and (segement = 87)
then 1
else 0
end as is_canceled_87,
case when 
(subscription_end Between First_day and last_day) and (segement = 87)
then 1
else 0
end as is_canceled_30
from cross_join) select * from status
order by id ,month
limit 10;

-- created 4th temprorary table name as status_aggreagte which shows the sum of all the active and canceled ids

WITH months As
( select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select 
'2017-02-01' as 'first_day',
'2017-02-21' as 'last_day'
union
select 
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'
),
cross_join AS -- 2 
(SELECT * FROM codeflix
CROSS JOIN months),

status as -- 3 
(select id, first_day AS month,
Case when
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 87) 
then 1
else 0
end as is_active_87,
case when 
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 30) 
then 1
else 0
end as is_active_30,
case when 
(subscription_end Between First_day and last_day) and (segement = 87)
then 1
else 0
end as is_canceled_87,
case when 
(subscription_end Between First_day and last_day) and (segement = 87)
then 1
else 0
end as is_canceled_30
from cross_join),
status_aggregate as -- 4
(select month, 
sum(is_active_87) as sum_active_87,
sum(is_active_30) as sum_active_30,
sum(is_canceled_87) as sum_canceled_87,
sum(is_canceled_30) as sum_canceled_30 from status
group by month) select * from status_aggregate;


-- calcualted the churn by deviding all canceled ids by all active in that perticular month

WITH months As
( select 
'2017-01-01' as 'first_day',
'2017-01-31' as 'last_day'
union
select 
'2017-02-01' as 'first_day',
'2017-02-21' as 'last_day'
union
select 
'2017-03-01' as 'first_day',
'2017-03-31' as 'last_day'
),
cross_join AS
(SELECT * FROM codeflix
CROSS JOIN months),

status as 
(select id, first_day AS month,
Case when
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 87) 
then 1
else 0
end as is_active_87,
case when 
(subscription_start < first_day) and
(subscription_end > first_day or subscription_end is NULL) 
and (segement = 30) 
then 1
else 0
end as is_active_30,
case when 
(subscription_end Between First_day and last_day) and (segement = 87)
then 1
else 0
end as is_canceled_87,
case when 
(subscription_end Between First_day and last_day) and (segement = 87)
then 1
else 0
end as is_canceled_30
from cross_join),
status_aggregate as 
(select month, 
sum(is_active_87) as sum_active_87,
sum(is_active_30) as sum_active_30,
sum(is_canceled_87) as sum_canceled_87,
sum(is_canceled_30) as sum_canceled_30 from status
group by month) select month,
1.0 * sum_canceled_87/sum_active_87 as chrun_rate_87,
1.0 * sum_canceled_30/sum_active_30 as chrun_rate_30
from status_aggregate
order by 1;