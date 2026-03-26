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

