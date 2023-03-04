select 
	case
		when ws.created_at < '2013-12-12' then 'A. Pre_birthday_bear'
        when ws.created_at >= '2013-12-12' then 'B. Post_birthday_bear'
        else 'check logic'
	end as time_period,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id)/count(distinct ws.website_session_id) as conv_rate,
    sum(o.price_usd) as total_revenue,
    sum(o.items_purchased) as total_products_sold,
    sum(o.price_usd) / count(distinct o.order_id) as avg_order_value,
    sum(items_purchased) /count(distinct o.order_id) as products_per_order,
    sum(o.price_usd)/count(distinct ws.website_session_id) as revenue_per_session
from website_sessions ws
	left join orders o
		on ws.website_session_id = o.website_session_id
where ws.created_at between '2013-11-12' and '2014-01-12'
group by 1;