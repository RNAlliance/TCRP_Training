#####################################################################################
###
### 	Scripts associated with 2013 EOCT ELA: GRADE_9_LIT, AMERICAN_LIT
###
#####################################################################################


GRADE_9_LIT_2012_2013.config <- list(
	 GRADE_9_LIT.2012_2013 = list(
		sgp.content.areas=c('READING', 'GRADE_9_LIT'),
		sgp.panel.years=c('2011_2012', '2012_2013'),
		sgp.grade.sequences=list(c(8, 'EOCT')),
		sgp.exact.grade.progression=TRUE,
		sgp.norm.group.preference=3),
	 GRADE_9_LIT.2012_2013 = list(
		sgp.content.areas=c('READING', 'READING', 'GRADE_9_LIT'),
		sgp.panel.years=c('2010_2011', '2011_2012', '2012_2013'),
		sgp.grade.sequences=list(c(7:8, 'EOCT')),
		sgp.exact.grade.progression=TRUE,
		sgp.norm.group.preference=2),
	 GRADE_9_LIT.2012_2013 = list(
		sgp.content.areas=c('READING', 'READING', 'READING', 'GRADE_9_LIT'),
		sgp.panel.years=c('2009_2010', '2010_2011', '2011_2012', '2012_2013'),
		sgp.grade.sequences=list(c(6:8, 'EOCT')),
		sgp.exact.grade.progression=TRUE,
		sgp.norm.group.preference=1)
)

AMERICAN_LIT_2012_2013.config <- list(
	AMERICAN_LIT.2012_2013 = list(
		sgp.content.areas=c('GRADE_9_LIT', 'AMERICAN_LIT'),
		sgp.panel.years=c('2011_2012', '2012_2013'),
		sgp.grade.sequences=list(c('EOCT', 'EOCT')),
		sgp.exact.grade.progression=TRUE,
		sgp.norm.group.preference=2),
	AMERICAN_LIT.2012_2013 = list(
		sgp.content.areas=c('READING', 'GRADE_9_LIT', 'AMERICAN_LIT'),
		sgp.panel.years=c('2010_2011', '2011_2012', '2012_2013'),
		sgp.grade.sequences=list(c('EOCT', 'EOCT', 'EOCT')),
		sgp.exact.grade.progression=TRUE,
		sgp.norm.group.preference=1)
)
