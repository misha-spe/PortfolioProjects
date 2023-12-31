Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100.0 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2

-- Looking  at Total Cases vs Population
-- Shows the percentage of the population that got covid
SELECT Location, date, population, total_cases, (total_cases/population) * 100.0 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, Max(cast(total_cases/population as decimal (10,6))) * 100.0 AS 
PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By Location, Population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group By Location
ORDER BY TotalDeathCount desc


-- Showing Continents with the highest death count per population

SELECT Continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group By Continent
ORDER BY TotalDeathCount desc


-- Global Numbers

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF; 

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(
	new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
Group by date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(
	new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2



-- Looking at Covid cases vs Covid Deaths per Population Density

SELECT dea.location, SUM(dea.total_cases), SUM(dea.total_deaths), vac.population_density, 
	SUM(vac.people_fully_vaccinated), dea.population
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
WHERE dea.continent is not null
Group by dea.location, vac.population_density, dea.population



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, 
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3
-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, 
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE

--DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, 
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating Views to Store data for later visualizations

--viewing Rolling count of People Vaccinated per Country
Create View RollingCountOfPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, 
	dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
--select * from RollingCountOfPeopleVaccinated


--Create View HighestDeathCountPerPopulation as
--SELECT Continent, MAX(total_deaths) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--Where continent is not null
--Group By Continent

--DROP VIEW highestdeathcountperpopulation


--viewing Continents with the Highest Death Count per Population
Create View ContinentsHighestDeathCountPerPopulation as
SELECT Continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group By Continent
--select * from ContinentsHighestDeathCountPerPopulation

--viewing Countries with the Highest Death Count per Population
Create View CountriesHighestDeathCountPerPopulation as
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group By Location
--select * from CountriesHighestDeathCountPerPopulation



--viewing Countries with Highest Infection Rate compared to Population
CREATE VIEW CountriesHighestInfectionRatePerPopulation as
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, Max(total_cases/population) * 100.0 AS 
PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
Group By Location, Population
--select * from CountriesHighestInfectionRatePerPopulation