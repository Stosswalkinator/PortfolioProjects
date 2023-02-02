-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths`
WHERE location = "United States"
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS DiagnosedPercentage
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths`
WHERE location = "United States"
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths`
WHERE continent != "null"
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths`
WHERE continent != "null"
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths`
WHERE continent != "null"
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths`
WHERE continent != "null"
-- GROUP BY date
ORDER BY 1,2


-- Vaccinations time
-- Looking at total population vs vaccinations

WITH PopvsVac AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/dea.population)*100
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths` dea
JOIN `portfolioproject-376601.PortfolioProject.CovidVaccinations` vac
  on dea.location = vac.location and dea.date = vac.date
WHERE dea.continent != "null"
ORDER BY 2, 3
) SELECT * FROM PopvsVac


-- Use CTE

WITH PopvsVac AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths` dea
JOIN `portfolioproject-376601.PortfolioProject.CovidVaccinations` vac
  on dea.location = vac.location and dea.date = vac.date
WHERE dea.continent != "null"
ORDER BY 2, 3
) SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopvsVac


-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated

INSERT INTO #PercentPopulationVaccinated (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  , (RollingPeopleVaccinated/dea.population)*100
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths` dea
JOIN `portfolioproject-376601.PortfolioProject.CovidVaccinations` vac
  on dea.location = vac.location and dea.date = vac.date
WHERE dea.continent != "null"
-- ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopvsVac
)


-- VIEW

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  , (RollingPeopleVaccinated/dea.population)*100
FROM `portfolioproject-376601.PortfolioProject.CovidDeaths` dea
JOIN `portfolioproject-376601.PortfolioProject.CovidVaccinations` vac
  on dea.location = vac.location and dea.date = vac.date
WHERE dea.continent != "null"
-- ORDER BY 2, 3
-- SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
-- FROM PopvsVac

