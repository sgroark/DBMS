
use assignment3Movies;


-- create actor table 
create table if not exists actor(
	actor_id int primary key,
    first_name varchar(50),
    last_name varchar(50)
);

-- create address table 

create table if not exists address(
	address_id int primary key, 
    address varchar(150),
    address2 varchar(150),
    district varchar(50), 
    city_id int, 
    postal_code varchar(20),
    phone varchar(30),
    
    foreign key (city_id) references city(city_id)


);

-- create city table 

create table if not exists city(
	city_id int primary key,
    city varchar(100), 
    country_id int,
    
    foreign key (country_id) references country(country_id)

);

-- create category table 

create table if not exists category(

	category_id int primary key,
    name varchar(200) not null,
    
    constraint chk_name check (name in ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music'))

);

-- create country table 

create table if not exists country(

	country_id int primary key, 
    country varchar(100)

);



-- create customer table 

create table if not exists customer(
	customer_id int primary key,
    store_id int, 
    first_name varchar(100),
    last_name varchar(100),
    email varchar(150),
    address_id int, 
    active int not null, 
    
    foreign key (store_id) references store(store_id),
    foreign key (address_id) references address(address_id),
    
    constraint chk_active check (active in (0,1))

);

-- create film table 

create table if not exists film(

	film_id int primary key,
    title varchar(200) not null,
    description text,
    release_year year,
    language_id int,  
    rental_duration int, 
    rental_rate decimal(10,2), 
    length int, 
    replacement_cost decimal(10,2), 
    rating varchar(20), 
    special_features varchar(100), 
    
    foreign key (language_id) references language(language_id),
    constraint chk_rate check (rental_rate between 0.99 and 6.99),
    constraint chk_duration check (rental_duration between 2 and 8),
    constraint chk_length check (length between 30 and 200),
    constraint chk_cost check (replacement_cost between 5.00 and 100.00),
    constraint chk_rating check (rating in ('PG','G','NC-17','PG-13','R')),
    constraint chk_feat check (special_features in ('Behind the Scenes','Commentaries','Deleted Scenes','Trailers'))
    
);


-- create film_actor table 

create table if not exists film_actor(

	actor_id int,
    film_id int, 
    
    PRIMARY KEY (actor_id,film_id),
    foreign key (actor_id) references actor(actor_id),
    foreign key (film_id) references film(film_id)


);

-- create rental table 

create table if not exists rental(
	
    rental_id int primary key, 
    rental_date date not null, 
    inventory_id int not null, 
    customer_id int not null, 
    return_date date not null, 
    staff_id int, 
    
    foreign key (inventory_id) references inventory(inventory_id),
    foreign key (customer_id) references customer(customer_id),
    foreign key (staff_id) references staff(staff_id)

);
ALTER TABLE rental
DROP INDEX rental_date;  -- Drops unique constraint on rental_date

desc rental;

drop table rental;



-- create staff table 

create table if not exists staff(

	staff_id int primary key,
    first_name varchar(50), 
    last_name varchar(50),
    address_id int, 
    email varchar(150), 
    store_id int, 
    active int not null, 
    username varchar(50), 
    password varchar(100),
    
    foreign key (address_id) references address(address_id),
    foreign key (store_id) references store(store_id), 
    constraint chk_active2 check (active in (0,1))

);

-- creat store table 

create table if not exists store(
	store_id int primary key, 
    address_id int, 
    
    foreign key (address_id) references address(address_id)
);

-- create film_category table 

create table if not exists film_category(

	film_id int, 
    category_id int, 
    
    PRIMARY KEY (film_id, category_id),
    foreign key (film_id) references film(film_id),
    foreign key (category_id) references category(category_id)
    
);

-- create inventory table 

create table if not exists inventory(

	inventory_id int primary key, 
    film_id int, 
    store_id int, 
    
    foreign key (film_id) references film(film_id),
    foreign key (store_id) references store(store_id)


);

-- create language table 

create table if not exists language(
	language_id int primary key, 
    name varchar(50)
);

-- create payment table 

create table if not exists payment(
	payment_id int primary key, 
    customer_id int, 
    staff_id int,
    rental_id int, 
    amount decimal(10,2) not null,
    payment_date date not null,
    
    foreign key (customer_id) references customer(customer_id),
    foreign key (staff_id) references staff(staff_id),
    foreign key (rental_id) references rental(rental_id), 
    constraint chk_amt check (amount >= 0) 
);


