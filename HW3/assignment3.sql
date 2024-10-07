-- DBMS Assignment 3
-- Author: Sarah Groark
-- Date: 10/1/2024

-- create database for assignment 3
create database if not exists assignment3;
use assignment3;

-- set flags 
set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

-- merchant table
create table merchants(
	mid int primary key,
    name varchar(50) not null,
    city varchar(50),
    state varchar(50)
);

-- products table
create table products(
	pid int primary key,
    product_name varchar(50),
    category varchar(50), 
    description varchar(100),
	
    constraint check_name check (product_name in ('Printer','Ethernet Adapter','Desktop','Hard Drive', 'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor')),
    constraint check_product check (category in ('Peripheral','Networking','Computer'))
);


-- sell table
create table sell(
	mid int, 
    pid int,
    
    price decimal(10,2) not null, 
    quantity_available int,
    
    primary key(mid,pid),
    
    constraint chk_price check (price between 0 and 100000),
    constraint chk_int_value check (quantity_available between 0 and 10000),
    foreign key (mid) references merchants(mid),
    foreign key (pid) references products(pid)

);


-- orders table
create table orders(
	oid int primary key,
    shipping_method varchar(30),
    shipping_cost decimal(10,2),
    
    constraint chk_method check (shipping_method in ('UPS','FedEx','USPS')),
    constraint chk_cost check (shipping_cost between 0 and 500)

);

-- contain table
create table contain(
	oid int, 
    pid int, 
    
    primary key(oid,pid),
    
    foreign key (oid) references orders(oid),
    foreign key (pid) references products(pid)

);


-- customers table
create table customers(
	cid int primary key,
    full_name varchar(100),
    city varchar(50),
    state varchar(50)

);


-- place table
create table place(
	cid int, 
    oid int, 
    order_date date,
    
    primary key(cid,oid),
    
    foreign key (cid) references customers(cid),
    foreign key (oid) references orders(oid)
);

-- fix import for rows that failed
alter table products
modify description varchar(400);
insert into products (pid, product_name, category, description) values
(6, 'Laptop', 'Computer', 'Intel Core i5-2410M 2.3GHz / 4GB RAM / 640GB Hard Drive / Blu-ray / Intel HD Graphics / 802.11n / Bluetooth / Webcam / HDMI / Windows 7 Home Premium'),
(17,'Desktop','Computer','Intel Core i7-2630QM 2.00GHz / 8GB RAM / 2TB HD / Blu-ray Reader / GeForce GT 540M Graphics / 802.11n / HDMI / TV Tuner / USB 3.0 / Windows 7 Home Premium'),
(24,'Laptop','Computer', '1.66GHz Processor / 2GB RAM / 250GB Hard Drive / Intel GMA 3150 / 802.11n / Webcam / 6-cell Li-ion battery / Windows 7 Starter'),
(25, 'Laptop','Computer','Core i7 /17.3 / 750/8GB PC HP 8760w Core i7-2720QM CPU 17.3 FHD AG LED UWVA 2GB nVidia Webcam 8GB 1333DDR3 RAM(2D) 750GB HDDDVD+/-RW 802.11a/b/g/n I3 BT FPR Windows 7 PRO 64 OF10 STR U.S. - English localization');

alter table products
change product_name name varchar(50);

alter table products
drop constraint check_name;

-- fix products table constraint 
alter table products
add constraint check_name check(name in ('Printer','Ethernet Adapter','Desktop','Hard Drive', 'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor'));


-- -- -- -- --
-- QUERIES: --
-- -- -- -- --



-- 1. names and sellers of products no longer available (quantity=0)
-- inner join: sell (mid), merchants (mid), products (pid) 

select m.name as merchant, p.name as product
from sell s 
inner join merchants m on s.mid = m.mid
inner join products p on s.pid = p.pid
where quantity_available=0;

-- 2. list names and descriptions of products that aren't sold 
-- left join: products (pid), sell (null pid)

select p.name as product_name, p.description
from products p left join sell s
	on (p.pid = s.pid)
where s.pid is null;


-- 3. how many customers bought SATA drives but not any routers
-- inner join: place (oid), contain (oid), products (pid); filter by has name (SATA drives); filter by (no router)

select count(distinct place.cid) as customer_count
from place 
inner join contain 
	on place.oid = contain.oid
inner join products
	on contain.pid = products.pid
