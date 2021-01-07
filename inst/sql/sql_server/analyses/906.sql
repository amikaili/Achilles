/*********
Achilles Analysis #@analysisId:
- Analysis Name = @analysisName

Parameters used in this template:
- cdmDatabaseSchema = @cdmDatabaseSchema
- scratchDatabaseSchema = @scratchDatabaseSchema
- oracleTempSchema = @oracleTempSchema
- schemaDelim = @schemaDelim
- tempAchillesPrefix = @tempAchillesPrefix
**********/

--HINT DISTRIBUTE_ON_KEY(subject_id)
select 
  de.drug_concept_id as subject_id,
  p1.gender_concept_id,
  de.drug_start_year - p1.year_of_birth as count_value
INTO #rawData_@analysisId
from @cdmDatabaseSchema.person p1
join
(
	select 
	  person_id, 
	  drug_concept_id, 
	  min(year(drug_era_start_date)) as drug_start_year
	from @cdmDatabaseSchema.drug_era
	group by person_id, drug_concept_id
) de on p1.person_id =de.person_id
;

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
with overallStats 
as
(
  select 
    subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_@analysisId
	group by subject_id, gender_concept_id
),
statsView 
as
(
  select 
    subject_id as stratum1_id, 
    gender_concept_id as stratum2_id, 
    count_value, count_big(*) as total, 
    row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_@analysisId
  group by subject_id, gender_concept_id, count_value
),
priorStats
as
(
  select 
    s.stratum1_id, 
    s.stratum2_id, 
    s.count_value, 
    s.total, 
    sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id 
    and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 
  @analysisId as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults_@analysisId
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id 
  and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 
  analysis_id, 
  stratum1_id as stratum_1, 
  stratum2_id as stratum_2, 
  cast(null as varchar(255)) as stratum_3, 
  cast(null as varchar(255)) as stratum_4, 
  cast(null as varchar(255)) as stratum_5,
  count_value, 
  min_value, 
  max_value, 
  avg_value, 
  stdev_value, 
  median_value, 
  p10_value, 
  p25_value, 
  p75_value, 
  p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_@analysisId
from #tempResults_@analysisId
;


truncate table #rawData_@analysisId;
drop table #rawData_@analysisId;

truncate table #tempResults_@analysisId;
drop table #tempResults_@analysisId;
