CREATE EXTENSION postgis;

--SELECT * FROM gtfs_routes WHERE route_desc ILIKE '%bus%' LIMIT 10;--
-- checking what is in gtfs routes--

CREATE TABLE key_stops AS
SELECT DISTINCT r.route_id, r.route_short_name 
	FROM gtfs_routes AS r, gtfs_trips AS trp, gtfs_stops AS stp,
	WHERE route_desc = 'Key Bus'
		AND r.route_id = trp.route_id;

DROP TABLE IF EXISTS freq_stops;
CREATE TABLE freq_stops AS
SELECT DISTINCT s.stop_name, s.the_geom, r.route_id
FROM gtfs_routes r
JOIN gtfs_trips t on r.route_id = t.route_id
JOIN gtfs_stop_times st on st.trip_id = t.trip_id
JOIN gtfs_stops s on s.stop_id = st.stop_id
WHERE r.route_desc IN ('Key Bus', 'Rapid Transit');

