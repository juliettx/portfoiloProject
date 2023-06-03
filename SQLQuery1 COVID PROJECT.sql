--SELECT *
--FROM [portfoilo project]..CovidVaccinations$
--ORDER BY 3,4
--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT *
FROM [portfoilo project]..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [portfoilo project]..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- shows likeihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [portfoilo project]..CovidDeaths$
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2

-- looking at toal cases vs pop
-- shows what percentage of pop got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage -- change to percentpopinflection
FROM [portfoilo project]..CovidDeaths$
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2


-- looking at countries w/ highest infection rate compared to pop
SELECT location, population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as pERCENTpopulationInfected
FROM [portfoilo project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY pERCENTpopulationInfected desc

-- LET BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [portfoilo project]..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- showing countries w/ highest death count per pop
SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [portfoilo project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBER
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [portfoilo project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking total pop vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM [portfoilo project]..CovidDeaths$ dea JOIN [portfoilo project]..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 ;


-- use CTE
-- 1:03:59 timestamp need fixing
With PopvsVac (Continent, Location, Date, Population, NEW_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM [portfoilo project]..CovidDeaths$ dea JOIN [portfoilo project]..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- temp table
DROP TABLE IF exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM [portfoilo project]..CovidDeaths$ dea JOIN [portfoilo project]..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

--SELECT *, (RollingPeopleVaccinated/Population)*100
--FROM #PercentPopulationVaccinated;

-- creating view to store data for later visualizations

GO
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM [portfoilo project]..CovidDeaths$ dea JOIN [portfoilo project]..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated