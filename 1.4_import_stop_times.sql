DROP TABLE IF EXISTS gtfs_stop_times;

CREATE TABLE gtfs_stop_times (
	

	
	trip_id text , --REFERENCES gtfs_trips(trip_id),
  	arrival_time text, -- CHECK (arrival_time LIKE '__:__:__'),
  	departure_time text, -- CHECK (departure_time LIKE '__:__:__'),
  	stop_id text , --REFERENCES gtfs_stops(stop_id),
  	stop_sequence int , --NOT NULL,
  	stop_headsign text,
  	pickup_type   int , --REFERENCES gtfs_pickup_dropoff_types(type_id),
  	drop_off_type int , --REFERENCES gtfs_pickup_dropoff_types(type_id),
  	timepoint text,
	checkpoint_id text
);

COPY gtfs_stop_times FROM 'C:\Users\maxar\Dropbox (MIT)\Spring 2019\Analytics\Assign1\MBTA_GTFS\stop_times.txt' CSV HEADER; -- ENCODING 'windows-1252';

SELECT * FROM gtfs_stop_times LIMIT 100;