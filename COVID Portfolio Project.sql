SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order BY 3,4

-- SELECT dData that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the liklihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location LIKE '%states%' and continent is not null
Order BY 1,2

-- Looking at the Total Cases vs the Population

SELECT location, date, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Order BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Group By location, population
Order BY PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Where continent is not null
Group By location
Order BY TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
-- correct query
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Where continent is null
Group By location
Order BY TotalDeathCount desc


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location LIKE '%states%'
Where continent is not null
Group By continent
Order BY TotalDeathCount desc


-- GLOBAL NUMBERS 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where location LIKE '%states%' 
WHERE continent is not null
Group by date
order by 1,2


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where location LIKE '%states%' 
WHERE continent is not null
--Group by date
order by 1,2


SELECT *
FROM PortfolioProject..CovidVaccinations

-- JOININNG TABLES

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date

-- Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 Order by 2,3

 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 Order by 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
 , (RollingPeopleVaccinated/population)*
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 Order by 2,3

 -- Didnt work, so now need to use a CTE or temp table

 -- USE CTE

 With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
-- Order by 2,3
 )
 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac


 -- Temp Table
 DROP Table if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255)
 ,location nvarchar(255)
 ,date datetime
 ,population numeric
 ,new_vaccinations numeric
 ,RollingPeopleVaccinated numeric
 )
 
 INSERT INTO #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
-- Where dea.continent is not null
-- Order by 2,3

 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated


-- Creating view to store later for visualizations

Create view PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

SELECT *
FROM sys.views
WHERE name = 'PercentPopulationVaccinated';
