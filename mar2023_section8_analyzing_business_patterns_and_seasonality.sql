-- Section 8: Analyzing Business Patterns and Seasonality
use mavenfuzzyfactory;

-- Business Concept: Analyzing seasonality and business patterns
/*
Analyzing business patterns is about generating insights to help you maximize efficiency and anticipate future trends

Common use cases: 
	- Day-parting analysis to understand how much support staff you should have at different times of day or days of the week
    - Analyzing seasonality to better prepare for upcoming spikes or slowdowns in demand
*/

select 
	website_session_id,
    created_at,
    hour(created_at) as hr,
    weekday(created_at) as wkday,
    case
		when weekday(created_at) = 0 then 'monday'
        when weekday(created_at) = 1 then 'tuesday'
        when weekday(created_at) = 2 then 'wednesday'
        when weekday(created_at) = 3 then 'thur'
        when weekday(created_at) = 4 then 'fri'
        when weekday(created_at) = 5 then 'sat'
		when weekday(created_at) = 6 then 'sunday'
	end as clean_weekday,
    quarter(created_at) as qtr,
    month(created_at) as mo,
    date(created_at) as dt,
    week(created_at) as wk
from website_sessions
where website_session_id between 150000 and 155000;