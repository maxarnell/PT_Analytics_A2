DROP TABLE IF EXISTS gtfs_stops;

--Set up table
create table gtfs_stops (
	stop_id    text ,--PRIMARY KEY,
  	stop_name  text , --NOT NULL,
  	stop_desc  text,
  	stop_lat   double precision,
  	stop_lon   double precision,
  	level_id text,
  	location_type int,
  	parent_station text,
  	wheelchair_boarding int,
  	stop_code  text,
  	platform_code text,
  	platform_name text,
  	zone_id    text,
  	stop_url   text,
  	stop_address text
);

-- Import from CSV
COPY gtfs_stops FROM 'C:\Users\maxar\Dropbox (MIT)\Spring 2019\Analytics\Assign1\MBTA_GTFS\stops.txt' CSV HEADER; -- ENCODING 'windows-1252';

-- Add the_geom column to the gtfs_stops table - a 2D point geometry
SELECT AddGeometryColumn('gtfs_stops', 'the_geom', 4326, 'POINT', 2);

-- Update the the_geom column
UPDATE gtfs_stops SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

-- Create spatial index
CREATE INDEX "gtfs_stops_the_geom_gist" ON "gtfs_stops" using gist ("the_geom" gist_geometry_ops_2d);

