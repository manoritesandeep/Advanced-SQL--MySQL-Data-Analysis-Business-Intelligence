select 
	is_repeat_session,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    sum(o.price_usd) as total_revenue
from website_sessions ws
	left join orders o
		on ws.website_session_id = o.website_session_id
where ws.created_at between '2014-01-01' and '2014-11-08'
group by 1;