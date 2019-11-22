
{% docs click_id %}
This is a unique identifier for each click
{% enddocs %}

{% docs click_time %}
Timestamp when user clicked.
{% enddocs %}

{% docs shortened %}
Shortened URL
{% enddocs %}

{% docs target_url %}
URL where the user will be directed
{% enddocs %}

{% docs broadcast_id %}
ID of the broadcast that generated the shortened URL
{% enddocs %}

{% docs source %}
Source of the URL (e.g. SMS, web), origin of the post (e.g. phoenix-web, phoenix-ashes, sms), or source where user was acquired. (e.g. sms, phoenix-next)
{% enddocs %}

{% docs interaction_type %}
How the user interacted with the link (e.g. preview, click)
{% enddocs %}

{% docs id %}
Unique identifier for the post
{% enddocs %}

{% docs type %}
Type of post (e.g. photo)
{% enddocs %}

{% docs action %}
Post action (e.g. DefendDreamers_Nov9_CongressCalls, GunViolence2018_Feb15_ParklandResponse)
{% enddocs %}

{% docs status %}
Post status (e.g. accepted, rejected)
{% enddocs %}

{% docs quantity %}
Numerical quantity of items specified in the call to action (e.g. 10, 200)
{% enddocs %}

{% docs source_bucket %}
Grouping bucket for origin of the post (e.g. web, sms) 
{% enddocs %}

{% docs created_at %}
When the item was created in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs updated_at %}
When the item was updated in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs text %}
Text of the post (e.g. "Zoo animals and a super hero trying to help too!") 
{% enddocs %}

{% docs signup_id %}
Unique identifier for the signup 
{% enddocs %}

{% docs post_class %}
Class of the signup (e.g. "photo - default", "phone-call - DefendDreamers_Jan16_BothBodies")
{% enddocs %}

{% docs is_accepted %}
Whether the post has been accepted to be displayed to the public on the website
{% enddocs %}

{% docs action_id %}
Internal identifier of the action 
{% enddocs %}

{% docs location %}
Location where the action takes place (e.g. US-NY)
{% enddocs %}

{% docs postal_code %}
Postal code where the action takes place
{% enddocs %}

{% docs is_reportback %}
Whether the post is a reportback. The application allows for multiple types of posts.
{% enddocs %}

{% docs civic_action %}
Whether the post is a Civic Action. The application allows for multiple types of posts.
{% enddocs %}

{% docs scholarship_entry %}
Whether the post is a Scholarship Entry. The application allows for multiple types of posts.
{% enddocs %}

{% docs why_participated %}
Why the user participated in this action. Entered by the user.
{% enddocs %}

{% docs details %}
Details about the post. Contains contentfulId and other information (e.g. {"campaignContentfulId":"6ATBgGEQEeJoIcxs1qbwaC"})
{% enddocs %}

{% docs reportback_volume %}
"???"
{% enddocs %}

{% docs email %}
Email address of the user.
{% enddocs %}

{% docs source_details %}
Details about the source of the item. This is sometimes represented as a JSON object, and for other tables like Turbovote its represented as a string. (e.g. "{"contentful_id":"3CTLlXfbwtz1FOMpl31SKV","utm_source":"scholarship_listing","utm_medium":"referral","utm_campaign":"fastweb_2019_08"}", newsletter_456)
{% enddocs %}


{% docs campaign_id %}
This is a unique identifier for the campaign
{% enddocs %}

{% docs campaign_run_id %}
Unique identifier for the campaign run
{% enddocs %}

{% docs campaign_name %}
Name of the campaign
{% enddocs %}

{% docs campaign_cause %}
Campaign cause (eg. Mental Health, Education)
{% enddocs %}

{% docs campaign_run_start_date %}
Start date of the campaign run
{% enddocs %}

{% docs campaign_run_end_date %}
End date of the campaign run
{% enddocs %}

{% docs campaign_created_date %}
When the campaign was created in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs campaign_node_id %}
Internal unique node id for the campaign
{% enddocs %}

{% docs campaign_node_id_title %}
Campaign title
{% enddocs %}

{% docs campaign_run_id_title %}
Title of the campaign run
{% enddocs %}

{% docs campaign_action_type %}
Campaign action type (eg. Make Something, Share Something)
{% enddocs %}

{% docs campaign_cause_type %}
Campaign cause type (eg. Mental Health, Education)
{% enddocs %}

{% docs campaign_noun %}
Noun applicable to the user's action
{% enddocs %}

{% docs campaign_verb %}
Verb describing the action the user should take
{% enddocs %}

{% docs campaign_cta %}
Campaign's call to action
{% enddocs %}

{% docs campaign_language %}
"Language in which the campaign is available"
{% enddocs %}

{% docs agent_id %}
If set, the content type of the picture the member is sending us. Exp. image/png.
{% enddocs %}

