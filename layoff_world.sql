
use world_layoffs;
SELECT * 
FROM layoffs;
-- removing duplicates
CREATE TABLE layoffs_staging_2 
LIKE layoffs;




SELECT *
FROM layoffs_staging_2;


INSERT layoffs_staging_2 
SELECT * FROM layoffs;
SELECT *
FROM layoffs_staging_2;


/*with duplicate_cte as 
(
select *, 
row_number() over(
partition by company , location,  industry, total_laid_off, percentage_laid_off, 'date',stage,country,funds_raised_millions   ) as row_num
from layoffs_staging 
)
select * from duplicate_cte 
where row_num >1;  */



        
        
SELECT *
FROM (
	SELECT company, location,industry, total_laid_off,`date`,stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company,location, industry, total_laid_off,`date`,stage,country,funds_raised_millions
			) AS row_num
	FROM layoffs_staging_2
) duplicates
WHERE 
	duplicates.row_num > 1;
    
    SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE company = 'Oda'
;
-- create another table for row_num =1
CREATE TABLE `layoffs_staging_3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging_3
where row_num >1;

insert into layoffs_staging_3

	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`,stage,country,funds_raised_millions
			) AS row_num
	FROM layoffs_staging_2;


    
    select * 
from layoffs_staging_3
where row_num>1;

delete 
from layoffs_staging_3
where row_num>1;
 select * 
from layoffs_staging_2;



-- 2 standardize the data


select company , trim(company)
from layoffs_staging_3;

update layoffs_staging_3 
set company = trim(company);

select *
from layoffs_staging_3;

select distinct(industry)
from layoffs_staging_3
order by 1;

update layoffs_staging_3
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct industry from layoffs_staging_3 ;
select distinct location from layoffs_staging_3 ;
select distinct country from layoffs_staging_3 ;



select distinct country 
from layoffs_staging_3  
where country like 'United States%';


update layoffs_staging_3
set country = 'United States'
where country like 'United States%';

select distinct country 
from layoffs_staging_3  
where country like 'United States%';

select `date` ,
STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging_3;

update layoffs_staging_3
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

alter table layoffs_staging_3 
modify  column `date` Date;

select `date` 
from layoffs_staging_3 ;


-- 3 Null values or blank values


select * 
from layoffs_staging_3 
where industry is null 
or industry ='';

select * 
from layoffs_staging_3
where company = 'Airbnb' ;

update layoffs_staging_3
set industry = Null 
where industry ='';


select t1.industry,t2.industry
from layoffs_staging_3 t1 
join layoffs_staging_3 t2 
on t1.company = t2.company
where (t1.industry is null or t1.industry='') and 
t2.industry is not null;


update layoffs_staging_3 t1 
join layoffs_staging_3 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null  
and 
t2.industry is not null;


select * 
from layoffs_staging_3
where company = 'Airbnb' ;

select * 
from layoffs_staging_3 
where industry is null 
or industry ='';

select * 
from layoffs_staging_3
where total_laid_off is null
 and percentage_laid_off is null;

delete
from layoffs_staging_3
where total_laid_off is null
 and percentage_laid_off is null;
 
 select* 
 from layoffs_staging_3;
 
 -- 4. remove columns
 alter table layoffs_staging_3
 drop column row_num;

select* 
 from layoffs_staging_3;
 