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

## SQL Query

with fb_joined as (
    select f.ad_date, c.campaign_name, a.adset_name, f.spend, f.impressions, f.reach, f.clicks, f.leads, f.value
    from facebook_ads_basic_daily f
    left join facebook_campaign c on c.campaign_id = f.campaign_id
    left join facebook_adset a on a.adset_id = f.adset_id
    where f.ad_date is not null
),
unified_ads as (
    select ad_date, 'Facebook Ads' as media_source, campaign_name, adset_name, spend, impressions, reach, clicks, leads, value
    from fb_joined
    union all
    select g.ad_date, 'Google Ads' as media_source, g.campaign_name, g.adset_name, g.spend, g.impressions, g.reach, g.clicks, g.leads, g.value
    from google_ads_basic_daily g
    where g.ad_date is not null
)
select ua.ad_date, ua.media_source, ua.campaign_name, ua.adset_name, sum(ua.spend) as total_spend, sum(ua.impressions) as total_impressions, sum(ua.clicks) as total_clicks, sum(ua.value) as total_value
from unified_ads ua
group by ua.ad_date, ua.media_source, ua.campaign_name, ua.adset_name
order by ua.ad_date desc, ua.media_source, ua.campaign_name, ua.adset_name;



with fb_joined as (
    select f.ad_date, c.campaign_name, a.adset_name, f.spend, f.impressions, f.reach, f.clicks, f.leads, f.value
    from facebook_ads_basic_daily f
    left join facebook_campaign c on c.campaign_id = f.campaign_id
    left join facebook_adset a on a.adset_id = f.adset_id
    where f.ad_date is not null
),
unified_ads as (
    select ad_date, campaign_name, adset_name, spend, value
    from fb_joined

    union all

    select g.ad_date, g.campaign_name, g.adset_name, g.spend, g.value
    from google_ads_basic_daily g
    where g.ad_date is not null
),
campaign_rollup as (
    select campaign_name, SUM(spend) as total_spend, SUM(value) as total_value, ((SUM(value)::numeric - SUM(spend)::numeric) * 100) / NULLIF(SUM(spend)::numeric, 0) as romi
    from unified_ads
    group by campaign_name
),
best_campaign as (
    select *
    from campaign_rollup
    where total_spend > 500000
    order by romi desc
    limit 1
),
best_adset as (
    select u.campaign_name, u.adset_name, SUM(u.spend) as total_spend, SUM(u.value) as total_value, ((SUM(u.value)::numeric - SUM(u.spend)::numeric) * 100) / NULLIF(SUM(u.spend)::numeric, 0) as romi
    from unified_ads u
    join best_campaign bc on bc.campaign_name = u.campaign_name
    group by u.campaign_name, u.adset_name
    order by romi desc
    limit 1
)
select
    bc.campaign_name as best_campaign_name,
    bc.total_spend   as campaign_spend,
    bc.total_value   as campaign_value,
    bc.romi          as campaign_romi,
    ba.adset_name    as best_adset_name,
    ba.total_spend   as adset_spend,
    ba.total_value   as adset_value,
    ba.romi          as adset_romi
from best_campaign bc
join best_adset ba on ba.campaign_name = bc.campaign_name;



---

## Conclusion
This project demonstrates how SQL can be used not only for KPI calculation, but also for combining multiple data sources, enriching raw data, and identifying the most effective campaign and ad set structures for marketing decision-making.
