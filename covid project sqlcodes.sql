--Countries' death percentages as of "2023-05-05"
select location, date, population, total_cases, total_deaths,
round(((total_deaths/population)*100),2) as DeathPercentage from 
profolioproject..CovidDeaths
where date = '2023-05-05' 
order by 6 desc

----------------
-- location and continent death percentage as of May 5th 2023 
select continent, location, population, total_cases, total_deaths,
round(((total_deaths/population)*100),2) as DeathPercentage from 
profolioproject..CovidDeaths
where date = '2023-05-05' and continent is not null
order by DeathPercentage desc

-- 7 Continents
select location, population, total_cases, total_deaths,
round(((total_deaths/population)*100),2) as DeathPercentage from 
profolioproject..CovidDeaths
where date = '2023-05-05' and continent is null and location not like '%income%' and location not like '%Union%'
order by DeathPercentage desc

--------------

--infected rate
select location, population, MAX(cast(total_cases as int)) as HighestCases, MAX((total_cases/new_cases)*100) as PopInfectionRate 
from profolioproject..CovidDeaths
group by location, population
order by PopInfectionRate desc

--Highest Death count
select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from profolioproject..CovidDeaths
where continent is not null and location not like '%income%' and location not like '%Union%'
group by location
order by TotalDeathCount desc

--Death Count by Continents
select location as Continents, MAX(cast(total_deaths as int)) as TotalDeathCount 
from profolioproject..CovidDeaths
where continent is null and location not like '%income%' and location not like '%Union%'
group by location
order by TotalDeathCount desc

--World
select * from profolioproject..CovidDeaths
where location like 'World'

select date, sum(new_cases) as Cases, sum(new_deaths) as Deaths
from profolioproject..CovidDeaths
where continent is not null
group by date
order by date

-- total pop vs vacs

select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacs.new_vaccinations, Vacs.total_vaccinations
, SUM(convert(bigint, vacs.new_vaccinations)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as total_vaxed 
from profolioproject..CovidVacs Vacs
Join profolioproject..CovidDeaths Deaths
	on Vacs.location = Deaths.location
	and Vacs.date = Deaths.date
where Deaths.continent is not null --and Deaths.location like 'China'
order by 2,3

-- The Vaccination data has total_vaccinations added but not in new_vaccinations, total vacs are not equaling the calculated partition.  The new vacs may not be recorded.

--with another table

With PopPop (continent, location, date, population, new_vaccination, total_vax) 
as (
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacs.new_vaccinations
, SUM(convert(int, vacs.new_vaccinations)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as total_vaxed 
from profolioproject..CovidVacs Vacs
Join profolioproject..CovidDeaths Deaths
	on Vacs.location = Deaths.location
	and Vacs.date = Deaths.date
where Deaths.continent is not null
--order by 2,3
)
Select *, (total_vax/Population)*100 --Population data may be incorrect, new vaccination overflow, or possibly re-vax
from PopPop
--where location like 'China'
order by location, date


--Temp table
Drop table if exists #PercentPopulationVaxed
Create table #PercentPopulationVaxed
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vax numeric,
)

insert into #PercentPopulationVaxed
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacs.new_vaccinations
, SUM(convert(bigint, vacs.new_vaccinations)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as total_vaxed 
from profolioproject..CovidVacs Vacs
Join profolioproject..CovidDeaths Deaths
	on Vacs.location = Deaths.location
	and Vacs.date = Deaths.date
where Deaths.continent is not null
--order by 2,3

select * , (total_vax/population)*100
from #PercentPopulationVaxed

-- the percentage of total people vax is actually the amount of vax per person on average. 

-- Creating View

Create View PopulationVaccinated as
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacs.new_vaccinations
, SUM(convert(bigint, vacs.new_vaccinations)) OVER (partition by Deaths.location order by Deaths.location, Deaths.date) as total_vaxed 
from profolioproject..CovidVacs Vacs
Join profolioproject..CovidDeaths Deaths
	on Vacs.location = Deaths.location
	and Vacs.date = Deaths.date
where Deaths.continent is not null
--order by 2,3

Drop view if exists PopulationVaccinated 

Select * from PopulationVaccinated