-- okay, now I've determined they must be calculating the baseline on a per station basis
-- so let's do that too.

-- first, add column baseline to tavg that contains the baseline for that station
alter table tavg add column baseline float8;

-- then create tmp relation and fill it with the baselines for each station in tavg
-- note that this will ignore stations not appearing in 1961-1990
create table tmp (stnid float8, baseline float8, cnt integer);
insert into tmp (select stnid, avg(mean), count(*) from tavg where year >= 1961 and year <= 1990 group by stnid);

-- out of curiousity, I explored the number of stations the baseline is based on
-- mean: 20
select avg(cnt) from tmp;
-- std dev: 9
select stddev(cnt) from tmp;
-- min: 1
select min(cnt) from tmp;
-- max: 52
select max(cnt) from tmp;

-- also, how many stations will now contribute to the yearly averages?
-- count: 6719/7280 (but at least 2 are corrupt...)
select count(*) from tmp;

-- now transfer those baselines back to tavg
update tavg set baseline = tmp.baseline from tmp where tmp.stnid = tavg.stnid;

-- now icorporate baseline into column "anom"
-- note that after this anom has 9,206 null values (corresponding to null baselines)
-- so that's how many measurements we're ignoring by doing this anomaly business this way
alter table tavg add column anom float8;
update tavg set anom = mean - baseline;

-- now I'll redo the averaging (or random selection) over grid boxes using anom instead of mean

-- find yearly average temperatures by first averaging over the stations in each grid box
-- note: this seriously overweights stations in sparsely populated boxes
-- do they really think this is reasonable?
create table yrly_grid_anoms (year integer, anom float8);
explain insert into yrly_grid_anoms (select tmp.year, avg(tmp.anom) from (select t.year as year, s.gridid as box, avg(t.anom) as anom from tavg as t, stations as s where t.stnid = s.stnid group by t.year, s.gridid) as tmp group by tmp.year);

-- export yrly_grid_avgs so I can graph it in R
-- this is practically identical to their plot
\copy yrly_grid_anoms to 'yrly_grid_anoms.csv' csv header;

-- make the plot without the grid assumption (but with the anomaly assumption)
-- just need to calculate yearly avg anoms and output
create table yrly_anoms (year integer, anom float8);
insert into yrly_anoms (select year, avg(anom) from tavg group by year);
\copy yrly_anoms to 'yrly_anoms.csv' csv header;

-- now redo using different baseline periods
-- baselineA: 1901-2000
-- baselineB: 1991-2000
-- baselineC: 1981-2010
-- baselineD: 2001-2010

-- first let's create a new table to hold the baseline calculations so we don't impact the tavg
-- table too much
create table tavg_baselines (stnid float8, year integer, mean float8, baselineA float8, anomA float8, baselineB float8, anomB float8, baselineC float8, anomC float8, baselineD float8, anomD float8);
insert into tavg_baselines(stnid, year, mean) (select stnid, year, mean from tavg);

-- now redo the baseline calculations four times, once for 1901-2000 and once for 1991-2000
-- once for 1981-2010 and once for 2001-2010

-- 1901-2000
create table tmpA (stnid float8, baseline float8, cnt integer);
insert into tmpA (select stnid, avg(mean), count(*) from tavg_baselines where year >= 1901 and year <= 2000 group by stnid);
update tavg_baselines set baselineA = tmpA.baseline from tmpA where tmpA.stnid = tavg_baselines.stnid;

-- 1991-2000
create table tmpB (stnid float8, baseline float8, cnt integer);
insert into tmpB (select stnid, avg(mean), count(*) from tavg_baselines where year >= 1991 and year <= 2000 group by stnid);
update tavg_baselines set baselineB = tmpB.baseline from tmpB where tmpB.stnid = tavg_baselines.stnid;

-- 1981-2010
create table tmpC (stnid float8, baseline float8, cnt integer);
insert into tmpC (select stnid, avg(mean), count(*) from tavg_baselines where year >= 1981 and year <= 2010 group by stnid);
update tavg_baselines set baselineC = tmpC.baseline from tmpC where tmpC.stnid = tavg_baselines.stnid;

-- 2001-2010
create table tmpD (stnid float8, baseline float8, cnt integer);
insert into tmpD (select stnid, avg(mean), count(*) from tavg_baselines where year >= 2001 and year <= 2010 group by stnid);
update tavg_baselines set baselineD = tmpD.baseline from tmpD where tmpD.stnid = tavg_baselines.stnid;

-- use those baselines to compute the anom columns
update tavg_baselines set anomA = mean - baselineA;
update tavg_baselines set anomB = mean - baselineB;
update tavg_baselines set anomC = mean - baselineC;
update tavg_baselines set anomD = mean - baselineD;

-- use the anoms to compute the yearly averages
create table yrly_anom_baselines (year integer, anomA float8, anomB float8, anomC float8, anomD float8);
insert into yrly_anom_baselines (select year, avg(anomA), avg(anomB), avg(anomC), avg(anomD) from tavg_baselines group by year);

-- export yrly_anom_baselines for plotting
\copy yrly_anom_baselines to 'yrly_anom_baselines4.csv' csv header;

create table tavg_experiment (stnid float8, year integer, mean float8, baseline float8, anom float8);
insert into tavg_experiment(stnid, year, mean) (select stnid, year, mean from tavg);

create table tmpE (stnid float8, baseline float8);
insert into tmpE (select stnid, avg(mean) from tavg_experiment group by stnid);
update tavg_experiment set baseline = tmpE.baseline from tmpE where tmpE.stnid = tavg_experiment.stnid;

update tavg_experiment set anom = mean - baseline;

create table yrly_anom_experiment (year integer, anom float8);
insert into yrly_anom_experiment (select year, avg(anom) from tavg_experiment group by year);

\copy yrly_anom_experiment to 'yrly_anom_varying.csv' csv header;

