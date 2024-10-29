-- DBMS Assignment 4
-- Sarah Groark 

use assignment3Movies;

-- 1. what is the average length of films in each category? 
-- list results in alphabetic order of categories 
-- joins category on film_category (category_id) and film (film_id) to retrieve film categories + their lengths 

select category.name as category_name, round(avg(film.length),2) as average_length
from category 
inner join film_category 
	on (category.category_id = film_category.category_id)
inner join film
	on (film_category.film_id = film.film_id)
group by category.name
order by category.name asc;

-- 2. which categories have the longest and shortest average film lengths?
-- uses CTEs to filter through and choose min and max film lengths 

WITH AverageFilmLengths AS (

	select c.name as category_name, round(avg(film.length),2) as average_length
    from category c
	inner join film_category 
		on (c.category_id = film_category.category_id)
	inner join film
		on (film_category.film_id = film.film_id)
	group by c.name
	order by c.name asc

),

LongestCategory AS (

	select av.category_name as category_name, av.average_length
    from AverageFilmLengths av
    where average_length = (
		select max(average_length)
        from AverageFilmLengths av2
        )

),

ShortestCategory AS (
	
	select av.category_name, av.average_length
    from AverageFilmLengths av
    where average_length = (
		select min(average_length)
        from AverageFilmLengths av3
        )
)

select l.category_name as longest_category, l.average_length as longest_avg, s.category_name as shortest_category, s.average_length as shortest_avg
from LongestCategory l, ShortestCategory s;


-- 3. Which customers have rented action but not comedy or classic movies? 
-- uses subquery to exclude customers not renting any comedy or classics movies 

select distinct cu.customer_id, cu.first_name, cu.last_name
from customer cu
inner join rental r on (cu.customer_id = r.customer_id)
inner join inventory i on (r.inventory_id = i.inventory_id)
inner join film f on (i.film_id = f.film_id)
inner join film_category fc on (f.film_id = fc.film_id)
inner join category ca on (fc.category_id = ca.category_id)
where ca.name = 'Action'
AND cu.customer_id NOT IN (
	select distinct c2.customer_id
    from customer c2
	JOIN rental r2 ON c2.customer_id = r2.customer_id
    JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
    JOIN film f2 ON i2.film_id = f2.film_id
    JOIN film_category fc2 ON f2.film_id = fc2.film_id
    JOIN category cat2 ON fc2.category_id = cat2.category_id
    WHERE cat2.name IN ('Comedy', 'Classics')

);



-- 4. Which actor has appeared in the most English-language movies? 
-- uses having subquery to return actor(s) with the highest English-languages movie count 

select distinct a.actor_id, a.first_name, a.last_name, count(fa.film_id) as movie_count
from actor a 
inner join film_actor fa on (a.actor_id = fa.actor_id)
inner join film f on (fa.film_id = f.film_id)
inner join language l on (f.language_id = l.language_id)
where l.name = 'English'
group by a.actor_id, a.first_name, a.last_name
having count(fa.film_id) >= all(
	select count(fa2.film_id) as movie_count
    from film_actor fa2
    inner join film f2 on (fa2.film_id = f2.film_id)
    inner join language l2 on (f2.language_id = l2.language_id)
    where l2.name = 'English'
    group by fa2.actor_id
);

-- 5. How many distinct movies were rented for exactly 10 days from the store where Mike works?     
-- uses DATEDIFF() to find rental durations 


select count(distinct f.film_id) as distinct_movie_count
from rental r 
inner join inventory i on (r.inventory_id = i.inventory_id)
inner join film f on (i.film_id = f.film_id)
inner join store s on (i.store_id = s.store_id)
inner join staff st on (s.store_id = st.store_id)
where DATEDIFF(r.return_date, r.rental_date) = 10
	and st.first_name = 'Mike';

-- 6. Alphabetically list actors who appeared in the movie with the largest cast of actors 
-- subquery finds the cast sizes and limits to 1 to find the largest cast 

select a.first_name, a.last_name
from actor a
inner join film_actor fa on (a.actor_id = fa.actor_id)
where fa.film_id = (
	select fa2.film_id
    from film_actor fa2
    group by fa2.film_id
    order by count(fa2.actor_id) desc
    limit 1
)
order by a.first_name, a.last_name;



