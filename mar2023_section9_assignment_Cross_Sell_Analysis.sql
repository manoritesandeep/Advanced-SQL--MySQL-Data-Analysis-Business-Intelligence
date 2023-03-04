-- Step 1: Identify the relevant /cart page views and thier sessions
-- Step 2: see which of those /cart sessions clicked through to the shipping page
-- Step 3: find the orders associated with the /cart sessions. Analyze products purchased, AOV
-- Step 4: aggregate and analyze a summary of your findings.

create temporary table if not exists sessions_seeing_cart
select 
	case 
		when created_at < '2013-09-25' then 'A. Pre_cross_sell'
        when created_at >= '2013-01-06' then 'B. Post_cross_sell'
        else 'check logic'
	end as time_period,
    website_session_id as cart_session_id,
    website_pageview_id as cart_pageview_id
from website_pageviews
where created_at between '2013-08-25' and '2013-10-25'
	and pageview_url = '/cart';

-- Step 2: see which of those /cart sessions clicked through to the shipping page

create temporary table if not exists cart_sessions_seeing_another_page
select 
	sc.time_period,
    sc.cart_session_id,
    min(wp.website_pageview_id) as pv_id_after_cart
from sessions_seeing_cart sc
	left join website_pageviews wp
		on sc.cart_session_id = wp.website_session_id
			and wp.website_pageview_id > sc.cart_pageview_id
group by 1,2
having min(wp.website_pageview_id) is not null;

select * from cart_sessions_seeing_another_page;

create temporary table if not exists pre_post_sessions_orders
select 
	time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
from sessions_seeing_cart sc
	inner join orders o
		on sc.cart_session_id = o.website_session_id;
        
select * from pre_post_sessions_orders;


select 
	sc.time_period,
    sc.cart_session_id,
    case when cs.cart_session_id IS NULL then 0 else 1 end as clicked_to_another_page,
    case when ps.order_id IS NULL then 0 else 1 end as placed_order,
    ps.items_purchased,
    ps.price_usd
from sessions_seeing_cart sc
	left join cart_sessions_seeing_another_page cs
		on sc.cart_session_id = cs.cart_session_id
	left join pre_post_sessions_orders ps
		on sc.cart_session_id = ps.cart_session_id
order by 2;

select
	time_period,
    count(distinct cart_session_id) as cart_sessions,
    sum(clicked_to_another_page) as clickthroughs,
    sum(clicked_to_another_page)/count(distinct cart_session_id) as cart_ctr,
--     sum(placed_order) as orders_placed,
--     sum(items_purchased) as products_purchased,
    sum(items_purchased)/sum(placed_order) as products_per_order,
    -- sum(price_usd) as revenue,
    sum(price_usd)/sum(placed_order) as aov,
    sum(price_usd)/count(distinct cart_session_id) as rev_per_cart_session
from (
select 
	sc.time_period,
    sc.cart_session_id,
    case when cs.cart_session_id IS NULL then 0 else 1 end as clicked_to_another_page,
    case when ps.order_id IS NULL then 0 else 1 end as placed_order,
    ps.items_purchased,
    ps.price_usd
from sessions_seeing_cart sc
	left join cart_sessions_seeing_another_page cs
		on sc.cart_session_id = cs.cart_session_id
	left join pre_post_sessions_orders ps
		on sc.cart_session_id = ps.cart_session_id
order by 2
) as full_data
group by time_period;