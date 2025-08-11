select *
from [Portfolio Project]..CovidDeaths$
order by 3,4
where continent is not null

--select *
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
order by 1,2

--shows the likelihood of dieing if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
where location like '%kingdom%'
where continent is not null
order by 1,2

--shows the population that contracted covid in your country
Select Location, date, population, total_cases,  total_deaths, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
where location like '%kingdom%'
and continent is not null
order by 1,2

--shows the country with highest infection rate compared to population
Select Location, population, MAX(total_cases) as  HighestInfectionCount,	MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
--where location like '%kingdom%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--shows the country with highest death count per population
Select Location, MAX (cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like '%kingdom%'
where continent is not null
Group by location
order by TotalDeathCount desc

--BY CONTINENT

--shows the continent with highest death count 
Select continent, MAX (cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like '%kingdom%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeaths$ 
--where location like '%kingdom%'
where continent is not null
--Group by date
order by 1,2


--Showing Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100 
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255), 
location nvarchar (255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100 
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store date for later visualisations
Create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100 
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
