select count(*) as orphan_orders
from [dbo].[ecommerce_sales_customer_analytics_150k] a
left join customer_master c 
on c.customer_id = a.customer_id
where c.customer_id is null


select 
    count(*) as orphan_order
from order_items o
left join dbo.ecommerce_sales_customer_analytics_150k a
    on o.order_id = a.order_id
where o.order_id is null;


select count(*) as orphan_products 
from dbo.order_items o
left join dbo.product_catalog p
on o.product_id = p.product_id
where o.product_id is null


alter table [dbo].[ecommerce_sales_customer_analytics_150k]
add constraint fk_orders_customers
foreign key (customer_id) references [dbo].[customer_master](customer_id)

alter table [dbo].[order_items]
add constraint fk_order_items_orders 
foreign key (order_id) references [dbo].[ecommerce_sales_customer_analytics_150k];


select c.region,p.product_category,round(sum(o.gross_sales),2)as total_sales,round(sum(o.profit),2) as total_profit

from [dbo].[customer_master] c 

inner join [dbo].[ecommerce_sales_customer_analytics_150k] a 

on c.customer_id = a.customer_id 

inner join [dbo].[order_items] o 
on o.order_id = a.order_id 

inner join [dbo].[product_catalog] p 
on p.product_id = o.product_id 

group by c.region,product_category

order by total_profit desc;

/* VIP */ 
select  c.customer_id,c.customer_name,c.customer_segment,round(o.gross_sales,2) as total_spent from [dbo].[customer_master] c 
inner join [dbo].[ecommerce_sales_customer_analytics_150k] a 
on a.customer_id = c.customer_id
inner join [dbo].[order_items] o 
on o.order_id = a.order_id 

group by c.customer_name,c.customer_id,o.gross_sales,c.customer_segment

having o.gross_sales > (select avg(gross_sales) from [dbo].[order_items])
and c.customer_segment = 'VIP'

order by o.gross_sales asc


select c.customer_id, c.customer_name, c.customer_segment, round(sum(o.gross_sales), 2) as total_spent
from [dbo].[customer_master] c
inner join [dbo].[ecommerce_sales_customer_analytics_150k] a
on a.customer_id = c.customer_id
inner join [dbo].[order_items] o
on o.order_id = a.order_id

group by c.customer_id, c.customer_name, c.customer_segment

having sum(o.gross_sales) > (select avg(customer_total) 
from ( select sum(oi.gross_sales) as customer_total from [dbo].[order_items] oi
inner join [dbo].[ecommerce_sales_customer_analytics_150k] ord 
 on oi.order_id = ord.order_id
 group by ord.customer_id ) as user_totals
)
order by total_spent desc;






select * from (
select p.product_name,p.product_category,round(sum(o.gross_sales),2)as total_revenue,
dense_rank() over (partition by p.product_category order by sum(o.gross_sales) desc) as column_rank from product_catalog p

inner join [dbo].[order_items] o 
on o.product_id = p.product_id
group by p.product_name,p.product_category) t 
where column_rank <=3



with customer_orders_ranked as (
    select c.customer_id, c.customer_segment, o.order_id, o.order_date, row_number() over(partition by c.customer_id order by o.order_date asc) as order_num
    from [dbo].[customer_master] c
    inner join [dbo].[ecommerce_sales_customer_analytics_150k] o
    on c.customer_id = o.customer_id
),
order_lags as (
    select customer_id, customer_segment, order_num, order_date, 
    datediff(day, lag(order_date) over(partition by customer_id order by order_date asc), order_date) as days_since_last_order
    from customer_orders_ranked
)
select customer_segment, count(customer_id) as total_repeat_customers, 
round(avg(cast(days_since_last_order as float)), 1) as avg_days_to_second_purchase, min(days_since_last_order) as min_days, max(days_since_last_order) as max_days
from order_lags
where order_num = 2
group by customer_segment
order by avg_days_to_second_purchase asc;




with customer_metrics as (
select c.customer_id, c.customer_name, c.customer_segment, c.customer_country, count(distinct a.order_id) as total_orders, 
count(o.product_id) as total_items_bought, round(sum(o.gross_sales), 2) as lifetime_gross_sales, round(sum(o.profit), 2) as lifetime_profit, 
round(avg(cast(a.delivery_days as float)), 1) as avg_delivery_days, 
sum(case when a.order_status = 'Returned' or a.return_status is not null then 1 else 0 end) as total_returned_items, 
round(100.0 * sum(case when a.order_status = 'Returned' or a.return_status is not null then 1 else 0 end) / nullif(count(o.product_id), 0), 2) as customer_return_rate_pct
from [dbo].[customer_master] c
inner join [dbo].[ecommerce_sales_customer_analytics_150k] a
on c.customer_id = a.customer_id
inner join [dbo].[order_items] o
on a.order_id = o.order_id
group by c.customer_id, c.customer_name, c.customer_segment, c.customer_country
),
customer_tiers as (
select customer_id, customer_name, customer_segment, customer_country, total_orders, total_items_bought, lifetime_gross_sales, 
lifetime_profit, avg_delivery_days, total_returned_items, customer_return_rate_pct, 
ntile(5) over(order by lifetime_gross_sales desc) as spend_tier, dense_rank() over(order by lifetime_profit desc) as profit_rank
from customer_metrics
)
select customer_id, customer_name, customer_segment, customer_country, total_orders, lifetime_gross_sales, 
lifetime_profit, customer_return_rate_pct, avg_delivery_days, profit_rank
from customer_tiers
where spend_tier = 1 
and customer_return_rate_pct > (
select 100.0 * sum(case when order_status = 'Returned' or return_status is not null then 1 else 0 end) / nullif(count(*), 0)
from [dbo].[ecommerce_sales_customer_analytics_150k]
)
order by customer_return_rate_pct desc, lifetime_gross_sales desc;









