-- =============================================================================
-- Project 1: Telco Customer Churn - Data Cleaning & Schema Preparation
-- Database Engine: PostgreSQL
-- Author: Katie Martin
-- Description: Sanitizes raw CSV imports, fixes data typing issues, updates NULLs,
--              and creates structured calculated columns for analytical queries.
-- =============================================================================

--------------------------------------------------------------------------------
-- 1. INSPECT RAW SCHEMA & RECORD COUNTS
--------------------------------------------------------------------------------
-- Verify target row count (Expected: 7043)
SELECT COUNT(*) AS raw_row_count FROM telco_customer_churn;

-- Inspect structural data types assigned during import
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'telco_customer_churn';


--------------------------------------------------------------------------------
-- 2. HANDLE BLANKS AND CONVERT DATA TYPES
--------------------------------------------------------------------------------
-- In the Kaggle dataset, TotalCharges contains ' ' (blank spaces) for 11 customers 
-- with tenure = 0. Step A updates these blank spaces to true SQL NULL values.

UPDATE telco_customer_churn 
SET "TotalCharges" = NULL 
WHERE "TotalCharges" = ' ' OR "TotalCharges" = '';

-- Step B: Convert TotalCharges column from VARCHAR to NUMERIC
ALTER TABLE telco_customer_churn 
ALTER COLUMN "TotalCharges" TYPE NUMERIC 
USING "TotalCharges"::NUMERIC;

-- Step C: Set SeniorCitizen from INT (0/1) to BOOLEAN for readability
ALTER TABLE telco_customer_churn 
ALTER COLUMN "SeniorCitizen" TYPE BOOLEAN 
USING CASE WHEN "SeniorCitizen" = 1 THEN TRUE ELSE FALSE END;


--------------------------------------------------------------------------------
-- 3. CHECK AND REMOVE DUPLICATE RECORDS
--------------------------------------------------------------------------------
-- Ensure customerID is unique and identify any accidental duplication
SELECT 
    "customerID", 
    COUNT(*) AS instance_count
FROM telco_customer_churn
GROUP BY "customerID"
HAVING COUNT(*) > 1;

-- Set customerID as the Primary Key to enforce uniqueness
ALTER TABLE telco_customer_churn 
ADD CONSTRAINT pk_telco_customer_churn PRIMARY KEY ("customerID");


--------------------------------------------------------------------------------
-- 4. STANDARDIZE TEXT & CATEGORICAL VALUES
--------------------------------------------------------------------------------
-- Verify distinct values across key categorical fields to check for typos or inconsistencies
SELECT DISTINCT "Contract" FROM telco_customer_churn;
SELECT DISTINCT "PaymentMethod" FROM telco_customer_churn;
SELECT DISTINCT "InternetService" FROM telco_customer_churn;

-- Standardize values if necessary (e.g., removing leading/trailing spaces)
UPDATE telco_customer_churn
SET "PaymentMethod" = TRIM("PaymentMethod");


--------------------------------------------------------------------------------
-- 5. CREATE DERIVED / FEATURE COLUMNS FOR ANALYSIS
--------------------------------------------------------------------------------
-- Add a Tenure Cohort column to bucket customer lifecycle duration easily 
-- (e.g., 0-1 Year, 1-2 Years, 2-4 Years, 4-5 Years, 5+ Years)

ALTER TABLE telco_customer_churn ADD COLUMN tenure_cohort VARCHAR(30);

UPDATE telco_customer_churn
SET tenure_cohort = CASE 
    WHEN tenure <= 12 THEN '01. 0-1 Year'
    WHEN tenure BETWEEN 13 AND 24 THEN '02. 1-2 Years'
    WHEN tenure BETWEEN 25 AND 48 THEN '03. 2-4 Years'
    WHEN tenure BETWEEN 49 AND 60 THEN '04. 4-5 Years'
    WHEN tenure > 60 THEN '05. 5+ Years'
    ELSE 'Unknown'
END;


--------------------------------------------------------------------------------
-- 6. FINAL DATA CLEANING VALIDATION
--------------------------------------------------------------------------------
-- Confirm NULL counts on critical numerical fields
SELECT 
    COUNT(*) AS total_records,
    COUNT("customerID") AS valid_ids,
    SUM(CASE WHEN "TotalCharges" IS NULL THEN 1 ELSE 0 END) AS null_total_charges,
    SUM(CASE WHEN "MonthlyCharges" IS NULL THEN 1 ELSE 0 END) AS null_monthly_charges
FROM telco_customer_churn;