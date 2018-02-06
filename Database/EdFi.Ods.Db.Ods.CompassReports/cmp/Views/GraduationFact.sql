CREATE VIEW [cmp].[GraduationFact] AS

WITH DATES AS
(
SELECT SchoolId
	 , SchoolYear
	 , MIN(BeginDate) AS BeginDate
	 , MAX(EndDate) AS EndDate
FROM edfi.Session 
GROUP BY  SchoolId, SchoolYear
)

, StudentEnrollment AS /* STUDENTS WHO ARE CURRENTLY ENROLLED AND ARE IN GRADE 12 */
(
SELECT StudentUSI
      ,SE.SchoolId
	  ,FreeReducedLunchStatus
	  ,EnglishLanguageLearnerStatus
	  ,SE.SchoolYear
      ,GradeLevel
	  ,Ethnicity
	  ,ExpectedGraduationYear 
	  ,SpecialEducationStatus
FROM cmp.StudentEnrollment() SE
JOIN DATES DS
	ON DS.SchoolId = SE.SchoolId
	AND SE.SchoolYear = DS.SchoolYear
WHERE GradeLevel = 'Grade 12'


UNION

/* STUDENTS WHO WERE PREVIOUSLY ENROLLED AND AND ARE NOLONGER IN SCHOOL */
SELECT StudentUSI
      ,PSE.SchoolId
	  ,FreeReducedLunchStatus
	  ,EnglishLanguageLearnerStatus
	  ,PSE.SchoolYear
      ,GradeLevel
	  ,Ethnicity
	  ,ExpectedGraduationYear 
	  ,SpecialEducationStatus
FROM cmp.PriorStudentEnrollment() PSE
JOIN DATES DS
	ON DS.SchoolId = PSE.SchoolId
WHERE ExpectedGraduationYear = DS.SchoolYear-1 /* NEED TO ADD FILTER FROM EXTENSION EXPECTEDGRADYEAR = SCHOOLYEAR -1 */
)


