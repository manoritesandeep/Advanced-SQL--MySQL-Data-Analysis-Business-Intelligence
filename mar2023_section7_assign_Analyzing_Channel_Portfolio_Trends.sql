-- select * from website_sessions limit 10;

select
--     device_type,
--     utm_source,
    -- yearweek(created_at) as yearwk,
    min(date (created_at)) as week_start_date,
    -- count(distinct website_session_id) as sessions,
--     count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_sessions,
--     count(distinct case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_sessions,
-- 	count(distinct case when utm_source = 'bsearch' then website_session_id else null end)
--         / count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as percent_b_of_g
	count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as g_dtop_sessions,
    count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) as b_dtop_sessions,
	count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) 
    / count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as b_pct_of_g_dtop,
    count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as g_mob_sessions,
    count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) as b_mob_sessions,
    count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end)
    / count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as b_pct_of_g_mob
from website_sessions ws
where created_at between '2012-11-04' and '2012-12-22'
	and ws.utm_campaign = 'nonbrand'
group by yearweek(created_at)
order by 1;
    
