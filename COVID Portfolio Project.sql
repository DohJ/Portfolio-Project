Select *
FROM PortfolioProject.dbo.['CovidDeaths (2)$']
Where Continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
Order by 3,4

 --select data that we are going to be using
 
Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.['CovidDeaths (2)$']
order by 1,2

--looking at Total Cases vs Total Deaeths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.['CovidDeaths (2)$']
--Where location like '%states%'
Where Continent is not null
order by 1,2

--U.S. is currently around 1% of DeathPercentage as of 07Jan2022

--Looking at Total cases vs population
--Shows what percentage of population got covid


Select Location, date,Population, total_cases, (total_deaths/population)*100 as DeathPercentage
FROM PortfolioProject.dbo.['CovidDeaths (2)$']
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population 
Select Location, Population, MAX(total_cases) as hightestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject.dbo.['CovidDeaths (2)$']
Group by location, population
order by PercentagePopulationInfected desc



--Showing Counties with Highest Death Count per population 
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.['CovidDeaths (2)$']
Where Continent is not null
Group by location
order by TotalDeathCount desc

-- Let's BREAK THIGNS DOWN BY CONTINENT 
-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..['CovidDeaths (2)$']
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global numbers
Select Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.['CovidDeaths (2)$']
--Where location like '%states%'
Where Continent is not null
--Group By date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
from PortfolioProject..['CovidDeaths (2)$'] dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
Order By 2,3


--Use CTE

with PopvsVac (Continent, Location, Date, Population,vac_new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeaths (2)$'] dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP TAble if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeaths (2)$'] dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store date for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeaths (2)$'] dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order By 2,3

Select*
From PercentPopulationVaccinated