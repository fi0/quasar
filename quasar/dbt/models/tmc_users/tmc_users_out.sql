SELECT first_name, 
       last_name, 
       address_street_1, 
       address_street_2,
       city,
       state,
       zipcode,
       mobile,
       email,
       northstar_id
FROM {{ ref('users') }}
