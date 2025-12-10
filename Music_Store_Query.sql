/* 
   DIGITAL MUSIC STORE ANALYSIS - SQL PROJECT -MySQL */


/* Q1: Who is the senior most employee based on job title? */
SELECT title, last_name, first_name
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Q2: Which countries have the most invoices? */
SELECT billing_country, COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

/* Q3: What are the top 3 highest invoice totals? */
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Q4: Which city has the highest sum of invoice totals?
   Return city name and sum of sales */
SELECT billing_city, SUM(total) AS total_invoice_value
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice_value DESC
LIMIT 1;

/* Q5: Who is the best customer based on total spending? */
SELECT c.customer_id, c.first_name, c.last_name,
       SUM(i.total) AS total_spending
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spending DESC
LIMIT 1;



/* Q6: Return email, first name, last name, and genre of all Rock music listeners.
   Order results alphabetically by email */
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoiceline il ON i.invoice_id = il.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

/* Q2: Top 10 artists who have created the most Rock music */
SELECT a.artist_id, a.name,
       COUNT(*) AS number_of_songs
FROM track t
JOIN album al ON al.album_id = t.album_id
JOIN artist a ON a.artist_id = al.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY number_of_songs DESC
LIMIT 10;

/* Q7: List all tracks longer than the average song length.
   Return track name & milliseconds sorted longest first */
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;




 /*Q8: How much has each customer spent on the best-selling artist?
   Return customer name, artist name, total amount spent */
WITH best_selling_artist AS (
    SELECT a.artist_id, a.name AS artist_name,
           SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    JOIN album al ON al.album_id = t.album_id
    JOIN artist a ON a.artist_id = al.artist_id
    GROUP BY a.artist_id, a.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name,
       bsa.artist_name,
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

/* Q9: Most popular music genre in each country (based on quantity purchased).
   If tie, return all genres */
WITH popular_genre AS (
    SELECT c.country, g.name AS genre_name, g.genre_id,
           COUNT(il.quantity) AS purchases,
           ROW_NUMBER() OVER (
               PARTITION BY c.country
               ORDER BY COUNT(il.quantity) DESC
           ) AS rn
    FROM invoice_line il
    JOIN invoice i ON i.invoice_id = il.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name, g.genre_id
)
SELECT country, genre_name, purchases
FROM popular_genre
WHERE rn = 1
ORDER BY country;

/* Q10: Customer who spent the most in each country.
   If tie, return all customers */
WITH spending AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           c.country, SUM(i.total) AS total_spent,
           ROW_NUMBER() OVER (
               PARTITION BY c.country
               ORDER BY SUM(i.total) DESC
           ) AS rn
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT country, customer_id, first_name, last_name, total_spent
FROM spending
WHERE rn = 1
ORDER BY country;







