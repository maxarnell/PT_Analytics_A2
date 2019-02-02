
	


--calculate population density column




ALTER TABLE block_groups_2010
	ALTER COLUMN poptotal float;

--calc pop density	
	SELECT geom, geoid10, CAST(aland10 AS float), CAST( poptotal AS float), 
	(poptotal / (aland10 * .000000386)) AS pop_den FROM block_groups_2010 WHERE aland10>0;
				 
--add permenant pop_den column to block groups
	
ALTER TABLE block_groups_2010
	DROP COLUMN IF EXISTS pop_den;
ALTER TABLE block_groups_2010
	ADD COLUMN pop_den float;
				 
UPDATE block_groups_2010
		SET pop_den = (CAST(poptotal AS float) / (CAST(aland10 AS float) * .000000386))
												  WHERE aland10>0;
				 

/*				 --embedded CAST doesn't work?
 SELECT (CAST(poptotal AS float) / (CAST(aland10 AS float) * .000000386)) AS pop_den
	INTO block_groups_2010
	WHERE aland10>0;
												  */
	
									
--total population of dense areas
 SELECT geom, geoid10, CAST(aland10 AS float), CAST( poptotal AS float), 
	(poptotal / (aland10 * .000000386)) AS pop_den FROM block_groups_2010 WHERE aland10>0;
	SELECT SUM(poptotal) FROM block_groups_2010 WHERE aland10>0 AND (poptotal / (aland10 * .000000386)) >= 7000 ;
	
																				 
--total population of service area
 SELECT geom, geoid10, CAST(aland10 AS float), CAST( poptotal AS float), 
	(poptotal / (aland10 * .000000386)) AS pop_den FROM block_groups_2010 WHERE aland10>0;
	SELECT SUM(poptotal) FROM block_groups_2010 WHERE aland10>0 ;																			 

				 
				 
--add and union buffer to all_stops
 SELECT ST_Union(ST_BUFFER( ST_TRANSFORM(the_geom,2163),
 	800, 'quad_segs=8')) FROM all_stops;
						  
	UPDATE all_stops
		SET buffer = ST_BUFFER( ST_TRANSFORM(the_geom,2163),
 	800, 'quad_segs=8');
						  
--add and union buffer to frequent stops
SELECT ST_Union(ST_BUFFER( ST_TRANSFORM(the_geom,2163),
 	800, 'quad_segs=8')) FROM freq_stops;
	
	ALTER TABLE freq_stops
	DROP COLUMN IF EXISTS freq_buffer;
ALTER TABLE freq_stops
	ADD COLUMN freq_buffer geometry;
						  
	UPDATE freq_stops
		SET freq_buffer = ST_BUFFER( ST_TRANSFORM(the_geom,2163),
		800, 'quad_segs=8');
		
						  
	--create of mbta area union
DROP TABLE IF EXISTS mbta_zone;
CREATE TABLE mbta_zone AS
	SELECT st_union((SELECT st_transform(geom,2163) FROM gisdata_rtasmbtasec_polypolygon),
	(SELECT st_transform(geom,2163) FROM gisdata_rtasmbtahigh_polypolygon) ); 		
						   
--add perm transformed geometry
ALTER TABLE block_groups_2010
 ADD COLUMN geom_t geometry;
 UPDATE block_groups_2010
 SET geom_t =
  st_transform(geom, 2163) ;

						   --clip blocks_2010 to mbta service area
DROP TABLE IF EXISTS mbta_blocks;
CREATE TABLE mbta_blocks AS 
	SELECT * FROM block_groups_2010
	WHERE st_intersects(block_groups_2010.geom_t, (SELECT st_union FROM mbta_zone));					   
						  
--Select intersection of frequent buffer and dense areas NUMERATOR 
	SELECT SUM(poptotal) FROM mbta_blocks WHERE pop_den >=7000 AND 
						  ST_Intersects(geom_t, (SELECT st_union(freq_buffer) FROM freq_stops));
																  
--Select population of dense areas DENOMINATOR
SELECT SUM(poptotal) FROM mbta_blocks WHERE pop_den >=7000;	
																  
--coverage rate in Dense Areas
DROP TABLE IF EXISTS coverage;
	CREATE TABLE coverage(
	serv_type varchar(20),
	covered_pop float,
	total_pop float,
	coverage_pct float,
	covered_geom geometry,
	total_geom geometry);	

--base coverage values
INSERT INTO coverage
	(serv_type, covered_pop, total_pop, covered_geom, total_geom)
	VALUES('Base', (SELECT SUM(poptotal) FROM mbta_blocks WHERE
				   ST_intersects(geom_t, (SELECT st_union(buffer) FROM all_stops))), 
							(SELECT SUM(poptotal) FROM mbta_blocks WHERE aland10>0), (SELECT st_union(buffer) FROM all_stops),
							(SELECT st_union(geom_t) FROM mbta_blocks));
--frequent in dense coverage values															  
INSERT INTO coverage
	(serv_type, covered_pop, total_pop, covered_geom, total_geom)
	VALUES('Frequent_Dense', (SELECT SUM(poptotal) FROM mbta_blocks WHERE pop_den >= 7000 AND 
						  ST_Intersects(geom_t, (SELECT st_union(freq_buffer) FROM freq_stops))),
								(SELECT SUM(poptotal) FROM mbta_blocks WHERE pop_den >= 7000), (SELECT st_union(freq_buffer) FROM freq_stops),
																  (SELECT st_union(geom_t) FROM mbta_blocks WHERE pop_den >= 7000) );
										
--calculate coverage
	UPDATE coverage
	SET coverage_pct = (covered_pop)/(total_pop);
										
--plot maps
SELECT * FROM coverage;
							 
	