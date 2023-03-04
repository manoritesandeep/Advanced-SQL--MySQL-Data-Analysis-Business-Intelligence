use mavenfuzzyfactory;

/*
1. show vol. growth. 
*/

select 
	year(ws.created_at) as yr,
    quarter(ws.created_at) as qtr,
	count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders
from website_sessions ws
	left join orders o
		on ws.website_session_id = o.website_session_id
group by 1,2
order by 1,2;


/*
2. efficiency improvements. Show quaterly figures since launch for session-to-order conv_rate, revenue per order,
and revenue per session
*/

select 
	year(ws.created_at) as yr,
    quarter(ws.created_at) as qtr,
-- 	count(distinct ws.website_session_id) as sessions,
--     count(distinct o.order_id) as orders,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as session_to_order_conv_rate,
    sum(o.price_usd)/count(distinct o.order_id) as revenue_per_order,
    sum(o.price_usd)/count(distinct ws.website_session_id) as revenue_per_session
from website_sessions ws
	left join orders o
		on ws.website_session_id = o.website_session_id
group by 1,2
order by 1,2;


/*
3. pull quaterly view of orders from gsearch nonbrand, bsearch nonbrand, brand search overall
	organic search and direct type in?
*/
select 
	year(ws.created_at) as yr,
    quarter(ws.created_at) as qtr,
    count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as gsearch_nonbrand_orders,
    count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as bsearch_nonbrand_orders,
	count(distinct case when utm_campaign = 'brand' then o.order_id else null end) as brand_search_orders,
    count(distinct case when utm_source IS NULL and http_referer IS NOT NULL then o.order_id else null end) as organic_search_orders,
	count(distinct case when utm_source IS NULL and http_referer IS NULL then o.order_id else null end) as direct_type_in_orders
from website_sessions ws
	left join orders o
		on ws.website_session_id = o.website_session_id
group by 1,2
order by 1,2;


/*
4. show overall session-to-order conv_rate trends for same channels, by quater. 
*/
select 
	year(ws.created_at) as yr,
    quarter(ws.created_at) as qtr,
    count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then o.order_id else null end)
    / count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then ws.website_session_id else null end) as gsearch_nonbrand_conv_rt,
    count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) 
	/ count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then ws.website_session_id else null end) as bsearch_nonbrand_orders,
	count(distinct case when utm_campaign = 'brand' then o.order_id else null end) 
    /count(distinct case when utm_campaign = 'brand' then ws.website_session_id else null end) as brand_search_conv_rt,
    count(distinct case when utm_source IS NULL and http_referer IS NOT NULL then o.order_id else null end) 
    /count(distinct case when utm_source IS NULL and http_referer IS NOT NULL then ws.website_session_id else null end) as organic_search_conv_rt,
	count(distinct case when utm_source IS NULL and http_referer IS NULL then o.order_id else null end)
    / count(distinct case when utm_source IS NULL and http_referer IS NULL then ws.website_session_id else null end) as direct_type_in_conv_rt
from website_sessions ws
	left join orders o
		on ws.website_session_id = o.website_session_id
group by 1,2
order by 1,2;

/*
5. Pull monthly trends for revenue and margin by product along with total sales and revenue.
	Note anything you notice about seasonality.
*/

select 
	year(o.created_at) as yr,
    month(o.created_at) as mo,
    sum(case when o.primary_product_id = 1 then o.price_usd else null end) as fuzzy_rev,
    sum(case when o.primary_product_id = 1 then o.price_usd - o.cogs_usd else null end) as fuzzy_margin,
    sum(case when o.primary_product_id = 2 then o.price_usd else null end) as lovebear_rev,
    sum(case when o.primary_product_id = 2 then o.price_usd - o.cogs_usd else null end) as lovebear_margin,
    sum(case when o.primary_product_id = 3 then o.price_usd else null end) as bdaybear_rev,
    sum(case when o.primary_product_id = 3 then o.price_usd - o.cogs_usd else null end) as bdaybear_margin,
    sum(case when o.primary_product_id = 4 then o.price_usd else null end) as minibear_rev,
    sum(case when o.primary_product_id = 4 then o.price_usd - o.cogs_usd else null end) as minibear_margin,
    sum(o.price_usd) as total_revenue,
    sum(o.price_usd - o.cogs_usd) as total_margin
from orders o
group by 1,2
order by 1,2;


/*
6. Introducing new products. Pull monthly sessions to the /products page, and show how the % of those sessions clicking
	through another page has changed over time, along with a view of how conversion from /products to placing an
    order has improved.
*/

create temporary table products_pageviews
select 
	website_session_id, 
    website_pageview_id,
	created_at as saw_product_page_at
from website_pageviews
where pageview_url = '/products';

select 
	year(pp.saw_product_page_at) as yr,
    month(pp.saw_product_page_at) as mo,
    count(distinct pp.website_session_id) as sessions_to_product_page,
    count(distinct wp.website_session_id) as clicked_to_next_page,
    count(distinct wp.website_session_id)/count(distinct pp.website_session_id) as clickthrough_rt,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id)/count(distinct pp.website_session_id) as products_to_order_rt
from products_pageviews pp
	left join website_pageviews wp
		on wp.website_session_id = pp.website_session_id
        and wp.website_pageview_id > pp.website_pageview_id
	left join orders o
		on o.website_session_id = pp.website_session_id
group by 1,2;