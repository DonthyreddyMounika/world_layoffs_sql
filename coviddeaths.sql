select * 
from SQLPORTFOLIO..CovidDeaths$
where continent is not null

SELECT location, date, total_cases, new_cases , total_deaths, population 
from SQLPORTFOLIO..CovidDeaths$
order by 1,2

-- total cases vs total deaths
SELECT location, date, total_cases,  total_deaths,(total_deaths/ total_cases)*100 as DeathPercentage
from SQLPORTFOLIO..CovidDeaths$
where location like '%India%' and continent is not null
order by 1,2

-- total cases vs population
SELECT location, date,  population, total_cases, (convert(float,total_cases)/NULLIF(convert(float ,population),0))*100 as CasesPercentage
from SQLPORTFOLIO..CovidDeaths$
where continent is not null
order by 1,2

-- countries with highest infection rate

SELECT location,   population, MAX(total_cases) as highestinfectioncount , max((convert(float,total_cases)/NULLIF(convert(float ,population),0))*100) as populationpercentinfected
from SQLPORTFOLIO..CovidDeaths$
where continent is not null
group by location, population
order by populationpercentinfected desc


-- countries with highest death count per population 

SELECT location, max(cast (total_deaths as int))as TotalDeathCount
from SQLPORTFOLIO..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- showing continents with highest death count

SELECT continent, max(cast (total_deaths as int))as TotalDeathCount
from SQLPORTFOLIO..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- total new deaths and new cases
SELECT date, sum(new_cases) as TotalNewCases,sum(cast (new_deaths as int))as TotalNewDeaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as NewDeathPercent
from SQLPORTFOLIO..CovidDeaths$
where continent is not null
group by date
order by 1 ,2



select * from 
SQLPORTFOLIO..CovidVaccinations$
--join two tables

select *
from  SQLPORTFOLIO..CovidDeaths$  dea
join SQLPORTFOLIO..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date= vac.date

-- total population vs vaccinations

select dea.continent, dea.location , dea.date, dea.population, vac.total_vaccinations
from  SQLPORTFOLIO..CovidDeaths$  dea
join SQLPORTFOLIO..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date= vac.date
where dea.continent is not null
order by 2,3




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
--rolling count of vaccinations


-- rolling sum vaccinated percentage using cte 
 with popvsvac ( continent, location , date, population, total_vaccinations, rolling_peoplevaccinated)
 as 
 (
 select dea.continent, dea.location , dea.date, dea.population, vac.total_vaccinations, 
sum(convert (int,vac.total_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as rolling_peoplevaccinated
from  SQLPORTFOLIO..CovidDeaths$  dea
join SQLPORTFOLIO..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date= vac.date
where dea.continent is not null
)
select * , (rolling_peoplevaccinated/population)*100 as rollingvaccinePercent
from popvsvac


-- temptable
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population, vac.total_vaccinations, 
sum(convert (int,vac.total_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollingPeopleVaccinated
from  SQLPORTFOLIO..CovidDeaths$  dea
join SQLPORTFOLIO..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date= vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated