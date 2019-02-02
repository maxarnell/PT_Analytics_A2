DROP TABLE IF EXISTS gtfs_routes;

--Set up table
create table gtfs_routes (
	route_id text,
	agency_id text,
	route_short_name text,
	route_long_name text,
	route_desc text,
	route_fare_class text,
	route_type int,
	route_url text,
	route_color text,
	route_text_color text,
	route_sort_order int,
	line_id text,
	listed_route text
);

-- Import from CSV
COPY gtfs_routes FROM 'C:\Users\maxar\Dropbox (MIT)\Spring 2019\Analytics\Assign1\MBTA_GTFS\routes.txt' CSV HEADER; -- ENCODING 'windows-1252';

-- Test
SELECT * FROM gtfs_routes 
	WHERE gtfs_routes.route_desc LIKE 'Key Bus' OR
	gtfs_routes.route_desc LIKE 'Rapid Transit'
