-- SELECT utm_source,
-- 	utm_campaign,
--     http_referer,
--     count(distinct website_session_id) as sessions
-- FROM website_sessions
-- WHERE created_at < '2012-04-12'
-- GROUP BY 1,2,3
-- ORDER BY 4 DESC;


SELECT ws.utm_source,
	ws.utm_campaign,
    ws.http_referer,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id)/count(distinct ws.website_session_id) as CTR
FROM website_sessions as ws
LEFT JOIN orders as o
	ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-04-14'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
GROUP BY 1,2,3
ORDER BY 6 DESC;