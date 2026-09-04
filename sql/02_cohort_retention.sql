-- Cohort retention analysis: group customers by first purchase month,
-- track how many remain active in each subsequent month
WITH first_purchase AS (
  SELECT
    "CustomerID",
    DATE_TRUNC('month', MIN("InvoiceDate")) AS cohort_month
  FROM transactions
  GROUP BY "CustomerID"
),
customer_activity AS (
  SELECT
    t."CustomerID",
    DATE_TRUNC('month', t."InvoiceDate") AS activity_month,
    fp.cohort_month
  FROM transactions t
  JOIN first_purchase fp ON t."CustomerID" = fp."CustomerID"
),
cohort_data AS (
  SELECT
    cohort_month,
    activity_month,
    COUNT(DISTINCT "CustomerID") AS active_customers,
    EXTRACT(YEAR FROM AGE(activity_month, cohort_month)) * 12 +
    EXTRACT(MONTH FROM AGE(activity_month, cohort_month)) AS month_number
  FROM customer_activity
  GROUP BY cohort_month, activity_month
)
SELECT
  cohort_month,
  month_number,
  active_customers,
  ROUND(
    active_customers::decimal /
    FIRST_VALUE(active_customers) OVER (PARTITION BY cohort_month ORDER BY month_number)
    * 100, 1
  ) AS retention_pct
FROM cohort_data
ORDER BY cohort_month, month_number;