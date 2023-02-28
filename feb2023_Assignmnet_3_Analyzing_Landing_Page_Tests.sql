USE mavenfuzzyfactory;

-- Step 1: Find out when the new page /lander launched
-- Step 2: find the first website_pageview_id for relevant sessions
-- Step 3: Identify the landing page for each session
-- Step 4: Counting pageviews for each session, to identify 'bounces'
-- Step 5: Summarizing total sessions, bounced sessions and bounce rate by LP (landing page)

-- find the first instance of /lander-1 to set analysis timeframe
select 
	created_at,
    pageview_url
from website_pageviews
where pageview_url = '/lander-1'
order by created_at asc; -- 2012-06-19

select 
	min(created_at) as first_date,
	min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url = '/lander-1'
and created_at IS NOT NULL;

create table if not exists first_pageview
select 
	wp.website_session_id,
    min(wp.website_pageview_id) as min_pv_id
from website_pageviews as wp
	inner join website_sessions as ws
		on ws.website_session_id = wp.website_session_id
	AND ws.created_at between '2012-06-19' AND '2012-07-28'
	AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
group by 1;

-- drop table first_pageview;
select * from first_pageview;

-- get landing page 
create table if not exists sessions_w_landing_page
select 
	fp.website_session_id,
    wp.pageview_url as landing_page
from first_pageview fp
	left join website_pageviews wp
		on wp.website_pageview_id = fp.min_pv_id
where wp.pageview_url IN ('/home','/lander-1');

-- drop table sessions_w_landing_page;
select * from sessions_w_landing_page;
select distinct(landing_page) from sessions_w_landing_page;

-- have a table of count of pageviews per session then limit it to bounced session
create table if not exists bounced_sessions
select 
	sl.website_session_id,
    sl.landing_page,
    count(distinct wp.website_pageview_id) as count_of_pages_viewed
from sessions_w_landing_page sl
	left join website_pageviews wp
		on sl.website_session_id = wp.website_session_id
group by 1,2
having count(wp.website_pageview_id) = 1;

-- drop table bounced_sessions;
select * from bounced_sessions;
select * from sessions_w_landing_page limit 10;

select 
	sl.landing_page,
    count(distinct sl.website_session_id) as sessions,
    count(distinct bs.website_session_id) as bounced_sessions,
	count(distinct bs.website_session_id)/count(distinct sl.website_session_id) as bounce_rate
from sessions_w_landing_page sl
	left join bounced_sessions bs
		on sl.website_session_id = bs.website_session_id
group by 1
order by 2;
