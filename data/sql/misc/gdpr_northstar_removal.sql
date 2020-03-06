UPDATE :users
	SET birthdate = date_trunc('year', birthdate)
	WHERE _id IN (SELECT _id FROM :users.northstar_users_snapshot WHERE deleted_at IS NOT NULL);

UPDATE :legacy_users
	SET birthdate = date_trunc('year', birthdate)
	WHERE id IN (SELECT _id FROM :users.northstar_users_snapshot WHERE deleted_at IS NOT NULL);

UPDATE :users
	SET first_name = NULL,
		last_name = NULL,
		avatar = NULL,
		email = NULL,
		mobile = NULL,
		facebook_id = NULL,
		addr_street_1 = NULL,
		addr_street_2 = NULL,
		addr_source = NULL,
		sms_status = NULL,
		sms_paused = NULL,
		drupal_id = NULL,
		"role" = NULL,
		last_accessed_at = NULL,
		last_authenticated_at = NULL,
		last_messaged_at = NULL,
		email_subscription_status = NULL 
	WHERE _id IN (SELECT _id FROM :users.northstar_users_snapshot WHERE deleted_at IS NOT NULL);

UPDATE :legacy_users
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
	WHERE id IN (SELECT _id FROM :users.northstar_users_snapshot WHERE deleted_at IS NOT NULL);