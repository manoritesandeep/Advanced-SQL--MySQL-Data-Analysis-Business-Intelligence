select 
	year(ws.created_at) as yr,
    month(ws.created_at) as mo,
    min(date (ws.created_at)) as week_start_date,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders
from website_sessions ws
	left join orders o
		on o.website_session_id = ws.website_session_id
where ws.created_at < '2013-01-01'
group by 1,2;

-- On a weekly basis

select 
	year(ws.created_at) as yr,
    week(ws.created_at) as wk,
	min(date (ws.created_at)) as week_start_date,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders
from website_sessions ws
	left join orders o
		on o.website_session_id = ws.website_session_id
where ws.created_at < '2013-01-01'
group by 1,2;