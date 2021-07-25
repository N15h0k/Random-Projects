select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--looking at total cases vs population
--Shows the Percentage of Population that got Covid in INDIA
select Location, Date, population, total_cases, (total_cases/population)*100 as "Population_Infected(%)"
from PortfolioProject..CovidDeaths$
where location like '%ndia%'
order by 1,2

--looking at total deaths vs total cases
--shows the likelihood of dying if you contract covid in INDIA
select Location, Date, total_deaths, total_cases, (total_deaths/total_cases)*100 as "Deaths_per_cases(%)"
from PortfolioProject..CovidDeaths$
where location like '%ndia%'
order by 1,2

-- Looking at countries with highest infection rate
select Location, population, max(cast(total_cases as int)) as "Highest_Infection_Count", max((total_cases/population))*100 "Population_Infected(%)"
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by 4 desc

--Showing Countries with  Highest Death Count per Population
select Location, max(cast(total_deaths as int)) as "total_death_count"
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by 2 desc

--Showing continents with highest death count
select continent, max(cast(total_deaths as int)) as "total_death_count"
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by 2 desc

or

select location, max(cast(total_deaths as int)) as "total_death_count"
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by 2 desc

--Death Percentage by Date
select Date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as "death_percentage(%)"
from PortfolioProject..CovidDeaths$
where continent is not Null
group by date
order by 1,2

--Death percentage in Total
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as "death_percentage(%)"
from PortfolioProject..CovidDeaths$
where continent is not Null
order by 1,2

--Looking at Total Population vs Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date)as "adding_up_vaccinated_people"
from PortfolioProject..CovidDeaths$ d join PortfolioProject..CovidVaccination$ v on d.location = v.location and d.date = v.date
where d.continent is not null
order by 1,2,3

--CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, adding_up_vaccinated_people)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date)as "adding_up_vaccinated_people"
from PortfolioProject..CovidDeaths$ d join PortfolioProject..CovidVaccination$ v on d.location = v.location and d.date = v.date
where d.continent is not null
)
select *, (adding_up_vaccinated_people/Population)*100 as "Percentage_Vaccinated(%)"
from PopvsVac

-- Temp Table
Drop table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
adding_up_vaccinated_people numeric
)
Insert into #Percent_Population_Vaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location, d.date)as adding_up_vaccinated_people
from PortfolioProject..CovidDeaths$ d join PortfolioProject..CovidVaccination$ v on d.location = v.location and d.date = v.date

select *, (adding_up_vaccinated_people/Population)*100 as "Percentage_Vaccinated(%)"
from #Percent_Population_Vaccinated

--creating views for visualisation
create view Percentage_Population_Vaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint, v.new_vaccinations)) over (partition by d.location order by d.location, d.date)as adding_up_vaccinated_people
from PortfolioProject..CovidDeaths$ d join PortfolioProject..CovidVaccination$ v on d.location = v.location and d.date = v.date

select * 
from Percentage_Population_Vaccinated