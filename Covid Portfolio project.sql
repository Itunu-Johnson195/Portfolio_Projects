Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

-- Select data going to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


ALTER TABLE CovidDeaths
Alter COLUMN total_deaths decimal

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases decimal

-- Looking at total cases vs total deaths
-- Likelihood of dying from covid in the united kingdom

Select Location,date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%kingdom%'
order by 1,2


--total cases compared to the total population
-- what was the percentage of the population that got covid
Select Location,date, Population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where location like '%kingdom%'
order by 1,2


-- Countries with a high infection rate compared to it population
Select Location, Population, MAX(total_cases) as PeakInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Group by Location, Population
order by InfectedPopulationPercentage desc


-- Countries with the highest death rate per population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc



-- Sorting data by continent
-- Sorting by the highest death counts
Select continent , MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc








-- Looking at the data globally

-- total of global cases & deaths
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by Date
order by 1,2


--Sorting the total cases & deaths daily
Select Date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Date
order by 1,2




Select *
From PortfolioProject..CovidVaccinations







-- Looking at Total Population compared to Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



--CTE--

With PopCompareVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopCompareVac




--Temp table

Create Table #VaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #VaccinationPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From #VaccinationPercentage





---





Drop Table if exists #VaccinationPercentage
Create Table #VaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #VaccinationPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3


Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From #VaccinationPercentage




-- view for data visualizations

Create view VaccinationPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


select * from dbo.VaccinationPercentage

