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
	CAST(procedure_concept_id as varchar(255)) as stratum_1,
	CAST(prc_cnt as varchar(255)) as stratum_2,
	cast(null as varchar(255)) as stratum_3,
	cast(null as varchar(255)) as stratum_4,
	cast(null as varchar(255)) as stratum_5,
	sum(count(person_id)) over (partition by procedure_concept_id order by prc_cnt desc) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@analysisId
from 
(
  select
    p.procedure_concept_id,
    count(p.procedure_occurrence_id) as prc_cnt,
    p.person_id
  from @cdmDatabaseSchema.procedure_occurrence p
  group by p.person_id, p.procedure_concept_id
) cnt_q
group by cnt_q.procedure_concept_id, cnt_q.prc_cnt
;
