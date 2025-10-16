DROP TABLE IF EXISTS online_casino;

CREATE TABLE online_casino (
    licensee TEXT NOT NULL,
    fiscal_year TEXT NOT NULL,
    month_ending TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    wagers NUMERIC(18,2) NOT NULL,
    patron_winnings NUMERIC(18,2) NOT NULL,
    cancelled_wagers NUMERIC(18,2) NOT NULL,
    online_casino_gaming_win NUMERIC(18,2) NOT NULL,
    promotional_coupons_or_credits NUMERIC(18,2) NOT NULL,
    promotional_deduction_4 NUMERIC(18,2) NOT NULL,
    total_gross_gaming NUMERIC(18,2) NOT NULL,
    tax_payment_5 NUMERIC(18,2) NOT NULL
);
select*
from online_casino;

-- Business Questions for Online Casino Dataset:

-- 1. Monthly Revenue Trend
--    - What is the total gross gaming revenue per month and how does it change over time?
SELECT
    TO_CHAR(DATE_TRUNC('month', month_ending), 'YYYY-MM') AS month,
    SUM(total_gross_gaming) AS total_gross_revenue_month,
    LAG(SUM(total_gross_gaming)) OVER (
        ORDER BY DATE_TRUNC('month', month_ending)
    ) AS prev_month_revenue,
    ROUND(
        (SUM(total_gross_gaming) - LAG(SUM(total_gross_gaming)) OVER (
            ORDER BY DATE_TRUNC('month', month_ending)
        )) 
        / LAG(SUM(total_gross_gaming)) OVER (
            ORDER BY DATE_TRUNC('month', month_ending)
        ) * 100, 2
    ) AS mom_growth_pct
FROM online_casino
GROUP BY DATE_TRUNC('month', month_ending)
ORDER BY DATE_TRUNC('month', month_ending);


-- 2. Licensee Performance Ranking
--    - Which licensees generated the highest net revenue (GGR - promo deduction) over the fiscal year?
WITH ranked AS (
    SELECT
        licensee,
        fiscal_year,
        SUM(total_gross_gaming - promotional_deduction_4) AS net_revenue,
        RANK() OVER (
            PARTITION BY fiscal_year
            ORDER BY SUM(total_gross_gaming - promotional_deduction_4) DESC
        ) AS rank_by_net_revenue
    FROM online_casino
    GROUP BY licensee, fiscal_year
)
SELECT *
FROM ranked
WHERE rank_by_net_revenue = 1
ORDER BY fiscal_year;


-- 3. Year-over-Year Growth
--    - What is the year-over-year revenue growth for each licensee?
SELECT
    licensee,
    fiscal_year,
    SUM(total_gross_gaming - promotional_deduction_4) AS net_revenue_year,
    LAG(SUM(total_gross_gaming - promotional_deduction_4)) OVER (
        PARTITION BY licensee
        ORDER BY fiscal_year
    ) AS prev_year_net_revenue,
    ROUND(
        (SUM(total_gross_gaming - promotional_deduction_4) 
         - LAG(SUM(total_gross_gaming - promotional_deduction_4)) OVER (
             PARTITION BY licensee
             ORDER BY fiscal_year
         ))
        / LAG(SUM(total_gross_gaming - promotional_deduction_4)) OVER (
             PARTITION BY licensee
             ORDER BY fiscal_year
         ) * 100, 2
    ) AS year_growth_pct
FROM online_casino
GROUP BY licensee, fiscal_year
ORDER BY licensee, fiscal_year;



