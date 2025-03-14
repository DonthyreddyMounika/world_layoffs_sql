use world_layoffs;
select * from  layoffs_staging_3;

select max(total_laid_off) , max(percentage_laid_off)
from layoffs_staging_3;

select * 
from layoffs_staging_3
where percentage_laid_off = 1 
order by  total_laid_off desc;

--  Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging_3
WHERE  percentage_laid_off IS NOT NULL;

-- Companies with the biggest single Layoffs
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging_3
ORDER BY 2 DESC
LIMIT 5;

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_3
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging_3
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;





-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging_3
GROUP BY dates
ORDER BY dates ASC;


-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging_3
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;