{% docs attachment_content_type %}
If set, the handle of the Front agent this outbound support message is from.
{% enddocs %}

{% docs topic %}
Holds a reference to the **last** campaign topic the member's conversation was in. This is useful to allow members to talk to Gambit and get quick responses (through Rivescript), without Gambit completely forgetting what state the member's interaction with a campaign topic was in.
{% enddocs %}

{% docs action_serial_id %}
Serial id for the user's action. Depends on the source of the action. May be the bertly click id, sms message id, etc.
{% enddocs %}

{% docs channel %}
Channel for the user's action. Depends on the source of the action. (e.g. web, sms)
{% enddocs %}

{% docs first_action_month %}
Month during which the user took their first action. 
{% enddocs %}

{% docs event_id %}
This is a unique identifier for each event
{% enddocs %}

{% docs event_source %}
Application source for event (eg. Phoenix, Northstar)
{% enddocs %}

{% docs event_datetime %}
When the event occurred in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs event_name %}
Name of the event (eg. northstar_submitted_register, https://docs.google.com/spreadsheets/d/1lm-fGrIm85nUTxSojqyCt_Ehmm1zEbViFhKpxcJiz1A/edit#gid=406441516)
{% enddocs %}

{% docs event_type %}
Type of event (pv = 'Page View', se = 'Structured Event')
{% enddocs %}

{% docs host %}
URL host where event occurred (eg. www.dosomething.org or identity.dosomething.org)
{% enddocs %}

{% docs path %}
URL path event occurred at (eg. /login or /us/campaigns/huddle-for-heroes)
{% enddocs %}

{% docs query_parameters %}
Optional query parameters for the request (eg. query=huddle)
{% enddocs %}

{% docs se_category %}
Category of event (eg. focused_field, authentication) - Custom structured event
{% enddocs %}

{% docs se_action %}
Action performed / event name (eg. form_submitted, action_failed) - Custom structured event
{% enddocs %}

{% docs se_label %}
The object of the action (eg. first_name, register, voter_reg_status) - Custom structured event
{% enddocs %}

{% docs session_id %}
Unique identifier of the user's session
{% enddocs %}

{% docs session_counter %}
How many sessions a user has started
{% enddocs %}

{% docs browser_size %}
Which type of browser a user is using (eg. Mobile, Desktop)
{% enddocs %}

{% docs northstar_id %}
The Northstar ID of the user who generated the event
{% enddocs %}

{% docs device_id %}
ID of the device used
{% enddocs %}

{% docs referrer_host %}
URL host of the referring site (eg. google.com)
{% enddocs %}

{% docs referrer_path %}
URL path from referring site (eg. /10-stats-on-teen-drug-and-alcohol-use/)
{% enddocs %}

{% docs referrer_source %}
Referrer source name (eg. Google, Facebook)
{% enddocs %}

{% docs utm_source %}
Tracks where the traffic is coming from. (eg. scholarship_listing, Facebook)
{% enddocs %}

{% docs utm_medium %}
How the traffic got to the platform (eg. referral, CPC)
{% enddocs %}

{% docs utm_campaign %}
Tracks which campaign the traffic was generated by. Shows up in Google Analytics as Campaign Name (eg. editorial_newsletter)
{% enddocs %}

{% docs url %}
URL of campaign (eg. https://dosome.click/nyn5m7)
{% enddocs %}

{% docs modal_type %}
NULL or SURVEY_MODAL
{% enddocs %}

{% docs landing_datetime %}
When the session started in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs ending_datetime %}
When the session ended in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs session_duration_seconds %}
Session duration in seconds
{% enddocs %}

{% docs num_pages_views %}
Number of pages viewed in session
{% enddocs %}

{% docs landing_page %}
First page the user viewed in the session (eg. /us/facts/11-facts-about-bp-oil-spill)
{% enddocs %}

{% docs exit_page %}
"Which page the user ended or exited their session from (eg. /us/campaigns/green-your-getaway)"
{% enddocs %}

{% docs days_since_last_session %}
"Days since their last session."
{% enddocs %}

{% docs post_type %}
Type of post, (e.g. photo, voter-reg)
{% enddocs %}

{% docs noun %}
Noun that corresponds to the item in the call to action that was delivered. (e.g. drawings, tweets)
{% enddocs %}

{% docs verb %}
Verb corresponding to the action the user took. (e.g. shared, sent, taken)
{% enddocs %}

{% docs deleted_at %}
Date time in UTC when a user deleted their post.
{% enddocs %}

{% docs _fivetran_deleted %}
 marks rows that were deleted in the source table
{% enddocs %}

{% docs _fivetran_synced %}
(UTC timestamp) keeps track of when each row was last successfully synced
{% enddocs %}

{% docs reportback %}
Whether the post is a reportback 
{% enddocs %}

