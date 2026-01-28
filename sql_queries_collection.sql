# SQL Query Collection - Retail Alcohol Sales Analysis
# Author: Asees Anwar
# Database: PostgreSQL (retail_project)
# Date: January 2026

# ============================================================
# SECTION 1: DATA QUALITY CHECKS
# ============================================================

-- Query 1.1: Check for missing values across key columns
-- Purpose: Identify data quality issues before analysis
SELECT 
    COUNT(*) - COUNT("RETAIL SALES") as missing_retail_sales,
    COUNT(*) - COUNT("SUPPLIER") as missing_supplier,
    COUNT(*) - COUNT("ITEM TYPE") as missing_item_type
FROM sales_data;

-- Result: Found 3 missing retail sales, 167 missing suppliers, 1 missing item type


-- Query 1.2: Examine rows with missing retail sales
-- Purpose: Understand what data is missing before deciding to delete
SELECT * 
FROM sales_data 
WHERE "RETAIL SALES" IS NULL 
LIMIT 5;

-- Finding: These were garbage records (RMS ITEM, COUPON, no real product data)


-- Query 1.3: Examine rows with missing supplier information
-- Purpose: Decide whether to keep or delete these records
SELECT * 
FROM sales_data 
WHERE "SUPPLIER" IS NULL OR "SUPPLIER" = ''
LIMIT 10;

-- Finding: Real sales data (ICE, supplies, credits) - worth keeping with "UNKNOWN" label


-- Query 1.4: Comprehensive data completeness check
-- Purpose: Identify which months have data vs which are missing
WITH all_months AS (
    SELECT 
        y.year,
        m.month
    FROM 
        (SELECT 2017 as year UNION SELECT 2018 UNION SELECT 2019 UNION SELECT 2020) y
    CROSS JOIN
        (SELECT 1 as month UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8
         UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) m
),
actual_data AS (
    SELECT DISTINCT 
        CAST("YEAR" AS INTEGER) as year, 
        CAST("MONTH" AS INTEGER) as month
    FROM sales_data
)
SELECT 
    am.year,
    am.month,
    CASE WHEN ad.year IS NOT NULL THEN 'HAS DATA' ELSE 'MISSING' END as status
FROM all_months am
LEFT JOIN actual_data ad ON am.year = ad.year AND am.month = ad.month
ORDER BY am.year, am.month;

-- Finding: Only 24 of 48 months have data (50% complete)
-- 2017: Jun-Dec (7 months)
-- 2018: Jan-Feb only (2 months)
-- 2019: Jan-Nov (11 months) - most complete
-- 2020: Only 4 scattered months


-- Query 1.5: Verify final row count after cleaning
SELECT COUNT(*) as total_rows FROM sales_data;

-- Final count: 307,642 rows


# ============================================================
# SECTION 2: DATA CLEANING QUERIES
# ============================================================

-- Query 2.1: Delete rows with NULL retail sales
-- Rationale: Sales records without sales amounts are unusable
DELETE FROM sales_data 
WHERE "RETAIL SALES" IS NULL;

-- Rows affected: 3


-- Query 2.2: Fill missing supplier information
-- Rationale: Preserve sales data even when supplier is unknown
UPDATE sales_data 
SET "SUPPLIER" = 'UNKNOWN'
WHERE "SUPPLIER" IS NULL OR "SUPPLIER" = '';

-- Rows affected: 167


-- Query 2.3: Fill missing item type
-- Rationale: Product was clearly wine (Barolo) based on description
UPDATE sales_data 
SET "ITEM TYPE" = 'WINE'
WHERE "ITEM TYPE" IS NULL OR "ITEM TYPE" = '';

-- Rows affected: 1


-- Query 2.4: Verify no critical missing values remain
SELECT 
    COUNT(*) as total_rows,
    COUNT(*) - COUNT("RETAIL SALES") as missing_sales,
    COUNT(*) - COUNT("SUPPLIER") as missing_supplier,
    COUNT(*) - COUNT("ITEM TYPE") as missing_item_type
