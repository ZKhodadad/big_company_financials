-- Project: Big companies
-- Author: Zohreh Khodadad
-- Created: 2025-06-27
-- Source: https://www.kaggle.com/datasets/marshuu/worlds-biggest-companies-dataset?select=cleaned_biggest_companies.csv

USE big_companies;

-- Create the Table
CREATE TABLE big_companies
(
company_name varchar(225),	
country_founded	varchar(225),
year_founded int,	
revenue2018 double,	
revenue2019 double,	
revenue2020 double,	
net_income2018 double,	
net_income2019 double,	
net_income2020 double,
industry varchar(225),
category varchar(225)
);

-- Load data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/big_companies/big_companies.csv'
INTO TABLE big_companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

-- ===============================================================
-- Q1: Max and Min of Revenue Growth by Industry
-- ===============================================================
-- CTE to caculate revenue growth
WITH IndustryGrowth AS (
    SELECT 
        company_name,
        industry,
        ROUND((revenue2020 - revenue2018) / (revenue2018) * 100, 2) AS revenue_growth_pct
    FROM big_companies
)

-- Print max and min growth alongside compay name and their category
(
    SELECT company_name, industry, revenue_growth_pct
    FROM IndustryGrowth
    ORDER BY revenue_growth_pct DESC
    LIMIT 1
)

UNION ALL

(
    SELECT company_name, industry, revenue_growth_pct
    FROM IndustryGrowth
    ORDER BY revenue_growth_pct ASC
    LIMIT 1
)

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/big_companies/q1_output.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

-- ===========================================================================
-- Q2: Compare companies based on their avg income, margin, and profit over these 3 years
-- ===========================================================================
-- Margin
WITH MarginCTE AS (
    SELECT 
        company_name,
        category,
        ROUND(((net_income2018 + net_income2019 + net_income2020) / 3) * 100 
              / ((revenue2018 + revenue2019 + revenue2020) / 3), 2) AS avg_margin_percent
    FROM big_companies
)

SELECT *
FROM MarginCTE
ORDER BY avg_margin_percent DESC
LIMIT 10

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/big_companies/q2_margin_output.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Net income
WITH IncomeCTE AS (
    SELECT 
        company_name,
        category,
        ROUND((net_income2018 + net_income2019 + net_income2020) / 3, 2) AS avg_net_income
    FROM big_companies
)
SELECT *
FROM IncomeCTE
ORDER BY avg_net_income DESC
LIMIT 10

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/big_companies/q2_income_output.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Revenue
WITH RevenueCTE AS (
    SELECT 
        company_name,
        category,
        ROUND((revenue2018 + revenue2019 + revenue2020) / 3, 2) AS avg_revenue
    FROM big_companies
)
SELECT *
FROM RevenueCTE
ORDER BY avg_revenue DESC
LIMIT 10

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/big_companies/q2_revenue_output.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- ==================================================================
-- Q3: How many companies are in a country?
-- ==================================================================
SELECT
    country_founded,
    category,
    COUNT(*) AS company_count         -- count rows for each combination of country_founded and category
FROM big_companies
GROUP BY country_founded, category
ORDER BY country_founded, category

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/big_companies/q3_distribution_output.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- ====================================================================
-- Q4: Detailed v of Q3 by only focusing on 10 first countries
-- ====================================================================
-- Get the total company count by country, we need this to find 10 first countries
WITH CountryCompanyCount AS (
    SELECT 
        country_founded AS country,
        COUNT(*) AS company_count
    FROM big_companies
    GROUP BY country_founded
    ORDER BY company_count DESC
    LIMIT 10
)

-- Join with original data to get industry info and filter top countries
SELECT 
    bc.country_founded AS country,
    bc.category,
    COUNT(*) AS industry_company_count
FROM big_companies bc
JOIN CountryCompanyCount cc
ON bc.country_founded = cc.country
GROUP BY bc.country_founded, bc.category
ORDER BY country, industry_company_count DESC

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/big_companies/q4_10_countries_output.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';






















