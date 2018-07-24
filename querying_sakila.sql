USE sakila;

-- 1a: Display the first and last names of all actors from the table actor
SELECT first_name, last_name
FROM actor
;

-- 1b: Display the first and last name of each actor in a single column in upper case letters.
-- Name the column 'Actor Name'.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor
;

-- 2a: You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "JOE"
;
 
-- 2b: Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE "%GEN%"
;

-- 2c: Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order
SELECT last_name, first_name FROM actor
WHERE last_name LIKE "%LI%"
;

-- 2d: Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China')
;

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(45) AFTER first_name
;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY COLUMN middle_name BLOB
;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name
;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) AS shared_last_name_count
FROM actor 
GROUP BY last_name
;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*) AS shared_last_name_count
FROM actor
GROUP BY last_name
HAVING shared_last_name_count >= 2
;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;

UPDATE actor
SET first_name = REPLACE(first_name, 'GROUCHO', 'HARPO')
WHERE first_name LIKE ('GROUCHO')
;

SELECT first_name, last_name FROM actor
WHERE last_name LIKE "WILLIAMS"
;

SELECT first_name, last_name FROM actor
WHERE first_name LIKE "HARPO"
;


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
-- START TRANSACTION;

UPDATE actor
SET first_name = CASE WHEN first_name = 'HARPO' AND last_name = 'WILLIAMS' THEN 'GROUCHO'
ELSE first_name
END
WHERE first_name IN ('HARPO')
;

SELECT first_name, last_name FROM actor
WHERE last_name LIKE "WILLIAMS"
;

-- COMMIT;
-- ROLLBACK;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address
;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT staff.staff_id, staff.first_name, staff.last_name, address.address, address.address2
FROM staff
INNER JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount) AS 'Payment in Aug 2005'
FROM staff
INNER JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY staff.staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
SELECT film.title, count(film_actor.film_id) AS 'Amount of Actors'
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.title
;

-- this should return 10 unique actor_ids for film id 1 to verify:
-- SELECT actor_id FROM film_actor
-- WHERE film_id = 1;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, count(inventory.inventory_id) AS 'Amount in Inventory'
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
WHERE film.title = 'HUNCHBACK IMPOSSIBLE'
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
SELECT customer.first_name, customer.last_name, sum(payment.amount) AS 'Total Amt Paid'
FROM customer
INNER JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM language;
-- language_id 1 = English

SELECT title, language_id
FROM film
WHERE film_id IN
(
	SELECT film_id
	FROM film
	WHERE title LIKE 'K%' OR title LIKE 'Q%'
)
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN
		(
		SELECT film_id
		FROM film
		WHERE title = 'ALONE TRIP'
		)
	)
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN address USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id)
WHERE country = 'Canada'
; 

-- canada is country_id 20
-- select * from country;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN
(
	SELECT film_id 
    FROM film_category
    WHERE category_id IN
    (
    SELECT category_id FROM category
    WHERE name LIKE 'Family'
    )
)
;

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, count(p.rental_id) AS 'Times Rented'
FROM film f
JOIN inventory USING (film_id)
JOIN rental USING (inventory_id)
JOIN payment p USING (rental_id)
GROUP BY title
ORDER BY 'Times Rented' DESC
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT sum(payment.amount), store.store_id
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN staff ON rental.staff_id = staff.staff_id
JOIN store ON staff.store_id = store.store_id
GROUP BY staff.store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name AS 'Genre', sum(payment.amount)
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres_revenue AS
	SELECT category.name AS 'Genre', sum(payment.amount)
	FROM category
	JOIN film_category ON category.category_id = film_category.category_id
	JOIN film ON film_category.film_id = film.film_id
	JOIN inventory ON film.film_id = inventory.film_id
	JOIN rental ON inventory.inventory_id = rental.inventory_id
	JOIN payment ON rental.rental_id = payment.rental_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5
	;
    
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres_revenue
;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres_revenue
;