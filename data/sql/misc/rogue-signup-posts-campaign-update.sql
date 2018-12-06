/* This SQL block is to address removal of campaign_run_id's
   from DS systems, and updating them with campaign_id's */

-- Update signups with new camaign_id based on campaign mapping table.
UPDATE rogue.signups s
SET campaign_id = c.id
FROM rogue_prod.campaigns c
WHERE s.campaign_run_id = c.campaign_run_id;

-- Update posts with new campaign_id based on updated signups tbale.
UPDATE rogue.posts t
SET campaign_id = s.campaign_id
FROM rogue.signups s
WHERE t.signup_id = s.id;
