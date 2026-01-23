WITH doctor_visits AS (
    SELECT
        doctor_id,
        product_promoted,
        COUNT(*) AS visit_count
    FROM gold.fact_sales_visits
    WHERE doctor_id != 'n/a' AND product_promoted != 'n/a'
    GROUP BY doctor_id, product_promoted
), 
doctor_sales AS (
    SELECT
        t.product_name,
        t.pharmacy_id,
        SUM(t.total_value) AS total_sales
    FROM gold.fact_sales_transactions t
    GROUP BY t.product_name, t.pharmacy_id
)
SELECT
    v.visit_count,
    AVG(s.total_sales) AS avg_sales
FROM doctor_visits v
LEFT JOIN doctor_sales s
    ON s.product_name = v.product_promoted
GROUP BY v.visit_count
ORDER BY v.visit_count;
