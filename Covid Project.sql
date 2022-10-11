-- Set the schema as default schema for easy navigation

SELECT * FROM coviddeaths
WHERE continent IS NOT NULL
order by 4,5;

-- Extract data for analysis

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- Total Cases vs Total Deaths
-- To see the likelihood of death upon contracting covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
order by 1,2;

-- Exploring Pakistani figures

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths where location = 'Pakistan'
order by 1,2;

-- By 30th Apr '21, Pakistan had a death percentage of 2.17% compared to India's 1.10% and 4.39% in Afghanistan for the same date. This shows the percentage of death if you contract covid in these countries.

-- Exploring countries with highest infection rate compared to the population ordered by location and population

select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths group by location, population
order by 1,2;

-- Exploring countries with highest infection rate compared to the population ordered in a descending order by PercentPopulationInfected

select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths group by location, population
order by 4 desc;

-- Exploring Pakistan's infection rate compared to the population

select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths where location = 'Pakistan' group by location, population
order by 4;

-- As per the data, 0.37% of the population was affected by covid in Pakistan

-- Exploring countries with highest death count per population

select location, max(total_deaths) as HighestDeathCount
from coviddeaths group by location
order by 2 desc;

-- The results included continents as location as well therefore filtering out such results

select location, max(total_deaths) as HighestDeathCount
from coviddeaths where continent is not null
group by location order by 2 desc;

-- United States of America had the highest death count equal to 576,232

-- Now, extracting the same results by continent instead of countries

select continent, max(total_deaths) as HighestDeathCount
from coviddeaths where continent is not null
group by continent order by 2 desc;

-- Extracting Global Numbers

select sum(new_cases) as totalcases, sum(new_deaths) as totaldeaths,
sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeaths where continent is not null;

-- Joining Covid Vaccinations with Covid Deaths
-- Extracting Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Adding a rolling count column for the calculation of commulative vaccinations for each country

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CommulativeVaccinations
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Creating a CTE to see how many people are vaccinated in a country

With PopVsVacc (Continent, Location, Date, Population, New_Vaccinations, CommulativeVaccinations)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CommulativeVaccinations
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3)
select * from PopVsVacc;

-- Calculating commulative vaccinations over population as a percentage using the CTE

With PopVsVacc (Continent, Location, Date, Population, New_Vaccinations, CommulativeVaccinations)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CommulativeVaccinations
from coviddeaths dea join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3)
select *, (CommulativeVaccinations/Population)*100 as CommulativeVaccPerc from PopVsVacc;