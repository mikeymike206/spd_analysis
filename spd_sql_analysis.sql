SELECT * 
FROM SPD.dispatch;

-- These are the reports that are outside of city limits. We can remove this from the analysis but should be notes. 109 total
SELECT DISTINCT dispatch_precinct, count(unique_id)
FROM spd.dispatch
WHERE Dispatch_Precinct = "UNKNOWN";

-- Rename columns
ALTER TABLE spd.dispatch
RENAME COLUMN `Call Sign In-Service Time` TO Call_Sign_InService_Time;

ALTER TABLE spd.dispatch
DROP COLUMN `First Co-Response Call Sign Response Time (s)`;


-- This is the number of units that were dispacted to each call
SELECT CAD_id, Count(CAD_id) as count
FROM spd.dispatch
WHERE CAD_id 
GROUP BY CAD_id
ORDER BY COUNT DESC;

-- Average first response time for SPD to arrive on scene by dispatch precinct

WITH FirstArrival AS(
	SELECT CAD_id, MIN(first_SPD_Call_Sign_Response_Time) as first_arrival_time, dispatch_precinct
    FROM SPD.dispatch
    GROUP BY CAD_ID, dispatch_precinct
    )

SELECT dispatch_precinct, AVG(first_arrival_time) / 60 as avg_first_arrival_minutes, COUNT(DISTINCT Cad_id) as number_of_calls
FROM FirstArrival
GROUP BY Dispatch_Precinct
ORDER BY avg_first_arrival_minutes desc;

-- Average first response time for SPD to arrive on scene based on priority level
WITH FirstArrival AS(
	SELECT CAD_id, MIN(first_SPD_Call_Sign_Response_Time) as first_arrival_time, dispatch_precinct, priority
    FROM SPD.dispatch
    GROUP BY CAD_ID, dispatch_precinct, priority
    )

SELECT  dispatch_precinct,  priority, AVG(first_arrival_time) / 60 as avg_first_arrival_minutes, COUNT(DISTINCT Cad_id) as number_of_calls
FROM FirstArrival
GROUP BY Dispatch_Precinct, priority
ORDER BY priority asc, avg_first_arrival_minutes asc;

-- Create a new column, and -- Update date/time format
ALTER TABLE SPD.dispatch
ADD COLUMN CAD_Event_Original_Time_Queued_parsed DATETIME;

UPDATE SPD.dispatch
SET CAD_Event_Original_Time_Queued_parsed = STR_TO_DATE(CAD_Event_Original_Time_Queued, '%m/%d/%Y %r');


-- update the cells with blanks to null
UPDATE spd.dispatch
SET CAD_Event_First_Response_Time = NULL, Call_Sign_at_Scene_Time = NULL
WHERE TRIM(CAD_Event_First_Response_Time) = ''
	OR TRIM(Call_Sign_at_Scene_Time) = '';
    
    
-- the goal is to find the average time in minutes it takes it take for the frist SPD to repond 
-- to a call in desc order by first priorty. Include the princint they are in and the total number of calls each percinct gets 

SELECT *
FROM spd.dispatch;

SELECT * 
FROM SPD.dispatch
WHERE First_SPD_Call_Sign_Dispatch_Delay_Time < 0;

DELETE FROM spd.dispatch
WHERE First_SPD_Call_Sign_Dispatch_Delay_Time < 0;



-- DROP column data cleaning
ALTER TABLE 
	SPD.dispatch
DROP COLUMN 
	First_CARE_Call_Sign_Response_Time;

-- add unique id to the rows
ALTER TABLE spd.dispatch
ADD COLUMN unique_id INT;

SET @row_number = 0;

UPDATE spd.dispatch
SET unique_id = (@row_number := @row_number + 1);

-- first response time

WITH first_response_time
	AS (
    
    SELECT priority, cad_id, Dispatch_Precinct, min(First_SPD_Call_Sign_Response_Time) as first_on_scene
    FROM SPD.dispatch
    GROUP BY cad_id, dispatch_precinct
    )
    
