SELECT id AS post_id, 
	details::jsonb->>'hostname' AS hostname,
	details::jsonb->>'referral_code' AS referral_code,
	details::jsonb->>'partner_comms_opt_in' AS partner_comms_opt_in,
	(details::jsonb->>'created-at')::timestamp AS created_at,
	(details::jsonb->>'updated-at')::timestamp AS updated_at,
	source_details,
	details::jsonb->>'voter_registration_status' AS voter_registration_status,
	details::jsonb->>'voter_registration_source' AS voter_registration_source,
	details::jsonb->>'voter_registration_method' AS voter_registration_method,
	details::jsonb->>'voter_registration_preference' AS voter_registration_preference,
	details::jsonb->>'email_subscribed' AS email_subscribed,
	details::jsonb->>'sms_subscribed' AS sms_subscribed
FROM ft_dosomething_rogue.posts
WHERE source = 'turbovote'