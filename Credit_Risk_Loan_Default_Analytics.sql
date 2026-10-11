CREATE DATABASE IF NOT EXISTS credit_risk_analytics;
USE credit_risk_analytics;

-- =====================================================
-- CREDIT RISK & LOAN DEFAULT ANALYTICS
-- Author: Tanvi Kamat
-- =====================================================

-- 1. FIX BORROWER_ID COLUMN NAME IF REQUIRED
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'loan_data'
      AND COLUMN_NAME = 'ï»¿Borrower_ID'
);

SET @rename_sql = IF(
    @column_exists > 0,
    'ALTER TABLE loan_data CHANGE COLUMN `ï»¿Borrower_ID` Borrower_ID VARCHAR(50)',
    'SELECT ''Borrower_ID column already has a standard name'' AS Status'
);

PREPARE stmt FROM @rename_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. OVERALL LOAN PORTFOLIO SUMMARY
SELECT
    COUNT(*) AS Total_Loans,
    COUNT(DISTINCT Borrower_ID) AS Unique_Borrowers,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct,
    ROUND(AVG(Loan_Amount_INR), 2) AS Average_Loan_Amount,
    ROUND(AVG(Credit_Score), 2) AS Average_Credit_Score,
    ROUND(AVG(Interest_Rate_Pct), 2) AS Average_Interest_Rate,
    ROUND(AVG(Debt_to_Income_Ratio), 3) AS Average_DTI
FROM loan_data;

-- 3. DEFAULT RATE BY LOAN TYPE
SELECT
    Loan_Type,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY Loan_Type
ORDER BY Default_Rate_Pct DESC;

-- 4. DEFAULT RATE BY REGION
SELECT
    Region,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY Region
ORDER BY Default_Rate_Pct DESC;

-- 5. DEFAULT RATE BY EMPLOYMENT STATUS
SELECT
    Employment_Status,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY Employment_Status
ORDER BY Default_Rate_Pct DESC;

-- 6. CREDIT SCORE RISK SEGMENTS
SELECT
    CASE
        WHEN Credit_Score < 580 THEN 'Poor'
        WHEN Credit_Score < 670 THEN 'Fair'
        WHEN Credit_Score < 740 THEN 'Good'
        ELSE 'Very Good'
    END AS Credit_Score_Band,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY
    CASE
        WHEN Credit_Score < 580 THEN 'Poor'
        WHEN Credit_Score < 670 THEN 'Fair'
        WHEN Credit_Score < 740 THEN 'Good'
        ELSE 'Very Good'
    END
ORDER BY Default_Rate_Pct DESC;

-- 7. DEFAULT RATE BY DEBT-TO-INCOME RATIO
SELECT
    CASE
        WHEN Debt_to_Income_Ratio < 0.20 THEN 'Low DTI'
        WHEN Debt_to_Income_Ratio < 0.35 THEN 'Moderate DTI'
        ELSE 'High DTI'
    END AS DTI_Band,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY
    CASE
        WHEN Debt_to_Income_Ratio < 0.20 THEN 'Low DTI'
        WHEN Debt_to_Income_Ratio < 0.35 THEN 'Moderate DTI'
        ELSE 'High DTI'
    END
ORDER BY Default_Rate_Pct DESC;

-- 8. DEFAULT RATE BY CREDIT UTILIZATION
SELECT
    CASE
        WHEN Credit_Utilization_Ratio < 0.30 THEN 'Low Utilization'
        WHEN Credit_Utilization_Ratio < 0.60 THEN 'Moderate Utilization'
        ELSE 'High Utilization'
    END AS Utilization_Band,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY
    CASE
        WHEN Credit_Utilization_Ratio < 0.30 THEN 'Low Utilization'
        WHEN Credit_Utilization_Ratio < 0.60 THEN 'Moderate Utilization'
        ELSE 'High Utilization'
    END
ORDER BY Default_Rate_Pct DESC;

-- 9. DEFAULT RATE BY PREVIOUS DEFAULT HISTORY
SELECT
    CASE
        WHEN Previous_Default_Count = 0 THEN 'No Previous Defaults'
        ELSE 'Previous Defaults'
    END AS Default_History,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY
    CASE
        WHEN Previous_Default_Count = 0 THEN 'No Previous Defaults'
        ELSE 'Previous Defaults'
    END;

-- 10. LOAN AMOUNT AND DEFAULT RISK
SELECT
    CASE
        WHEN Loan_Amount_INR < 500000 THEN 'Below 5 Lakh'
        WHEN Loan_Amount_INR < 1500000 THEN '5–15 Lakh'
        ELSE 'Above 15 Lakh'
    END AS Loan_Amount_Band,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(AVG(Loan_Amount_INR), 2) AS Average_Loan_Amount,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY
    CASE
        WHEN Loan_Amount_INR < 500000 THEN 'Below 5 Lakh'
        WHEN Loan_Amount_INR < 1500000 THEN '5–15 Lakh'
        ELSE 'Above 15 Lakh'
    END
ORDER BY Default_Rate_Pct DESC;

-- 11. INTEREST RATE AND DEFAULT RISK
SELECT
    CASE
        WHEN Interest_Rate_Pct < 8 THEN 'Below 8%'
        WHEN Interest_Rate_Pct < 12 THEN '8–12%'
        ELSE '12% and Above'
    END AS Interest_Rate_Band,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY
    CASE
        WHEN Interest_Rate_Pct < 8 THEN 'Below 8%'
        WHEN Interest_Rate_Pct < 12 THEN '8–12%'
        ELSE '12% and Above'
    END
ORDER BY Default_Rate_Pct DESC;

-- 12. MONTHLY LOAN APPLICATION TRENDS
SELECT
    DATE_FORMAT(Application_Date, '%Y-%m') AS Application_Month,
    COUNT(*) AS Total_Applications,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY DATE_FORMAT(Application_Date, '%Y-%m')
ORDER BY Application_Month;

-- 13. DEFAULT RATE BY AGE GROUP
SELECT
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age < 45 THEN '30–44'
        WHEN Age < 60 THEN '45–59'
        ELSE '60+'
    END AS Age_Group,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age < 45 THEN '30–44'
        WHEN Age < 60 THEN '45–59'
        ELSE '60+'
    END
ORDER BY Default_Rate_Pct DESC;

-- 14. TOP 10 HIGH-RISK LOAN TYPES AND REGIONS
SELECT
    Loan_Type,
    Region,
    COUNT(*) AS Total_Loans,
    SUM(Default_Flag) AS Defaulted_Loans,
    ROUND(100.0 * SUM(Default_Flag) / COUNT(*), 2)
        AS Default_Rate_Pct
FROM loan_data
GROUP BY Loan_Type, Region
HAVING COUNT(*) >= 2
ORDER BY Default_Rate_Pct DESC, Total_Loans DESC
LIMIT 10;

-- 15. HIGH-RISK BORROWER REVIEW
SELECT
    Borrower_ID,
    Credit_Score,
    Annual_Income_INR,
    Loan_Type,
    Loan_Amount_INR,
    Interest_Rate_Pct,
    Debt_to_Income_Ratio,
    Credit_Utilization_Ratio,
    Previous_Default_Count,
    Default_Flag
FROM loan_data
WHERE Default_Flag = 1
ORDER BY Credit_Score ASC, Debt_to_Income_Ratio DESC
LIMIT 20;