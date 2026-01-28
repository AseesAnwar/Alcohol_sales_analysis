# Retail Alcohol Sales Analysis Portfolio Project

**Analyst:** Asees Anwar  
**Date:** January 2026  
**Tools Used:** PostgreSQL, Python (pandas, sqlalchemy), Google Sheets

---

## Project Overview

This project analyzes 4 years of alcohol distribution data (2017-2020) containing 307,642 transactions across wine, beer, and liquor products. The analysis reveals business insights about product performance, supplier relationships, seasonal trends, and channel distribution strategies.

**Key Finding:** This is primarily a B2B wholesale distribution business, with warehouse sales representing 78% of total revenue ($7.78M vs $2.16M retail).

---

## Dataset Information

**Source:** Warehouse and Retail Sales Data  
**Size:** 307,642 records (after cleaning)  
**Date Range:** June 2017 - November 2019 (24 months with data)  
**Completeness:** 50% of potential months have data (significant gaps in 2018 and 2020)

**Columns:**
- Year, Month
- Supplier
- Item Code, Item Description, Item Type
- Retail Sales (dollar amount)
- Retail Transfers
- Warehouse Sales (dollar amount)

---

## Data Quality Assessment

### Missing Data Analysis

Before conducting analysis, I systematically assessed data completeness:

**Coverage by Year:**
- 2017: 7 months (Jun-Dec)
- 2018: 2 months only (Jan-Feb) - 83% missing
- 2019: 11 months (Jan-Nov) - Most complete
- 2020: 4 months only (Jan, Mar, Jul, Sep) - 67% missing

**Total:** 24 out of 48 possible months contain data

### Data Cleaning Actions

1. **Deleted 3 records** with NULL retail sales (incomplete transactions with no revenue data)
2. **Updated 167 records** with missing supplier information → Labeled as "UNKNOWN" to preserve sales data
3. **Updated 1 record** with missing item type → Filled with "WINE" based on product description (Barolo wine)

**Rationale:** Prioritized preserving records with valid sales amounts while removing truly unusable data. Missing supplier names don't invalidate the sales transaction.

---

## Analysis Limitations

Due to incomplete data coverage, the following analyses are **NOT reliable:**
-  Year-over-year growth comparisons
-  Full COVID-19 impact assessment (2020 too incomplete)
-  Complete seasonal pattern analysis (missing key months)
-  Annual revenue projections

**Valid analyses despite data gaps:**
-  Product and supplier performance rankings (using all available data)
-  Category comparisons (Wine vs Beer vs Liquor)
-  Channel analysis (Retail vs Wholesale)
-  2019 seasonal patterns (11 months available)

---

## Key Findings

### 1. Business Model: B2B Wholesale Distribution

**Channel Revenue Split:**
- Warehouse (B2B): $7,781,756 (78.27%)
- Retail (B2C): $2,160,899 (21.73%)

**Insight:** This is fundamentally a wholesale distribution business supplying bars, restaurants, and liquor stores. Retail operations are secondary.

### 2. Product Category Performance

**Revenue Distribution:**
- Liquor: 37.15% ($802,691)
- Wine: 34.55% ($746,499)
- Beer: 26.57% ($574,221)

**Product Efficiency:**
- Liquor: $179 revenue per product (4,475 products)
- Beer: $105 revenue per product (5,457 products)
- Wine: $35 revenue per product (21,301 products)

**Insight:** Wine catalog appears bloated with 21,000+ products generating only 35% of revenue. Liquor generates 5X more revenue per SKU - suggests opportunity to rationalize wine portfolio and focus on high-performing items.

### 3. Top Performing Products

**Retail Channel Top 5:**
1. Tito's Handmade Vodka 1.75L - $27,580
2. Corona Extra (Loose) - $25,064
3. Heineken (Loose) - $17,761
4. Miller Lite 30pk - $14,440
5. Bud Light 30pk - $12,299

**Wholesale Channel Top 5:**
1. Corona Extra (Loose) - $303,161
2. Corona Extra 2/12pk - $247,924
3. Heineken (Loose) - $171,950
4. Heineken 2/12pk - $154,654
5. Miller Lite 30pk - $134,486

