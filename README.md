**COVID-PORTFOLIO-PROJECT**

This project  dataset is used to analyse the  global data about covid_19 patients.

This project uses two dataset CovidDeaths.xlsx and CovidVaccinations.xlsx which have been cleaned in excel and loaded to mssql for data exploration.

**The files used;**

~**CovidDeaths.xlsx**- the dataset contains information on Covid-19 deaths worldwide

~**CovidVaccinations.xlsx**- the dataset contains information on Covid-19 vaccinations worldwide

~**Data Exploration.sql** - the SQL code used to explore the data in the database

~**Tableau Visualization.sql** - the SQL code used to visualize the dataset after exploration.

**skilles used include;**

JOINS, AGGREGATE FUNCTIONS, CTE'S, WINDOWS FUNCTIONS, TEMP TABLES, CONVERTING DATATYPES, CREATING VIEWS

**data exploration in SQL**

The COVID_19_PORTFOLIO PROJECT.SQL file contains SQL queries used to explore the covid 19 data.
The sql queries are used to analyse and explore the COVID DATA for a data analysis project.I used mssql to write the codes and tableu for visualizing the data.
The first two quries are use to select and order data from CovidDeaths and CovidVaccinations tables
The next queries we are looking at the death percentage based on;
  1. total_cases and total_deaths showing what percentage of population got covid.
  2. The countries that have the highest infection rate compared to the population.
  3. Looking countries with highest deathcount per population
  4. The last query breaking down the death counts by continent to provide a more global view of the COVID 19 pandemic.
  5. 
**THE QUERIES ARE AS FOLLOWS:**

-**-COVID 19 DATA EXPLORATION

--SKILLS USED; JOINS, AGGREGATE FUNCTIONS, CTE'S, WINDOWS FUNCTIONS, TEMP TABLES, CONVERTING DATATYPES, CREATING VIEWS

**
SELECT *
FROM  dbo.covidDeaths
where continent is not null
order by 3,4
      
Select *
FROM dbo.CovidVaccinations
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










