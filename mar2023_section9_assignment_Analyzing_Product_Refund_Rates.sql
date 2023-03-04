select 
	year(oi.created_at) as yr,
    month(oi.created_at) as mo,
    count(distinct case when product_id = 1 then oi.order_item_id else null end) as p1_orders,
    count(distinct case when product_id = 1 then oir.order_item_id else null end) 
		/	count(distinct case when product_id = 1 then oi.order_item_id else null end) as p1_refund_rt,
	count(distinct case when product_id = 2 then oi.order_item_id else null end) as p2_orders,
    count(distinct case when product_id = 2 then oir.order_item_id else null end) 
		/	count(distinct case when product_id = 2 then oi.order_item_id else null end) as p2_refund_rt,
	count(distinct case when product_id = 3 then oi.order_item_id else null end) as p3_orders,
    count(distinct case when product_id = 3 then oir.order_item_id else null end) 
		/	count(distinct case when product_id = 3 then oi.order_item_id else null end) as p3_refund_rt,
	count(distinct case when product_id = 4 then oi.order_item_id else null end) as p4_orders,
    count(distinct case when product_id = 4 then oir.order_item_id else null end) 
		/	count(distinct case when product_id = 4 then oi.order_item_id else null end) as p4_refund_rt
from order_items oi
	left join order_item_refunds oir
		on oi.order_item_id = oir.order_item_id
where oi.created_at < '2014-10-15'
group by 1,2;