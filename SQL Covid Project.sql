Select *
From [Portfolio SQL Project]..CovidDeaths$
Where continent is not null
Order By 3,4

--Select *
--From [Portfolio SQL Project]..CovidVaccinations$
--Order By 3,4

-- Select Data we are going to USE

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio SQL Project]..CovidDeaths$
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio SQL Project]..CovidDeaths$
WHERE location like '%states%' AND continent is not null
Order By 1,2


-- Looking at Total case vs Population

Select location, date, population, total_cases, (total_cases/population)*100 AS Contraction_Percentage
From [Portfolio SQL Project]..CovidDeaths$
WHERE location like '%states%' AND continent is not null
Order By 1,2


-- Looking at Countries with Highest Infection rate compared to Population
Select location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS PercentPopulationInfected
From [Portfolio SQL Project]..CovidDeaths$
WHERE continent is not null
Group By location, population
Order By PercentPopulationInfected desc


-- Showing Countires with the Highest Death Count 
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From [Portfolio SQL Project]..CovidDeaths$
WHERE continent is not null
Group By location
Order By TotalDeathCount desc



--Showing Highest Death Count per Continent
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From [Portfolio SQL Project]..CovidDeaths$
WHERE continent is null AND NOT location = 'World' AND NOT location = 'International'
Group By location
Order By TotalDeathCount desc


-- Global Numbers 
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio SQL Project]..CovidDeaths$
WHERE continent is not null
Order By 1,2

--Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio SQL Project]..CovidDeaths$ dea
Join [Portfolio SQL Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- Using  CTE
With PopsvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio SQL Project]..CovidDeaths$ dea
Join [Portfolio SQL Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, RollingPeopleVaccinated/population*100
From PopsvsVac


-- Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio SQL Project]..CovidDeaths$ dea
Join [Portfolio SQL Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *, RollingPeopleVaccinated/population*100
From #PercentPopulationVaccinated


-- Creating View for Later Data Visualations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio SQL Project]..CovidDeaths$ dea
Join [Portfolio SQL Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated