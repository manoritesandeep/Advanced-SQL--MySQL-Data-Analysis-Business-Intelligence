select 
	ws.device_type,
    ws.utm_source,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as conv_rate
from website_sessions ws
	left join orders o
		on o.website_session_id = ws.website_session_id
where ws.created_at between '2012-08-22' and '2012-09-18'
	and  ws.utm_campaign = 'nonbrand'
group by 1,2;