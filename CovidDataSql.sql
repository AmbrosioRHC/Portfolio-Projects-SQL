SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order by 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

SELECT location, date, CAST(total_cases as float) AS total_cases, new_cases, 
CAST(total_deaths as float) AS total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

Order by 1,2;

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in Chile
SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths as float) / NULLIF(CAST(total_cases as float), 0)) * 100 AS Deathpercentage

FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'chile'
AND continent IS NOT NULL
Order by 1,2;

-- Looking at total cases vs population

SELECT location, date, total_cases, population, 
(CAST(total_cases as float) / NULLIF(CAST(population as float), 0)) * 100 AS PercentPopulationInfected

FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'chile'
AND continent IS NOT NULL

Order by 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population,  MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentagePopulationInfected

FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'chile'
WHERE continent IS NOT NULL
GROUP BY location, population
Order by PercentagePopulationInfected DESC;


-- Showing countries with highest deaths counts per population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'chile' AND continent IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location
Order by TotalDeathsCount DESC;


-- Showing continent with highest deaths counts per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'chile' AND continent IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY continent
Order by TotalDeathsCount DESC;



-- Showing continents with highest deaths count per population

-- GLOBAL NUMBERS	

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%chile%'
WHERE continent IS NOT NULL		
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccinatios

SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population float,
new_vaccinations float, 
RollingPeopleVaccinated float
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

--Creating view to store data for later viz

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations )) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *
FROM PercentPopulationVaccinated