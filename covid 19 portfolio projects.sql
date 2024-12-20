
--COVID 19 DATA EXPLORATION

--SKILLS USED; JOINS, AGGREGATE FUNCTIONS, CTE'S, WINDOWS FUNCTIONS, TEMP TABLES, CONVERTING DATATYPES, CREATING VIEWS


SELECT *
FROM  dbo.covidDeaths
where continent is not null
order by 3,4
      
Select *
FROM PortfolioProject.dbo.CovidVaccinations
Order By 3,4


---selecting the data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM  dbo.covidDeaths
where continent is not null
order by 1,2

--- total_cases vs total_deaths
---shows likelyhood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, 
      (convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as deathpercentage
FROM  dbo.covidDeaths
where location like '%kenya%'
and continent is not null
order by 1,2


---total_cases vs population
---shows what percentage of population got covid

SELECT location,date,total_cases,population, 
      (convert(float,total_cases)/nullif(convert(float,population),0))*100 as percentagepopulationinfected
FROM  dbo.covidDeaths
--where location like '%kenya%'
order by 1,2

--- countries that have the highest infection rate compared to the population

 set ansi_warnings off
SELECT location, population, max(total_cases) as highestinfectioncount,convert(float,total_cases)/nullif(convert(float,population),0)*100 as percentagepopulationinfected
from dbo.covidDeaths
--where location like '%kenya%'
--where continent is not null
group by location,population,total_cases
order by percentagepopulationinfected desc



---showing countries with highest deathcount per population

select location, sum(cast(total_deaths as int))as totaldeathcount
from dbo.coviddeaths
--where location like %kenya%
where continent is not null
group by location
order by totaldeathcount desc



-- BREAKING THINGS DOWN BY CONTINENT

select continent, sum(cast(new_deaths as int)) as totaldeathcount
from dbo.covidDeaths
--where location like %kenya%
where continent  is NOT null
group by continent
order by totaldeathcount desc

--showing continents with the highest death count 

select continent, MAX(cast(TOTAL_deaths as int))as totaldeathcount
from dbo.coviddeaths
--where location like %kenya%
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers
SELECT sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/nullif(sum(cast(new_cases as int)),0)*100 as deathpercentage
FROM  dbo.covidDeaths
--where location like '%kenya%'
where continent is not null
--group by date
order by 1,2

--looking at total vaccination vs population
---Percentage of population that received at least one covid vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from dbo.coviddeaths dea
 join dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3


--- using CTE to perform calculation on pertition by in previous query

 with popvsvac (continent,lacation,date,population, new_vaccinatins,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from dbo.coviddeaths dea
 join dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3
)
 select*, nullif(rollingpeoplevaccinated,0)/nullif(population,0)*100 
 from popvsvac



 -- using temp table to perform calculation on partiton by in previous query

 drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
 (
 continent varchar(50),
 location varchar(50),
 date varchar(50),
 population float,
 new_vaccinations float,
 rollingpeoplevaccinated float
 )


 insert into #percentagepopulationvaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from dbo.coviddeaths dea
 join dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 1,2,3

  select*, nullif(rollingpeoplevaccinated,0)/nullif(population,0)*100 
 from #percentagepopulationvaccinated


 --creating view to store data for later visualization


 create view percentagepopulationvaccinated as
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from dbo.coviddeaths dea
 join dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3

 select*
 from percentagepopulationvaccinated