SELECT priority, Dispatch_Precinct, AVG(first_on_scene) / 60 as minutes, COUNT(DISTINCT cad_id)
FROM first_response_time
GROUP BY Dispatch_Precinct
ORDER BY minutes asc;

-- average first arrival time and total number of calls for priortiy 1 calls by dispatch precinct
WITH FirstArrival AS (
	SELECT
		CAD_id,priority,
		MIN(first_SPD_Call_Sign_Response_Time) AS first_arrival_time,
		dispatch_precinct
	FROM
		SPD.dispatch
	GROUP BY
		CAD_id, dispatch_precinct, priority
)

SELECT
	dispatch_precinct, priority,
	ROUND(AVG(first_arrival_time) / 60, 2) AS avg_first_arrival_minutes,
	COUNT(DISTINCT CAD_id) AS number_of_calls
FROM
	FirstArrival
WHERE Priority = "1"
GROUP BY
	dispatch_precinct
ORDER BY
	avg_first_arrival_minutes ASC;
    
    
-- average time it takes for a unit to respond to a call by priorty and precinct
    
WITH FirstArrival
	AS (
		SELECT cad_id, 
			min(first_SPD_Call_Sign_Response_Time) as first_arrival, 
			dispatch_precinct, priority
        FROM 
			spd.dispatch
        GROUP BY 
			cad_ID, dispatch_precinct, priority
        )
        
        SELECT 
			dispatch_precinct, priority, 
            round(avg(first_arrival) / 60, 2) as avg_first_arrival, 
            count(cad_id)
        FROM 
			FirstArrival
        GROUP BY 
			dispatch_precinct, priority
        ORDER BY 
			priority asc, 
            avg_first_arrival asc;
            
-- average time it take for all firstunits to arrive to a call - by priority

WITH FirstArrival
	AS (
		SELECT cad_id, 
			min(first_SPD_Call_Sign_Response_Time) as first_arrival, 
			 priority
        FROM 
			spd.dispatch
        GROUP BY 
			cad_ID, priority
        )
        
        SELECT 
			priority, 
            round(avg(first_arrival) / 60, 2) as avg_first_arrival, 
            count(cad_id)
        FROM 
			FirstArrival
        GROUP BY 
			priority
        ORDER BY 
			priority asc, 
            avg_first_arrival asc;
            
-- Average delay from when a SPD unit is dispatched after the original queue 
-- find the null data points. it is screwing the data. 
WITH
	DispatchDelay
		AS (
        Select
			cad_id, min(Call_Sign_Dispatch_Delay_Time) as dispatch_delay, dispatch_precinct, priority 
		FROM
			spd.dispatch
		GROUP BY
			cad_id, dispatch_precinct, priority
            )
            
		SELECT 
			dispatch_precinct, priority, round(avg(dispatch_delay) / 60, 2) as avg_dispatch_delay, count(cad_id) as total_calls
		FROM 
			dispatchdelay
		GROUP BY 
			dispatch_precinct, priority
		ORDER BY
			priority asc, avg_dispatch_delay;
		
-- average call time by precinct and priority level
		SELECT 
            dispatch_precinct,
            priority, 
            round(avg(SPD_Call_Sign_Total_Service_Time) /60, 2) as avg_total_time, 
            count(cad_id)
		FROM 
			SPD.dispatch
		GROUP BY
			dispatch_precinct, priority
		ORDER BY
			priority ASC, avg_total_time ASC;
            
-- average total service time by priority level 
		SELECT 
            priority, 
            round(avg(SPD_Call_Sign_Total_Service_Time) /60, 2) as avg_total_time, 
            count(cad_id)
		FROM 
			SPD.dispatch
		GROUP BY
			priority
		ORDER BY
			priority ASC, avg_total_time ASC;
            
