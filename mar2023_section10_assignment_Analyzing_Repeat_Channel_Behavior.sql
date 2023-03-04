select 
	utm_source,
    utm_campaign,
    http_referer,
    count(case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
    count(case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
from website_sessions
where created_at between '2014-01-01' and '2014-11-05'
group by 1,2,3
order by 5 desc;

select 
	case
		when utm_source IS NULL and http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') then 'organic'
        when utm_campaign  = 'nonbrand' then 'paid_nonbrand'
        when utm_campaign = 'brand' then 'paid_brand'
        when utm_source IS NULL AND http_referer IS NULL then 'direct_type_in'
        when utm_source = 'socialbook' then 'paid_social'
	end as channel_group,
-- 	utm_source,
--     utm_campaign,
--     http_referer,
    count(case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
    count(case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
from website_sessions
where created_at between '2014-01-01' and '2014-11-05'
group by 1
order by 3 desc;