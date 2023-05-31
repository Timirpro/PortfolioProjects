select * from PortfolioProject..CovidDeaths 
Where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations 
--order by 3,4

--select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2 

-- Loking at Total Cases vs Total Deaths, Likelihood of death

select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%russia%'
order by 1,2 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location, date, population, total_cases, total_deaths, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%russia%'
order by 1,2 

-- Looking at Countries with Hightst Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
from PortfolioProject..CovidDeaths
-- where location like '%russia%'
Group by Location, population
order by InfectedPercentage desc

-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- by date

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%russia%'
where continent is not null
group by date
order by 1,2 

-- all time

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%russia%'
where continent is not null
-- group by date
order by 1,2


-- Looking ad Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From popvsVac

-- TEMP TABLE


Drop Table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PrecentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
From #PrecentPopulationVaccinated


-- Crating View to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated