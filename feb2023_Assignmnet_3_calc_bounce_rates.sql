-- Step 1: get min website_pageview_id.. 
-- website pageview is the landing page
-- get websessions relating to first_pageviews
-- step 2: find landing page fore each session
-- step 3: counting pageviews for each session, to identify 'bounces'
-- step 4: summarize by counting total sessions and bounced sessions. 

create temporary table if not exists first_pageview
select 
	wp.website_session_id,
    min(wp.website_pageview_id) as min_pv_id
from website_pageviews as wp
	Inner join website_sessions as ws
		on wp.website_session_id = ws.website_session_id
where wp.created_at < '2012-06-14'
group by 1;

-- drop table first_pageview;
select * from first_pageview;

-- get landing page relating to first_pageviews
create temporary table if not exists sessions_w_landing_page
select 
	fp.website_session_id,
    wp.pageview_url as landing_page    
from first_pageview as fp
	inner join website_pageviews as wp
		on fp.min_pv_id = wp.website_pageview_id
where wp.pageview_url='/home';

-- drop table sessions_w_landing_page;
        
select * from sessions_w_landing_page;

-- Next, creat a table to include a count of pageviews per session

select 
	sl.website_session_id, 
    sl.landing_page,
    count(wp.website_session_id) as pv_per_session
from sessions_w_landing_page as sl
	left join website_pageviews as wp
		on wp.website_session_id = sl.website_session_id
group by 1,2;

create temporary table if not exists bounced_sessions_only
select 
	sl.website_session_id, 
    sl.landing_page,
    count(wp.website_session_id) as pv_per_session
from sessions_w_landing_page as sl
	left join website_pageviews as wp
		on wp.website_session_id = sl.website_session_id
group by 1,2
having count(wp.website_session_id) = 1;

-- drop table bounced_sessions_only;
select * from bounced_sessions_only;

-- Final output : do a count on records and group by landing page then add bounce rate column

select 
	sl.landing_page,
    count(distinct sl.website_session_id) as total_sessions,
    count(distinct bs.website_session_id) as bounced_sessions, 
    count(distinct bs.website_session_id) / count(distinct sl.website_session_id) as bounce_rate
from sessions_w_landing_page as sl
	Left join bounced_sessions_only as bs
		on sl.website_session_id = bs.website_session_id;