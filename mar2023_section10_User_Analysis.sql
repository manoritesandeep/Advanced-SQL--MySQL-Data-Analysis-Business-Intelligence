-- Business concept: Analyze repeat behavior
/*
Analyzing repeat visits helps you understand user behavior and identify some of your most valuable customers

Common use cases:
	- Analyzing repeat activity to see how often customers are coming back to visit your site.
    - Understanding which channels they use when they come back, and whether or not you are paying for
		them again through paid channels
	- Using your repeat visit activity to build a better understanding of the value of a customer
		in order to better optimize marketing channels

Businesses track customer behavior across multiple sessions using browser cookies

Cookies have unique ID values associated with them, which allows us to recognize a customer when they come back
and track their behavior over time.
*/

/*
DATEDIFF() allows you to compare the time difference between two dates
DATEDIFF() subtracts the second date from the first date, so typically you will list more recent date first
DATEDIFF(second_date, first_date)

-- Examples: DATEDIFF(NOW(), born_on_date) as days_old
DATEDIFF(second_session_created_at, first_session_created_at) as days_between_sessions
DATEDIFF(refunded_at, ordered_at)/7 as weeks_from_order_to_refund

DATEDIFF() returns a number of days, but you can convert to other time periods using division.
*/

USE mavenfuzzyfactory;

select 
	oi.order_id,
    oi.order_item_id,
    oi.price_usd as price_paid_usd,
    oi.created_at,
    oir.order_item_refund_id,
    oir.refund_amount_usd,
    oir.created_at,
    DATEDIFF(oir.created_at, oi.created_at) as days_order_to_refund
from order_items oi
	left join order_item_refunds oir
		on oir.order_item_id = oi.order_item_id
where oi.order_id in (3489,32049,27061);