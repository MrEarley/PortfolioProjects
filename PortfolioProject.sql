SELECT * FROM coviddeaths;

-- SELECT * FROM covidvaccinations;

-- Select Data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population FROM coviddeaths
ORDER BY location, date;

-- Look at Total Cases vs. Total Deaths
-- Shows likelihood of dying if infected
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
Where location = 'France'
ORDER BY location, date;

-- Looking at Total Cases vs Population

SELECT location, date, total_cases, Population, (Population/total_cases)*100 as PercentageInfected
FROM coviddeaths
Where location = 'France'
ORDER BY location, date;

-- Looking at countries with highest infection rate

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 
AS PercentagePopulationInfected
FROM coviddeaths
Group BY location, population
ORDER BY PercentagePopulationInfected desc;

-- Showing countries with the highest death count per population as percentage

SELECT location, Population, MAX(cast(total_deaths as unsigned)) as HighestDeathCount, Max((total_deaths/population))*100 
AS PercentagePopulationDead
FROM coviddeaths
Where continent is not null
Group BY location, population
ORDER BY HighestDeathCount desc;

-- Showing continents with the highest death count

SELECT continent, MAX(cast(total_deaths as unsigned)) as TotalDeathCount
FROM coviddeaths
Where continent is not null
Group BY continent
ORDER BY TotalDeathCount desc;

-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
where continent is not null;
-- Group by date;


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
    where dea.continent is not null
    Order BY location, date;
   
   
SELECT dea.date, vac.date, dea.location, vac.location
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.date = vac.date
JOIN coviddeaths dea
ON dea.location = vac.location;
-- AND dea.location = vac.location;
	-- ON dea.date = vac.date;
    -- ON dea.location = vac.location;
    -- where dea.continent is not null;
    -- Order BY location, date;
    
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as TotalPeopleVaxxed
FROM coviddeaths dea
JOIN covidvaccinations2 vac
ON dea.date = vac.date
AND dea.location = vac.location
where dea.continent is not null
ORDER BY 2, 3;


-- Using a CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, TotalPeopleVaxxed)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as TotalPeopleVaxxed
FROM coviddeaths dea
JOIN covidvaccinations2 vac
ON dea.date = vac.date
AND dea.location = vac.location
where dea.continent is not null
-- ORDER BY 2, 3;
)
Select *, (TotalPeopleVaxxed/Population)*100 as VaxxedPercent
From PopvsVac;

-- Using a Temp Table to do the same

Drop table if exists PercentPopulationVaccinated;
Create table PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaxxed numeric
);

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as TotalPeopleVaxxed
FROM coviddeaths dea
JOIN covidvaccinations2 vac
ON dea.date = vac.date
AND dea.location = vac.location;
-- where dea.continent is not null;
-- ORDER BY 2, 3;

Select *, (TotalPeopleVaxxed/Population)*100 as VaxxedPercent
From PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW WhoVaxxed as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as TotalPeopleVaxxed
FROM coviddeaths dea
JOIN covidvaccinations2 vac
ON dea.date = vac.date
AND dea.location = vac.location
where dea.continent is not null
ORDER BY 2, 3;




