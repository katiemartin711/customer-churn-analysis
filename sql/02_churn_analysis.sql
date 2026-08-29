-- =============================================================================
-- Project 1: Telco Customer Churn - Exploratory Data Analysis & Business Metrics
-- Database Engine: PostgreSQL
-- Author: Katie Martin
-- Description: Analyzes overall churn rates, revenue impact, service adoption,
--              contract risks, and tenure cohorts to isolate key retention drivers.
-- =============================================================================

--------------------------------------------------------------------------------
-- 1. EXECUTIVE OVERVIEW: OVERALL CHURN & REVENUE LOSS
--------------------------------------------------------------------------------
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


--------------------------------------------------------------------------------
-- 2. CHURN BY CONTRACT TYPE (RISK SEGMENTATION)
--------------------------------------------------------------------------------
SELECT 
    "Contract",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        (100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*))::numeric, 
        2
    ) AS churn_rate_pct,
    ROUND(AVG("MonthlyCharges")::numeric, 2) AS avg_monthly_charges
FROM telco_customer_churn
GROUP BY "Contract"
ORDER BY churn_rate_pct DESC;


--------------------------------------------------------------------------------
-- 3. CHURN BY TENURE COHORT (LIFECYCLE ANALYSIS)
--------------------------------------------------------------------------------
SELECT 
    tenure_cohort,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        (100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*))::numeric, 
        2
    ) AS churn_rate_pct
FROM telco_customer_churn
GROUP BY tenure_cohort
ORDER BY tenure_cohort ASC;


--------------------------------------------------------------------------------
-- 4. INTERNET SERVICE & TECH SUPPORT IMPACT ON CHURN
--------------------------------------------------------------------------------
SELECT 
    "InternetService",
    "TechSupport",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        (100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*))::numeric, 
        2
    ) AS churn_rate_pct
FROM telco_customer_churn
GROUP BY "InternetService", "TechSupport"
ORDER BY churn_rate_pct DESC;


--------------------------------------------------------------------------------
-- 5. PAYMENT METHOD & SENIOR CITIZEN RISK PROFILES
--------------------------------------------------------------------------------
SELECT 
    "PaymentMethod",
    "SeniorCitizen",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        (100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*))::numeric, 
        2
    ) AS churn_rate_pct
FROM telco_customer_churn
GROUP BY "PaymentMethod", "SeniorCitizen"
ORDER BY churn_rate_pct DESC;