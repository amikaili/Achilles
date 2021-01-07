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

{cdmVersion == '5'}?{

	select
	  @analysisId as analysis_id,  
	  cast(null as varchar(255)) as stratum_1, 
	  cast(null as varchar(255)) as stratum_2, 
	  cast(null as varchar(255)) as stratum_3, 
	  cast(null as varchar(255)) as stratum_4, 
	  cast(null as varchar(255)) as stratum_5,
		COUNT_BIG(pc1.procedure_cost_ID) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@analysisId
	from @cdmDatabaseSchema.procedure_cost pc1
	left join @cdmDatabaseSchema.payer_plan_period ppp1 on pc1.payer_plan_period_id = ppp1.payer_plan_period_id
	where pc1.payer_plan_period_id is not null
		and ppp1.payer_plan_period_id is null
	;
}:{

	select 
	  @analysisId as analysis_id,  
	  cast(null as varchar(255)) as stratum_1, 
	  cast(null as varchar(255)) as stratum_2, 
	  cast(null as varchar(255)) as stratum_3, 
	  cast(null as varchar(255)) as stratum_4, 
	  cast(null as varchar(255)) as stratum_5,
		COUNT_BIG(pc1.cost_id) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@analysisId
	from @cdmDatabaseSchema.cost pc1
	left join @cdmDatabaseSchema.payer_plan_period ppp1 on pc1.payer_plan_period_id = ppp1.payer_plan_period_id
	where pc1.payer_plan_period_id is not null
		and ppp1.payer_plan_period_id is null
		and pc1.cost_domain_id = 'Procedure'
	;
}
