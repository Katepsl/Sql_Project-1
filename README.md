# Sql_Project
# Worldwide_companys_layoffs_analysis_using_sql
# Overview

This SQL script is designed to process, clean, and analyze data from a table named layoffs. The script performs the following main tasks:

Creating staging tables

Removing duplicates

Standardizing data

Cleaning null and blank values

Adding and populating new columns

Conducting exploratory data analysis (EDA)

# Script Details

# 1. Creating Staging Tables
   
Create and populate layoffs_staging table.

CREATE TABLE layoffs_staging LIKE layoffs;

INSERT layoffs_staging SELECT * FROM layoffs;

# 2. Removing Duplicates

Use CTE to identify and delete duplicate records.

WITH duplicate_CTE AS (SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num FROM layoffs_staging)

DELETE FROM layoffs_staging2 WHERE row_num > 1;

# 3. Standardizing Data

Trim spaces and standardize industry and country names.

UPDATE layoffs_staging2 SET company = TRIM(company);

UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';

UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

# 4. Cleaning Null and Blank Values

Handle null and blank values in industry and total_laid_off columns.

Delete rows with null total_laid_off, percentage_laid_off, or date.

UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';

DELETE FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2 WHERE `date` IS NULL;

# 5. Adding and Populating New Columns

Add ranking, total_employee, and employee_reduction_percentage columns.

Populate with calculated values.

ALTER TABLE layoffs_staging2 ADD COLUMN ranking INT;

ALTER TABLE layoffs_staging2 ADD COLUMN total_employee INT;

ALTER TABLE layoffs_staging2 ADD COLUMN employee_reduction_percentage VARCHAR(10);

UPDATE layoffs_staging2 SET total_employee = FLOOR(total_laid_off / percentage_laid_off) WHERE percentage_laid_off != 0;

UPDATE layoffs_staging2 SET employee_reduction_percentage = CONCAT(FLOOR((total_laid_off / total_employee) * 100), '%');

# 6. Exploratory Data Analysis (EDA)

Execute queries to explore the data.

SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoffs_staging2;

SELECT company, SUM(total_laid_off) FROM layoffs_staging2 GROUP BY company ORDER BY 2 DESC;

WITH rolling_total AS (SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_sum FROM layoffs_staging2 WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL GROUP BY `MONTH` ORDER BY 1 ASC)
SELECT `MONTH`, total_sum, SUM(total_sum) OVER (ORDER BY `MONTH`) AS rolling_total FROM rolling_total;

# Conclusion

This script ensures that the layoff data is clean, standardized, and ready for further analysis.





