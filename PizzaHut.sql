create database pizzahut;
use pizzahut;
CREATE TABLE order_details (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_det (
    order_details_id INT NOT NULL,
    order_id int NOT NULL,
    pizza_id text NOT NULL,
    quantity int not null,
    PRIMARY KEY (order_details_id)
);


-- 1. Retrieve the total number of orders placed.
select count(order_id) as total_order from order_details;


-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_det.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_det
        JOIN
    pizzas ON pizzas.pizza_id = order_det.pizza_id;

    
-- 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_det.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_det ON pizzas.pizza_id = order_det.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_det.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_det ON order_det.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, SUM(order_det.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_det ON order_det.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- 7. Determine the distribution of orders by hour of the day.
select hour(order_time) as hour, count(order_id) as order_count
from order_details
group by hour(order_time);


-- 8. Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        order_details.order_date,
            SUM(order_det.quantity) AS quantity
    FROM
        order_details
    JOIN order_det ON order_details.order_id = order_det.order_id
    GROUP BY order_details.order_date) AS order_quantity;
    
    
-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_det.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_det ON order_det.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(
        SUM(order_det.quantity * pizzas.price) /
        (
            SELECT 
                SUM(order_det.quantity * pizzas.price)
            FROM order_det
            JOIN pizzas 
                ON pizzas.pizza_id = order_det.pizza_id
        ) * 100,
        2
    ) AS revenue
FROM pizza_types
JOIN pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_det 
    ON order_det.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- 12. Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from (select order_details.order_date, sum(order_det.quantity * pizzas.price) as revenue
from order_det join pizzas
on order_det.pizza_id = pizzas.pizza_id
join order_details on order_details.order_id = order_det.order_id
group by order_details.order_date) as sales;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_det.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_det
on order_det.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;