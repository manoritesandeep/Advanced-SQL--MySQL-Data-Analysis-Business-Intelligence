-- Business Concept - Product Sales Analysis

/*
Analysing product sales helps you understand how each product contributes to your business,
and how product launches impact the overall portfolio

Common use cases: 
	- Analyzing sales and revenue by product
    - Monitoring the impact of adding a new product to your product portfolio 
    - Watchin product sales trends to understand the overall health of your business
    
Orders - number of orders placed by customers count(order_id)
Revenue - Money the business brings in from orders sum(price_usd)
Margin - Revenue less the cost of goods sold sum(price_usd - cogs_usd)
AOV - Average revenue generated per order AVG(price_usd)
*/

use mavenfuzzyfactory;

select 
	count(order_id) as orders,
    sum(price_usd) as revenue,
    sum(price_usd - cogs_usd) as margin,
    avg(price_usd) as avg_order_value
from orders
where order_id between 100 and 200;

select 
	primary_product_id,
	count(order_id) as orders,
    sum(price_usd) as revenue,
    sum(price_usd - cogs_usd) as margin,
    avg(price_usd) as aov
from orders
where order_id between 10000 and 11000
group by 1
order by 2 desc;

-- Business concept: Product level website analysis
/*
Product-focused website analysis is about learning how customers interact with each of your products,
and how well each product converts customers

Common use cases:
	- Understanding which of your products generate the most interest on multi-product showcase pages
    - Analyzing the impact on website conversion rates when you add a new product
    - Building product-specific conversion funnels to understand whether certain products convert better than others
*/

select distinct 
pageview_url
from website_pageviews
where created_at between '2013-02-01' and '2013-03-01';

select 
	pageview_url,
    count(distinct wp.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id)/count(distinct wp.website_session_id) as viewed_product_to_order_rate
from website_pageviews wp
	left join orders o
		on o.website_session_id = wp.website_session_id
where wp.created_at between '2013-02-01' and '2013-03-01'
	and wp.pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear')
group by 1;

-- Business Concept: Cross-selling products
/*
Cross-sell analysis is about understanding which products users are most likely to purchase together,
and offering smart product recommendations

Commom use cases:
	- Understanding which products are often purchased together
    - Testing and optimizing the way you cross-sell products on your website
    - Understanding the conversion rate impact and the overall revenue impact of trying to cross-sell additional products
*/

select 
	o.primary_product_id,
    -- oi.product_id as cross_sell_product,
    count(distinct o.order_id) as orders,
    count(distinct case when oi.product_id = 1 then o.order_id else null end) as cross_sell_prod1,
    count(distinct case when oi.product_id = 2 then o.order_id else null end) as cross_sell_prod2,
    count(distinct case when oi.product_id = 3 then o.order_id else null end) as cross_sell_prod3,
    
    count(distinct case when oi.product_id = 1 then o.order_id else null end)/count(distinct o.order_id) as cross_sell_prod1_rt,
    count(distinct case when oi.product_id = 2 then o.order_id else null end)/count(distinct o.order_id) as cross_sell_prod2_rt,
    count(distinct case when oi.product_id = 3 then o.order_id else null end)/count(distinct o.order_id) as cross_sell_prod3_rt
from orders o
	left join order_items oi
		on oi.order_id = o.order_id
			and oi.is_primary_item = 0 -- cross sell only
where o.order_id between 10000 and 11000
group by 1;

-- Business Concept: Product refund analysis
/*
Analyzing produc refund rates is about controlling for quality and understanding where you might have problems to address

Common use cases: 
	- Monitoring products from different suppliers
    - Understanding refund rates for products at different price points
    - Taking product refund rates and the associated costs into account when assessing the overall performance of the business
*/

select 
	oi.order_id,
    oi.order_item_id,
    oi.price_usd as price_paid_usd,
    oi.created_at,
    oir.order_item_refund_id,
    oir.refund_amount_usd,
    oir.created_at
from order_items oi
	left join order_item_refunds oir
		on oir.order_item_id = oi.order_item_id
where oi.order_id in (3489,32049,27061);