where products.description LIKE '%SATA%'
AND place.cid NOT IN (
    select distinct place.cid
    from place
    inner join contain
		on place.oid = contain.oid
	inner join products
		on contain.pid = products.pid
	where products.name = 'Router'
);


-- 4. HP has a 20% sale on all of its networking products
-- update sell table (price) on pid and mid where merchant = HP and product category = networking

UPDATE sell s
INNER JOIN products p ON s.pid = p.pid
INNER JOIN merchants m ON s.mid = m.mid
SET s.price = s.price * 0.8  -- Apply a 20% discount
WHERE p.category = 'Networking' AND m.name = 'HP';



-- 5. What did Uriel Whitney order from Acer? 
-- inner join: customers (cid), contain (oid), products (pid), sell (pid), merchants (mid)

select merchants.name as company, customers.full_name as customer_name, products.name as product, sell.price
from customers
inner join place on (customers.cid = place.cid) 
inner join contain on (place.oid = contain.oid)
inner join products on (contain.pid = products.pid)
inner join sell on (products.pid = sell.pid)
inner join merchants on (sell.mid = merchants.mid)
where merchants.name = 'Acer' and customers.full_name = 'Uriel Whitney'; -- filter by what Uriel Whitney bought only from Acer


-- 6. list the annual total sales for each company (sort results along the company and the year attributes)

select merchants.name as company_name, year(place.order_date) as year, sum(sell.price) as annual_sales
from place 
inner join contain on (place.oid = contain.oid)
inner join sell on (contain.pid = sell.pid)
inner join merchants on (sell.mid = merchants.mid)
group by merchants.name, year
order by year;

-- 7. which company had the highest annual revenue and in what year? 
-- inner join: place (oid), contain (oid), sell (pid), merchants (mid), group by company & year, order limit by top 1


select merchants.name as company_name, year(place.order_date) as year, sum(sell.price) as annual_revenue
from place 
inner join contain on (place.oid = contain.oid)
inner join sell on (contain.pid = sell.pid)
inner join merchants on (sell.mid = merchants.mid)
group by merchants.name, year
order by annual_revenue desc
limit 1;

-- 8. on average, what was the cheapest shipping method used ever
-- reports cheapest shipping cost of all orders (on average); uses orders table to filter output

select orders.shipping_method, round(avg(orders.shipping_cost),2) as average_price
from orders
group by orders.shipping_method
having avg(orders.shipping_cost) <= all(
	select avg(orders.shipping_cost)
	from orders
    group by orders.shipping_method
)
order by avg(orders.shipping_cost);



-- 9. what is the best sold ($) category for each company? 
-- name (merchants), category (products), sell (price), dontain (pid)

WITH CategorySales AS (

	select m.name as merchant_name, p.category, sum(s.price) as total_sales
    from products p
    inner join contain c on (p.pid = c.pid)
    inner join sell s on (p.pid = s.pid)
    inner join merchants m on (s.mid = m.mid)
    group by m.name, p.category
),
MaxSales AS (

	select merchant_name, max(total_sales) as max_sales
    from CategorySales
    group by merchant_name

)
select cs.merchant_name, cs.category, cs.total_sales
from CategorySales cs
inner join MaxSales ms on (cs.merchant_name = ms.merchant_name and cs.total_sales = ms.max_sales);


-- 10. for each company find out which customer has spent the least and most amounts
-- place (oid), contain (oid -> pid), sell (price), merchants (mid)


WITH CustomerSpending AS (
	select m.name as company, c.full_name, sum(s.price) as total_spent
	from customers c
	inner join place p on (c.cid = p.cid)
	inner join contain con on (p.oid = con.oid)
	inner join sell s on (con.pid = s.pid)
	inner join merchants m on (s.mid = m.mid)
	group by m.name, c.full_name

), 
HighestSpender AS(
	
    select cs.company, cs.full_name, cs.total_spent
    from CustomerSpending cs
    where total_spent = (
		select max(total_spent)
        from CustomerSpending cs2
        where cs2.company = cs.company
    )
), 
LowestSpender AS(
	select cs.company, cs.full_name, cs.total_spent
    from CustomerSpending cs
    where total_spent = (
		select min(total_spent)
        from CustomerSpending cs3
        where cs3.company = cs.company
    
    )
)

select h.company, h.full_name as highest_spender, h.total_spent as highest_spent, l.full_name as lowest_spender, l.total_spent as lowest_spent
from HighestSpender h
inner join LowestSpender l on (h.company = l.company);





