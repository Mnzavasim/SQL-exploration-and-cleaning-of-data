Select *
From Portofolio_project.dbo.coviddeaths$
where continent is not null
order by 3,4



Select *
from Portofolio_project..covidvaccinations$
where continent is not null
Order by 3,4


--Select the data that are going to be used 

Select Location, date, total_cases, new_cases, total_deaths, population
From Portofolio_project.dbo.coviddeaths$
where continent is not null
order by 1,2


-- Total deaths vs total cases


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portofolio_project.dbo.coviddeaths$
where continent is not null
order by 1,2

--Looking at Total cases vs Population to show what percentage of population got covid


Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From Portofolio_project.dbo.coviddeaths$
where continent is not null
order by 1,2

--Looking at countries with high infection rate compared to Population

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectedPercentage
From Portofolio_project.dbo.coviddeaths$
where continent is not null
Group by Location, Population, date
Order by InfectedPercentage desc


--determine countries with Highest death count per population

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From Portofolio_project.dbo.coviddeaths$
where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by Location 
Order by TotalDeathCount desc

--View death count in each  continent

Select Continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From Portofolio_project.dbo.coviddeaths$
where continent is not null
Group by Continent 
Order by TotalDeathCount desc





--try global numbers other way around

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portofolio_project..coviddeaths$
where continent is not null 
--Group By date
order by 1,2

--Join the vaccination and death tables
--Looking at Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as PeopleVaccinatedAdded
From Portofolio_project..coviddeaths$ dea
Join Portofolio_project..covidvaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3



--Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinatedAdded) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as PeopleVaccinatedAdded
From Portofolio_project..coviddeaths$ dea
Join Portofolio_project..covidvaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (PeopleVaccinatedAdded/Population)*100
From PopvsVac


-- Temporary table
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedAdded numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as PeopleVaccinatedAdded
From Portofolio_project..coviddeaths$ dea
Join Portofolio_project..covidvaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3

Select *, (PeopleVaccinatedAdded/Population)*100
From #PercentagePopulationVaccinated



-- creating view to store data for visualization




Create View Mbagala 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinatedAdded
From Portofolio_project..coviddeaths$ dea
Join Portofolio_project..covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



Select *
From Mbagala