select 
	year(ws.created_at) as yr,
    month(ws.created_at) as mo,
	count(distinct o.order_id) as orders,
    -- count(distinct ws.website_session_id) as sessions
    count(distinct o.order_id) / count(distinct ws.website_session_id) as conv_rate,
    sum(o.price_usd) / count(distinct ws.website_session_id) as revenue_per_session,
    count(distinct case when o.primary_product_id = 1 then o.order_id else null end) as product_one_orders,
    count(distinct case when o.primary_product_id = 2 then o.order_id else null end) as product_two_orders
from website_sessions ws
	left join orders o
		on o.website_session_id = ws.website_session_id
where ws.created_at between '2012-04-01' and '2013-04-05'
group by 1,2
order by 1,2;