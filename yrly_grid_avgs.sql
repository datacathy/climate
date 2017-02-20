-- database: climate, created with command 'sudo -u postgres createdb --owner=cathyw climate'

-- load postGIS
CREATE EXTENSION postgis;

-- tavg: table containing the average temperature observations from 1901 through 2016
-- will have 328,182 rows
create table tavg (
       rownum		SERIAL PRIMARY KEY,
       stnid		FLOAT8,
       year		INTEGER,
       jan		FLOAT4,
       feb		FLOAT4,
       mar		FLOAT4,
       apr		FLOAT4,
       may		FLOAT4,
       jun		FLOAT4,
       jul		FLOAT4,
       aug		FLOAT4,
       sep		FLOAT4,
       oct		FLOAT4,
       nov		FLOAT4,
       dec		FLOAT4
);


-- stations: table containing the location information for the weather stations
-- will have 7,280 rows
create table stations (
       stnid 	      FLOAT8 PRIMARY KEY,
       lat	      FLOAT8,
       lng	      FLOAT8,
       stnelev	      FLOAT8,
       stnname	      VARCHAR(30),
       grelev	      integer,
       popcls	      CHAR(1),
       popsiz	      integer,
       topo	      CHAR(2),
       stveg	      char(2),
       stloc	      char(2),
       ocndis	      integer,
       airstn	      char(1),
       towndis	      integer,
       grveg	      varchar(20),
       popcss	      char(1),
       point_geom     geometry,
       gridid	      integer
);

-- grid: table containing the grid polygons for 5x5 boxes covering the earth
-- will have 2,592 rows
create table grid (
       gridid	  integer primary key,
       poly	  varchar(5000),
       poly_geom  geometry
);

-- load data
\copy tavg(stnid, year, jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec) from 'tavg_qca_final.csv' csv header;
\copy stations(stnid, lat, lng, stnelev, stnname, grelev, popcls, popsiz, topo, stveg, stloc, ocndis, airstn, towndis, grveg, popcss) from 'locations_final.csv' csv header;
\copy grid(gridid, poly) from '5x5grid.csv' csv header;

-- create geometries for stations (points) and grid boxes (polygons)
update stations set point_geom = ST_MakePoint(lng, lat);
update grid set poly_geom = ST_GeomFromText(poly);

-- now find containing grid box for each station
-- check query plan first, although I'm not expecting it to take too long since the relations are small
-- est 5e6 PIO worst case, cheap and easy, takes like 5 seconds
explain update stations as s set gridid = g.gridid from grid as g where ST_Contains(g.poly_geom, s.point_geom);

-- add column MEAN to tavg table and fill it with row-wise mean (so it is a yearly average temperature for that station)
alter table tavg add column mean float8;
update tavg set mean = (jan + feb + mar + apr + may + jun + jul + aug + sep + oct + nov + dec)/12;

-- verify R value I got is correct (12.13625)
select avg(mean) from tavg where year >= 1961 and year <= 1990;

-- now find yearly average temperatures by first averaging over the stations in each grid box
-- note: this seriously overweights stations in sparsely populated boxes
-- do they really think this is reasonable?
create table yrly_grid_avgs (year integer, mean float8);
explain insert into yrly_grid_avgs (select tmp.year, avg(tmp.mean) from (select t.year as year, s.gridid as box, avg(t.mean) as mean from tavg as t, stations as s where t.stnid = s.stnid group by t.year, s.gridid) as tmp group by tmp.year);

-- export yrly_grid_avgs so I can graph it in R
\copy yrly_grid_avgs to 'yrly_grid_avgs.csv' csv header;
