select *
from PorfolioProjectSQL..CovidDeaths
where continent is not null
order by 3, 4


Select *
from PorfolioProjectSQL..CovidVaccinations
where continent is not null
order by 3, 4

Select location, date, total_cases, new_cases, new_deaths, total_deaths, population
from PorfolioProjectSQL..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProjectSQL..CovidDeaths
where location like '%ph%'
where continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PorfolioProjectSQL..CovidDeaths
where location like '%ph%'
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population


Select location, population , max(total_cases) as HighestInfectionsCount ,max((total_cases/population))*100 as PercentPopulationInfected
from PorfolioProjectSQL..CovidDeaths
--where location like '%ph%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population
--Notes use bigint instead of int since bigger storage

Select location, max(cast(Total_deaths as bigint)) as TotalDeathCount
from PorfolioProjectSQL..CovidDeaths
--where location like '%ph%'
where continent is not null
Group by location
order by TotalDeathCount desc

--By Continent
--my note : use is null in order to count total number in continent

Select Continent, max(cast(Total_deaths as bigint)) as TotalDeathCount
from PorfolioProjectSQL..CovidDeaths
--where location like '%ph%'
where continent is not null
Group by Continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PorfolioProjectSQL..CovidDeaths
--Where location like '%ph%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProjectSQ..CovidDeaths dea
Join PorfolioProjectSQ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
--error 

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProjectSQL..CovidDeaths dea
Join PorfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table 

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProjectSQL..CovidDeaths dea
Join PorfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations (sample)


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProjectSQL..CovidDeaths dea
Join PorfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 