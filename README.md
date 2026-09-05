# Customer Segmentation & Retention Analysis (RFM)

A SQL + Power BI case study identifying high-value customers, tracking retention, and flagging churn risk using the Online Retail dataset (406,829 transactions).

## Business Question
Which customers drive the most revenue, how well are we retaining customers over time, and which segments are showing early signs of churn?

## Approach
1. **Data prep**: Cleaned the Online Retail dataset (dropped null CustomerIDs) using Python/Pandas.
2. **RFM Scoring (SQL)**: Calculated Recency, Frequency, and Monetary scores per customer using PostgreSQL window functions (`NTILE`), combined into segment labels (Champions, Loyal Customers, At Risk, Needs Attention, Lost, New Customers). See [`sql/01_rfm_scoring.sql`](sql/01_rfm_scoring.sql).
3. **Cohort Retention (SQL)**: Grouped customers by first-purchase month and tracked how many remained active in each subsequent month, converting raw counts into a `retention_pct` (using `FIRST_VALUE` window function against each cohort's month-0 size) so retention is comparable across cohorts of different starting sizes. See [`sql/02_cohort_retention.sql`](sql/02_cohort_retention.sql).
4. **Dashboard (Power BI)**: Built a 3-page interactive dashboard on top of the SQL outputs — segment distribution, revenue contribution, a cohort retention heatmap, a segment slicer, and a churn-risk flag (`Churn_Risk` DAX column, based on recency score).

## Dashboard

### 1. RFM Overview
Customer count and revenue contribution by segment, with a segment slicer.
![RFM Overview](screenshots/01_rfm_overview.png)

### 2. Cohort Retention
Month-by-month retention percentage per acquisition cohort.
![Cohort Retention](screenshots/02_cohort_retention.png)

### 3. Churn Risk
Customers flagged "At Risk" (low recency score) broken down by RFM segment.
![Churn Risk](screenshots/03_churn_risk.png)

## Key Findings
- **"At Risk" is both the largest segment by customer count and the top revenue contributor** — the majority of current revenue is concentrated in a segment showing clear churn signals, not in "safe" segments like Champions or Loyal Customers.
- Churn risk isn't confined to low-value customers — some Champions and Loyal Customers also carry an "At Risk" flag based on recency, meaning even historically valuable customers can go quiet.
- Retention drops off early in a cohort's lifecycle and then stabilizes, so the first couple of months after acquisition are the highest-leverage window for re-engagement.

## Recommendation
Retention should be the priority over acquisition: with this much revenue concentrated in a churn-prone segment, a targeted win-back campaign for "At Risk" customers — especially the high-monetary-value ones — likely has more upside than spending further on new customer acquisition. Given the early drop-off pattern in the cohort data, introducing a structured onboarding or follow-up touchpoint in the first 1-2 months post-first-purchase would also help prevent customers from reaching "At Risk" status in the first place.
## Tech Stack
- **PostgreSQL** — RFM scoring and cohort retention logic (window functions: `NTILE`, `FIRST_VALUE`)
- **Python / Pandas** — data cleaning and preprocessing
- **Power BI** — interactive dashboard (segment slicer, DAX calculated column for churn risk, matrix visual with conditional formatting)

## Repo Structure
```
├── data/                       # Raw dataset
├── notebooks/                  # Data cleaning notebook
├── sql/                        # RFM scoring and cohort retention SQL
├── outputs/                    # SQL query outputs (CSV)
├── screenshots/                # Dashboard screenshots
└── rfm_segmentation_dashboard.pbix   # Power BI dashboard file
```
