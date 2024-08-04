SELECT * 
FROM [Portforlio Projects].dbo.CovidDeathsCSV
--WHERE continent is not null
order by 3,4

--SELECT * 
--FROM [Portforlio Projects].dbo.CovidVaccinationsCSV
--order by 3,4

-- SELECT Data that we are going to be using

--SELECT location,date,total_cases, new_cases, total_deaths, population
--FROM [Portforlio Projects].dbo.CovidDeathsCSV
--order by 1,2

-- Looking at total cases Vs total deaths

SELECT location,date,total_cases, total_deaths, (CONVERT(float, total_deaths)/ NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM [Portforlio Projects].dbo.CovidDeathsCSV
WHERE location LIKE '%states%'
order by 1,2

SELECT location,date,total_cases,population, (NULLIF(CONVERT(float, total_cases), 0)/ CONVERT(float, population)) * 100 AS PercentPopulationInfected
FROM [Portforlio Projects].dbo.CovidDeathsCSV
--WHERE location LIKE 'Thailand'
order by 1,2

-- Looking at countries with  highest infection rate compared to population

SELECT location,MAX(total_cases) as HighestInfectionCount,population,
MAX((NULLIF(CONVERT(float, total_cases), 0)/ NULLIF(CONVERT(float, population),0))) * 100 AS PercentPopulationInfected
FROM [Portforlio Projects].dbo.CovidDeathsCSV
--WHERE location LIKE 'Thailand'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with highest death count per population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portforlio Projects].dbo.CovidDeathsCSV
WHERE continent <> ''
Group by location
order by TotalDeathCount desc



-- Showing continents with the highest death counts

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portforlio Projects].dbo.CovidDeathsCSV
WHERE continent <> '' 
Group by continent
order by TotalDeathCount desc

-- Global numbers

--SELECT date,SUM(cast(new_cases as int)), SUM(cast(new_deaths as int)),
--SUM(CAST(new_deaths AS int)) / CAST(SUM(CAST(new_cases AS int)) as float) * 100 as DeathPercentage--total_cases, total_deaths, (CONVERT(float, total_deaths)/ NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
--FROM [Portforlio Projects].dbo.CovidDeathsCSV
----WHERE location LIKE '%states%'
--Where continent <> ''
--Group by date
--order by 1,2

SELECT 
    SUM(CAST(new_cases AS int)) AS TotalNewCases,
    SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,
	Case
		WHEN SUM(CAST(new_cases as int)) = 0  THEN 0
        ELSE SUM(CAST(new_deaths AS int)) / CAST(SUM(CAST(new_cases AS int)) as float) * 100 
	END AS DeathPercentage
FROM 
    [Portforlio Projects].dbo.CovidDeathsCSV
WHERE 
    continent <> ''
--GROUP BY 
   -- date
ORDER BY 
    1,2

-- Looking at total Population vs Vacination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portforlio Projects].dbo.CovidDeathsCSV as dea
JOIN [Portforlio Projects].dbo.CovidVaccinationsCSV as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ''
Order by 1,2,3

--USE CTE

WITH PopVsVac(Continent, Location, Date, Population,New_vaccinations,RollingPeopleVaccinated)  AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portforlio Projects].dbo.CovidDeathsCSV as dea
JOIN [Portforlio Projects].dbo.CovidVaccinationsCSV as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '')
--Order by 2,3)
SELECT * 
FROM PopVsVac

-- Temporary Table


CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Data datetime,
Population numeric(18,2),
New_vaccination numeric(18,2),
RollingPeopleVaccinated int)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date as Data, CAST(dea.population as numeric(18,2)) as Population, CAST(vac.new_vaccinations as numeric(18,2)) as New_vaccination,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portforlio Projects].dbo.CovidDeathsCSV as dea
JOIN [Portforlio Projects].dbo.CovidVaccinationsCSV as vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent <> '')
--Order by 2,3)
SELECT * 
FROM #PercentPopulationVaccinated

--Creating Views to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portforlio Projects].dbo.CovidDeathsCSV as dea
JOIN [Portforlio Projects].dbo.CovidVaccinationsCSV as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ''
--Order by 2,3

SELECT * FROM PercentPopulationVaccinated










