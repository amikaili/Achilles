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

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 
  @analysisId as analysis_id,   
	CAST(observation_concept_id as varchar(255)) as stratum_1,
	CAST(obs_cnt as varchar(255)) as stratum_2,
	cast(null as varchar(255)) as stratum_3,
	cast(null as varchar(255)) as stratum_4,
	cast(null as varchar(255)) as stratum_5,
	sum(count(person_id)) over (partition by observation_concept_id order by obs_cnt desc) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@analysisId
from 
(
  select
    o.observation_concept_id,
    count(o.observation_id) as obs_cnt,
    o.person_id
  from @cdmDatabaseSchema.observation o
  group by o.person_id, o.observation_concept_id
) cnt_q
group by cnt_q.observation_concept_id, cnt_q.obs_cnt
;
