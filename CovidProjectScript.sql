-- Exploring COVID data by country using SQL queries 

--Selecting the data we will be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the percent chance of dying if you contract COVID
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases ) * 100 AS deathPercentage
FROM CovidPortfolioProject..CovidDeaths$
WHERE Location = 'United States' 
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases / population ) * 100 AS casesPercentage
FROM CovidPortfolioProject..CovidDeaths$
WHERE Location = 'United States'
ORDER BY 1, 2


--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases / population )) * 100 AS PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths$
GROUP BY population, location
ORDER BY 4 DESC


--Showing countries with highest death count per Population
-- Continents are included in the location data so "WHERE continent is NOT NULL" removes them 

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM CovidPortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Total Cases by Continents/Region (EU is included)
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM CovidPortfolioProject..CovidDeaths$
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers of cases and deaths per day

SELECT date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast (new_deaths as int))/SUM(new_cases) * 100 as globalDeathPercentage
FROM CovidPortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
Group BY date
ORDER BY 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths$ dea
JOIN CovidPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL 
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH popVsVac (continent, location, date, population, new_vaccinations,  rollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths$ dea
JOIN CovidPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL 
)
SELECT *, (rollingPeopleVaccinated / population) * 100   
FROM popVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
newVaccinations int,
rollingPeopleVaccinated int
)

Insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths$ dea
JOIN CovidPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL 

SELECT *, (rollingPeopleVaccinated / population) * 100   
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths$ dea
JOIN CovidPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
