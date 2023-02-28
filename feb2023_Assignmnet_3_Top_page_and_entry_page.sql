-- select 
-- 	pageview_url,
--     COUNT(DISTINCT website_session_id) as sessions
-- FROM website_pageviews
-- where created_at < '2012-06-09'
-- group by 1
-- order by 2 desc;

-- DROP TABLE first_lander_page;

-- STEP 1: Find the first page view for each session

CREATE temporary table if not exists first_lander_page
SELECT 
	website_session_id,
    MIN(website_pageview_id) as first_pv
FROM website_pageviews
where created_at < '2012-06-19'
group by 1;

SELECT * from first_lander_page;

-- STEP 2: Find url of page
SELECT 
	wp.pageview_url as lander_page,
    COUNT(distinct flp.website_session_id) as sessions
FROM first_lander_page as flp
	LEFT JOIN website_pageviews as wp
		ON flp.first_pv = wp.website_pageview_id
group by 1
order by 2 DESC;
