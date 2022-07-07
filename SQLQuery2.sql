select *
From CovidDeaths
where continent is not null
order by 3,4


--select *
--From covidVaccinations
--order by 3,4


--select Data that we are going to be using


select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2


--Looking at the Total Cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where location like '%states%'
where continent is not null
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got covid

select Location, date, Population, total_cases, (total_cases/population)*100 as DeathPercentage
From CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--showing Countries with Highest Death count per Population
Select Location, Max(cast(Total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, Max(cast(Total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing the continent with the highest deathcount per population

Select continent, Max(cast(Total_deaths as bigint)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
where continent is null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Looking at total Population Vs vaccination

select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as rollingPeopleVaccinated
From CovidDeaths dea
join covidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
From CovidDeaths dea
join covidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
From CovidDeaths dea
join covidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
From CovidDeaths dea
join covidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
From CovidDeaths dea
join covidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
