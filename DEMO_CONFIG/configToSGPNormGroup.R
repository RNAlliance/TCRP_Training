###################################################################################################
###
### Script to convert SGP configurations for EOCT analyses to SGP_NORM_GROUP preference tables
###
###################################################################################################

### Load packages

require("data.table")
options(error=recover)

setwd("DEMO_Trainign")

### utility function

configToSGPNormGroup <- function(sgp.config) {
	if ("sgp.norm.group.preference" %in% names(sgp.config)) {
		if ("sgp.exact.grade.progression" %in% names(sgp.config)) {
			tmp.norm.group.baseline <- tmp.norm.group <- paste(sgp.config$sgp.panel.years, paste(sgp.config$sgp.content.areas, 
				unlist(sgp.config$sgp.grade.sequences), sep="_"), sep="/")
			tmp.data.all <- data.table(
				SGP_NORM_GROUP=paste(tmp.norm.group, collapse="; "), 
				SGP_NORM_GROUP_BASELINE=paste(tmp.norm.group.baseline, collapse="; "),
				PREFERENCE=as.integer(sgp.config$sgp.norm.group.preference)
			)
		} else {
			tmp.data.all <- data.table()
			for (g in 1:length(sgp.config$sgp.grade.sequences)) {
				l <- length(sgp.config$sgp.grade.sequences[[g]])
				tmp.norm.group.baseline <- tmp.norm.group <- paste(tail(sgp.config$sgp.panel.years, l), 
					paste(tail(sgp.config$sgp.content.areas, l), unlist(sgp.config$sgp.grade.sequences[[g]]), sep="_"), sep="/") 
		        
		        tmp.data <- data.table(
					SGP_NORM_GROUP=paste(tmp.norm.group, collapse="; "), 
					SGP_NORM_GROUP_BASELINE=paste(tmp.norm.group.baseline, collapse="; "),
					PREFERENCE= sgp.config$sgp.norm.group.preference*100)
							
		        if (length(tmp.norm.group) > 2) {
			        for (n in 1:(length(tmp.norm.group)-2)) {
						tmp.data <- rbind(tmp.data, data.table(
							SGP_NORM_GROUP=paste(tail(tmp.norm.group, -n), collapse="; "), 
							SGP_NORM_GROUP_BASELINE=paste(tmp.norm.group.baseline, collapse="; "),
							PREFERENCE= (sgp.config$sgp.norm.group.preference*100)+n))
					}
				}
				tmp.data.all <- rbind(tmp.data.all, tmp.data)
			}
		}
		return(unique(tmp.data.all))
	} else {
		return(NULL)
	}
}


### Load and create 2010, 2011, and 2012_2013 EOCT Configuration

	source("DEMO_CONFIG/EOCT/2013/MATHEMATICS.R")
	source("DEMO_CONFIG/EOCT/2013/ELA.R")

DEMO_EOCT_2012_2013.config <- c(
		ALGEBRA_I_2012_2013.config,
		GRADE_9_LIT_2012_2013.config,
		ALGEBRA_II_2012_2013.config,
		AMERICAN_LIT_2012_2013.config
)		

### Create configToNormGroup data.frame

tmp.configToNormGroup <- lapply(DEMO_EOCT_2012_2013.config, configToSGPNormGroup)

DEMO_SGP_Norm_Group_Preference_2012_2013 <- data.table(
					YEAR="2012_2013",
					rbindlist(tmp.configToNormGroup))

DEMO_SGP_Norm_Group_Preference <- rbind(
			DEMO_SGP_Norm_Group_Preference_2012_2013
			)

DEMO_SGP_Norm_Group_Preference$SGP_NORM_GROUP <- as.factor(DEMO_SGP_Norm_Group_Preference$SGP_NORM_GROUP)
# DEMO_SGP_Norm_Group_Preference$SGP_NORM_GROUP_BASELINE <- as.factor(DEMO_SGP_Norm_Group_Preference$SGP_NORM_GROUP_BASELINE)

# DEMO_SGP_Norm_Group_Preference <- DEMO_SGP_Norm_Group_Preference[!duplicated(DEMO_SGP_Norm_Group_Preference)]

### Save result

setkey(DEMO_SGP_Norm_Group_Preference, YEAR, SGP_NORM_GROUP)
save(DEMO_SGP_Norm_Group_Preference, file="DEMO_CONFIG/DEMO_SGP_Norm_Group_Preference.Rdata")