**Insight:** Wholesale buyers focus almost exclusively on major beer brands in bulk packaging. Retail customers show more diversity with premium spirits (Tito's) leading. Corona products alone represent ~$800k in wholesale revenue.

### 4. Supplier Concentration

**Top 5 Suppliers by Revenue:**
1. E & J Gallo Winery - $166,171 (617 products)
2. Diageo North America - $145,343 (481 products)
3. Constellation Brands - $131,665 (375 products)
4. Anheuser Busch - $109,961 (427 products)
5. Jim Beam Brands - $96,164 (346 products)

**Insight:** Top 5 suppliers represent ~$650k of $2.16M revenue (30%). E & J Gallo carries broadest portfolio (617 products) but Crown Imports shows highest revenue-per-product efficiency ($1,260 vs $269).

### 5. Seasonal Patterns (2019 Analysis)

**Peak Months:**
- November: $101,631 (Holiday preparation)
- May: $94,953 (Summer season start)
- Summer months (Jun-Aug): Consistently $90k+ (BBQ/outdoor season)

**Low Months:**
- January: $76,101 (Post-holiday slump)
- February: $80,114 (Shortest month)
- September: $82,126 (Back to school/work)

**Average Transaction Value:**
- November: $7.91 (highest - holiday stocking)
- May-August: $7.26-$7.37 (summer entertaining)
- January-February: $6.14-$6.52 (reduced spending)

**Insight:** Clear 20-25% revenue variance between peak and low months. Inventory planning should account for May/November surges.

---

## Business Recommendations

### 1. Focus on Wholesale Excellence
With 78% of revenue from wholesale, prioritize:
- Strengthen relationships with major beer suppliers (Corona, Heineken, Miller)
- Negotiate volume discounts on top-selling wholesale items
- Optimize logistics for bulk deliveries

### 2. Rationalize Wine Portfolio
21,000+ wine products generating only $35/product suggests:
- Identify bottom 50% performers and discontinue
- Focus on high-velocity wine items
- Reduce inventory carrying costs

### 3. Seasonal Inventory Planning
- Stock up 25% above average for May (summer start) and November (holidays)
- Plan promotional campaigns for January-February slow periods
- Adjust staffing levels to match seasonal patterns

### 4. Supplier Risk Management
- Heavy reliance on major brewers (AB InBev, Constellation)
- Corona products alone = significant revenue concentration
- Consider diversifying craft beer offerings to reduce dependency

### 5. Data Collection Improvement
- Current dataset has 50% missing months
- Implement complete monthly reporting for reliable trend analysis
- Enable year-over-year comparisons and forecasting

---

## Technical Approach

### Tools & Technologies
- **PostgreSQL:** Primary database for data storage and querying
- **Python (pandas, sqlalchemy):** Data import and export automation
- **DBeaver:** Database management and query development
- **Google Sheets:** Data visualization and chart creation
- **SQL:** All analytical queries

### Key SQL Techniques Used
- Aggregate functions (SUM, COUNT, AVG)
- GROUP BY for categorical analysis
- Common Table Expressions (CTEs) for data completeness checks
- CASE statements for conditional logic
- Type casting for data type handling
- JOIN operations for missing data analysis

### Analysis Workflow
1. Data Import & Validation (Python automation)
2. Quality Assessment (Missing value analysis, completeness checks)
3. Data Cleaning (Justified deletion and imputation decisions)
4. Exploratory Analysis (15+ queries across multiple dimensions)
5. Visualization (4 key charts highlighting findings)
6. Business Insights (Translating data to actionable recommendations)

---

## Deliverables

1. **Clean Dataset:** 307,642 records with documented cleaning rationale
2. **SQL Query Library:** 15+ analytical queries with business context
3. **Visualizations:** 4 charts showing key trends and patterns
4. **Analysis Report:** This document with findings and recommendations
5. **Data Quality Documentation:** Complete assessment of missing data

---

## What I Learned

### Technical Skills
- Troubleshooting database imports with multiple approaches (GUI tools vs Python)
- Handling messy real-world data with incomplete records
- Writing complex SQL queries with multiple aggregations
- Automating data exports with Python scripts
- Case-sensitive PostgreSQL column naming conventions

### Analytical Skills
- Systematically assessing data quality before analysis
- Making justified decisions about missing data handling
- Identifying when data gaps invalidate certain analyses
- Translating statistical findings into business recommendations
- Understanding the difference between wholesale and retail business models

### Business Insights
- Recognizing product efficiency metrics (revenue per SKU)
- Understanding seasonal patterns in alcohol sales
- Identifying supplier concentration risks
- Appreciating the importance of complete data for trend analysis

---

## Future Enhancements

With complete data, I would analyze:
- Full COVID-19 impact on 2020 sales by category
- Multi-year growth trends by product line
- Supplier performance stability over time
- Price elasticity analysis
- Predictive modeling for seasonal demand

---

## Contact

**Asees Anwar**  
Data Analytics Student  
Open to entry-level data analyst opportunities

---

## Repository Structure

```
portfolio-project/
│
├── README.md (this file)
├── data/
│   ├── Warehouse_and_Retail_Sales.csv (original dataset)
│   └── exports/
│       ├── monthly_revenue_2019.csv
│       ├── category_breakdown.csv
│       ├── top_products.csv
│       └── channel_split.csv
│
├── sql_queries/
│   ├── data_quality_checks.sql
│   ├── data_cleaning.sql
│   ├── exploratory_analysis.sql
│   └── business_insights.sql
│
├── scripts/
│   ├── load_data.py
│   └── export_data.py
│
└── visualizations/
    └── analysis_charts.xlsx (Google Sheets export)
```

---

*This project demonstrates practical data analytics skills including data quality assessment, SQL proficiency, business insight generation, and clear communication of findings to non-technical stakeholders.*
