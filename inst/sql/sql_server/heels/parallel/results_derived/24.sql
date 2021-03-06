select 
  cast(null as int) as analysis_id,
  a.stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(1.0*a.born_cnt/b.died_cnt as FLOAT) as statistic_value,
  cast('Death:BornDeceasedRatio' as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from 
(select 
  stratum_1,
  count_value as born_cnt 
  from @resultsDatabaseSchema.achilles_results
  where analysis_id = 3) a 
inner join 
(select 
  stratum_1, 
  sum(count_value) as died_cnt 
  from @resultsDatabaseSchema.achilles_results
  where analysis_id = 504 group by stratum_1) b 
on a.stratum_1 = b.stratum_1
where b.died_cnt > 0;
