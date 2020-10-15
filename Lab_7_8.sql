
/*
Lab | SQL Queries 7

Instructions

1. Which last names are not repeated?
2. Which last names appear more than once?
3. Rentals by employee.
4. Films by year.
5. Films by rating.
6. Mean length by rating.
7. Which kind of movies (rating) have a mean duration of more than two hours?
8. List movies and add information of average duration for their rating and original language.
9. Which rentals are longer than expected?
*/

#1. Which last names are not repeated?
use sakila;
select last_name from actor
group by last_name
having count(last_name) = 1;

#2. Which last names appear more than once?
select last_name from actor
group by last_name
having count(last_name) > 1;

#3. (how many) Rentals by employee.
select staff_id, count(*) from rental -- we can count anything groupped by staff_id in this case 
group by staff_id;

#4. (how many) Films by year.
select release_year, count(title) from film  -- counting titles within release year
group by release_year;

#5. (how many) Films by rating.
select rating, count(title) from film  -- counting titles within rating
group by rating;

#6. Mean length by rating.
select rating, round(avg(length),0) as mean_length from film  -- counting titles within rating
group by rating;

#7. Which kind of movies (rating) have a mean duration of more than two hours? #checking 110 mins as non with 2 hrs
select rating, round(avg(length),0) as mean_length from film  -- counting titles within rating
group by rating
having mean_length > 110;

#8. List movies and add information of average duration for their rating and original language.
select film_id, title, rating, original_language_id, 
avg(length) over (partition by rating, original_language_id) as average
from film
order by rating, original_language_id;

#if we want a separate column for rating/original language
select film_id, title, rating, original_language_id, 
avg(length) over (partition by rating) as average_by_rating,
avg(length) over (partition by original_language_id) as average_by_lang
from film
order by rating, original_language_id;


#9. Which rentals are longer than expected (interpreting = average as we can't use join yet)?
select * from (select inventory_id, rental_id, datediff(return_date, rental_date) rental_duration,
	avg(datediff(return_date, rental_date)) over (partition by inventory_id) average from rental) as smth
where rental_duration > average
	;




/*
Lab | SQL Queries 8

Instructions

1. Rank films by length.
2. Rank films by length within the rating category.
3. Rank languages by the number of films (as original language).
4. Rank categories by the number of films.
5. Which actor has appeared in the most films?
6. Most active customer.
7. Most rented film.
*/

#1. Rank films by length.
select title, length, dense_rank() over (order by length desc) as ranking 
from film;

#2. Rank films by length within the rating category.
select title, rating, length, 
dense_rank() over (partition by rating order by length desc) as ranking 
from film;

#3. Rank languages by the number of films (as original language).
-- film column 
select * from language;
select original_language_id, language.name, count(film_id), rank() over (order by count(film_id)) from film
join language on language.language_id = film.original_language_id
group by language.language_id, language.name;
;

-- try ranking ratings by the number of films
select rating, count(film_id), rank() over (order by count(film_id) ) from film
group by rating;

#4. Rank categories by the number of films.
select * from category;
select* from film_category;
-- category_id in category
-- film_id in film_category
-- category_id in film_category 

select c.category_id, c.name, count(fc.film_id) as number_of_films, rank() over (order by count(fc.film_id)) as ranking 
from category as c
join film_category as fc on c.category_id = fc.category_id
group by c.category_id, c.name
;

#5. Which actor has appeared in the most films?
select * from film_actor;
select * from actor;

select a.actor_id, a.first_name, a.last_name, count(fa.film_id) as number_of_films from actor as a
join film_actor as fa on a.actor_id = fa.actor_id
group by a.actor_id, a.first_name, a.last_name
order by count(fa.film_id) desc
limit 1;

#6. Most active customer. (looking at most rentals per customer).
select * from rental;
select * from customer;

select c.customer_id, c.first_name, c.last_name, count(r.rental_id) as nubmer_of_rental from customer as c
join rental as r on c.customer_id = r.customer_id
group by c.customer_id, c.first_name, c.last_name
order by count(r.rental_id) desc
limit 1;

#7. Most rented film.
select * from rental;
select * from inventory;
select * from film;

select i.film_id, f.title, count(r.rental_id) as number_of_rentals from rental as r
join inventory as i on i.inventory_id = r.inventory_id
join film as f on f.film_id = i.film_id
group by i.film_id, f.title
order by count(r.rental_id)  desc
limit 1;

#checnking the quantity of rentals overall:

select count(*) from rental;

select sum(number_of_rentals) from 
(select i.film_id, f.title, count(r.rental_id) as number_of_rentals from rental as r
join inventory as i on i.inventory_id = r.inventory_id
join film as f on f.film_id = i.film_id
group by i.film_id, f.title
order by count(r.rental_id)  desc) as x;