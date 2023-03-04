-- Step 1: find the relevant /products pageviews with website_session_id
-- Step 2: find the next pageview_id that occurs AFTER the product pageview
-- Step 3: find the pageview_url associated with any applicable next pageview_id
-- Step 4: Summarize the data and analyze the pre vs post periods

create temporary table if not exists product_pageviews
select 
	website_session_id,
    website_pageview_id,
    created_at,
    case
		when created_at < '2013-01-06' then 'A. Pre_product_2'
        when created_at >= '2013-01-06' then 'B. Post_product_2'
        else 'check logic'
	end as time_period
from website_pageviews
where created_at > '2012-10-06' and created_at < '2013-04-06'
	and pageview_url = '/products';
    
select * from product_pageviews;


-- Step 2: find the next pageview_id that occurs AFTER the product pageview
create temporary table if not exists sessions_w_next_pageview_id
select
	pp.time_period,
    pp.website_session_id,
    min(wp.website_pageview_id) as min_next_pageview_id
from product_pageviews pp
	left join website_pageviews wp
		on pp.website_session_id = wp.website_session_id
        and wp.website_pageview_id > pp.website_pageview_id
group by 1,2;

select * from sessions_w_next_pageview_id;

-- Step 3: find the pageview_url associated with any applicable next pageview_id
create temporary table if not exists sessions_w_next_pageview_url
select 
	sp.time_period,
    sp.website_session_id,
    wp.pageview_url as next_pageview_url
from sessions_w_next_pageview_id sp
	left join website_pageviews wp
		on wp.website_pageview_id = sp.min_next_pageview_id;

select * from sessions_w_next_pageview_url;

-- Step 4: Summarize the data and analyze the pre vs post periods

select 
	time_period,
    count(distinct website_session_id) as sessions,
    count(distinct case when next_pageview_url IS NOT NULL then website_session_id else null end) as w_next_pg,
    count(distinct case when next_pageview_url IS NOT NULL then website_session_id else null end)
    / count(distinct website_session_id) as pct_w_next_pg,
    count(distinct case when next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end) as to_fuzzy,
    count(distinct case when next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end)
    / count(distinct website_session_id) as pct_to_fuzzy,
	count(distinct case when next_pageview_url = '/the-forever-love-bear' then website_session_id else null end) as to_fuzzy,
    count(distinct case when next_pageview_url = '/the-forever-love-bear' then website_session_id else null end)
    / count(distinct website_session_id) as pct_to_lovebear
from sessions_w_next_pageview_url
group by 1;
