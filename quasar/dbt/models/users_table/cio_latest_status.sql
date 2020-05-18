SELECT 
	cio.customer_id,
	max(CASE WHEN 
			cio.event_type = 'customer_unsubscribed' 
			THEN 'customer_unsubscribed' 
			ELSE 'customer_subscribed' END) AS event_type,
	max(cio."timestamp") AS "timestamp"
FROM {{ ref('cio_email_event_new') }} cio
INNER JOIN 
	(SELECT 
		ctemp.customer_id,
		max(ctemp."timestamp") AS max_update
	FROM {{ ref('cio_email_event_new') }} ctemp
	GROUP BY ctemp.customer_id) cio_max 
		ON cio_max.customer_id = cio.customer_id 
		AND cio_max.max_update = cio."timestamp"
GROUP BY cio.customer_id
