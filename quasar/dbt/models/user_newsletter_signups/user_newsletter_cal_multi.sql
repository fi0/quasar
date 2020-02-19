WITH 
cal AS (
	SELECT generate_series( date_trunc('month', date('2019-03-01')), now(), '1 month' )::date AS cal_month
), 
user_months AS (
	SELECT u.northstar_id, u.created_at_month, u.last_mam, 
		  c.cal_month, age(c.cal_month, u.created_at_month) AS month_diff
	FROM {{ ref('user_created') }} u
	CROSS JOIN cal c 
	WHERE date_trunc('month',created_at_month) < c.cal_month
	--We eliminate users which did not provide an email since they can't subscribe
	AND u.email IS NOT NULL
),
user_cal AS (
	SELECT northstar_id,
	created_at_month, last_mam, 
	cal_month,
	extract('year' FROM month_diff)*12 +extract('month' FROM month_diff) AS months_since_created
	FROM user_months
),
nls AS (
	SELECT DISTINCT newsletter_topic
	FROM {{ ref('user_newsletter_subscriptions') }}
)
SELECT 
	northstar_id, created_at_month, last_mam, 
	cal_month, months_since_created,
  CASE WHEN months_since_created <= 5 THEN cal_month - interval '1 month' 
  	   ELSE cal_month - interval '5 month' 
  	   END AS period_start,
  cal_month - interval '1 millisecond' AS period_end,
 newsletter_topic
FROM user_cal
CROSS JOIN nls 
--We eliminate the 1st month because it contains noise from the high number of registration-signups activity  
WHERE ( months_since_created BETWEEN 2 AND 5 OR mod(months_since_created::int,5) = 0)
