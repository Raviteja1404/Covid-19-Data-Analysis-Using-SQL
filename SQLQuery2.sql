select * from [dbo].[CovidDeaths]
where continent is not null
order by 3,4

--select * from [dbo].[CovidVaccinations$]
--order by 3,4

--Selecting the Data that we are going to use
select [Location],[date],total_cases,new_cases,total_deaths,[population]
from [dbo].[CovidDeaths]
order by 1,2

-- Looking at Total cases Vs Total Deaths
select [Location],[date],total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2

--Total Cases Vs Population
--It Shows percentage of Population got Covid
select [Location],[date],population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [dbo].[CovidDeaths]
--where continent is not null
order by 1,2


--Countries with Highest Infection Rate Compared to Population
select [Location],population,max(total_cases) as InfectionCount, max((total_cases/population))*100 as PercentPopulationInfected 
from [dbo].[CovidDeaths]
--where continent is not null
group by [Location],population
order by PercentPopulationInfected desc

--Countries with Highest Death Count Per Population
select [Location],max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by [Location]
order by TotalDeathCount desc

--Lets Break Things by Continents
select location,max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is null
group by location
order by TotalDeathCount desc

--Lets Break Things by Continents
--Continents With Highest Death Count
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2



--Looking at Total Population Vs Vaccinations
--Using Of CTE
with PopVsVac (Continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
select * ,(RollingPeopleVaccinated/population)*100 
from PopVsVac


--Creating Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated int
)

insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select * ,(RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--Creating View to Store Data for Later Visualizations

create view PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated