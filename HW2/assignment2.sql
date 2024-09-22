-- ASSIGNMENT 2: 
-- Sarah Groark 
-- 9/21/2024

create database assign2;
show databases;
use assign2;
show tables;

-- set flags
set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;


-- PART 2 = 

-- problem 1: average price of foods at each restaurant (uses cross join) 

select restaurants.name, round(avg(foods.price),2) as average_price
from serves, restaurants, foods
where serves.foodID = foods.foodID and serves.restID = restaurants.restID
group by restaurants.name
order by average_price desc;

-- problem 2: maximum food price at each restaurant (inner join) 

select restaurants.name, round(max(foods.price),2) as max_food_price
from serves 
inner join foods
		on serves.foodID = foods.foodID
inner join restaurants
		on serves.restID = restaurants.restID
group by restaurants.name
order by max_food_price desc;

-- problem 3: count of different food types served at each restaurant (inner join) 

select restaurants.name, count(distinct foods.type) as food_type_count
from serves 
inner join foods using(foodID)
inner join restaurants using (restID)
group by restaurants.name
order by food_type_count;

-- problem 4: average price of foods served by each chef (inner join)

select chefs.name, round(avg(foods.price),2) as food_sold_avg
from works
inner join serves using (restID)
inner join foods using (foodID)
inner join chefs using (chefID)
group by chefs.name
order by food_sold_avg desc;

-- problem 5: find the restaurant with the highest average food price (inner join) 
select restaurants.name, round(avg(foods.price),2) as average_price
from serves 
inner join restaurants using (restID)
inner join foods using (foodID)
group by restaurants.name
having (average_price) >= all
    (select avg(foods.price)
    from serves
    inner join restaurants using (restID)
	inner join foods using (foodID)
    group by restaurants.name);

-- extra credit: chef w/ highest average food price (inner join) 

select chefs.name, round(avg(foods.price),2) as avg_food_price, group_concat(distinct restaurants.name) as restaurants_worked_at
from works
inner join serves using (restID)
inner join chefs using (chefID) 
inner join foods using (foodID)
inner join restaurants using (restID)
group by chefs.name
having (avg_food_price) >= all
	(select avg(foods.price)
    from works 
    inner join serves using (restID)
	inner join chefs using (chefID) 
	inner join foods using (foodID)
	inner join restaurants using (restID)
    group by chefs.name);
