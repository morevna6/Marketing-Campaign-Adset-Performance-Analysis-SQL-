# Marketing Campaign & Adset Performance Analysis (SQL)

## Project Overview
This project analyzes campaign and ad set performance across Facebook Ads and Google Ads using SQL.

The analysis combines multiple advertising data sources, enriches Facebook Ads data with campaign and ad set names, and evaluates performance using ROMI to identify the most efficient campaign structures.

---

## Datasets
- `facebook_ads_basic_daily`
- `facebook_campaign`
- `facebook_adset`
- `google_ads_basic_daily`

---

## Analysis Tasks

### 1. Enrich Facebook Ads Data
A CTE is used to join Facebook Ads daily data with campaign and ad set reference tables in order to retrieve descriptive campaign metadata.

### 2. Build a Unified Ads Dataset
Facebook Ads and Google Ads data are combined into a single structure using `UNION ALL`.

### 3. Analyze Campaign Performance
Campaign-level spend and value are aggregated to calculate:

- Total Spend
- Total Value
- ROMI (Return on Marketing Investment)

### 4. Identify Best Campaign and Ad Set
The query:
- finds the highest-ROMI campaign among campaigns with significant spend
- identifies the best-performing ad set within that campaign

---

## SQL Highlights

### Query Logic
- `LEFT JOIN` to enrich Facebook Ads with campaign and ad set names
- `UNION ALL` to combine Facebook and Google Ads data
- CTE-based modeling for reusable transformations
- ROMI calculation for campaign and ad set comparison

### Example Metrics
- **ROMI** = `((value - spend) / spend) * 100`

---

## Tools Used
- PostgreSQL
- DBeaver

---

## Conclusion
This project demonstrates how SQL can be used not only for KPI calculation, but also for combining multiple data sources, enriching raw data, and identifying the most effective campaign and ad set structures for marketing decision-making.