{% docs active %}
Whether the user is active 
{% enddocs %}

{% docs anonymous %}
Whether the user is anonymous when making the post 
{% enddocs %}

{% docs callpower_campaign_id %}
Unique ID corresponding to the Callpower campaign. Callpower allows users to record messages for their representatives.
{% enddocs %}

{% docs quiz %}
Whether the post is a quiz 
{% enddocs %}

{% docs action_type %}
Type of action the user took. (e.g. share-something, donate-something)
{% enddocs %}

{% docs online %}
Whether the action is a online as opposed to IRL.
{% enddocs %}

{% docs time_commitment %}
Estimated time required to do the action (e.g. 3.0+, <0.5)
{% enddocs %}


{% docs num_signups %}
Quantity of campaign signups
{% enddocs %}

{% docs most_recent_signup %}
Timestamp of the most recent signup in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs num_rbs %}
Quantity of reportbacks for the user
{% enddocs %}

{% docs total_quantity %}
Total quantity of items in reportbacks
{% enddocs %}

{% docs most_recent_rb %}
When the most recent reportback occurred in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs first_rb %}
When the first reportback occurred in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs avg_time_betw_rbs %}
Calculated average time between reportbacks.
{% enddocs %}

{% docs avg_days_next_action_after_rb %}
Calculated average days until next action after reportback
{% enddocs %}

{% docs days_to_next_action_after_last_rb %}
This is a unique identifier for each event
{% enddocs %}

{% docs most_recent_mam_action %}
Most recent monthly active member qualifying action in UTC (eg. 2018-01-01 12:00:00).
{% enddocs %}

{% docs most_recent_email_open %}
Most recent email open in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs most_recent_all_actions %}
Most recent timestamp of any action in UTC (eg. 2018-01-01 12:00:00)
{% enddocs %}

{% docs last_action_is_rb %}
Whether the last action the user took was a reportback
{% enddocs %}

{% docs days_since_last_action %}
Days since the user's last action
{% enddocs %}

{% docs time_to_first_rb %}
How much time after registering until the user's first reportback
{% enddocs %}

{% docs sms_unsubscribed_at %}
Timestamp of when user unsubscribed from SMS messaging
{% enddocs %}

{% docs user_unsubscribed_at %}
Timestamp of when user unsubscribed from email or sms
{% enddocs %}

{% docs voter_reg_acquisition %}
Whether the user was an acquisition through voter registration efforts. 
{% enddocs %}

{% docs last_logged_in %}
Date time in UTC when user last logged in to Northstar
{% enddocs %}

{% docs last_accessed %}
Date time in UTC when user last access the website
{% enddocs %}

{% docs last_messaged_at %}
Date time in UTC when user was last sent a message via SMS or email
{% enddocs %}

{% docs facebook_id %}
User's facebook id
{% enddocs %}

{% docs mobile %}
Users's mobile phone number
{% enddocs %}

{% docs birthdate %}
User's birthdate
{% enddocs %}

{% docs first_name %}
User's first name
{% enddocs %}

{% docs last_name %}
User's last name
{% enddocs %}

{% docs voter_registration_status %}
User's registration status. (e.g. registration_complete, confirmed, uncertain) 
{% enddocs %}

{% docs address_street_1 %}
First line of user's street address
{% enddocs %}

{% docs address_street_2 %}
Second line of user's street address
{% enddocs %}

{% docs city %}
User's city
{% enddocs %}

{% docs state %}
User's state
{% enddocs %}

{% docs country %}
User's country
{% enddocs %}

{% docs language %}
User's language
{% enddocs %}

{% docs cio_status %}
Status of user from CIO. (e.g. customer_subscribed, customer_unsubscribed)
{% enddocs %}

{% docs cio_status_timestamp %}
Timestamp when users's status was updated.
{% enddocs %}

{% docs sms_status %}
Current SMS status. (e.g. undeliverable, unknown)
{% enddocs %}

{% docs source_detail %}
Details of the origin of the user. (e.g. tell_a_friend, other, opt_in_path/197981)
{% enddocs %}

{% docs badges %}
Whether the user has any badges. 
{% enddocs %}

{% docs refer_friends %}
Whether the user is a part of the refer a friend campaign. 
{% enddocs %}

{% docs subscribed_member %}
Whether the user is subscribed. 
{% enddocs %}

{% docs last_updated_at %}
Timestamp when users's was updated.
{% enddocs %}

{% docs school_id %}
Unique identifier for the user's school. This info comes from the school finder.
{% enddocs %}

{% docs newsletter_topic %}
Newsletter topic. (e.g. community, lifestyle)
{% enddocs %}

{% docs user_agent %}
Full user agent string for a user's browser (e.g. "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:24.0) Gecko/20100101 Firefox/24.0")
{% enddocs %}

