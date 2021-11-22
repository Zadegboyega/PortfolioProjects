
--Analysis on Covid Death and Covid Vaccinations

--Let's select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioprojects..Coviddeath
Order by 1,2

--Create a View to look at Nigeria Covid Total_cases vs Total Death as of October 2021

Create View NigeriaCoviddeathPercentage as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From portfolioprojects..Coviddeath
Where location = 'Nigeria'


--Total cases vs population
--Shows what percentage of population got covid

Create view NigeriaPopulationVsCoviddeath as
	Select location, date, population, total_cases, (total_cases/population)*100 as Percentofpeopleinfected
	From portfolioprojects..Coviddeath
	Where location = 'Nigeria'
	And continent is not null


--looking at country with the highest infection rate compared to the population

Create View MostInfectedCountry as
Select location,population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as Percentpopulationinfected
From portfolioprojects..Coviddeath
Where continent is not null
Group by location,population
--Order by Percentpopulationinfected desc


--showing the country with highest death count
--Using Cast to convert the data type


Create View HighestdeathCount as
Select location,max(cast(total_deaths as int)) as TotalDeathCount
From portfolioprojects..Coviddeath
Where continent is not null
Group by location
--Order by TotalDeathCount desc


--Lets break down by continent
--showing the continents with the highest death count per population


Create View ContinentwiththeHighestdeathCount as
Select location,max(cast(total_deaths as int)) as TotalDeathCount
From portfolioprojects..Coviddeath
where continent is null
Group by location
Order by TotalDeathCount desc



Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Africa's highest covid deaths

Select location,max(cast(total_deaths as int)) as TotalDeathCount
From portfolioprojects..Coviddeath
Where continent is not null
and continent = 'Africa'
Group by location
Order by TotalDeathCount desc

Select * from PortfolioProjects..CovidDeath


--World total Covid Death Percentage
Create View WorldCoviddeathpercentage as
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_death , 
       SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From portfolioprojects..Coviddeath
Where continent is not null 
Order by 1,2


--daily Covid death percentage

Create View DailyCovidDeathPercentage as
Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_death , SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From portfolioprojects..Coviddeath
Where continent is not null 
Group by date
order by 1,2


--Joining the two datasets Covidvaccinations

Select * 
	From PortfolioProjects..CovidDeath dea
	Join PortfolioProjects..CovidVaccinations vac
		On dea.location = vac.location
		And dea.date =vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	From PortfolioProjects..CovidDeath dea
	Join PortfolioProjects..CovidVaccinations vac
		On dea.location = vac.location
		And dea.date =vac.date
	Where dea.continent is not null
	Order by 1,2,3


--To partition by location


Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location)
From PortfolioProjects..CovidDeath dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
	where dea.continent is not null
	order by 2,3

	--order by location and date
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProjects..CovidDeath dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
	where dea.continent is not null
	order by 2,3

Select dea.location,dea.population, 
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location ) as PeopleVaccinated
From PortfolioProjects..CovidDeath dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
	where dea.continent is not null
	group by dea.location

--Creating a CTE to show the cumulative percentage of peoplevaccinated for each country

With PopvsVac (continent, location, date, population, new_vaccinations, peoplevaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProjects..CovidDeath dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null) 
--To get the % of people vaccinated by day
Select * , (peoplevaccinated/population)*100 as Percentage_of_Peoplevaccinated
From PopvsVac

--TEMP TABLE
  
Drop Table if exists  #Percentage_of_Peoplevaccinated
Create Table #Percentage_of_Peoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
peoplevaccinated numeric
)
Insert into  #Percentage_of_Peoplevaccinated
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProjects..CovidDeath dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null 
--To get the % of people vaccinated by day
Select * , (peoplevaccinated/population)*100 as VaccinationsPercentage
From #Percentage_of_Peoplevaccinated

--Creating a view to be used later

Create view Percentage_of_Peoplevaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) as peoplevaccinated
From PortfolioProjects..CovidDeath dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
Where dea.continent is not null
and dea.location ='Africa'

Select dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) as peoplevaccinated
From PortfolioProjects..CovidDeath dea
Join PortfolioProjects..CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
--Where dea.continent is null
where dea.location ='Africa'