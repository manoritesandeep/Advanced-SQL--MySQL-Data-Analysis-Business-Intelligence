USE mavenfuzzyfactory;
-- Section 5: Analyzing Website Performance

SELECT * FROM website_pageviews where website_pageview_id < 1000;

select pageview_url,
	count(distinct website_pageview_id) as pvs
from website_pageviews
where website_pageview_id < 1000
group by 1
order by 2 DESC;

DROP TABLE first_pageview;

CREATE TEMPORARY TABLE first_pageview
SELECT 
	website_session_id,
    min(website_pageview_id) as min_pv_id
from website_pageviews
where website_pageview_id < 1000
group by 1;

SELECT 
	wp.pageview_url  as landing_page,
    count(distinct fp.website_session_id)
from first_pageview as fp
	left join website_pageviews as wp
		on fp.min_pv_id = wp.website_pageview_id
group by 1;

-- Landing page analysis

-- Step 1: Find the first website_pageview_id for relevant sessions
-- Step 2: Identify the landing page of each session
-- Step 3: counting the pageview for each session, to identify "bounces"
-- Step 4: summarizing total sessions and bounced sessions, by LP

-- finding the minimum website pageview id associated with each session we care about
select 
	wp.website_session_id,
    min(wp.website_pageview_id) as min_pageview_id
from website_pageviews as wp
	Inner join website_sessions as ws
		on wp.website_session_id = ws.website_session_id
        and ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
group by 1;

-- Store above query as a temp table
create temporary table if not exists first_pageview_demo
select 
	wp.website_session_id,
    min(wp.website_pageview_id) as min_pageview_id
    -- website pageview is the landing page
from website_pageviews as wp
	INNER JOIN website_sessions as ws
		ON ws.website_session_id = wp.website_session_id
        and ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
group by 1;

select * from first_pageview_demo;

-- Next, bring in the landing page to each session
create temporary table if not exists sessions_w_landing_page_demo
select 
	fpd.website_session_id,
	wp.pageview_url as landing_page
from first_pageview_demo as fpd
	left join website_pageviews as wp
		on fpd.min_pageview_id = wp.website_pageview_id;
        -- website pageview is the landing page
-- drop table sessions_w_landing_page_demo;
select * from sessions_w_landing_page_demo;

-- Next, creat a table to include a count of pageviews per session

select 
	sl.website_session_id,
    sl.landing_page,
    count(distinct wp.website_pageview_id) as count_of_pages_viewed
from sessions_w_landing_page_demo as sl
	left join website_pageviews as wp
		on wp.website_session_id = sl.website_session_id
group by 1,2;

create temporary table if not exists bounced_sessions_only
select 
	sl.website_session_id,
    sl.landing_page,
    count(distinct wp.website_pageview_id) as count_of_pages_viewed
from sessions_w_landing_page_demo as sl
	left join website_pageviews as wp
		on wp.website_session_id = sl.website_session_id
group by 1,2
having count(wp.website_pageview_id)=1;

-- drop table bounced_sessions_only;
select * from bounced_sessions_only;

select 
	sl.landing_page,
    sl.website_session_id,
    bs.website_session_id as bounced_sessions_id
from sessions_w_landing_page_demo as sl
	LEFT join bounced_sessions_only as bs
		on bs.website_session_id = sl.website_session_id
order by 2;

-- Final output : run same query, do a count on records and group by landing page then add bounce rate column

select 
	sl.landing_page,
    count(distinct sl.website_session_id) as total_sessions,
    count(distinct bs.website_session_id) as bounced_sessions,
    count(distinct bs.website_session_id) / count(distinct sl.website_session_id) as bounce_rate
from sessions_w_landing_page_demo as sl
	Left join bounced_sessions_only as bs
		on bs.website_session_id = sl.website_session_id
group by 1
order by 4 DESC;
