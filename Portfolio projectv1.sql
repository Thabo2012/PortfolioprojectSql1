Select location, date, total_deaths,total_cases, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject ..CovidDeaths
where location like '%africa%'
order by 1,2

--Looking at total cases vs Population
--Show what percentage of Population got CovidDeaths
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))* 100 as PercentagePopulationInfected
From PortfolioProject ..CovidDeaths
Group by Location,Population
order by PercentagePopulationInfected desc

--Showing the highest death count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject ..CovidDeaths
Where Continent is not null
Group by Location
order by TotalDeathCount desc

--Breakup by Continent
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject ..CovidDeaths
Where Continent is not null
Group by location
order by TotalDeathCount desc

--Global numbers
Select date, SUM(new_cases), SUM(cast(new_deaths as float))--, total_deaths,total_cases, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject ..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as float)) as total_death, SUM(cast(new_deaths as float))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject ..CovidDeaths
where continent is not null
Group by date
order by 1,2

--Total population vs Vaccination
Select dea.continent, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.date = vac.date
and dea.location = vac.location
Where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from PercentPopulationVaccinated