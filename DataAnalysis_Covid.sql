SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is null
ORDER BY 3,4

--selecting the columns to view out of all other columns
SELECT Location, date, total_cases,new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if person gets affect by covid in any given country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--what percentage of population got covid
SELECT Location, date, population,total_cases, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at countries having highest infection rate compared to Population
SELECT Location, population, Max(total_cases) AS HighestInfectionCount, Max((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

--Showing Countries with the highest death count per population
SELECT Location, Max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--let's break things down by continent
SELECT continent, Max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT location, Max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--showing the continents with highest death count
SELECT continent, Max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Breaking global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--Joining two tables Covid deaths and Covid vaccinations
SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- looking at total population vs vaccinations
SELECT dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- rolling sum for vaccinations
SELECT dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--use cte (Option:1)
WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100 
FROM PopVSVac

--Temp table
DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


--Creating View to store data for visualizations
Create view PercentPopulationVaccinated as
SELECT dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

SELECT * from PercentPopulationVaccinated