FROM sales_data;

-- Result: All zeros - data is clean


# ============================================================
# SECTION 3: EXPLORATORY ANALYSIS
# ============================================================

-- Query 3.1: Date range of dataset
-- Purpose: Understand temporal coverage
SELECT 
    MIN("YEAR") as earliest_year, 
    MAX("YEAR") as latest_year 
FROM sales_data;

-- Result: 2017 to 2020


-- Query 3.2: Product type breakdown
-- Purpose: Understand product mix
SELECT 
    "ITEM TYPE", 
    COUNT(*) as num_records 
FROM sales_data 
GROUP BY "ITEM TYPE"
ORDER BY num_records DESC;

-- Result: Wine (187,640), Liquor (64,910), Beer (42,413), plus minor categories


-- Query 3.3: Total sales by year
-- Purpose: Identify revenue trends (with caveat about incomplete data)
SELECT 
    "YEAR", 
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_retail_sales
FROM sales_data 
GROUP BY "YEAR" 
ORDER BY "YEAR";

-- Result: 2019 highest ($960k), 2020 lowest ($360k) - but years incomplete


-- Query 3.4: Monthly sales pattern across all years
-- Purpose: Look for overall trends despite missing months
SELECT 
    "YEAR",
    "MONTH",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as monthly_revenue,
    COUNT(*) as num_transactions
FROM sales_data
GROUP BY "YEAR", "MONTH"
ORDER BY "YEAR", "MONTH";

-- Finding: Clear gaps in data, December 2017 shows strong spike


# ============================================================
# SECTION 4: PRODUCT ANALYSIS
# ============================================================

-- Query 4.1: Top 10 products by retail sales
-- Purpose: Identify best-selling consumer products
SELECT 
    "ITEM DESCRIPTION",
    "ITEM TYPE",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_revenue,
    COUNT(*) as num_transactions
FROM sales_data
GROUP BY "ITEM DESCRIPTION", "ITEM TYPE"
ORDER BY total_revenue DESC
LIMIT 10;

-- Key Finding: Tito's Vodka #1 ($27,580), followed by Corona and Heineken beers


-- Query 4.2: Top 10 products by warehouse sales
-- Purpose: Identify what bars/restaurants buy in bulk
SELECT 
    "ITEM DESCRIPTION",
    "ITEM TYPE",
    ROUND(SUM("WAREHOUSE SALES"::numeric), 2) as warehouse_revenue,
    COUNT(*) as num_orders
FROM sales_data
WHERE "WAREHOUSE SALES"::numeric > 0
GROUP BY "ITEM DESCRIPTION", "ITEM TYPE"
ORDER BY warehouse_revenue DESC
LIMIT 10;

-- Key Finding: ALL top 10 are beers, Corona dominates wholesale ($303k)


-- Query 4.3: Product category revenue breakdown
-- Purpose: Understand category mix and efficiency
SELECT 
    "ITEM TYPE",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_revenue,
    ROUND(100.0 * SUM("RETAIL SALES"::numeric) / 
          (SELECT SUM("RETAIL SALES"::numeric) FROM sales_data), 2) as pct_of_total,
    COUNT(DISTINCT "ITEM CODE") as num_products,
    ROUND(SUM("RETAIL SALES"::numeric) / COUNT(DISTINCT "ITEM CODE"), 2) as revenue_per_product
FROM sales_data
GROUP BY "ITEM TYPE"
ORDER BY total_revenue DESC;

-- Key Finding: Liquor most efficient ($179/product), Wine least efficient ($35/product)


-- Query 4.4: Category performance - main categories only
-- Purpose: Focus on core business (exclude minor categories)
SELECT 
    "ITEM TYPE",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_revenue,
    ROUND(100.0 * SUM("RETAIL SALES"::numeric) / 
          (SELECT SUM("RETAIL SALES"::numeric) FROM sales_data 
           WHERE "ITEM TYPE" IN ('LIQUOR', 'WINE', 'BEER')), 2) as pct_of_core_business
FROM sales_data
WHERE "ITEM TYPE" IN ('LIQUOR', 'WINE', 'BEER')
GROUP BY "ITEM TYPE"
ORDER BY total_revenue DESC;

-- Shows clean split: Liquor 37%, Wine 35%, Beer 27%


# ============================================================
# SECTION 5: SUPPLIER ANALYSIS
# ============================================================

-- Query 5.1: Top 10 suppliers by revenue
-- Purpose: Identify most valuable supplier relationships
SELECT 
    "SUPPLIER",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_revenue,
    COUNT(DISTINCT "ITEM CODE") as num_products,
    COUNT(*) as num_transactions,
    ROUND(SUM("RETAIL SALES"::numeric) / COUNT(DISTINCT "ITEM CODE"), 2) as revenue_per_product
FROM sales_data
GROUP BY "SUPPLIER"
ORDER BY total_revenue DESC
LIMIT 10;

-- Key Finding: E & J Gallo leads ($166k, 617 products), but Crown Imports most efficient


-- Query 5.2: Supplier concentration analysis
-- Purpose: Assess business risk from supplier dependency
WITH supplier_revenue AS (
    SELECT 
        "SUPPLIER",
        SUM("RETAIL SALES"::numeric) as revenue
    FROM sales_data
    GROUP BY "SUPPLIER"
),
total_revenue AS (
    SELECT SUM("RETAIL SALES"::numeric) as total FROM sales_data
)
SELECT 
    sr."SUPPLIER",
    ROUND(sr.revenue, 2) as supplier_revenue,
    ROUND(100.0 * sr.revenue / tr.total, 2) as pct_of_total,
    ROUND(SUM(100.0 * sr.revenue / tr.total) OVER (ORDER BY sr.revenue DESC), 2) as cumulative_pct
FROM supplier_revenue sr, total_revenue tr
ORDER BY sr.revenue DESC
LIMIT 15;

-- Shows concentration: Top 5 suppliers = ~30% of revenue


# ============================================================
# SECTION 6: SEASONAL & TEMPORAL ANALYSIS
# ============================================================

-- Query 6.1: Monthly pattern for 2019 (most complete year)
-- Purpose: Understand seasonality without incomplete data distortion
SELECT 
    "MONTH",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as monthly_revenue,
    COUNT(*) as num_transactions,
    ROUND(AVG("RETAIL SALES"::numeric), 2) as avg_transaction_value
FROM sales_data
WHERE "YEAR" = '2019'
GROUP BY "MONTH"
ORDER BY CAST("MONTH" AS INTEGER);

-- Key Finding: November peak ($101k), January low ($76k), 25% variance


-- Query 6.2: Average monthly revenue by month (across all years)
-- Purpose: Identify consistent seasonal patterns
SELECT 
    "MONTH",
    ROUND(AVG(monthly_rev), 2) as avg_revenue,
    COUNT(*) as years_with_data
FROM (
    SELECT 
        "YEAR",
        "MONTH",
        SUM("RETAIL SALES"::numeric) as monthly_rev
    FROM sales_data
    GROUP BY "YEAR", "MONTH"
) subquery
GROUP BY "MONTH"
ORDER BY CAST("MONTH" AS INTEGER);

-- Shows which months appear consistently across years


-- Query 6.3: Day of month pattern (if granular data available)
-- Purpose: Check if data is monthly aggregated or daily
SELECT 
    MIN(CAST("MONTH" AS INTEGER)) as min_month,
    MAX(CAST("MONTH" AS INTEGER)) as max_month,
    COUNT(DISTINCT "MONTH") as unique_months
FROM sales_data
WHERE "YEAR" = '2019';

-- Confirms data is monthly aggregated (not daily transactions)


# ============================================================
# SECTION 7: CHANNEL ANALYSIS (RETAIL VS WHOLESALE)
# ============================================================

-- Query 7.1: Total revenue by channel
-- Purpose: Understand business model (B2B vs B2C)
SELECT 
    ROUND(SUM("RETAIL SALES"::numeric), 2) as retail_revenue,
    ROUND(SUM("WAREHOUSE SALES"::numeric), 2) as warehouse_revenue,
    ROUND(100.0 * SUM("RETAIL SALES"::numeric) / 
          (SUM("RETAIL SALES"::numeric) + SUM("WAREHOUSE SALES"::numeric)), 2) as retail_pct,
    COUNT(CASE WHEN "RETAIL SALES"::numeric > 0 THEN 1 END) as retail_transactions,
    COUNT(CASE WHEN "WAREHOUSE SALES"::numeric > 0 THEN 1 END) as warehouse_transactions
FROM sales_data;

-- Key Finding: Wholesale = 78% of revenue ($7.78M vs $2.16M)


-- Query 7.2: Average transaction size by channel
-- Purpose: Understand customer buying patterns
SELECT 
    'Retail' as channel,
    ROUND(AVG("RETAIL SALES"::numeric), 2) as avg_transaction,
    COUNT(*) as num_transactions
FROM sales_data
WHERE "RETAIL SALES"::numeric > 0
UNION ALL
SELECT 
    'Warehouse' as channel,
    ROUND(AVG("WAREHOUSE SALES"::numeric), 2) as avg_transaction,
    COUNT(*) as num_transactions
FROM sales_data
WHERE "WAREHOUSE SALES"::numeric > 0;

-- Shows warehouse = $37 avg vs retail = $11 avg (bulk vs individual)


-- Query 7.3: Category performance by channel
-- Purpose: See if product mix differs between channels
SELECT 
    "ITEM TYPE",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as retail_revenue,
    ROUND(SUM("WAREHOUSE SALES"::numeric), 2) as warehouse_revenue,
    ROUND(100.0 * SUM("WAREHOUSE SALES"::numeric) / 
          (SUM("RETAIL SALES"::numeric) + SUM("WAREHOUSE SALES"::numeric)), 2) as warehouse_pct
FROM sales_data
WHERE "ITEM TYPE" IN ('LIQUOR', 'WINE', 'BEER')
GROUP BY "ITEM TYPE"
ORDER BY warehouse_revenue DESC;

-- Shows if certain categories are more wholesale-focused


# ============================================================
# SECTION 8: BUSINESS INSIGHTS QUERIES
# ============================================================

-- Query 8.1: Products with highest warehouse-to-retail ratio
-- Purpose: Identify pure wholesale products vs retail products
SELECT 
    "ITEM DESCRIPTION",
    "ITEM TYPE",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as retail_rev,
    ROUND(SUM("WAREHOUSE SALES"::numeric), 2) as warehouse_rev,
    ROUND(SUM("WAREHOUSE SALES"::numeric) / NULLIF(SUM("RETAIL SALES"::numeric), 0), 2) as wholesale_ratio
FROM sales_data
WHERE "RETAIL SALES"::numeric > 0 AND "WAREHOUSE SALES"::numeric > 0
GROUP BY "ITEM DESCRIPTION", "ITEM TYPE"
HAVING SUM("RETAIL SALES"::numeric) > 1000  -- Filter for significant products
ORDER BY wholesale_ratio DESC
LIMIT 20;

-- Identifies products that are primarily wholesale-driven


-- Query 8.2: Suppliers with broadest product portfolio
-- Purpose: Understand supplier diversification
SELECT 
    "SUPPLIER",
    COUNT(DISTINCT "ITEM TYPE") as num_categories,
    COUNT(DISTINCT "ITEM CODE") as num_products,
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_revenue,
    STRING_AGG(DISTINCT "ITEM TYPE", ', ' ORDER BY "ITEM TYPE") as categories_offered
FROM sales_data
GROUP BY "SUPPLIER"
HAVING COUNT(DISTINCT "ITEM CODE") > 50
ORDER BY num_products DESC
LIMIT 15;

-- Shows which suppliers offer diverse portfolios vs specialists


-- Query 8.3: Revenue concentration by top N products
-- Purpose: Understand how much revenue comes from top sellers
WITH product_revenue AS (
    SELECT 
        "ITEM DESCRIPTION",
        SUM("RETAIL SALES"::numeric) as revenue
    FROM sales_data
    GROUP BY "ITEM DESCRIPTION"
),
ranked_products AS (
    SELECT 
        "ITEM DESCRIPTION",
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) as rank,
        SUM(revenue) OVER () as total_revenue
    FROM product_revenue
)
SELECT 
    CASE 
        WHEN rank <= 10 THEN 'Top 10'
        WHEN rank <= 50 THEN 'Top 11-50'
        WHEN rank <= 100 THEN 'Top 51-100'
        ELSE 'Bottom products'
    END as product_tier,
    COUNT(*) as num_products,
    ROUND(SUM(revenue), 2) as tier_revenue,
    ROUND(100.0 * SUM(revenue) / MAX(total_revenue), 2) as pct_of_total
FROM ranked_products
GROUP BY product_tier
ORDER BY tier_revenue DESC;

-- Shows revenue concentration (Pareto principle check)


# ============================================================
# SECTION 9: DATA EXPORT QUERIES FOR VISUALIZATION
# ============================================================

-- Export Query 1: Monthly revenue trend (2019)
SELECT 
    "MONTH",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as monthly_revenue
FROM sales_data
WHERE "YEAR" = '2019'
GROUP BY "MONTH"
ORDER BY CAST("MONTH" AS INTEGER);


-- Export Query 2: Category breakdown
SELECT 
    "ITEM TYPE",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_revenue,
    ROUND(100.0 * SUM("RETAIL SALES"::numeric) / 
          (SELECT SUM("RETAIL SALES"::numeric) FROM sales_data), 2) as pct_of_total
FROM sales_data
WHERE "ITEM TYPE" IN ('LIQUOR', 'WINE', 'BEER')
GROUP BY "ITEM TYPE"
ORDER BY total_revenue DESC;


-- Export Query 3: Top 10 products
SELECT 
    "ITEM DESCRIPTION",
    "ITEM TYPE",
    ROUND(SUM("RETAIL SALES"::numeric), 2) as total_revenue
FROM sales_data
GROUP BY "ITEM DESCRIPTION", "ITEM TYPE"
ORDER BY total_revenue DESC
LIMIT 10;


-- Export Query 4: Channel split
SELECT 
    'Retail' as channel,
    ROUND(SUM("RETAIL SALES"::numeric), 2) as revenue
FROM sales_data
UNION ALL
SELECT 
    'Warehouse' as channel,
    ROUND(SUM("WAREHOUSE SALES"::numeric), 2) as revenue
FROM sales_data;


# ============================================================
# NOTES & LESSONS LEARNED
# ============================================================

-- Key SQL Techniques Used:
-- 1. Common Table Expressions (WITH clause) for complex logic
-- 2. Window functions (SUM OVER, ROW_NUMBER) for running totals and rankings
-- 3. CASE statements for conditional logic and data categorization
-- 4. Type casting (::numeric, CAST) for data type conversions
-- 5. Aggregate functions with HAVING clause for filtered aggregations
-- 6. NULLIF to handle division by zero
-- 7. STRING_AGG for concatenating values
-- 8. Subqueries for percentage calculations

-- Important Considerations:
-- 1. Always quote column names with spaces or uppercase in PostgreSQL
-- 2. Data imported as TEXT requires explicit casting for calculations
-- 3. Missing data requires investigation before making cleaning decisions
-- 4. Incomplete temporal data limits trend analysis validity
-- 5. Understanding business context is crucial for insight generation

-- Performance Notes:
-- 1. Dataset of 300k rows runs quickly for all queries
-- 2. Indexes not required for this project size
-- 3. For production with millions of rows, would add indexes on:
--    - ("YEAR", "MONTH") for temporal queries
--    - "SUPPLIER" for supplier analysis
--    - "ITEM TYPE" for category queries

# End of SQL Query Collection
