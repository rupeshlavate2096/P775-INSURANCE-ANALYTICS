
-- 1. No. of Invoice by Account Executive
select * from invoice;

SELECT `account executive`, COUNT(invoice_date) AS invoice_count
FROM invoice
GROUP BY `account executive`
ORDER BY invoice_count DESC;  

-- 2-Yearly Meeting Count
select * from meeting;
select count(meeting_date) as Meeting_count ,year(meeting_date)as Years from meeting
group by year(meeting_date)
order by years desc;

-- 3.
select * from brokerage;
select * from fees;
select * from invoice;
select * from individual;

SELECT 
    CASE 
        WHEN income_class LIKE 'Cross%' THEN 'Cross Sell' 
        ELSE income_class 
    END AS income_class,
    
    CASE WHEN SUM(total_invoice) > 0 THEN CONCAT(ROUND(SUM(total_invoice) / 1000000, 2), ' M') ELSE '' END AS Invoice,
    CASE WHEN SUM(total_target) > 0 THEN CONCAT(ROUND(SUM(total_target) / 1000000, 2), ' M') ELSE '' END AS Target,
    CASE WHEN SUM(total_brokerage_fees) > 0 THEN CONCAT(ROUND(SUM(total_brokerage_fees) / 1000000, 2), ' M') ELSE '' END AS Achievement,
    
   
    CASE 
        WHEN SUM(total_target) > 0 THEN CONCAT(ROUND((SUM(total_invoice) / SUM(total_target)) * 100, 2), ' %') 
        ELSE '' 
    END AS placed_invoice,

  
    CASE 
        WHEN SUM(total_target) > 0 THEN CONCAT(ROUND((SUM(total_brokerage_fees) / SUM(total_target)) * 100, 2), ' %') 
        ELSE '' 
    END AS placed_achievement

FROM (
   
    SELECT 
        income_class, 
        SUM(amount) AS total_brokerage_fees,
        0 AS total_invoice,
        0 AS total_target
    FROM brokerage
    GROUP BY income_class
    
    UNION ALL
    
    SELECT 
        income_class, 
        SUM(amount) AS total_brokerage_fees,
        0 AS total_invoice,
        0 AS total_target
    FROM fees
    GROUP BY income_class
    
    UNION ALL
    
    -- Invoice data
    SELECT 
        income_class, 
        0 AS total_brokerage_fees,
        SUM(amount) AS total_invoice,
        0 AS total_target
    FROM invoice
    WHERE income_class <> '' 
    GROUP BY income_class

    UNION ALL
    
    -- Target data
    SELECT 
        income_class, 
        0 AS total_brokerage_fees,
        0 AS total_invoice,
        SUM(amount) AS total_target
    FROM indi_bug
    GROUP BY income_class

) AS combined
WHERE income_class IS NOT NULL AND income_class <> 'NA' 
GROUP BY 
    CASE 
        WHEN income_class LIKE 'Cross%' THEN 'Cross Sell'  -- Normalize Cross Sell
        ELSE income_class 
    END
HAVING Invoice <> '' OR Target <> '' OR Achievement <> '' -- Remove rows with all zero values
ORDER BY 
    CASE 
        WHEN income_class = 'Renewal' THEN 1
        WHEN income_class = 'New' THEN 2
        WHEN income_class LIKE 'Cross%' THEN 3
        ELSE 4
    END;




-- 4. Stage by Revenue
select * from opportunity;
select sum(revenue_amount) as Revenue, Stage from opportunity
group by stage;

-- 5. No of meeting By Account Exe
select count(`Account Exe ID`) as Number_of_meeting, `Account executive`  from meeting
group by `account executive`;

-- 6-Top 5 Open Opportunity
select * from opportunity;
select opportunity_name, revenue_amount as amount from opportunity 
where stage <> 'Negotiate'
order by revenue_amount desc limit 5; 

-- Top 4 Opportunity
select * from opportunity;
select opportunity_name, revenue_amount as Amount from opportunity
order by amount desc limit 4;

-- Opportunity by product group 
select * from opportunity;
select count(*) as Total , Product_group from opportunity
group by product_group order by total desc;
