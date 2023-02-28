-- SELECT
-- 	MIN(DATE(created_at)) as week_start,
-- 	count(distinct website_session_id) as sessions,
--     week(created_at) as week    
-- FROM website_sessions
-- WHERE created_at < '2012-05-10'
-- 	AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
-- GROUP BY 3;


SELECT 
	device_type,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as CTR
FROM website_sessions as ws
	LEFT JOIN orders as o
		ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-05-11'
	AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 1
ORDER BY 4 DESC;