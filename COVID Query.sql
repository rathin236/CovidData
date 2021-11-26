--USE CovidPortfolio

--shows the likelihood dying if I contract covid in my homecountry

select location,date,total_cases,new_cases,total_deaths,new_deaths,(total_deaths/total_cases)*100 as deathrate
from CovidDeaths
where location like '%india%'
order by 1,2 

-- shows what percent of population was infected

select location,date,total_cases,population,(total_cases/population)*100 as Poppercent
from CovidDeaths
order by 1,2 

--Showing countries with high infection rates

SELECT TOP 10 location,population,MAX(total_cases) AS CasesToll,(MAX(total_cases)/MAX(population))*100 AS Infection_Rate
FROM CovidDeaths
GROUP BY location,population
ORDER BY 4 DESC,2

--Showing Maximum Deaths by country

SELECT location,MAX(CAST((total_deaths) AS int)) AS TotalDeathcount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Let's break things down by continent

SELECT continent,MAX(CAST((total_deaths) AS int)) AS TotalDeathcount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--Lets have a look at global numbers

SELECT date,SUM(new_cases) AS New_Cases,SUM(CAST(new_deaths AS int)) AS New_Deaths,(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercent 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

--New Vaccination Table

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccination
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--using CTE for percentage

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingVaccination)
AS (
	SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccination
	FROM CovidDeaths dea
	JOIN CovidVaccination vac
	ON dea.location=vac.location 
		AND dea.date=vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *,(RollingVaccination/population)*100
FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentVaccinated

CREATE TABLE #PercentVaccinated(
continent NVARCHAR(255),
location NVARCHAR(255),
Date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingVaccination NUMERIC)

INSERT INTO #PercentVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccination
	FROM CovidDeaths dea
	JOIN CovidVaccination vac
	ON dea.location=vac.location 
		AND dea.date=vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

SELECT * FROM #PercentVaccinated

--Creating a view

CREATE VIEW Percentpeoplevacc
AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccination
	FROM CovidDeaths dea
	JOIN CovidVaccination vac
	ON dea.location=vac.location 
		AND dea.date=vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
--DROP VIEW Percentpeoplevacc


