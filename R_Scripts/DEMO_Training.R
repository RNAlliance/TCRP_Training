##########################################################
####
####	Code for analysis of CMO data 
####		- June 2013
####
##########################################################

	### Load the required R packages and set the working directory

	setwd("TCRP_Training")

	require(SGP)
	require(data.table)

	###   Load the required data objects (coefficient matrices and 'Norm Preference' objects)

	load("Coefficient_Matrices/DEMO_Cohort_Matrices.Rdata")
	load("Coefficient_Matrices/DEMO_Baseline_Matrices.Rdata")

	load('DEMO_CONFIG/DEMO_SGP_Norm_Group_Preference.Rdata')

	###  Read in the raw longitudinal data text files (student test data and teacher-student links).
	###  The teacher linking data is optional for producing SGPs.  It is used in producing summary tables.
	MY_DEMO_Data_LONG <- sgpData_LONG[sgpData_LONG$DISTRICT_NAME == 'Lakeside School District',]
	MY_TEACHER_STUDENT_LINKS <- sgpData_INSTRUCTOR_NUMBER
	
	MY_DEMO_Data_LONG$CONTENT_AREA[MY_DEMO_Data_LONG$CONTENT_AREA == 'MATHEMATICS' & MY_DEMO_Data_LONG$GRADE == '9'] <- 'ALGEBRA_I'
	MY_DEMO_Data_LONG$CONTENT_AREA[MY_DEMO_Data_LONG$CONTENT_AREA == 'MATHEMATICS' & MY_DEMO_Data_LONG$GRADE == '10'] <- 'ALGEBRA_II'
	
	MY_DEMO_Data_LONG$CONTENT_AREA[MY_DEMO_Data_LONG$CONTENT_AREA == 'READING' & MY_DEMO_Data_LONG$GRADE == '9'] <- 'GRADE_9_LIT'
	MY_DEMO_Data_LONG$CONTENT_AREA[MY_DEMO_Data_LONG$CONTENT_AREA == 'READING' & MY_DEMO_Data_LONG$GRADE == '10'] <- 'AMERICAN_LIT'
	
	###  In the past several months we have changed how we deal with 'end of course tests' (EOCTs).
	###  Grade levels for student records associated with these courses now need to be set to 'EOCT'.
	###  However, we want to retain the original reported grade information for summarization, 
	###  so first we create a new variable named GRADE_REPORTED before changing GRADE.
	
	MY_DEMO_Data_LONG$GRADE_REPORTED <- MY_DEMO_Data_LONG$GRADE

	#  Change all values of GRADE to 'EOCT' for all subject specific test records.
	MY_DEMO_Data_LONG$GRADE[MY_DEMO_Data_LONG$CONTENT_AREA %in% c('ALGEBRA_I', 'ALGEBRA_II', 'GRADE_9_LIT', 'AMERICAN_LIT')] <-  'EOCT'

	#  Inspect the cross tab of grades and content area
	table(MY_DEMO_Data_LONG$CONTENT_AREA, MY_DEMO_Data_LONG$GRADE)
	
############################################################
####
####		prepareSGP
####
############################################################

	MY_DEMO_SGP <- prepareSGP(MY_DEMO_Data_LONG, state='DEMO',  
		data_supplementary = list(INSTRUCTOR_NUMBER = MY_TEACHER_STUDENT_LINKS))
	
