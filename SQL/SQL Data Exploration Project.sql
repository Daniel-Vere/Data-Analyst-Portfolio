--Shows the Global Average Temperature Anomaly for each decade

SELECT LTRIM(STR((Year - Year%10))) + 's' as Decade, AVG([Global average temperature anomaly relative to 1961-1990]) as [Global Average Temperature Anomaly]
FROM PortfolioProject.dbo.TemperatureAnomaly
WHERE Entity = 'Global' AND Year NOT IN (2020, 2021, 2022,2023)
GROUP BY LTRIM(STR((Year - Year%10))) + 's'
order by 1

--Shows the Total Global GHG Emissions in each decade

SELECT LTRIM(STR((Year - Year%10))) + 's' as Decade, SUM([Annual greenhouse gas emissions in CO2 equivalents]) as [Total Global Decennial GHG Emissions]
FROM PortfolioProject.dbo.TotalGHGEmissions
WHERE Entity = 'World' AND Year NOT IN (2020, 2021, 2022,2023)
GROUP BY LTRIM(STR((Year - Year%10))) + 's'
order by 1

--Shows the Cumulative Global GHG Emissions

SELECT LTRIM(STR((Year - Year%10))) + 's' as Decade, 
SUM(SUM([Annual greenhouse gas emissions in CO2 equivalents])) OVER(ORDER BY LTRIM(STR((Year - Year%10))) + 's') AS [Cumulative Global GHG Emissions]
FROM PortfolioProject.dbo.TotalGHGEmissions
WHERE Entity = 'World' AND Year NOT IN (2020, 2021, 2022,2023)
GROUP BY LTRIM(STR((Year - Year%10))) + 's'
order by 1

--Joining Cumulative Global GHG Emissions to Global Average Temperature Anomaly for each decade

SELECT LTRIM(STR((Emissions.Year - Emissions.Year%10))) + 's' as Decade, AVG([Global average temperature anomaly relative to 1961-1990]) as [Global Average Temperature Anomaly],
SUM(SUM([Annual greenhouse gas emissions in CO2 equivalents])) OVER(ORDER BY LTRIM(STR((Emissions.Year - Emissions.Year%10))) + 's') AS [Cumulative Global GHG Emissions]
FROM PortfolioProject.dbo.TotalGHGEmissions as Emissions
JOIN PortfolioProject.dbo.TemperatureAnomaly as Temp
	ON Emissions.Year = Temp.Year
WHERE Emissions.Entity = 'World' AND Emissions.Year NOT IN (2020, 2021, 2022,2023) AND Temp.Entity = 'Global' AND Temp.Year NOT IN (2020, 2021, 2022,2023)
GROUP BY LTRIM(STR((Emissions.Year - Emissions.Year%10))) + 's'

--Joining Cumulative Global GHG Emissions to Global Average Temperature Anomaly for each decade (using temp tables)

DROP TABLE IF EXISTS #CumulativeGlobalGHGEmissions
CREATE TABLE #CumulativeGlobalGHGEmissions
(Decade varchar(255), [Cumulative Global GHG Emissions] BIGINT)
INSERT INTO #CumulativeGlobalGHGEmissions
SELECT LTRIM(STR((Year - Year%10))) + 's' as Decade, 
SUM(SUM(CAST([Annual greenhouse gas emissions in CO2 equivalents] AS BIGINT))) OVER(ORDER BY LTRIM(STR((Year - Year%10))) + 's') AS [Cumulative Global GHG Emissions]
FROM PortfolioProject.dbo.TotalGHGEmissions
WHERE Entity = 'World' AND Year NOT IN (2020, 2021, 2022,2023)
GROUP BY LTRIM(STR((Year - Year%10))) + 's'

DROP TABLE IF EXISTS #GlobalAverageTemperatureAnomaly
CREATE TABLE #GlobalAverageTemperatureAnomaly
 (Decade varchar(255), [Global Average Temperature Anomaly] float)
INSERT INTO #GlobalAverageTemperatureAnomaly
SELECT LTRIM(STR((Year - Year%10))) + 's' as Decade, AVG([Global average temperature anomaly relative to 1961-1990]) as [Global Average Temperature Anomaly]
FROM PortfolioProject.dbo.TemperatureAnomaly
WHERE Entity = 'Global' AND Year NOT IN (2020, 2021, 2022,2023)
GROUP BY LTRIM(STR((Year - Year%10))) + 's'

SELECT TempEmissions.Decade, [Global Average Temperature Anomaly], [Cumulative Global GHG Emissions]
FROM #CumulativeGlobalGHGEmissions as TempEmissions
JOIN #GlobalAverageTemperatureAnomaly as TempTemp
	ON TempEmissions.Decade = TempTemp.Decade

--Shows the Total GHG Emissions for each country in 2021

SELECT Entity, Code, SUM([Annual greenhouse gas emissions in CO2 equivalents]) as [Total GHG Emissions in 2021]
FROM PortfolioProject.dbo.TotalGHGEmissions
WHERE Code IS NOT NULL AND Entity <> 'World' AND Year = 2021
GROUP BY Entity, Code
Order by 3 Desc

--Creating Views to store data for visualisations

CREATE VIEW TotalGHGEmissions2021 as 
SELECT Entity, Code, SUM([Annual greenhouse gas emissions in CO2 equivalents]) as [Total GHG Emissions in 2021]
FROM PortfolioProject.dbo.TotalGHGEmissions
WHERE Code IS NOT NULL AND Entity <> 'World' AND Year = 2021
GROUP BY Entity, Code

CREATE VIEW GlobalCumulativeEmissionsAndTemperature as
SELECT LTRIM(STR((Emissions.Year - Emissions.Year%10))) + 's' as Decade, AVG([Global average temperature anomaly relative to 1961-1990]) as [Global Average Temperature Anomaly],
SUM(SUM([Annual greenhouse gas emissions in CO2 equivalents])) OVER(ORDER BY LTRIM(STR((Emissions.Year - Emissions.Year%10))) + 's') AS [Cumulative Global GHG Emissions]
FROM PortfolioProject.dbo.TotalGHGEmissions as Emissions
JOIN PortfolioProject.dbo.TemperatureAnomaly as Temp
	ON Emissions.Year = Temp.Year
WHERE Emissions.Entity = 'World' AND Emissions.Year NOT IN (2020, 2021, 2022,2023) AND Temp.Entity = 'Global' AND Temp.Year NOT IN (2020, 2021, 2022,2023)
GROUP BY LTRIM(STR((Emissions.Year - Emissions.Year%10))) + 's'
