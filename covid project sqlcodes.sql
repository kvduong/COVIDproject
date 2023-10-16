/* COVID PROJECT PT2*/

--- displaying cases and deaths alongside percentage of total cases

With tempTable as 
(select location, total_cases, total_deaths, (select convert(float, total_cases) from profolioproject..CovidDeaths where date = '2023-05-05' and continent is null and location not like '%income%' and location not like '%Union%' and location like 'World') as 'world_total_cases'
from profolioproject..CovidDeaths
where date = '2023-05-05' and continent is not null and location not like '%income%' and location not like '%Union%')
Select location as 'Country', total_cases as 'Cases', total_deaths as 'Deaths', format(total_cases/world_total_cases, 'P3') as 'Percentage of World Total Cases' from tempTable

--- Global statistic of deaths and cases

Select location as Region, total_cases as 'Total Cases', total_deaths as 'Total Deaths', format( (convert(float, total_cases)/(select total_cases from profolioproject..CovidDeaths where date = '2023-05-05' and location like 'World')), 'P3' ) as 'Percentage From World'
from profolioproject..CovidDeaths
where date = '2023-05-05' and continent is null and location not like '%income%' and location not like '%Union%' and location not like 'World'

---timeline of deaths/cases

select location, date, total_cases, total_deaths from profolioproject..CovidDeaths
where location not like '%income%' and location not like '%Union%' and date between '2020-01-03' and '2023-05-05'
order by location, date

-- new case/deaths by continents

select location as Continent, date, new_cases, new_deaths from profolioproject..CovidDeaths
where continent is null and location not like '%income%' and location not like '%Union%' and date between '2020-01-03' and '2023-05-05'
order by Continent, date


/* One created table that holds world's cases will join rows by date*/

select o.location as Regions, o.date as 'Date', o.new_cases as 'New Cases', o.new_deaths as 'New Deaths', World.new_cases as 'Total World New Cases', format(isnull(o.new_cases / nullif(World.new_cases, 0), 0), 'P3') as 'Percentage of Total New Cases' from profolioproject..CovidDeaths as o
full join World on o.date = World.date
where Continent is null and location not like '%income%' and location not like '%Union%' and o.date between '2020-01-03' and '2023-05-05' and location not like 'World'
order by o.date, o.location
