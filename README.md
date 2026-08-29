# 📊 Telco Customer Churn & Retention Analysis

## 🎯 Executive Overview
This project evaluates customer retention dynamics for a telecommunications provider using a dataset of **7,043 customer records**. The analysis focuses on quantifying revenue loss, identifying high-risk contract types, and pinpointing critical lifecycle tenure windows to inform targeted retention strategies.

### 🔑 Key Business Findings
* **Baseline Churn:** The overall customer churn rate is **26.54%** (1,869 churned customers), resulting in significant recurring revenue loss.
* **Contract Risk Segmentation:** Month-to-Month contract holders exhibit a **42.71% churn rate**, compared to **11.27%** for 1-Year contracts and **2.83%** for 2-Year contracts.
* **Early Lifecycle Drop-Off:** Retention risk is heavily concentrated in the first year of service. The **0–1 Year tenure cohort experiences a 47.44% churn rate**, after which churn rates drop significantly (reaching 28.71% in Year 2 and declining steadily thereafter).

---

## 🛠️ Data Architecture & Cleaning (`01_data_cleaning.sql`)

Prior to analytical execution, raw transactional data was cleaned, validated, and transformed in PostgreSQL to ensure data integrity and query efficiency:

- **Handling Blank Numeric Values:** Identified 11 customer records with empty string values (`' '`) in the `TotalCharges` column (corresponding to new customers with 0 months tenure). Converted these spaces to SQL `NULL` values to allow numeric conversion without skewing aggregates.
- **Data Type Casting:** Cast `TotalCharges` from `VARCHAR` to `NUMERIC` to facilitate financial aggregation (`SUM`, `AVG`).
- **Primary Key Constraint:** Enforced `customerID` as a unique Primary Key after verifying zero duplicate records (`HAVING COUNT(*) > 1` returned 0 rows).
- **Feature Engineering (`tenure_cohort`):** Engineered a categorical feature column bucketing tenure into 12-month cohorts (`01. 0-1 Year`, `02. 1-2 Years`, etc.) to isolate retention bottlenecks across customer lifecycles.
- **Precision Rounding:** Standardized explicit `::numeric` type casting within percentage calculations to handle PostgreSQL-specific floating-point arithmetic.

---

## 📈 Analytical Methodology (`02_churn_analysis.sql`)

Exploratory Data Analysis was executed through modular SQL queries designed to answer core business questions:

### 1. Overall Metrics & Financial Impact
```sql
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        (100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*))::numeric, 
        2
    ) AS churn_rate_pct,
    ROUND(SUM("MonthlyCharges")::numeric, 2) AS total_monthly_revenue,
    ROUND(
        SUM(CASE WHEN "Churn" = 'Yes' THEN "MonthlyCharges" ELSE 0 END)::numeric, 
        2
    ) AS churned_monthly_revenue_lost
FROM telco_customer_churn;
```
---

## 📊 Tableau Public Interactive Dashboard

An interactive dashboard was built using **Tableau Public** to enable stakeholders to explore key churn risk drivers, drill down into customer cohorts, and isolate specific high-risk service profiles in real time.

* **Live Dashboard:** [Telco Customer Churn & Retention Executive Dashboard](https://public.tableau.com/views/telco_churn_dashboard_17879729789630/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### Key Features & Design Architecture
* **Executive Summary Panel:** Instant visibility into overall business performance metrics, including **Total Revenue ($16.06M)** and baseline dataset churn rate.
* **Contract Risk Breakdown:** Visualizes customer concentration across contract types, highlighting **Month-to-month contracts** as the primary driver of churn (**42.71%**).
* **Tenure Cohort Analysis:** Identifies customer lifecycle drop-off patterns, demonstrating that **47.44%** of churned users leave within their first year of service.
* **Service Risk Matrix:** Maps the intersection of Internet Service and Tech Support, isolating **Fiber Optic customers without Tech Support** as the highest-risk segment (**49.37%** churn).
* **Cross-Filtering & Interactivity:** Built-in filter actions and hover highlights allow dynamic drill-down across all four views upon selecting any contract, tenure cohort, or service combination.