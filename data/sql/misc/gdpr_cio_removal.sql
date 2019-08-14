UPDATE :customer_event
	SET email_address = NULL,
		event_id = NULL
	WHERE customer_id = ':nsid';

UPDATE :email_bounced
	SET email_address = NULL,
		event_id = NULL,
		subject = NULL
	WHERE customer_id = ':nsid';

UPDATE :email_event
	SET email_address = NULL,
		event_id = NULL,
		subject = NULL,
		href = NULL,
		link_id = NULL
	WHERE customer_id = ':nsid';

UPDATE :email_sent
	SET email_address = NULL,
		event_id = NULL,
		subject = NULL
	WHERE customer_id = ':nsid';

DELETE FROM :event_log
	WHERE "event"#>>'{data,variables,customer,id}' = ':nsid';