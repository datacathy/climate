-- using climate zones to grid stations

-- first load climate zones and create geometric objects
create table climates (gridid integer, poly varchar(10000), zone_numcode integer, zone_code varchar(5), climate varchar(25), precip varchar(25), temp varchar(25), poly_geom geometry);
\copy climates(gridid, poly, zone_numcode, zone_code, climate, precip, temp) from 'climate_zones.csv' csv header;
update climates set poly_geom = ST_GeomFromText(poly);

-- next, find zone containing stations
alter table stations add column climate_gridid integer;
update stations set climate_gridid = c.gridid from climates as c where ST_Contains(c.poly_geom, stations.point_geom);

-- have a look at result (391 are null)
select count(*) from stations where climate_gridid is null;

-- average temperatures over climate grid and export for graphing
-- the result is really pretty :)
create table yrly_climate_avgs (year integer, mean float8);
explain insert into yrly_climate_avgs (select tmp.year, avg(tmp.mean) from (select t.year as year, s.climate_gridid as box, avg(t.mean) as mean from tavg as t, stations as s where t.stnid = s.stnid group by t.year, s.climate_gridid) as tmp group by tmp.year);
\copy yrly_climate_avgs to 'yrly_climate_avgs.csv' csv header;

-- now see what happens if I use my variable baseline anomaly method too:
create table yrly_climate_anoms (year integer, anom float8);
insert into yrly_climate_anoms (select tmp.year, avg(tmp.anom) from (select t.year as year, s.climate_gridid as box, avg(t.anom) as anom from tavg_experiment as t, stations as s where t.stnid = s.stnid group by t.year, s.climate_gridid) as tmp group by tmp.year);
\copy yrly_climate_anoms to 'yrly_climate_anoms.csv' csv header;





