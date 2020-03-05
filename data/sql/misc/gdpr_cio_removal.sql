UPDATE :customer_event
	SET email_address = NULL,
		event_id = NULL
	WHERE customer_id IN (SELECT _id FROM :users WHERE deleted_at IS NOT NULL);

UPDATE :email_bounced
	SET email_address = NULL,
		event_id = NULL,
		subject = NULL
	WHERE customer_id IN (SELECT _id FROM :users WHERE deleted_at IS NOT NULL);

UPDATE :email_event
	SET email_address = NULL,
		event_id = NULL,
		subject = NULL,
		href = NULL,
		link_id = NULL
	WHERE customer_id IN (SELECT _id FROM :users WHERE deleted_at IS NOT NULL);

UPDATE :email_sent
	SET email_address = NULL,
		event_id = NULL,
		subject = NULL
	WHERE customer_id IN (SELECT _id FROM :users WHERE deleted_at IS NOT NULL);

DELETE FROM :event_log
	WHERE "event"#>>'{data,variables,customer,id}' IN (SELECT _id FROM :users WHERE deleted_at IS NOT NULL);