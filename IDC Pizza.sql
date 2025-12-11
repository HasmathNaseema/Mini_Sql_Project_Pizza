use idc_pizza

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50) PRIMARY KEY, -- e.g., 'bbq_ckn'
    name VARCHAR(100),                      -- e.g., 'The Barbecue Chicken Pizza'
    category VARCHAR(50),                   -- e.g., 'Chicken'
    ingredients TEXT                        -- e.g., 'Barbecued Chicken, Red Peppers, ...'
);


CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,   -- e.g., 'bbq_ckn_s'
    pizza_type_id VARCHAR(50) REFERENCES pizza_types(pizza_type_id),
    size VARCHAR(10),                   -- e.g., 'S', 'M', 'L'
    price NUMERIC(5, 2)                 -- e.g., 12.75
);


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time time
);

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    pizza_id VARCHAR(50) REFERENCES pizzas(pizza_id),
    quantity INT
);




use idc_pizza
# PHASE 1  Foundation & Inspection
# 1 List all unique pizza categories (DISTINCT).
select distinct category from pizza_types

#2 Display pizza_type_id, name, and ingredients, replacing NULL ingredients with "Missing Data". Show first 5 rows.
select pizza_type_id,name,coalesce(ingredients,'Missing Data')
from pizza_types
limit 5 

#3 Check for pizzas missing a price (IS NULL).
select pizza_id from pizzas
where price is null ;

# PHASE 2  Filtering & Exploration

#1 Orders placed on '2015-01-01' (SELECT + WHERE).
select * from orders
where date='2015-01-01'  ;

#2  List pizzas with price descending.
select * from pizzas
order by price desc ;

#3 Pizzas sold in sizes 'L' or 'XL'.
select * from pizzas
where size ='L' or size ='XL' ;

#4 Pizzas priced between $15.00 and $17.00.
select * from pizzas
where price between 15.00 and 17.00 ;

#5 Pizzas with "Chicken" in the name.
select * from pizza_types
where name like '%chicken%' ;

#6 Orders on '2015-02-15' or placed after 8 PM.
select * from orders
where date ='2105-02-15' or time > '20:00:00' ;

# PHASE 3  Sales Performance

#1 Total quantity of pizzas sold (SUM).
select
sum(quantity) as TotalPizzaSold 
from order_details ;

#2 Average pizza price (AVG).
select 
round(avg(price),2) as AvgPrice
from pizzas ;

#3 Total order value per order (JOIN, SUM, GROUP BY).
select o.order_id,
sum(od.quantity * p.price) TotalOrderValuePerOrder
from orders o
join order_details od
on o.order_id = od.order_id 
join pizzas p
on p.pizza_id = od.pizza_id
group by o.order_id ;

#4 Total quantity sold per pizza category (JOIN, GROUP BY).
select 
pt.category,
sum(od.quantity) TotalQuantitySold
from order_details od 
join pizzas p
on od.pizza_id = p.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.category ;

#5 Categories with more than 5,000 pizzas sold (HAVING).
select 
pt.category,
sum(od.quantity) TotalQuantitySold
from order_details od 
join pizzas p
on od.pizza_id = p.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.category 
having TotalQuantitySold > 5000 ;

# 6 Pizzas never ordered (LEFT/RIGHT JOIN).
select * from pizzas p
left join order_details od 
on p.pizza_id = od.pizza_id
where od.order_id is null 

# 7 Price differences between different sizes of the same pizza (SELF JOIN).

select 
p1.size size1,
p2.size size2,
p1.price price1,
p2.price price2 ,
(p1.price-p2.price) as PriceDifference  
from pizzas p1
join pizzas p2 
on p1.pizza_type_id =p2.pizza_type_id
and p1.size <> p2.size
and p1.size > p2.size