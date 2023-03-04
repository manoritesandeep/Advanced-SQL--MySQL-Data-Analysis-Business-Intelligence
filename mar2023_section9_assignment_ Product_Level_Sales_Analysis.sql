select 
	year(created_at) as yr,
	month(created_at) as mo,
    count(order_id) as num_sales,
    sum(price_usd) as revenue,
    sum(price_usd - cogs_usd)as margin
from orders
where created_at < '2013-01-04'
group by 1,2
order by 1,2;