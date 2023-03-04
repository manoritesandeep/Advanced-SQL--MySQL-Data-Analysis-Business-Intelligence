-- Step 1: select all pageviews for relevant sessions
-- Step 2: figure our which pageview urls to look for
-- Step 3: pull all pageviews and identify the funnel steps
-- Step 4: create the session-level conversion funnel view
-- Step 5: aggregate the data to assess funnel performance

create temporary table if not exists sessions_seeing_product_pages
select 
	website_session_id,
    website_pageview_id,
    pageview_url as product_page_seen
from website_pageviews
where created_at < '2013-04-10' and created_at > '2013-01-06'
	and pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear');
    
select * from sessions_seeing_product_pages;

-- Step 2: figure our which pageview urls to look for

select distinct
    wp.pageview_url 
from sessions_seeing_product_pages sp
	left join website_pageviews wp
		on wp.website_session_id = sp.website_session_id
			and wp.website_pageview_id > sp.website_pageview_id;
            
/*
/cart
/shipping
/billing-2
/thank-you-for-your-order
*/

-- Step 3: pull all pageviews and identify the funnel steps

-- inner query
select 
	sp.website_session_id,
    sp.product_page_seen,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = '/billing-2' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from sessions_seeing_product_pages sp
	left join website_pageviews wp
		on sp.website_session_id = wp.website_session_id
			and wp.website_pageview_id > sp.website_pageview_id
order by 1,wp.created_at;

create temporary table if not exists session_product_level_made_it_flags
select 
	website_session_id,
    case
		when product_page_seen = '/the-original-mr-fuzzy' then 'fuzzy'
        when product_page_seen = '/the-forever-love-bear' then 'lovebear'
        else 'logic error'
	end as product_seen,
    max(cart_page) as cart_made_it,
    max(shipping_page) as shipping_made_it,
    max(billing_page) as billing_made_it,
    max(thankyou_page) as thankyou_made_it
from 
(
select 
	sp.website_session_id,
    sp.product_page_seen,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when pageview_url = '/billing-2' then 1 else 0 end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from sessions_seeing_product_pages sp
	left join website_pageviews wp
		on sp.website_session_id = wp.website_session_id
			and wp.website_pageview_id > sp.website_pageview_id
order by 1,wp.created_at
) as pageview_level
group by 1,2;

select * from session_product_level_made_it_flags;

-- Step 4: create the session-level conversion funnel view
select 
	product_seen,
	count(distinct website_session_id) as sessions,
    count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) as to_billing,
    count(distinct case when thankyou_made_it = 1 then website_session_id else null end) as to_thankyou
from session_product_level_made_it_flags
group by 1;

-- Step 5: aggregate the data to assess funnel performance
-- translate counts to click rates for final output part 2 (click rates)

select 
	product_seen,
    count(distinct website_session_id) as sessions,
    count(distinct case when cart_made_it = 1 then website_session_id else null end) 
    / count(distinct website_session_id) as product_page_click_rt,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end)
    / count(distinct case when cart_made_it = 1 then website_session_id else null end) as cart_click_rt,
    count(distinct case when billing_made_it = 1 then website_session_id else null end)
    / count(distinct case when shipping_made_it = 1 then website_session_id else null end) as shipping_click_rt,
    count(distinct case when thankyou_made_it = 1 then website_session_id else null end)
    / count(distinct case when billing_made_it = 1 then website_session_id else null end) as billing_click_rt
from session_product_level_made_it_flags
group by 1;