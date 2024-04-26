-- Exploring the Marketing Data
SELECT *
FROM PortfolioProject..DigitalMarketingCampaign
ORDER BY 2, 3

-- Figuring out How Many People were exposed to Each Campaign

SELECT campaign_name, SUM(CAST(impressions AS FLOAT)) AS NumberofPeopleExposed
FROM PortfolioProject..DigitalMarketingCampaign
GROUP BY campaign_name
ORDER BY NumberofPeopleExposed DESC

-- Calculating the Total Number of People Exposed to All of the Campaigns

SELECT SUM(CAST(impressions AS FLOAT)) AS NumberofPeopleExposed
FROM PortfolioProject..DigitalMarketingCampaign

-- Finding the Overall ROMI (Return on Marketing Investment) Obtained from the Marketing Campaigns

SELECT SUM(CAST(revenue AS FLOAT)) AS TotalRevenue, 
SUM(CAST(mark_spent AS FLOAT)) AS TotalExpenses,
(SUM(CAST(revenue AS FLOAT)) - SUM(CAST(mark_spent AS FLOAT)))/NULLIF(SUM(CAST(mark_spent AS FLOAT)), 0)*100 AS OverallROMI
FROM PortfolioProject..DigitalMarketingCampaign

-- Finding the ROMI (Return on Marketing Investment) for Each Individual Campaign

SELECT campaign_name, SUM(CAST(revenue AS FLOAT)) AS TotalRevenue, 
SUM(CAST(mark_spent AS FLOAT)) AS TotalExpenses,
ROUND((SUM(CAST(revenue AS FLOAT)) - SUM(CAST(mark_spent AS FLOAT)))/NULLIF(SUM(CAST(mark_spent AS FLOAT)), 0)*100, 2) AS romi
FROM PortfolioProject..DigitalMarketingCampaign
GROUP BY campaign_name
ORDER BY romi DESC

-- Identifying the Total Conversion Rate

SELECT SUM(CAST(orders AS FLOAT)) AS TotalOrders, 
SUM(CAST(clicks AS FLOAT)) AS TotalClicks,
ROUND((SUM(CAST(orders AS FLOAT))/NULLIF(SUM(CAST(clicks AS FLOAT)), 0))*100, 2) AS total_Conversion_Rate
FROM PortfolioProject..DigitalMarketingCampaign
ORDER BY total_Conversion_Rate DESC

-- Identifying the Conversion Rate for Each Individual Campaign

SELECT campaign_name, SUM(CAST(orders AS FLOAT)) AS TotalOrders, 
SUM(CAST(clicks AS FLOAT)) AS TotalClicks,
ROUND((SUM(CAST(orders AS FLOAT))/NULLIF(SUM(CAST(clicks AS FLOAT)), 0))*100, 2) AS Conversion_Rate
FROM PortfolioProject..DigitalMarketingCampaign
GROUP BY campaign_name
ORDER BY Conversion_Rate DESC

-- Calculating the CTR (Click-Through-Rate) for All Campaigns

SELECT SUM(CAST(clicks AS FLOAT)) AS TotalClicks, 
SUM(CAST(impressions AS FLOAT)) AS TotalImpressions,
ROUND((SUM(CAST(clicks AS FLOAT))/NULLIF(SUM(CAST(impressions AS FLOAT)), 0))*100, 2) AS total_CTR
FROM PortfolioProject..DigitalMarketingCampaign


-- Finding the CTR (Click-Through-Rate) for Each Individual Campaign

SELECT campaign_name, SUM(CAST(clicks AS FLOAT)) AS TotalClicks, 
SUM(CAST(impressions AS FLOAT)) AS TotalImpressions,
ROUND((SUM(CAST(clicks AS FLOAT))/NULLIF(SUM(CAST(impressions AS FLOAT)), 0))*100, 2) AS ctr
FROM PortfolioProject..DigitalMarketingCampaign
GROUP BY campaign_name
ORDER BY ctr DESC

-- Figuring Out Which Campaigns Generated a Profit for the Company and Which was a Loss

SELECT
	CASE 
        WHEN romi > 0 THEN 'Profit'
		WHEN romi < 0 THEN 'Loss'
        ELSE 'Neither'
    END AS ProfitORLoss, romi, campaign_name
FROM (
SELECT campaign_name, SUM(CAST(revenue AS FLOAT)) AS TotalRevenue, 
SUM(CAST(mark_spent AS FLOAT)) AS TotalExpenses,
ROUND((SUM(CAST(revenue AS FLOAT)) - SUM(CAST(mark_spent AS FLOAT)))/NULLIF(SUM(CAST(mark_spent AS FLOAT)), 0)*100, 2) AS romi
FROM PortfolioProject..DigitalMarketingCampaign
GROUP BY campaign_name
) AS subquery

-- Identifying which date the most money was spent on advertising 

SELECT TOP 1 CAST(mark_spent AS FLOAT) AS MostMoneySpent, c_date
FROM PortfolioProject..DigitalMarketingCampaign
ORDER BY mark_spent DESC

-- Looking at What Date a Campaign Produced the Most Revenue

SELECT TOP 1 CAST(revenue AS FLOAT) AS MostRevenue, c_date
FROM PortfolioProject..DigitalMarketingCampaign
ORDER BY mark_spent DESC

-- Identifying The Date with the Highest Conversion Rate and Lowest Conversion Rate

WITH ConversionRates AS 
(
SELECT c_date, ROUND((SUM(CAST(orders AS FLOAT)) / NULLIF(SUM(CAST(clicks AS FLOAT)), 0)) * 100, 2) AS ConversionRate
FROM PortfolioProject..DigitalMarketingCampaign
GROUP BY c_date
),
MaxMinConversionRates AS (
    SELECT 
        MAX(ConversionRate) AS MaxConversionRate,
        MIN(ConversionRate) AS MinConversionRate
    FROM 
        ConversionRates
)
SELECT 
    (SELECT c_date FROM ConversionRates WHERE ConversionRate = (SELECT MaxConversionRate FROM MaxMinConversionRates)) AS DateWithHighestConversionRate,
    (SELECT MaxConversionRate FROM MaxMinConversionRates) AS HighestConversionRate,
    (SELECT c_date FROM ConversionRates WHERE ConversionRate = (SELECT MinConversionRate FROM MaxMinConversionRates)) AS DateWithLowestConversionRate,
    (SELECT MinConversionRate FROM MaxMinConversionRates) AS LowestConversionRate

-- Identifying at the Average Revenue on Weekdays and Weekends

SELECT WeekdayOrWeekend,
	CASE
		WHEN WeekdayOrWeekend = 'WeekDay' THEN ROUND(AVG(CAST(revenue AS FLOAT)), 2)
		WHEN WeekdayOrWeekend = 'WeekEnd' THEN ROUND(AVG(CAST(revenue AS FLOAT)), 2)
	END AS AverageRevenue
FROM (
SELECT
	CASE
		WHEN DATEPART(dw, c_date) >= 1 AND DATEPART(dw, c_date) <= 5 THEN 'WeekDay'
		ELSE 'WeekEnd'
	END AS WeekdayOrWeekend, c_date, revenue
FROM PortfolioProject..DigitalMarketingCampaign)
AS Subquery
GROUP BY WeekdayOrWeekend
ORDER BY AverageRevenue DESC
