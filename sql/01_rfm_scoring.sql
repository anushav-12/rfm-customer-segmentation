-- RFM scoring using window functions (NTILE) on CustomerID

WITH rfm_base AS (
  SELECT
    "CustomerID",
    MAX("InvoiceDate") AS last_purchase_date,
    COUNT(DISTINCT "InvoiceNo") AS frequency,
    SUM("TotalAmount") AS monetary
  FROM transactions
  GROUP BY "CustomerID"
),
rfm_scores AS (
  SELECT
    "CustomerID",
    last_purchase_date,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY last_purchase_date DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
  FROM rfm_base
)
SELECT
  *,
  (r_score + f_score + m_score) AS rfm_total,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
    WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
    WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
    ELSE 'Needs Attention'
  END AS segment
FROM rfm_scores
ORDER BY rfm_total DESC;