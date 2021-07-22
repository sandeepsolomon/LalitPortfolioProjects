--COVID DATA EXPLORATION PROJECT

--select * from CovidVaccinations order by 3,4

select * from CovidDeaths 
where continent is not null
order by 3,4

--select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths 
order by 1,2

-- Looking at the total cases vs total deaths
--shows the likelihood dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths 
where location like '%states%'
order by 1,2

--Looking at the total cases vs population
--Shows what percentage of population got covid
select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from CovidDeaths 
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select Location, Population, max(total_cases) as highestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
from CovidDeaths 
--where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with the highest death count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths 
--where location like '%states%'
where continent is not null
group by Location, Population
order by TotalDeathCount desc

-- Let's break things down by CONTINENT
select Continent, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- SHowing Continents with the highest death count

select Continent, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select  Sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as Total_Deaths, 
Sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths 
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs total vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
