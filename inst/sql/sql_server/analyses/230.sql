-- 230	Number and proportion of look back days by visit_concept_id.
-- NB: Look back days (stratum_3) are limited to the Atlas defaults: 0,1,7,14,21,30,60,90,120,180,365,548,730,1095.
--     Proportion (stratum_2) represents the proportion of people with a given visit that have at least
--     N days of look back.

--HINT DISTRIBUTE_ON_KEY(stratum_1)
  with vo as (
-- Find earliest occurrence of each concept_id, person_id pair  
select visit_concept_id, person_id, min(visit_start_date) visit_start_date
  from @cdmDatabaseSchema.visit_occurrence
 group by visit_concept_id,person_id
), lookback as (
-- Count the concept_id, look back day pairs 
select vo.visit_concept_id,
       datediff(d,op.observation_period_start_date,vo.visit_start_date) as lookback_days,
       count_big(*) as count_value
  from @cdmDatabaseSchema.observation_period op join vo
    on vo.person_id = op.person_id
 where op.observation_period_start_date <= vo.visit_start_date
 group by vo.visit_concept_id, datediff(d,op.observation_period_start_date,vo.visit_start_date)
), lookback_prop as (
-- Compute the proportion of people with N days of look back per concept_id
select *,
       1.0*sum(count_value)over(
	            partition by visit_concept_id 
				    order by lookback_days 
	                 rows between current row and unbounded following)/sum(count_value)over() as proportion       
  from lookback
)
-- To avoid flooding Achilles, limit look back days to the Atlas defaults
select 230 as analysis_id,
       cast(visit_concept_id       as varchar(255)) as stratum_1,
       cast(proportion             as varchar(255)) as stratum_2,
       cast(lookback_days          as varchar(255)) as stratum_3,
       cast(null                   as varchar(255)) as stratum_4,
       cast(null                   as varchar(255)) as stratum_5,
       count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_230
  from lookback_prop 
 where lookback_days in (0,1,7,14,21,30,60,90,120,180,365,548,730,1095); 
   