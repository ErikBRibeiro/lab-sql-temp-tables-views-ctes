USE sakila;

CREATE VIEW customer_rental_summary AS
SELECT 
    customer.customer_id,
    CONCAT(customer.first_name, ' ', customer.last_name) AS name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM customer
JOIN rental ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    customer_rental_summary.customer_id,
    SUM(payment.amount) AS total_paid
FROM customer_rental_summary
JOIN payment ON customer_rental_summary.customer_id = payment.customer_id
GROUP BY customer_rental_summary.customer_id;

WITH customer_summary_cte AS (
    SELECT 
        customer_rental_summary.name,
        customer_rental_summary.email,
        customer_rental_summary.rental_count,
        customer_payment_summary.total_paid
    FROM customer_rental_summary
    JOIN customer_payment_summary ON customer_rental_summary.customer_id = customer_payment_summary.customer_id
)
SELECT 
    name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count
        ELSE 0 
    END AS average_payment_per_rental
FROM customer_summary_cte;
