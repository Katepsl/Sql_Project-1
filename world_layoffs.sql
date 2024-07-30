SELECT * FROM layoffs;

-- Creating new tables

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT * FROM layoffs;

WITH duplicate_CTE AS
(SELECT *, ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date',stage, country, funds_raised_millions ) 
AS row_num
FROM layoffs_staging)
SELECT * 
FROM duplicate_CTE 
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
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

SELECT * 
FROM layoffs_staging2;

-- Data cleaning

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date',stage, country, funds_raised_millions ) 
AS row_num
FROM layoffs_staging;

-- Deleting duplicates

DELETE
FROM layoffs_staging2 
WHERE row_num >1 ;

-- Data standardizing

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs_staging2
order by 1;

SELECT *
FROM layoffs_staging2 WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(country)
FROM layoffs_staging2 WHERE country LIKE 'United States%' ;

UPDATE layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Deleting blank values and uncessary Null values

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2 WHERE industry IS NULL;

SELECT t1.industry,t2.industry FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE Layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off iS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off iS NULL;

DELETE 
FROM layoffs_staging2
WHERE `date` IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

UPDATE layoffs_staging2
SET total_laid_off = COALESCE(total_laid_off, 47)
WHERE percentage_laid_off = 0.06 AND industry = 'Healthcare';

UPDATE layoffs_staging2
SET total_laid_off = COALESCE(total_laid_off, 60)
WHERE percentage_laid_off = 0.06 AND location = 'Sao Paulo';

select * from layoffs_staging2;

-- Creating my own new columns

ALTER TABLE layoffs_staging2
ADD COLUMN ranking INT;

WITH company_year (company,years,total_laid_off) AS
(SELECT company,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)), 
company_year_rank AS
(SELECT * , DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
 WHERE years IS NOT NULL)
UPDATE layoffs_staging2 AS ls
JOIN company_year_rank AS cyr
ON ls.company = cyr.company AND YEAR(ls.`date`) = cyr.years
SET ls.ranking = cyr.ranking;

SELECT *,total_laid_off/percentage_laid_off AS total_employee
FROM layoffs_staging2 ;

ALTER TABLE layoffs_staging2
ADD COLUMN total_employee INT;

UPDATE layoffs_staging2
SET total_employee = FLOOR(total_laid_off/percentage_laid_off)
WHERE percentage_laid_off != 0;

ALTER TABLE layoffs_staging2
ADD COLUMN employee_reduction_percentage VARCHAR(10);

UPDATE layoffs_staging2
SET employee_reduction_percentage =CONCAT(Floor((total_laid_off/total_employee)*100),'%');

SELECT * , DENSE_RANK() OVER(PARTITION BY `date` 
ORDER BY SUM(total_laid_off) DESC) AS ranking 
FROM layoffs_staging2;

SELECT company,YEAR(`date`),total_laid_off, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company,YEAR(`date`), total_laid_off;

-- Exploratory data analysis

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`FROM layoffs_staging2;

WITH rolling_total AS
(SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_sum
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY  `MONTH`
ORDER BY 1 ASC)
SELECT `MONTH`, total_sum, SUM(total_sum) OVER(ORDER BY `MONTH`) AS rolling_total
FROM rolling_total;















