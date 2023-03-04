use mavenfuzzyfactory;

-- Business Concept: Channel portfolio Optimization
/*
Analyzing a portfolio of markerting channels if about bidding efficiently and using data to maximize the 
effectiveness of your marketing budget.
Channels such as: email, social media, search, direct type in traffic

Common use cases:
	- Understanding which marketing channels are driving the most sessions and orders through your websites
	- Understanding differences in user characteristics and conversion performance across marketing channels
    - Optimizing bids and allocating marketing spend across a multi-channel portfolio to achieve max performance
*/

select * from website_sessions limit 10;

select 
	ws.utm_content,
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as session_to_order_conv_rate    
from website_sessions ws
	left join orders o
		on o.website_session_id = ws.website_session_id
where ws.created_at between '2014-01-01' and '2014-02-01'
group by 1
order by 2 desc;

-- Business Concept: Analyzing Direct Traffic
/*
Analyzing branded or direct traffic is about keeping a pulse on how well you brand is doing with consumers,
and how well your brand drives business

Common use cases:
- Identifying how much revenue you are generating from direct traffic - this is high margin revenue without direct cost 
of customer acquisition
- Understanding whether or not your paid traffic is generating a 'halo' effect, and promoting additional direct traffic
- Assessing the impact of various initiatives on how many customers seek out your business
*/

select 
	case
		when http_referer IS NULL then 'direct_type_in'
        when http_referer = 'https://www.gsearch.com' then 'gsearch_organic'
        when http_referer = 'https://www.bsearch.com' then 'bsearch_organic'
        else 'other'
	end as segments,
    count(distinct website_session_id) as sessions
from website_sessions
where website_session_id between 100000 and 115000
	and utm_source IS NULL
group by 1
order by 2 desc;

select 
	case
		when http_referer IS NULL then 'direct_type_in'
        when http_referer = 'https://www.gsearch.com' and utm_source IS NULL then 'gsearch_organic'
        when http_referer = 'https://www.bsearch.com' and utm_source IS NULL then 'bsearch_organic'
        else 'other'
	end as segments,
    count(distinct website_session_id) as sessions
from website_sessions
where website_session_id between 100000 and 115000
	-- and utm_source IS NULL
group by 1
order by 2 desc;