-- 4. Promotion Efficiency
--    - How effective are promotional credits in driving wagers and revenue?
SELECT
    TO_CHAR(DATE_TRUNC('month', month_ending), 'YYYY-MM') AS month,
    SUM(promotional_coupons_or_credits) AS total_promotions,
    SUM(wagers) AS total_wagers,
    SUM(total_gross_gaming) AS total_ggr,
    SUM(total_gross_gaming - promotional_deduction_4) AS net_revenue,
    ROUND(
        (SUM(total_gross_gaming) - SUM(promotional_deduction_4)) 
        / NULLIF(SUM(promotional_coupons_or_credits), 0), 2
    ) AS promo_roi,
    ROUND(
        SUM(promotional_coupons_or_credits) / NULLIF(SUM(wagers), 0) * 100, 2
    ) AS promo_share_of_wagers_pct
FROM online_casino
GROUP BY DATE_TRUNC('month', month_ending)
ORDER BY month;


-- 5. Payout Ratio and Profitability
--    - What’s the payout ratio (winnings / wagers) and net margin per licensee and month?
SELECT
    TO_CHAR(DATE_TRUNC('month', month_ending), 'YYYY-MM') AS month,
    licensee,
    SUM(wagers) AS total_wagers,
    SUM(patron_winnings) AS total_winnings,
    ROUND(SUM(patron_winnings) / NULLIF(SUM(wagers), 0), 4) AS payout_ratio,
    SUM(total_gross_gaming - promotional_deduction_4) AS net_revenue,
    ROUND(
        (SUM(total_gross_gaming - promotional_deduction_4) / NULLIF(SUM(wagers), 0)) * 100,
        2
    ) AS net_margin_pct
FROM online_casino
GROUP BY DATE_TRUNC('month', month_ending), licensee
ORDER BY month, licensee;

-- 6. Tax Burden Analysis
--    - What percentage of total revenue goes to tax payments, and does it vary across licensees?
SELECT
    licensee,
    SUM(wagers) AS total_wagers,
    SUM(total_gross_gaming) AS total_revenue,
    SUM(tax_payment_5) / NULLIF(SUM(total_gross_gaming), 0) AS tax_ratio
FROM online_casino
GROUP BY licensee
ORDER BY tax_ratio DESC, licensee;


-- 7. Anomalies in Cancelled Wagers
--    - Identify months or licensees where cancelled wagers spiked unusually.
WITH monthly_cancellations AS (
    SELECT
        licensee,
        DATE_TRUNC('month', month_ending) AS month,
        SUM(cancelled_wagers) AS total_cancelled
    FROM online_casino
    GROUP BY licensee, DATE_TRUNC('month', month_ending)
),
stats AS (
    SELECT
        licensee,
        month,
        total_cancelled,
        AVG(total_cancelled) OVER (PARTITION BY licensee) AS avg_cancelled,
        STDDEV(total_cancelled) OVER (PARTITION BY licensee) AS stddev_cancelled
    FROM monthly_cancellations
)
SELECT
    licensee,
    TO_CHAR(month, 'YYYY-MM') AS month,
    total_cancelled,
    ROUND((total_cancelled - avg_cancelled) / NULLIF(stddev_cancelled, 0), 2) AS z_score,
    CASE 
        WHEN (total_cancelled - avg_cancelled) / NULLIF(stddev_cancelled, 0) > 2 
            THEN 'Spike Detected'
        ELSE 'Normal'
    END AS anomaly_flag
FROM stats
ORDER BY licensee, month;


-- 8. Cumulative Revenue Over Time
--    - How does cumulative revenue evolve month over month per licensee?
--    - Useful SQL: SUM(...) OVER (PARTITION BY licensee ORDER BY month_ending) cumulative sum.

WITH monthly_revenue AS (
    SELECT
        licensee,
        DATE_TRUNC('month', month_ending) AS month,
        SUM(total_gross_gaming - promotional_deduction_4) AS net_revenue_month
    FROM online_casino
    GROUP BY licensee, DATE_TRUNC('month', month_ending)
)
SELECT
    licensee,
    TO_CHAR(month, 'YYYY-MM') AS month,
    net_revenue_month,
    SUM(net_revenue_month) OVER (
        PARTITION BY licensee
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_net_revenue
FROM monthly_revenue
ORDER BY licensee, month;

