

--pull necessary info
DROP TABLE IF EXISTS revenue_stops;
CREATE TABLE revenue_stops AS

SELECT s.stop_name, s.the_geom, r.route_id, st.trip_id, t.service_id, st.arrival_time, st.departure_time, r.route_desc, st.pickup_type, st.drop_off_type
FROM gtfs_routes r
JOIN gtfs_trips t on r.route_id = t.route_id
JOIN gtfs_stop_times st on st.trip_id = t.trip_id
JOIN gtfs_stops s on s.stop_id = st.stop_id
WHERE st.pickup_type = 1 OR st.drop_off_type = 1;

--extract days
ALTER TABLE revenue_stops
DROP COLUMN IF EXISTS weekday;
ALTER TABLE revenue_stops
ADD COLUMN weekday int;
UPDATE revenue_stops
SET weekday =
strpos(service_id,'Weekday')
WHERE strpos(service_id,'Weekday')>0;

ALTER TABLE revenue_stops
DROP COLUMN IF EXISTS saturday;
ALTER TABLE revenue_stops
ADD COLUMN saturday int;
UPDATE revenue_stops
SET saturday =
strpos(service_id,'Saturday')
WHERE strpos(service_id, 'Saturday')>0;


DROP TABLE IF EXISTS trip_day;
CREATE TABLE trip_day AS (
SELECT weekday, saturday, service_id, trip_id,
CASE WHEN saturday > 0 THEN 'Saturday'
		WHEN weekday>0 THEN'Weekday'
		ELSE 'Other'
		END
		FROM revenue_stops);

--add new seconds columns
ALTER TABLE revenue_stops
DROP COLUMN IF EXISTS begin_sec;
ALTER TABLE revenue_stops
ADD COLUMN begin_sec float;
ALTER TABLE revenue_stops
DROP COLUMN IF EXISTS end_sec;
ALTER TABLE revenue_stops
ADD COLUMN end_sec float;



--convert times to seconds
UPDATE revenue_stops
SET begin_sec =
	(CAST(SUBSTRING(arrival_time FROM 1 FOR 2)AS float) * 3600) +
	( CAST(SUBSTRING(arrival_time FROM 4 FOR 2)AS float) * 60);

UPDATE revenue_stops
SET end_sec =
	(CAST(SUBSTRING(departure_time FROM 1 FOR 2)AS float) * 3600) +
	(CAST(SUBSTRING(departure_time FROM 4 FOR 2)AS float) * 60);
	
	

--time trips



DROP TABLE IF EXISTS journey_times;
CREATE TABLE journey_times AS
SELECT min(begin_sec), max(end_sec), ((max(end_sec) - min(begin_sec))/60) AS dur_minutes, trip_id  FROM revenue_stops
GROUP BY trip_id;

DROP TABLE IF EXISTS journey_combine;
CREATE TABLE journey_combine AS 
SELECT rs.route_id, j.trip_id, j.dur_minutes, rs.route_desc, td.case AS day_of_week
FROM revenue_stops rs
JOIN journey_times j on rs.trip_id = j.trip_id
JOIN trip_day td on rs.trip_id = td.trip_id;

DROP TABLE IF EXISTS journey_summ;
CREATE TABLE journey_summ AS 
SELECT jc.day_of_week, jc.route_desc, (SUM(jc.dur_minutes))/60 AS dur_hours
FROM journey_combine jc
WHERE NOT jc.day_of_week= 'Other'
GROUP BY route_desc, day_of_week
ORDER BY day_of_week;
										   
SELECT * FROM journey_summ;




