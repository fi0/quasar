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
(boolean) marks rows that were deleted in the source table
{% enddocs %}

{% docs _fivetran_synced %}
(UTC timestamp) keeps track of when each row was last successfully synced
{% enddocs %}

{% docs reportback %}
Whether the post is a reportback (boolean)
{% enddocs %}

{% docs civic_action %}
Whether the post is a civic_action (boolean)
{% enddocs %}

{% docs scholarship_entry %}
Whether the post is a scholarship_entry (boolean)
{% enddocs %}

{% docs active %}
Whether the user is active (boolean)
{% enddocs %}

{% docs anonymous %}
Whether the user is anonymous when making the post (boolean)
{% enddocs %}

{% docs callpower_campaign_id %}
Unique ID corresponding to the Callpower campaign. Callpower allows users to record messages for their representatives.
{% enddocs %}

{% docs quiz %}
Whether the post is a quiz (boolean)
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

