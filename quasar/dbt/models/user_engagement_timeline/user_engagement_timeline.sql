--The goal of this table is to have one row per NSID with multiple engagement metrics AND dates
--throuout different points in time (6 mo, 12 mo, 24 mo, 60 mo, total)

WITH 
user_mam AS (
	SELECT northstar_id,
		   min(timestamp) AS first_mam
	FROM public.member_event_log
	WHERE action_type <> 'account_creation'
	AND timestamp >= '2008-01-01'
	GROUP BY 1
),
user_created AS (
	SELECT u.northstar_id, 
		  CASE WHEN date(u.created_at) > date(a.first_mam) 
		  	THEN date(a.first_mam) 
		  	ELSE date(u.created_at) END AS created_at
	--date_trunc('month', date(u.created_at)) AS month_created
    FROM public.users u
    JOIN user_mam a ON u.northstar_id = a.northstar_id
    WHERE (u.email IS NULL OR u.email NOT LIKE '%@dosomething.org' OR email NOT LIKE '%invalid%')
),
user_actions AS (
	SELECT u.northstar_id, 
		   count(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '6 month'
		   		 THEN m.event_id END) AS mams_06, 
		   count(CASE WHEN date(r.post_created_at) <= date(u.created_at) + interval '6 month'
		   	     THEN r.post_id END) AS rbs_06,
		   max(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '6 month'
		   	   THEN date(m.timestamp) END) AS last_mam_06,
	       count(DISTINCT CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '6 month'
	       	     THEN date_trunc('month', m.timestamp) END) AS months_active_06,
		   count(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '12 month'
		   	     THEN m.event_id END) AS mams_12, 
		   count(CASE WHEN date(r.post_created_at) <= date(u.created_at) + interval '12 month'
		   	     THEN r.post_id END) AS rbs_12,
		   max(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '12 month'
		   	   THEN date(m.timestamp) END) AS last_mam_12,
		   count(DISTINCT CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '12 month'
		   	     THEN date_trunc('month', m.timestamp) END) AS months_active_12,
		   count(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '24 month'
		   	     THEN m.event_id END) AS mams_24, 
		   count(CASE WHEN date(r.post_created_at) <= date(u.created_at) + interval '24 month'
		   	     THEN r.post_id END) AS rbs_24,
		   max(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '24 month'
		   	   THEN date(m.timestamp) END) AS last_mam_24,
		   count(DISTINCT CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '24 month'
		   	     THEN date_trunc('month', m.timestamp) END) AS months_active_24,
		   count(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '60 month'
		   	     THEN m.event_id END) AS mams_60, 
		   count(CASE WHEN date(r.post_created_at) <= date(u.created_at) + interval '60 month'
		   	     THEN r.post_id END) AS rbs_60,
		   max(CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '60 month'
		   	   THEN date(m.timestamp) END) AS last_mam_60,
		   count(DISTINCT CASE WHEN date(m.timestamp) <= date(u.created_at) + interval '60 month'
		   	     THEN date_trunc('month', m.timestamp) END) AS months_active_60,
		   count(m.event_id) AS mams_total, 
		   count(r.post_id) AS rbs_total,
		   max(date(m.timestamp)) AS last_mam_total,
		   count(distinct date_trunc('month', m.timestamp)) AS months_active_total
	FROM user_created u
	JOIN public.member_event_log m ON (u.northstar_id = m.northstar_id)
	LEFT JOIN public.reportbacks r ON (u.northstar_id = r.northstar_id) 
	WHERE m.action_type <> 'account_creation'
	AND m.timestamp >= '2008-01-01'
	GROUP BY 1
),
calc AS (
	SELECT a.northstar_id, 
 	  	   created_at,
	  	   EXTRACT('year' FROM created_at) AS created_year,
	  	   date_trunc('month', created_at) AS created_month,
      	   EXTRACT(year FROM age(now(),created_at)) AS created_years,
      	   EXTRACT(month FROM age(now(),created_at)) AS created_months,
      	   COALESCE(mams_06,0) AS mams_06,
      	   COALESCE(rbs_06,0) AS rbs_06,
      	   EXTRACT(month FROM age(last_mam_06,created_at)) AS last_mam_06_months,
      	   months_active_06,
      	   COALESCE(mams_12,0) AS mams_12,
      	   COALESCE(rbs_12,0) AS rbs_12,
      	   EXTRACT(year FROM age(last_mam_12,created_at)) AS last_mam_12_years,
      	   EXTRACT(month FROM age(last_mam_12,created_at)) AS last_mam_12_months,
	  	   months_active_12,
      	   COALESCE(mams_24,0) AS mams_24,
      	   COALESCE(rbs_24,0) AS rbs_24,
      	   EXTRACT(year FROM age(last_mam_24,created_at)) AS last_mam_24_years,
      	   EXTRACT(month FROM age(last_mam_24,created_at)) AS last_mam_24_months,        
      	   months_active_24,
      	   COALESCE(mams_60,0) AS mams_60,
      	   COALESCE(rbs_60,0) AS rbs_60,
      	   EXTRACT(year FROM age(last_mam_60,created_at)) AS last_mam_60_years,
      	   EXTRACT(month FROM age(last_mam_60,created_at)) AS last_mam_60_months,
      	   months_active_60,
	  	   COALESCE(mams_total,0) AS mams_total,
	  	   COALESCE(rbs_total,0) AS rbs_total,
      	   EXTRACT(year FROM age(last_mam_total,created_at)) AS last_mam_total_years,
      	   EXTRACT(month FROM age(last_mam_total,created_at)) AS last_mam_total_months,
      	   months_active_total    
	FROM user_actions a
	JOIN user_created c on (a.northstar_id = c.northstar_id)
)
SELECT northstar_id, 
	   created_at,
	   created_year,
	   created_month,
	   (created_years * 12) + created_months AS created_months,
	   mams_06,
	   rbs_06,
	   last_mam_06_months AS last_mam_06,
	   months_active_06,
	   mams_12,
	   rbs_12,
	   (last_mam_12_years * 12) + last_mam_12_months AS last_mam_12,
	   months_active_12,
	   mams_24,
	   rbs_24,
	   (last_mam_24_years * 12) + last_mam_24_months AS last_mam_24,
	   months_active_24,
	   mams_60,
	   rbs_60,
	   (last_mam_60_years * 12) + last_mam_60_months AS last_mam_60,
	   months_active_60,
	   mams_total,
	   rbs_total,
	   (last_mam_total_years * 12) + last_mam_total_months AS last_mam_total,
	   months_active_total
FROM calc