Select *
From  [Portfolio Project]..['Covid - Deaths$']
Where continent is not null
order by 3, 4

--Select *
--From  [Portfolio Project]..['Covid - Vacination$']
--order by 3, 4

-- select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From  [Portfolio Project]..['Covid - Deaths$']
order by 1, 2

Select Location, date, new_vaccinations
From  [Portfolio Project]..['Covid - Vacination$']
order by 1, 2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From  [Portfolio Project]..['Covid - Deaths$']
Where location like '%Kingdom%'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of Population has Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
From  [Portfolio Project]..['Covid - Deaths$']
Where location like '%Kingdom%'
order by 1, 2


-- Highest Covid inffection rates compared to population

-- Looking at Total Cases vs Population
-- Shows what percentage of Population has Covid
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
From  [Portfolio Project]..['Covid - Deaths$']
Group by Location, Population
order by PercentageOfPopulationInfected desc


-- Showing Countries with the highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From  [Portfolio Project]..['Covid - Deaths$']
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Showing Contients with highest death count per Population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From  [Portfolio Project]..['Covid - Deaths$']
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Gobal Numbers
-- Getting the Global Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From  [Portfolio Project]..['Covid - Deaths$']
-- Where location like '%Kingdom%'
Where continent is not null
Group by date
order by 1, 2 desc

-- Forumla to Target Total Number of Covid Deaths World wide
Select SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From  [Portfolio Project]..['Covid - Deaths$']
-- Where location like '%Kingdom%'
Where continent is not null
-- Group by date
order by 1, 2 


-- Lookinhg for Total Population vs Vaccinations
-- Using CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid - Deaths$'] dea
Join [Portfolio Project]..['Covid - Vacination$'] vac
 On dea.location = vac.location
 and dea.date = vac.date
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- Temp Table
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid - Deaths$'] dea
Join [Portfolio Project]..['Covid - Vacination$'] vac
 On dea.location = vac.location
 and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentagePopulationVaccinated



-- Creating View to store data for later visualisations
Create View PercentagePopulationVaccinated as 
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid - Deaths$'] dea
Join [Portfolio Project]..['Covid - Vacination$'] vac
 On dea.location = vac.location
 and dea.date = vac.date
