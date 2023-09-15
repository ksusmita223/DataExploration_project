select *
from SQL_Project..covidDeaths
order by 3,4


select *
from SQL_Project..CovidVaccination
order by 3,4

--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from SQL_Project..covidDeaths
order by 1,2


--looking at total cases vs total deaths
--likelihood of dying if you contract covid in country India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from SQL_Project..covidDeaths
order by 1,2

--looking at total cases vs population
--shows what percent of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as covidPercentage
from SQL_Project..covidDeaths
order by 1,2

--highest infection duration
select location, date, population, new_cases, total_cases, MAX(new_cases) as HighestInfected
from SQL_Project..covidDeaths
Group by new_cases, date, location, population, total_cases
order by  HighestInfected desc

--highest death rate time
select location, date, population, new_cases, total_cases, new_deaths, MAX(new_deaths) as HighestDeaths
from SQL_Project..covidDeaths
Group by new_cases, date, location, population, total_cases, new_deaths
order by HighestDeaths desc

--total death rate 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from SQL_Project..covidDeaths
order by 1,2

--looking at total people vs vaccination

--merging of two tables
select *
from SQL_Project..covidDeaths dea
join SQL_Project..CovidVaccination vac
	on dea.date = vac.date

select dea.location, dea.date, dea.population, vac.new_vaccinations
from SQL_Project..covidDeaths dea
join SQL_Project..CovidVaccination vac
	on dea.date = vac.date
	and dea.location = vac.location
order by 1, 2

--total vaccination

select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations))   OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from SQL_Project..covidDeaths dea
join SQL_Project..CovidVaccination vac
	on dea.date = vac.date
	and dea.location = vac.location
order by 2

--USE CTE

with popVsVac(location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations))   OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from SQL_Project..covidDeaths dea
join SQL_Project..CovidVaccination vac
	on dea.date = vac.date
	and dea.location = vac.location
--order by 2
)
select*, (RollingPeopleVaccinated/population)*100
from popVsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations))   OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from SQL_Project..covidDeaths dea
join SQL_Project..CovidVaccination vac
	on dea.date = vac.date
	and dea.location = vac.location

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

create View PercentPopulationVaccinated as
select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations))   OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from SQL_Project..covidDeaths dea
join SQL_Project..CovidVaccination vac
	on dea.date = vac.date
	and dea.location = vac.location