Select *
FROM PortfolioProject.CovidDeaths 
WHERE continent IS NOT NULL AND continent <> ''
order by 3,4;

-- Select *
-- FROM PortfolioProject.CovidVaccinations cv 
-- order by 3,4;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.CovidDeaths 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths 
WHERE Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths 
-- WHERE Location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths 
-- WHERE Location like '%states%'
GROUP BY Location, population
order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths 
-- WHERE Location like '%states%'
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY continent
order by TotalDeathCount desc


-- Showing Continent with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths 
-- WHERE Location like '%states%'
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY continent
order by TotalDeathCount desc


-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths 
-- WHERE Location like '%states%'
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
ORDER BY 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) AS
(SELECT dea.continent, 
dea.location,
dea.date, 
dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);


INSERT INTO PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	CASE 
        WHEN vac.new_vaccinations = '' THEN NULL 
        ELSE vac.new_vaccinations 
    END AS new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
-- ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated


-- CReating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	CASE 
        WHEN vac.new_vaccinations = '' THEN NULL 
        ELSE vac.new_vaccinations 
    END AS new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
-- ORDER BY 2,3;

SELECT *
FROM PercentPopulationVaccinated