-- number of calls in each neighborhood by priortiy level
SELECT
	 dispatch_neighborhood, priority, dispatch_precinct, count(cad_id)
FROM
	spd.dispatch
GROUP BY
	dispatch_neighborhood, priority, dispatch_precinct
ORDER BY
	priority asc,
    count(cad_id) desc;
    
-- total number of calls in each neighborhood 
SELECT
	 dispatch_neighborhood, count(cad_id)
FROM
	spd.dispatch
GROUP BY
	dispatch_neighborhood, dispatch_precinct
ORDER BY
    count(cad_id) desc;
    
-- total number of calls by priority level

-- total number of calls by priority level 
SELECT
	 priority, count(cad_id)
FROM
	spd.dispatch
GROUP BY
	priority
ORDER BY
	priority asc,
    count(cad_id) desc;
    
    
-- number of units who responded to each call by priority level

SELECT 
	priority, cad_id, count(unique_id) as number_of_units_responded
FROM
	SPD.dispatch
GROUP BY 
	cad_id, priority
ORDER BY 
	number_of_units_responded desc;
    
-- average response time by time of day - 4 hour increments

WITH AvgResponseTimeByHoue
	AS (
	SELECT cad_id, CAD_Event_Original_Time_Queued_parsed, priority, min(call_sign_response_time) as first_response_time
    FROM SPD.dispatch
    GROUP BY cad_id, priority, CAD_Event_Original_Time_Queued_parsed, call_sign_response_time
    )
    
    SELECT priority, CAD_Event_Original_Time_Queued_parsed, avg(first_response_time) as acg_first_response_time,
    CASE
	WHEN HOUR (CAD_Event_Original_Time_Queued_parsed) between 0 and 4 THEN '00:00–03:59'
    END AS time_block
    FROM AvgResponseTimeByHoue
    GROUP BY priority, CAD_Event_Original_Time_Queued_parsed, time_block;
    
SELECT priority, avg(call_sign_response_time), 
	CASE
		WHEN HOUR (CAD_Event_Original_Time_Queued_parsed) between 0 and 4 THEN '00:00–03:59'
	END AS time_block
FROM spd.dispatch
GROUP BY priority;

        

SELECT 
	priority, CAD_Event_Original_Time_Queued_parsed,
CASE
	WHEN HOUR (CAD_Event_Original_Time_Queued_parsed) between 0 and 4 THEN '00:00–03:59'
END AS time_block
FROM spd.dispatch
WHERE priority = "1"
GROUP BY priority
ORDER BY time_block desc;


-- Heat Map for Areas of Crime by longitude and latitude
SELECT Dispatch_Longitude, Dispatch_Latitude, CAD_id
FROM spd.dispatch
GROUP BY CAD_id, Dispatch_Longitude, Dispatch_Latitude;
    
    
CREATE OR REPLACE VIEW fact_dispatch AS
SELECT
  cad_id,
  COUNT(*) AS responding_units,  -- 👈 Number of responding officers per call
  MIN(dispatch_time) AS first_dispatch_time,
  MIN(arrival_time) AS first_arrival_time,
  TIMESTAMPDIFF(SECOND, MIN(dispatch_time), MIN(arrival_time)) AS response_time_seconds,
  MIN(call_queued_time) AS call_queued_time,
  TIMESTAMPDIFF(SECOND, MIN(call_queued_time), MIN(dispatch_time)) AS dispatch_delay_seconds,
  ANY_VALUE(dispatch_datetime) AS dispatch_datetime,
  ANY_VALUE(dispatch_precinct) AS dispatch_precinct,
  ANY_VALUE(dispatch_neighborhood) AS dispatch_neighborhood,
  ANY_VALUE(priority) AS priority,
  HOUR(ANY_VALUE(dispatch_datetime)) AS dispatch_hour
FROM spd.dispatch
GROUP BY cad_id;

    