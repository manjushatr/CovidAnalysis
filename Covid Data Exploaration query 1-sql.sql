--Covid 19 Statistics

-- Covid Deaths Data

	SELECT * 
	FROM coviddeaths
	order by 1,2

--Covid Vaccinations Data

	SELECT *
	FROM  covidvaccinations
	order by 1,2

-- Covid deaths by location and date

	SELECT location, date,total_cases_per_million,new_cases,total_deaths,population
	FROM coviddeaths
	where continent is not null
	order by 1,2

-- Total cases vs Total Death

	--SET ARITHABORT ON   -- Default 
	--SET ANSI_WARNINGS ON --Default

	SET ARITHABORT OFF   
    SET ANSI_WARNINGS OFF

	SELECT location, date,total_cases_per_million,new_cases,total_deaths,(total_deaths/total_cases_per_million)
	FROM coviddeaths
	where continent is not null
	order by 1,2

	-- the result as percentage
	SET ARITHABORT OFF   
    SET ANSI_WARNINGS OFF

	SELECT location, date,total_cases_per_million,new_cases,total_deaths,(total_deaths/total_cases_per_million) * 100 as DeathPercentage
	FROM coviddeaths
	where continent is not null
	order by 1,2


	-- the death percentage by location - eg: Sweden
	SET ARITHABORT OFF   
    SET ANSI_WARNINGS OFF

	SELECT location, date,total_cases_per_million,new_cases,total_deaths,(total_deaths/total_cases_per_million) * 100 as DeathPercentage
	FROM coviddeaths
	where continent is not null
	and location = 'Sweden'
	order by 1,2
	
	--What percentage of population had covid in a location?
	-- Total cases vs Population
	SET ARITHABORT OFF   
    SET ANSI_WARNINGS OFF

	SELECT location, date,total_cases_per_million,new_cases,population,(total_cases_per_million/population) * 100 as CovidinPopulationPercentage
	FROM coviddeaths
	where continent is not null
	and location = 'Sweden'
	order by 1,2


	--What percentage of population had covid in all locations?
	-- Total cases vs Population
	SET ARITHABORT OFF   
    SET ANSI_WARNINGS OFF

	SELECT location, date, population,total_cases_per_million,new_cases,(total_cases_per_million/population) * 100 as CovidinPopulationPercentage
	FROM coviddeaths
	where continent is not null
	order by 1,2

	--countries with highest infection rate compared to the population

	SELECT location,population,max(total_cases_per_million) as HighestTotalInfected,max(total_cases_per_million/population) * 100 as PercentagePopulationInfected
	FROM coviddeaths
	where continent is not null
	GROUP BY location,population
	order by PercentagePopulationInfected desc

	--Countries with highest death count per population

	SELECT location, max(total_deaths) as HighestDeathCount
	FROM coviddeaths
	where continent is not null
	GROUP BY location
	order by HighestDeathCount desc

	--Continents with highest death count per population
	SELECT continent, max(total_deaths) as HighestDeathCount
	FROM coviddeaths
	where continent is not null
	GROUP BY continent
	order by HighestDeathCount desc
	
	--checking the correctness of values of the above query

	SELECT location, max(total_deaths) as HighestDeathCount
	FROM coviddeaths
	where continent is null
	GROUP BY location
	order by HighestDeathCount desc

	--Total new cases reported each day

	SELECT date, sum(new_cases) as totalnewcases
	FROM coviddeaths
	where continent is NOT NULL
	GROUP BY date
	order by 1,2

	--Total new cases and new deaths reported each day

	SELECT date, sum(new_cases) as totalnewcases, sum(new_deaths) as totalnewdeaths
	FROM coviddeaths
	where continent is NOT NULL
	GROUP BY date
	order by 1,2

	--Total new cases and new deaths reported each day, percentage of newdeaths over newcases
	SET ARITHABORT OFF   
    SET ANSI_WARNINGS OFF

	SELECT date, sum(new_cases) as totalnewcases, sum(new_deaths) as totalnewdeaths,
	sum(new_deaths)/sum(new_cases) * 100 as NewDeathPercentage
	FROM coviddeaths
	where continent is NOT NULL
	GROUP BY date
	order by 1,2


	--Total new cases and new deaths, percentage of newdeaths over newcases, global
	SET ARITHABORT OFF   
    SET ANSI_WARNINGS OFF

	SELECT  sum(new_cases) as totalnewcases, sum(new_deaths) as totalnewdeaths,
	sum(new_deaths)/sum(new_cases) * 100 as NewDeathPercentage
	FROM coviddeaths
	where continent is NOT NULL
	--GROUP BY date
	order by 1,2

	
	-- vaccination details of all covid infections

	SELECT *
	FROM coviddeaths cvd
	JOIN covidvaccinations cvc
	ON cvd.date = cvc.date
	AND  cvd.location= cvc.location

	--Total population vs vaccination

	SELECT cvd.continent, cvd.location,cvd.date,cvd.population,cvc.new_vaccinations
	FROM coviddeaths cvd
	JOIN covidvaccinations cvc
	ON cvd.date = cvc.date
	AND  cvd.location= cvc.location
	WHERE cvd.continent IS NOT NULL
	order by 1,2,3

	SELECT cvd.continent, cvd.location,cvd.date,cvd.population,cvc.new_vaccinations,
	SUM(cvc.new_vaccinations) OVER (PARTITION BY cvd.location order by cvd.location, cvd.date)
	FROM coviddeaths cvd
	JOIN covidvaccinations cvc
	ON cvd.date = cvc.date
	AND  cvd.location= cvc.location
	WHERE cvd.continent IS NOT NULL
	order by 1,2,3

	WITH popsvac(Continent, Location,Date,Population,New_vaccinations, RollingPeopleVaccinated)
	AS
	(SELECT cvd.continent, cvd.location,cvd.date,cvd.population,cvc.new_vaccinations,
	SUM(cvc.new_vaccinations) OVER (PARTITION BY cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
	FROM coviddeaths cvd
	JOIN covidvaccinations cvc
	ON cvd.date = cvc.date
	AND  cvd.location= cvc.location
	WHERE cvd.continent IS NOT NULL)
	SELECT *,(RollingPeopleVaccinated/Population)*100 FROM popsvac