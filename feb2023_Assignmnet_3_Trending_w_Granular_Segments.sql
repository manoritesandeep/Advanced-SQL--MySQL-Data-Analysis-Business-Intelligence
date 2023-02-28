SELECT 
    -- count(distinct website_session_id) as sessions,
    -- WEEK(created_at),
    MIN(DATE(created_at)) as week_start_date,
    -- device_type,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) as dtop_sessions
FROM website_sessions
WHERE created_at > '2012-04-15' 
	AND created_at < '2012-06-09'
	AND utm_source = 'gsearch' 
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at)
