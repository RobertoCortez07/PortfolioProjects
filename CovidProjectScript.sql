/*
Covid 19 Data Exploration. Primarily focusing on the United States but contains data for every country.

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


If you would like to see a Tableau visualization of this data

https://public.tableau.com/views/COVID-19DataAnalysisDashboard_16968142802930/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link

*/

Select *
From covid_deaths
Where continent is not null
order by 3,4;


-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
Where continent is not null
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as deaths_percentage
from covid_deaths
where location = 'United States'
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population) * 100 as percent_population_infected
From covid_deaths
where location = 'United States'
order by 2;

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as highest_infection_count,
       Max((total_cases/population))*100 as percent_population_infected
From covid_deaths
WHERE continent is not null and total_deaths is not null
Group by location, population
order by percent_population_infected desc;

-- Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as total_death_count
From covid_deaths
Where continent is not null AND total_deaths is not null
Group by Location
order by total_death_count desc;


-- Breaking things down by continents

-- Showing continents with the highest death count per population
-- Included the WHERE IN statement because location had several rows not related to geography such as 'lower income,
-- middle income, etc'


Select location, MAX(total_deaths) as total_death_count
From covid_deaths
Where continent is null and location in ('World', 'Asia', 'Europe', 'Africa', 'South America', 'North America', 'Oceania')
group by location
order by total_death_count desc;

-- Global COVID cases and deaths per day

Select date, SUM(new_cases) as total_cases_per_day, SUM(new_deaths) as total_deaths_per_day,
       (sum(new_deaths)/ sum(new_cases)) * 100 as death_percentage_per_day
From covid_deaths
Where continent is not null and new_cases > 0
group by date
order by 1, 2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one COVID vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (
           PARTITION BY dea.location
           order by dea.location, dea.date
           ) as rolling_vaccination_total
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
order by 2,3;



-- Using CTE to perform Calculation on Partition By in previous query

With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccination_total)
    AS (
        SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (
           PARTITION BY dea.location
           order by dea.location, dea.date
           ) as rolling_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
    )

SELECT *, (pop_vs_vac.rolling_vaccination_total/population) * 100 as rolling_vaccination_percentage from pop_vs_vac
order by 2,3;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists percent_population_vaccinated;
CREATE TEMPORARY TABLE percent_population_vaccinated
(
    continent varchar(255),
    location varchar(255),
    date date,
    population numeric,
    new_vaccinations numeric,
    rolling_vaccination_percentage numeric
);

INSERT INTO percent_population_vaccinated
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (
           PARTITION BY dea.location
           order by dea.location, dea.date
           ) as rolling_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
);

SELECT *,
       (percent_population_vaccinated.rolling_vaccination_percentage/
        percent_population_vaccinated.population) * 100 as rolling_vaccination_percentage
from percent_population_vaccinated
order by 2,3;


-- Creating View to store data for later visualizations

CREATE VIEW rolling_vaccination_percentage AS
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (
           PARTITION BY dea.location
           order by dea.location, dea.date
           ) as rolling_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null



