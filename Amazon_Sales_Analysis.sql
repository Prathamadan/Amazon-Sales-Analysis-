-- creating customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
                            customer_id VARCHAR(25) PRIMARY KEY,
                            customer_name VARCHAR(25),
                            state VARCHAR(25)
);


-- creating sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
                        seller_id VARCHAR(25) PRIMARY KEY,
                        seller_name VARCHAR(25)
);


-- creating products table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
                        product_id VARCHAR(25) PRIMARY KEY,
                        product_name VARCHAR(255),
                        Price FLOAT,
                        cogs FLOAT
);



-- creating orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
                        order_id VARCHAR(25) PRIMARY KEY,
                        order_date DATE,
                        customer_id VARCHAR(25),  -- this is a foreign key from customers(customer_id)
                        state VARCHAR(25),
                        category VARCHAR(25),
                        sub_category VARCHAR(25),
                        product_id VARCHAR(25),   -- this is a foreign key from products(product_id)
                        price_per_unit FLOAT,
                        quantity INT,
                        sale FLOAT,
                        seller_id VARCHAR(25),    -- this is a foreign key from sellers(seller_id)
    
                        CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
                        CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),    
                        CONSTRAINT fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);



-- creating returns table
DROP TABLE IF EXISTS returns;
CREATE TABLE returns (
                        order_id VARCHAR(25),
                        return_id VARCHAR(25),
                        CONSTRAINT pk_returns PRIMARY KEY (order_id), -- Primary key constraint
                        CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SELECT * FROM orders
SELECT * FROM customers
SELECT * FROM returns
SELECT * FROM sellers
SELECT * FROM products
--Solving Business Problems
--1.What are the total sales made by each customer?
SELECT 
	customers.customer_id,
	customers.customer_name,
	ROUND(SUM(orders.sale)::NUMERIC,1) AS TOTAL_SALES
FROM customers
INNER JOIN ORDERS 
ON customers.customer_id=ORDERS.customer_id 
GROUP BY customers.customer_id

--2.How many unique customers have placed orders?
SELECT
	COUNT(DISTINCT customer_id)
FROM ORDERS

--3.Which product has the highest sale price?
--METHOD 1
SELECT *
FROM PRODUCTS
WHERE PRICE= (SELECT MAX(PRICE) FROM PRODUCTS)

--METHOD 2
SELECT *
FROM products
ORDER BY PRICE DESC
LIMIT 1

--METHOD 3
SELECT * 
FROM (SELECT *, 
		ROW_NUMBER() OVER(ORDER BY PRICE DESC) AS RN
		FROM PRODUCTS) 
WHERE RN=1

--4. How many orders were placed in each state?
SELECT
	STATE,
	COUNT(ORDER_ID) AS ORDERS_BY_STATE
FROM ORDERS 
GROUP BY STATE
HAVING STATE IS NOT NULL

--5. What is the total revenue generated from each product category?
SELECT
	CATEGORY,
	ROUND(SUM(SALE)::NUMERIC, 2) AS TOTAL_REVENUE
FROM ORDERS
GROUP BY CATEGORY
HAVING CATEGORY IS NOT NULL

--6.Which seller has the highest total sales?
SELECT 
	SELLERS.seller_id,
	SELLERS.seller_name,
	ROUND(SUM(SALE)::NUMERIC, 2) AS TOTAL_SALES
FROM orders
INNER JOIN SELLERS
ON ORDERS.SELLER_ID=SELLERS.SELLER_ID
GROUP BY SELLERS.seller_id
ORDER BY TOTAL_SALES DESC
LIMIT 1


--7. What is the average quantity of products ordered per order?
SELECT 
	ORDER_ID,
	ROUND(AVG(QUANTITY)::NUMERIC,1) AS AVG_QUANTITY
FROM ORDERS
GROUP BY ORDER_ID

--8. Which customer has made the highest total purchase?
SELECT 
	CUSTOMERS.CUSTOMER_ID,
	CUSTOMERS.CUSTOMER_NAME,
	ROUND(SUM(ORDERS.SALE)::NUMERIC,2) AS TOTAL_PURCHASE
FROM ORDERS
INNER JOIN CUSTOMERS
ON ORDERS.CUSTOMER_ID=CUSTOMERS.CUSTOMER_ID
GROUP BY CUSTOMERS.CUSTOMER_ID
ORDER BY SUM(ORDERS.SALE) DESC
LIMIT 1

--9. How many returns were made for each order?
SELECT 
	ORDERS.ORDER_ID,
	COUNT(RETURNS.ORDER_ID) 
FROM ORDERS
LEFT JOIN RETURNS
ON ORDERS.ORDER_ID=RETURNS.ORDER_ID
GROUP BY ORDERS.ORDER_ID

--10. What is the total sales revenue generated per month?
SELECT
		EXTRACT (MONTH FROM ORDER_DATE) AS MONTH,
		ROUND(SUM(SALE)::NUMERIC,1) AS TOTAL_SALES
FROM ORDERS
GROUP BY MONTH
ORDER BY MONTH

--11. Which product category has the highest average sale price?
SELECT * FROM ORDERS

SELECT 
	CATEGORY,
	AVG(SALE) AS AVERAGE_SALE_PRICE
FROM ORDERS
GROUP BY CATEGORY
ORDER BY AVERAGE_SALE_PRICE DESC
LIMIT 1

--12.How many orders were placed for each sub-category?
SELECT 
	SUB_CATEGORY,
	COUNT(ORDER_ID) AS NUMBER_OF_ORDERS_PLACED
FROM ORDERS
GROUP BY SUB_CATEGORY

--13.What is the total profit margin for each product?

SELECT 
    p.product_id,
    p.product_name,
    SUM(O.sale - P.cogs) AS total_profit,
    SUM(O.sale - P.cogs) / SUM(o.sale) * 100 AS profit_margin_percentage
FROM 
    products p
INNER JOIN 
    orders AS O ON p.product_id = o.product_id
GROUP BY 
    p.product_id, p.product_name;
	
-- 14.Which seller has the highest number of unique customers?
SELECT * 
FROM 
	(SELECT 
		SELLERS.seller_id,
		SELLERS.seller_name,
		COUNT(DISTINCT ORDERS.CUSTOMER_ID) AS UNIQUE_CUSTOMERS,
		RANK() OVER(ORDER BY COUNT(DISTINCT ORDERS.CUSTOMER_ID) DESC) AS RK
	FROM SELLERS
	INNER JOIN orders
	ON SELLERS.SELLER_ID=ORDERS.SELLER_ID
	GROUP BY SELLERS.seller_id)
WHERE RK<=1

--15.How many orders were placed for each seller?
SELECT 
	SELLERS.SELLER_ID,
	COUNT(ORDERS.ORDER_ID) AS ORDERS_PLACED
FROM ORDERS
INNER JOIN SELLERS
ON ORDERS.SELLER_ID=SELLERS.SELLER_ID
GROUP BY SELLERS.SELLER_ID
ORDER BY ORDERS_PLACED DESC

--16.What is the total sales revenue generated per seller?
SELECT 
	SELLERS.SELLER_ID,
	ROUND(SUM(ORDERS.SALE)::NUMERIC,1) AS REVENUE
FROM ORDERS
INNER JOIN SELLERS
ON ORDERS.SELLER_ID=SELLERS.SELLER_ID
GROUP BY SELLERS.SELLER_ID
ORDER BY REVENUE DESC

-- 17. Determine the month with the highest number of orders.
SELECT
	EXTRACT(MONTH FROM ORDER_DATE) AS MONTH,
	COUNT(QUANTITY) AS TOTAL_ORDERS
FROM ORDERS
GROUP BY MONTH
ORDER BY TOTAL_ORDERS DESC
LIMIT 1

--18. What is the percentage contribution of each sub-category?
SELECT 
	CATEGORY,
	SUB_CATEGORY,
	ROUND(SUM(SALE)::NUMERIC,1) AS TOTAL_SALES,
	ROUND(((SUM(SALE)/(SELECT SUM(SALE) FROM ORDERS)) * 100)::NUMERIC,2) AS PERCENTAGE_CONTRIBUTION
FROM 
	ORDERS
GROUP BY 
	SUB_CATEGORY,CATEGORY
	
--19.Which state has the highest total sales revenue?
SELECT 
	STATE,
	ROUND(SUM(SALE)::NUMERIC,1) AS TOTAL_SALES_REVENUE
FROM ORDERS
GROUP BY STATE
ORDER BY TOTAL_SALES_REVENUE DESC
LIMIT 1

--20.What is the average price per unit for each product category?
SELECT
	CATEGORY,
	ROUND(AVG(PRICE_PER_UNIT)::NUMERIC,1) AS AVERAGE_PRICE_PER_UNIT
FROM ORDERS
GROUP BY CATEGORY