,STUDENTGRADSTATUS AS /* GRADUATION STATUS OF CURRENT STUDENTS WHO COMPLETED SCHOOL IN FOUR YEAR COHORT (ONTIME GRADS) */
(
SELECT SCA.[StudentUSI]
      ,SCA.[EducationOrganizationId] AS SchoolId
      ,[CohortIdentifier]
      ,SCA.[BeginDate]
      ,SCA.[EndDate]
	  ,SSA.[GraduationSchoolYear]
	  ,CASE WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12' 
	   END AS GradeLevel
	  ,CASE WHEN EWT.Description IS NULL THEN 'PossibleGraduate'
			WHEN EWT.Description = 'End of school year' THEN 'Students Still in School'
			WHEN EWT.Description = 'Completed' THEN 'Course Completion'
			ELSE 'Dropouts'
		END AS GraduationStatus
	  ,'Not Applicable' AS [DiplomaType]
	  ,'Not Applicable' AS [GraduationWaiver]
FROM [edfi].[StudentCohortAssociation] SCA
JOIN DATES DS
	ON DS.SchoolId = SCA.[EducationOrganizationId]
	AND SCA.[BeginDate] <= DS.[EndDate]
	AND SCA.[EndDate] >= DS.[EndDate]
JOIN [edfi].[StudentSchoolAssociation] SSA
	ON SSA.[StudentUSI] = SCA.[StudentUSI]
	AND SSA.SchoolId = SCA.[EducationOrganizationId]
JOIN DATES CD
	ON CD.SchoolId = SSA.SchoolId
	AND CD.SchoolYear = SSA.[GraduationSchoolYear]
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SSA.[EntryGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLD.[GradeLevelTypeId] = GLT.[GradeLevelTypeId]
	AND GLT.Description = 'Twelfth grade'
LEFT JOIN [edfi].[ExitWithdrawTypeDescriptor] EWD
	ON EWD.[ExitWithdrawTypeDescriptorId] = SSA.[ExitWithdrawTypeDescriptorId]
LEFT JOIN [edfi].[ExitWithdrawType] EWT
	ON EWT.[ExitWithdrawTypeId] = EWD.[ExitWithdrawTypeId]
)

,CURRENTSTUDENTGRADSTATUS AS /* GRADUATION STATUS OF CURRENT STUDENTS WHO COMPLETED SCHOOL IN FOUR YEAR COHORT (ONTIME GRADS) */
(
SELECT  SGS.StudentUSI,
		SGS.SchoolId,
		CASE WHEN DT.Description = 'Regular diploma' AND DiplomaDescription IN ('Honors', 'Core 40', 'General') THEN 'Non-Waiver'
			 ELSE GraduationWaiver
		END AS GraduationWaiver,
		GraduationSchoolYear,
		GradeLevel,
		CASE WHEN DT.Description IN ('High school equivalency credential, other than GED', 'General Educational Development (GED) credential') THEN 'HSE'
			 WHEN DT.Description = 'Certificate of completion' AND DiplomaDescription = 'Special Education Certificate' THEN 'Special Education Certificate'
			 WHEN DT.Description = 'Regular diploma' AND DiplomaDescription IN ('Honors', 'Core 40', 'General') THEN 'Graduates'
			 ELSE GraduationStatus
		END AS GraduationStatus,
		CASE WHEN DiplomaDescription = 'Core 40' THEN 'Core 40'
			 WHEN DiplomaDescription = 'Honors' THEN 'Honors'
			 WHEN DiplomaDescription = 'General' THEN 'General'
			 ELSE DiplomaType
		END AS DiplomaType
FROM STUDENTGRADSTATUS SGS
LEFT JOIN [edfi].[StudentAcademicRecordDiploma] SAR
	ON SAR.[StudentUSI] = SGS.[StudentUSI]
	AND SAR.[EducationOrganizationId] = SGS.[SchoolId]
	AND SAR.[SchoolYear] = SGS.[GraduationSchoolYear]
LEFT JOIN [edfi].[DiplomaType] DT
	ON DT.[DiplomaTypeId] = SAR.[DiplomaTypeId]

UNION 

/* GRADUATION STATUS OF STUDENTS WHO GRADUATED EARLY FROM COHORT SHOULD EXCLUDE STUDENTS WHO ARE NOT APART OF CURRENT FOUR YEAR COHORT*/
SELECT  SAR.StudentUSI,
		SAR.[EducationOrganizationId] AS SchoolId,
		CASE WHEN DT.Description = 'Regular diploma' AND DiplomaDescription IN ('Honors', 'Core 40', 'General') THEN 'Non-Waiver'
			 ELSE 'Not Applicable' /* NEED TO UPDATE THIS CLAUSE WHEN EXTENSION IS ADDED FOR WAIVER */
		END AS GraduationWaiver,
		[SchoolYear] AS GraduationSchoolYear,
		'Grade 12' AS GradeLevel,
		CASE WHEN DT.Description = 'Regular diploma' AND DiplomaDescription IN ('Honors', 'Core 40', 'General') THEN 'Early Graduates'
		END AS GraduationStatus,
		CASE WHEN DiplomaDescription = 'Core 40' THEN 'Core 40'
			 WHEN DiplomaDescription = 'Honors' THEN 'Honors'
			 WHEN DiplomaDescription = 'General' THEN 'General'
		END AS DiplomaType
FROM [edfi].[StudentAcademicRecordDiploma] SAR
LEFT JOIN [edfi].[DiplomaType] DT
	ON DT.[DiplomaTypeId] = SAR.[DiplomaTypeId]
JOIN [edfi].[StudentCohortAssociation] SCA
	ON SCA.StudentUSI = SAR.StudentUSI
	AND SCA.[EducationOrganizationId] = SAR.[EducationOrganizationId]
	AND SAR.[SchoolYear] = YEAR([EndDate])
	AND SAR.[DiplomaAwardDate]>= SCA.[EndDate]
WHERE SAR.[StudentUSI] NOT IN (SELECT [StudentUSI] FROM [edfi].[StudentSchoolAssociation])
/* WHERE (EXTENSION)ACTUALGRADUATIONYEAR = EXPECTEDGRADUATIONYEAR -1 OR EXPECTEDGRADUATIONYEAR -2 */
)

,STUDENTDEMOGRAPHICS AS
(
SELECT SSA.StudentUSI,
	   SSA.SchoolId,
	   SSA.GraduationWaiver,
	   SSA.GraduationSchoolYear AS SchoolYear,
	   SSA.GradeLevel,
	   CASE WHEN GraduationStatus = 'PossibleGraduate' THEN 'Students Still in School' 
			WHEN GraduationStatus = 'Early Graduates' THEN 'Graduates'
			ELSE GraduationStatus 
	   END AS GraduationStatus,
	   SSA.DiplomaType,
	   S.FreeReducedLunchStatus,
	   S.EnglishLanguageLearnerStatus,
	   S.Ethnicity,
	   S.ExpectedGraduationYear,
	   S.SpecialEducationStatus
FROM CURRENTSTUDENTGRADSTATUS SSA
LEFT JOIN StudentEnrollment S
	ON S.[StudentUSI] = SSA.[StudentUSI]
)

SELECT DJ.DemographicId,
	  GS.GraduationStatusKey,
	  SD.SchoolId,
	  SD.SchoolYear,
	  COUNT(DISTINCT SD.StudentUSI) AS [GraduationStudentCount]
FROM STUDENTDEMOGRAPHICS SD
JOIN cmp.DemographicDim() DJ
	ON DJ.GradeLevel = SD.GradeLevel
	AND DJ.Ethnicity = SD.Ethnicity
	AND DJ.FreeReducedLunchStatus = SD.FreeReducedLunchStatus
	AND DJ.SpecialEducationStatus = SD.SpecialEducationStatus
	AND DJ.EnglishLanguageLearnerStatus = SD.EnglishLanguageLearnerStatus
	AND DJ.ExpectedGraduationYear = SD.ExpectedGraduationYear
JOIN cmp.GraduationStatusDim() GS 
	ON GS.GraduationStatus = SD.GraduationStatus
	AND GS.DiplomaType = SD.DiplomaType
	AND GS.GraduationWaiver = SD.GraduationWaiver
GROUP BY  DJ.DemographicId,
	  GS.GraduationStatusKey,
	  SD.SchoolId,
	  SD.SchoolYear
