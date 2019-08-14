UPDATE :users
	SET birthdate = date_trunc('year', birthdate)
	WHERE id = ':nsid';

UPDATE :users
	SET first_name = NULL,
		last_name = NULL,
		last_initial = NULL,
		photo = NULL,
		email = NULL,
		mobile = NULL,
		facebook_id = NULL,
		interests = NULL,
		addr_street1 = NULL,
		addr_street2 = NULL,
		addr_source = NULL,
		slack_id = NULL,
		sms_status = NULL,
		sms_paused = NULL,
		drupal_id = NULL,
		"role" = NULL,
		last_accessed_at = NULL,
		last_authenticated_at = NULL,
		last_messaged_at = NULL,
		email_subscription_status = NULL 
	WHERE id = ':nsid';