############################################################
####
####		analyzeSGP
####
############################################################

	###  Add the previously calculated TCRP Coefficient Matrices for 2010 - 2012 to the SGP object.  
	###  We need these to use the argument 'sgp.use.my.coefficient.matrices=TRUE'
	
	MY_DEMO_SGP@SGP[["Coefficient_Matrices"]] <- DEMO_Cohort_Matrices
	SGPstateData[["DEMO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_Baseline_Matrices

	MY_DEMO_SGP <- analyzeSGP(MY_DEMO_SGP, state='DEMO',
                             content_areas=c("READING", "MATHEMATICS"),
                             years='2012_2013',
                             grades = 3:8,
                             sgp.percentiles = TRUE,
                             sgp.projections = FALSE, # Set to FALSE only for this training
                             sgp.projections.lagged = TRUE,
                             sgp.percentiles.baseline = TRUE,
                             sgp.projections.baseline = FALSE,
                             sgp.projections.lagged.baseline = FALSE,
                             simulate.sgps = FALSE,
                             sgp.use.my.coefficient.matrices=TRUE)

###
###			Heterogeneous Grade-level and Middle School EOCT progression analyses
###
###  Science and History courses use grade-level Math and Reading respectively as priors.  
###  Because of this heterogeneous CONTENT_AREA progression, we must explicitly specify the sgp.config.
###  In the section above (homogeneous course progressions), the analyzeSGP function can produce these 
###  lists of analyses internally.  Along with these two subjects, many middle school students take
###  Algebra I or General Math as well.
###  rather than separating 10th and 11th graders from 9th and 10th graders with that same course sequence)

	### Load ALL 2012 analysis configuration lists and create the Grade Level specific sgp.config
	
	source("DEMO_CONFIG/EOCT/2013/MATHEMATICS.R")
	source("DEMO_CONFIG/EOCT/2013/ELA.R")

	DEMO_Grade_Level.config <- c(
		ALGEBRA_I_2012_2013.config,
		GRADE_9_LIT_2012_2013.config
	)

	MY_DEMO_SGP <- analyzeSGP(MY_DEMO_SGP, state='DEMO',
                             sgp.config = DEMO_Grade_Level.config,
                             sgp.percentiles = TRUE,
                             sgp.projections = FALSE,
                             sgp.projections.lagged = FALSE,
                             sgp.percentiles.baseline = FALSE, # No baseline heterogeneous progression SGPs in the DEMO
                             sgp.projections.baseline = FALSE,
                             sgp.projections.lagged.baseline = FALSE,
                             simulate.sgps = FALSE,
                             sgp.use.my.coefficient.matrices = TRUE)

###
###			High school EOCT progressions
###
###  Rather than use GRADE as a source of the progression we now set all values of the GRADE variable to 'EOCT'.  This will focus the 
###  analysis on the CONTENT_AREA progression rather than the GRADE progression.  Thus, we are comparing ALL students that had
###  the same course progression (e.g. ALL students that took Geometry (2011 prior) and then Chemistry (2012 current), 
###  rather than separating 10th and 11th graders from 9th and 10th graders with that same course sequence into two seperate analyses)

	##  Change all GRADE values of the READING and Math priors to 'EOCT'
	
	MY_DEMO_SGP@Data[CONTENT_AREA %in% c('READING', 'MATHEMATICS'), GRADE := 'EOCT']

	##  Combine all the year and subject level configurations into a single list for the sgp.config argument

	DEMO_EOCT.config <- c(
		ALGEBRA_II_2012_2013.config,
		AMERICAN_LIT_2012_2013.config
	)
	
	###  Fake meta-data (EOCT Knots and Bounds) must be added to the SGPstateData for this DEMO since we've changed data values.
	SGPstateData[["DEMO"]][["Achievement"]][["Knots_Boundaries"]][["MATHEMATICS"]][["knots_EOCT"]] <- c(500, 545, 580, 620)
	SGPstateData[["DEMO"]][["Achievement"]][["Knots_Boundaries"]][["MATHEMATICS"]][["boundaries_EOCT"]] <- c(310, 890)

	SGPstateData[["DEMO"]][["Achievement"]][["Knots_Boundaries"]][["ALGEBRA_I"]] <- list(
		boundaries_EOCT=c(340, 920),
		knots_EOCT=c(515, 560, 595, 630))


	SGPstateData[["DEMO"]][["Achievement"]][["Knots_Boundaries"]][["READING"]][["knots_EOCT"]] <- c(605, 642, 670, 702)
	SGPstateData[["DEMO"]][["Achievement"]][["Knots_Boundaries"]][["READING"]][["boundaries_EOCT"]] <- c(330, 990)
	
	SGPstateData[["DEMO"]][["Achievement"]][["Knots_Boundaries"]][["GRADE_9_LIT"]] <- list(
		boundaries_EOCT=c(350, 995),
		knots_EOCT=c(620, 655, 680, 706))

	
	MY_DEMO_SGP <- analyzeSGP(MY_DEMO_SGP, state='DEMO',
                             sgp.config = DEMO_EOCT.config,
                             sgp.percentiles = TRUE,
                             sgp.projections = FALSE,
                             sgp.projections.lagged = FALSE,
                             sgp.percentiles.baseline = FALSE, # No baseline heterogeneous progression SGPs in the DEMO
                             sgp.projections.baseline = FALSE,
                             sgp.projections.lagged.baseline = FALSE,
                             simulate.sgps = FALSE,
                             sgp.use.my.coefficient.matrices = TRUE)
                           		                          		
	###  For reporting/summarization purposes, we will return the GRADE variable to its original form:
	
	MY_DEMO_SGP@Data[, GRADE := GRADE_REPORTED]
	MY_DEMO_SGP@Data[, GRADE_REPORTED := NULL]
	
	table(MY_DEMO_SGP@Data$CONTENT_AREA, MY_DEMO_SGP@Data$GRADE)

#########################################################
####
####	combineSGP
####
#########################################################

	SGPstateData[["DEMO"]][["SGP_Norm_Group_Preference"]] <- DEMO_SGP_Norm_Group_Preference

	MY_DEMO_SGP <- combineSGP(MY_DEMO_SGP, state='DEMO')

	#  Check the LONG @Data file now:
	sgp.names <- names(MY_DEMO_SGP@SGP[["SGPercentiles"]])
	tot<-0
	for(i in match(sgp.names[-grep('BASELINE', sgp.names)], sgp.names)) {
		print(paste(sgp.names[i], "N =", dim(MY_DEMO_SGP@SGP[['SGPercentiles']][[i]])[1], " :  Median SGP,", median(MY_DEMO_SGP@SGP[['SGPercentiles']][[i]][["SGP"]])))
		tot <- tot+(dim(MY_DEMO_SGP@SGP[['SGPercentiles']][[i]])[1])
	}
	tot 
	
	sum(!is.na(MY_DEMO_SGP@Data$SGP)) #  This number should be smaller than the total SGPs produced (tot) - duplicates have been removed.
	
	save(MY_DEMO_SGP, file="Data/MY_DEMO_SGP.Rdata")

#########################################################
####
####	summarizeSGP
####
#########################################################

	###  Identify the Content areas that have SGPs (some CST tests did not have enough kids/progresions to analyze)
	
	MY_DEMO_SGP <- summarizeSGP(MY_DEMO_SGP, state='DEMO',
			content_areas = c('READING', 'MATHEMATICS'),
			years='2012_2013',
			parallel.config=list(BACKEND="PARALLEL", WORKERS=6))
	
	save(MY_DEMO_SGP, file="Data/MY_DEMO_SGP.Rdata")
	


##############################################################################################################
####
####		Other Advanced Topics:  Restricting the Number of Priors Used to Calculate SGPs
####
##############################################################################################################

	####	Pass arguments to studentGrowthPercentiles through ... argument in analyzeSGP

	TEST_SGP <- prepareSGP(MY_DEMO_Data_LONG, state='DEMO', create.additional.variables = FALSE,
		data_supplementary = list(INSTRUCTOR_NUMBER = MY_TEACHER_STUDENT_LINKS))

	###  Add the previously calculated TCRP Coefficient Matrices for 2010 - 2012 to the SGP object.  
	###  We need these to use the argument 'sgp.use.my.coefficient.matrices=TRUE'
	
	TEST_SGP@SGP$Coefficient_Matrices <- DEMO_Cohort_Matrices
	
	SGPstateData[["DEMO"]][["DEMO_CONFIGuration"]] <- list(max.order.for.percentile=1)

	TEST_SGP <- analyzeSGP(TEST_SGP, state='DEMO',
                           content_areas=c("READING", "MATHEMATICS"),
                           grades = 3:8,
                           years='2012_2013',
                           sgp.projections = FALSE,
                           sgp.projections.lagged = FALSE,
                           sgp.percentiles.baseline = FALSE,
                           sgp.projections.baseline = FALSE,
                           sgp.projections.lagged.baseline = FALSE,
                           simulate.sgps = FALSE,
                           sgp.use.my.coefficient.matrices = TRUE)

##  Verify that all Norm Groups have only ONE prior

table(TEST_SGP@SGP$SGPercentiles$MATHEMATICS.2012$SGP_NORM_GROUP)

TEST_SGP <- combineSGP(TEST_SGP, state='DEMO')

setnames(TEST_SGP@Data, c('SGP', 'SGP_NORM_GROUP'), c('SGP_1_PRIOR', 'SGP_NORM_GROUP_1_PRIOR'))

###
	TEST_SGP@SGP$SGPercentiles_1_Prior <- TEST_SGP@SGP$SGPercentiles
	TEST_SGP@SGP$SGPercentiles <- NULL

	SGPstateData[["DEMO"]][["DEMO_CONFIGuration"]] <- list(max.order.for.percentile=2)

	TEST_SGP <- analyzeSGP(TEST_SGP, state='DEMO',
                           content_areas=c("READING", "MATHEMATICS"),
                           grades = 3:8,
                           years='2012_2013',
                           sgp.projections = FALSE,
                           sgp.projections.lagged = FALSE,
                           sgp.percentiles.baseline = FALSE,
                           sgp.projections.baseline = FALSE,
                           sgp.projections.lagged.baseline = FALSE,
                           simulate.sgps = FALSE,
                           sgp.use.my.coefficient.matrices = TRUE)

##  Verify that all Norm Groups have one OR two priors

table(TEST_SGP@SGP$SGPercentiles$MATHEMATICS.2012$SGP_NORM_GROUP)

TEST_SGP <- combineSGP(TEST_SGP, state='DEMO')

setnames(TEST_SGP@Data, c('SGP', 'SGP_NORM_GROUP'), c('SGP_2_PRIOR', 'SGP_NORM_GROUP_2_PRIOR'))

###
	TEST_SGP@SGP$SGPercentiles_2_Prior <- TEST_SGP@SGP$SGPercentiles
	TEST_SGP@SGP$SGPercentiles <- NULL

	SGPstateData[["DEMO"]][["DEMO_CONFIGuration"]] <- list(max.order.for.percentile=3)

	TEST_SGP <- analyzeSGP(TEST_SGP, state='DEMO',
                           content_areas=c("READING", "MATHEMATICS"),
                           grades = 3:8,
                           years='2012_2013',
                           sgp.projections = FALSE,
                           sgp.projections.lagged = FALSE,
                           sgp.percentiles.baseline = FALSE,
                           sgp.projections.baseline = FALSE,
                           sgp.projections.lagged.baseline = FALSE,
                           simulate.sgps = FALSE,
                           sgp.use.my.coefficient.matrices = TRUE)

TEST_SGP <- combineSGP(TEST_SGP, state='DEMO')

setnames(TEST_SGP@Data, c('SGP', 'SGP_NORM_GROUP'), c('SGP_3_PRIOR', 'SGP_NORM_GROUP_3_PRIOR'))

###
###		There is now a dataset with 3 different versions of the student SGPs using 1, 2 and 3 priors
###		There are any number of comparisons one can make about the differences in both student SGPs
###		and teacher or school aggregations (Median SGPs).
###		I'll leave those to your imagination, but here are a few descriptives for the student level:

diffs <- TEST_SGP@Data$SGP_1_PRIOR - TEST_SGP@Data$SGP_2_PRIOR
summary(diffs)
hist(TEST_SGP@Data$SGP_1_PRIOR - TEST_SGP@Data$SGP_2_PRIOR, breaks=50, col='grey')

diffs_2 <- TEST_SGP@Data[as.character(SGP_NORM_GROUP_1_PRIOR) != as.character(SGP_NORM_GROUP_2_PRIOR)]$SGP_1_PRIOR - TEST_SGP@Data[as.character(SGP_NORM_GROUP_1_PRIOR) != as.character(SGP_NORM_GROUP_2_PRIOR)]$SGP_2_PRIOR
summary(diffs_2)
hist(diffs_2, breaks=50, col='grey')
sd(diffs_2)

diffs_3 <- TEST_SGP@Data[as.character(SGP_NORM_GROUP_2_PRIOR) != as.character(SGP_NORM_GROUP_3_PRIOR)]$SGP_2_PRIOR - TEST_SGP@Data[as.character(SGP_NORM_GROUP_2_PRIOR) != as.character(SGP_NORM_GROUP_3_PRIOR)]$SGP_3_PRIOR
summary(diffs_3)
hist(diffs_3, breaks=50, col='grey')
sd(diffs_3)
