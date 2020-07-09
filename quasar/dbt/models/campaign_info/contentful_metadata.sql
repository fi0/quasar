SELECT 
  cmr.contentful_id,
  (cmr.fields #>>'{legacy_campaign_id}')::int AS legacy_campaign_id,
  cmr.fields #>>'{internal_title}' AS internal_title,
  cmr.fields #>>'{title}' AS title,
  cmr.fields #>>'{slug}' AS  slug, 
  cmr.fields #>>'{display_referral_page}' AS display_referral_page
FROM {{ source('public_intermediate', 'contentful_metadata_raw') }} cmr
