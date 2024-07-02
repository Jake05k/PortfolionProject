create view Covid_vaccination_2 as
select top 90000 *
from JacobProject..CovidV
-- Select Data that we are going to be using

Select location, date , total_cases, new_cases, total_deaths, population
from JacobProject..Covid_death_f
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from JacobProject..Covid_death_f
where location like '%india%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date ,Population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from JacobProject..Covid_death_f
where continent is not null
--where location like '%india%'
order by 1,2

--Looking at Countries with Highest Infection rate compared to population
Select location,Population, max(total_cases)as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from JacobProject..Covid_death_f
where continent is not null
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc

--Showing  countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from JacobProject..Covid_death_f
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from JacobProject..Covid_death_f
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global number


Select date ,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage-- total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from JacobProject..Covid_death_f
--where location like '%india%' 
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeoplevaccinated
from JacobProject..Covid_death_f dea 
join JacobProject..Covid_vaccination_2 vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null 
order by 2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeoplevaccinated
from JacobProject..Covid_death_f dea 
join JacobProject..Covid_vaccination_2 vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null 

)
select *, (RollingPeopleVaccinated/Population*100) from PopvsVac

--Creating view for visualisations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeoplevaccinated
from JacobProject..Covid_death_f dea 
join JacobProject..Covid_vaccination_2 vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
