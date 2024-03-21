Select *
From CovidProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From CovidProject..CovidVaccinations
Order by 3,4

Select location, DATE, total_cases,new_cases, total_deaths,  population
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in your country
Select location, DATE, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
Where continent is not null
Order by 1,2

--Looking at Total at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, DATE, population, total_cases, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by  location, population
Order by PercentPopulationInfected desc

--Showing Continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by  continent
Order by TotalDeathCount desc


--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by  location
Order by TotalDeathCount desc


--Global Numbers
Select  SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


--looking at Total Population vs vaccinations
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date =vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
with popvsvac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date =vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From popvsvac

--TEMP TABLE
Drop TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated 
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date =vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #percentPopulationVaccinated

--Creating View to store data for visualization

Create view PercentPopulationVaccinated as
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date =vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated