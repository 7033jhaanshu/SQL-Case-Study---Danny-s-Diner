create database dannys_diner;
SET search_path = dannys_diner;
use dannys_diner;
CREATE TABLE sales (
  customer_id VARCHAR(5),
  order_date date,
  product_id INT
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
 show tables ;
 select * from members;
 select * from menu ;
 select * from sales ;
#1 What is the total amount each customer spent at the restaurant?

 select customer_id, sum(price) from sales join menu on sales.product_id = menu.product_id group by 1 order by 1,2;

#2 How many days has each customer visited the restaurant?

 select count(distinct(order_date)),customer_id from sales group by customer_id ;


 #3 What was the first item from the menu purchased by each customer?

select customer_id, product_name from (select s.customer_id, m.product_name, s.order_date,
rank() over (partition by s.customer_id order by s.order_date) as rnk from sales s join menu m on s.product_id = m.product_id) sub
where rnk = 1;

#4 What is the most purchased item on the menu and how many times was it purchased by all customers?

select s.customer_id,s.order_date,m.product_name from sales s join members me on s.customer_id = me.customer_id 
join menu m on s.product_id = m.product_id where  s.order_date > me.join_date and s.order_date = 
(select min(order_date)from sales where customer_id = s.customer_id and order_date > me.join_date)order by 1;

select m.product_name, COUNT(*) AS total_orders from sales s join menu m on s.product_id = m.product_id 
group by m.product_name order by total_orders desc limit 1;
 
#5 Which item was the most popular for each customer?

select customer_id, product_name from (select s.customer_id, m.product_name, count(*) as total,
rank() over (partition by s.customer_id order by count(*) desc) as rnk from sales s join menu m on s.product_id = m.product_id
group by s.customer_id, m.product_name) sub where rnk = 1;

#6 Which item was purchased first by the customer after they became a member?

SELECT customer_id, product_name
FROM (
  select s.customer_id, m.product_name, s.order_date,rank() over (partition by s.customer_id order by s.order_date) as rnk from sales s
  join menu m on s.product_id = m.product_id join members mem on s.customer_id = mem.customer_id where s.order_date >= mem.join_date) sub where rnk = 1;

#7 Which item was purchased just before the customer became a member?

select customer_id, product_name from (select s.customer_id, m.product_name, s.order_date,
rank() over (partition by s.customer_id order by s.order_date desc) as rnk from sales s
join menu m on s.product_id = m.product_id join members mem on s.customer_id = mem.customer_id where s.order_date < mem.join_date) sub
where rnk = 1;

#8 What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(*) as total_items, sum(m.price) as total_spent from sales s
join menu m on s.product_id = m.product_id join members mem on s.customer_id = mem.customer_id where s.order_date < mem.join_date
group by s.customer_id;

#9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id,sum(case when m.product_name = 'sushi' then m.price * 20 else m.price * 10 end) as total_points from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;

#10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
# not just sushi - how many points do customer A and B have at the end of January?

select join_date from members ;
 with cte as (select s.customer_id,
 join_date,
 order_date,
price 
from sales s 
join members me on s.customer_id = me.customer_id
join menu m on s.product_id = m.product_id
where order_date - join_date <= 7 and order_date > join_date 
order by customer_id
)
select customer_id,
sum(price)*2 as points from cte
group by 1;

#The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

#Recreate the following table output using the available data:
#customer_id	order_date	product_name	price	member
#A	2021-01-01	curry	15	N
#A	2021-01-01	sushi	10	N
#A	2021-01-07	curry	15	Y
#A	2021-01-10	ramen	12	Y
#A	2021-01-11	ramen	12	Y
#A	2021-01-11	ramen	12	Y
#B	2021-01-01	curry	15	N
#B	2021-01-02	curry	15	N
#B	2021-01-04	sushi	10	N
#B	2021-01-11	sushi	10	Y
#B	2021-01-16	ramen	12	Y
#B	2021-02-01	ramen	12	Y
#C	2021-01-01	ramen	12	N
#C	2021-01-01	ramen	12	N
#C	2021-01-07	ramen	12	N
#Rank All The Things

select s.customer_id, s.order_date,product_name, price,case when order_date >= join_date then 'YES' else 'NO' end as members from sales s
join  menu m on  s.product_id = m.product_id join members me on s.customer_id = me.customer_id order by  1,2;

#Danny also requires further information about the ranking of customer products, but he purposely does not need the 
#ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

with cte as (select s.customer_id, s.order_date,product_name, price,
case when order_date >= join_date then 'YES' 
	when order_date <= join_date then 'NO'end as members from sales s
join  menu m on  s.product_id = m.product_id join members me on s.customer_id = me.customer_id order by 1,2) 
 select customer_id, order_date,product_name, price, members, 
 case when members = 'YES' then dense_rank () over(order by order_date) else null end as ranking
from cte  ;