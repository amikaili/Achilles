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

select 
  @analysisId as analysis_id, 
	cast(null as varchar(255)) as stratum_1, 
	cast(null as varchar(255)) as stratum_2, 
	cast(null as varchar(255)) as stratum_3, 
	cast(null as varchar(255)) as stratum_4, 
	cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(d1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@analysisId
from @cdmDatabaseSchema.death d1
left join @cdmDatabaseSchema.observation_period op1 on d1.person_id = op1.person_id
  and d1.death_date >= op1.observation_period_start_date
	and d1.death_date <= op1.observation_period_end_date
where op1.person_id is null
;
