SELECT *
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProjects..CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL AND location LIKE '%malaysia%'
ORDER BY 1, 2

--Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_deaths/population)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL AND location LIKE '%malaysia%'
ORDER BY 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC

--Looking at Countries with Highest Death Rate compared to Population
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeath
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeath DESC

--Breaking things down by Continents
--Showing the continents with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeath
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeath DESC

--Global numbers
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths AS int)) as TotalDeaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2 

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Creating view to store data for later visualisations

--Percentage of Rolling Vaccination
CREATE VIEW PercententageRollingVaccinantion AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
--ORDER BY 2,3

--Global Numbers
CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths AS int)) as TotalDeaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1, 2 

--Total Case v Population
CREATE VIEW TotalCasePop AS
SELECT location, date, total_cases, population, (total_deaths/population)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
--ORDER BY 1, 2

--Total Case v Total Death
CREATE VIEW TotalCaseDeath AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
--ORDER BY 1, 2

--Highest Infection per Population
CREATE VIEW HighInfect AS
SELECT location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY InfectedPercentage DESC