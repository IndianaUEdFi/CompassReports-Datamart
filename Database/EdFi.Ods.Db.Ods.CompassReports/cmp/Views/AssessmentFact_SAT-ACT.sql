CREATE VIEW [cmp].[AssessmentFact_SAT-ACT] AS
/* STUDENT ASSESSMENT PERFORMANCE FOR SAT AND ACT TAKEN */

WITH StudentEnrollment AS
(
SELECT *
FROM [cmp].StudentEnrollment()
WHERE GradeLevel IN ('Grade 12')
)

,PERFORMANCELEVELS AS
(
SELECT PerformanceLevel, ScoreResult, PerformanceKey
FROM cmp.PerformanceDim()
WHERE PerformanceLevel IN ('Took SAT', 'Took ACT', 'Did Not Take SAT', 'Did Not Take ACT')
)

,ASSESSMENTDIM AS
(
SELECT AssessmentKey, AssessmentTitle, AssessedGradeLevel, AcademicSubject
FROM cmp.AssessmentDim()
WHERE AssessmentTitle IN ('SAT', 'ACT')  
)

,LATESTASSESSMENT AS
(
SELECT [StudentUSI]
      ,[AssessmentTitle]
      ,[AcademicSubjectDescriptorId]
      ,[AssessedGradeLevelDescriptorId]
      ,[Version]
      ,MAX([AdministrationDate]) AS LatestAdministrationDate
FROM [edfi].[StudentAssessment] 
WHERE [AssessmentTitle] IN ('SAT', 'ACT')
GROUP BY [StudentUSI]
      ,[AssessmentTitle]
      ,[AcademicSubjectDescriptorId]
      ,[AssessedGradeLevelDescriptorId]
      ,[Version]
)

,STUDENTASSESSMENT AS
(
SELECT SA.[StudentUSI]
      ,SA.[AssessmentTitle]
      ,CASE WHEN AST.Description = 'Mathematics' THEN 'Math'
			WHEN AST.Description = 'English' THEN 'English (ACT Only)'
			WHEN AST.Description = 'Science' THEN 'Science (ACT Only)'
			WHEN AST.Description = 'Composite' THEN 'Composite Score'
			ELSE AST.Description
	   END AS AcademicSubject
      ,CASE WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12' END AS AssessedGradeLevel
	  ,'Not Applicable' AS GoodCauseExemption
	  ,CASE WHEN MONTH(LatestAdministrationDate) BETWEEN 8 AND 12 THEN YEAR(LatestAdministrationDate) + 1  ELSE YEAR(LatestAdministrationDate) END AS SchoolYear
FROM [edfi].[StudentAssessment] SA
JOIN [edfi].[AcademicSubjectDescriptor] ASD
	ON SA.[AcademicSubjectDescriptorId] = ASD.[AcademicSubjectDescriptorId]
JOIN [edfi].[AcademicSubjectType] AST
	ON AST.[AcademicSubjectTypeId] = ASD.[AcademicSubjectTypeId]
	AND AST.Description  IN ('English', 'Mathematics', 'Science', 'Composite', 'Writing', 'Reading')
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SA.[AssessedGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLT.[GradeLevelTypeId] = GLD.[GradeLevelTypeId]
	AND GLT.Description IN ('Twelfth grade')
JOIN LATESTASSESSMENT LA
	ON LA.[StudentUSI] = SA.[StudentUSI]
	AND LA.[AssessmentTitle] = SA.[AssessmentTitle]
	AND LA.[AcademicSubjectDescriptorId] = SA.[AcademicSubjectDescriptorId]
	AND LA.[AssessedGradeLevelDescriptorId] = SA.[AssessedGradeLevelDescriptorId]
	AND LA.[Version] = SA.[Version]
	AND [AdministrationDate] = LatestAdministrationDate
WHERE SA.[AssessmentTitle] IN ('SAT', 'ACT')
GROUP BY SA.[StudentUSI]
      ,SA.[AssessmentTitle]
      ,AST.Description
      ,GLT.Description
	  ,LatestAdministrationDate
)

,ALLSTUDENTS AS
(
SELECT SE.StudentUSI
      ,SE.SchoolId
	  ,SE.FreeReducedLunchStatus
	  ,SE.EnglishLanguageLearnerStatus
	  ,SE.SchoolYear
      ,SE.GradeLevel
	  ,SE.Ethnicity
	  ,SE.ExpectedGraduationYear
	  ,SE.SpecialEducationStatus
	  ,AD.AssessmentTitle
      ,AD.AcademicSubject
      ,AD.AssessedGradeLevel
	  ,'Not Applicable' AS GoodCauseExemption
	  ,CASE WHEN AD.AssessmentTitle = 'ACT' THEN 'Did Not Take ACT' ELSE 'Did Not Take SAT' END AS PerformanceLevel
FROM StudentEnrollment SE
CROSS JOIN ASSESSMENTDIM AD
GROUP BY SE.StudentUSI
      ,SE.SchoolId
	  ,SE.FreeReducedLunchStatus
	  ,SE.EnglishLanguageLearnerStatus
	  ,SE.SchoolYear
      ,SE.GradeLevel
	  ,SE.Ethnicity
	  ,SE.ExpectedGraduationYear
	  ,SE.SpecialEducationStatus
	  ,AD.AssessmentTitle
      ,AD.AcademicSubject
      ,AD.AssessedGradeLevel
)

,SATACT AS
(
SELECT DISTINCT SE.StudentUSI
      ,SE.SchoolId
	  ,SE.FreeReducedLunchStatus
	  ,SE.EnglishLanguageLearnerStatus
	  ,SE.SchoolYear
      ,SE.GradeLevel
	  ,SE.Ethnicity
	  ,SE.ExpectedGraduationYear
	  ,SE.SpecialEducationStatus
	  ,SE.AssessmentTitle
      ,SE.AcademicSubject
      ,SE.AssessedGradeLevel
	  ,SE.GoodCauseExemption
	  ,CASE WHEN SA.AssessmentTitle = 'SAT' THEN 'Took SAT'
			WHEN SA.AssessmentTitle = 'ACT' THEN 'Took ACT'
			ELSE SE.PerformanceLevel
		END AS PerformanceLevel
FROM ALLSTUDENTS SE
LEFT JOIN STUDENTASSESSMENT SA
	ON SE.StudentUSI = SA.StudentUSI
	AND SE.AssessmentTitle = SA.AssessmentTitle
    AND SE.AcademicSubject = SA.AcademicSubject
    AND SE.AssessedGradeLevel = SA.AssessedGradeLevel
	AND SE.GoodCauseExemption = SA.GoodCauseExemption
)

SELECT  DD.DemographicId,
		SA.SchoolId,
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey,
		COUNT(DISTINCT SA.[StudentUSI]) AS StudentCount
FROM SATACT SA
JOIN cmp.DemographicDim() DD
	ON DD.GradeLevel = SA.GradeLevel
	AND	DD.Ethnicity = SA.Ethnicity
	AND	DD.FreeReducedLunchStatus = SA.FreeReducedLunchStatus
	AND	DD.SpecialEducationStatus = SA.SpecialEducationStatus
	AND	DD.EnglishLanguageLearnerStatus = SA.EnglishLanguageLearnerStatus
	AND DD.ExpectedGraduationYear = SA.ExpectedGraduationYear
JOIN PERFORMANCELEVELS PL
	ON PL.PerformanceLevel = SA.PerformanceLevel
JOIN ASSESSMENTDIM AD
	ON AD.AssessmentTitle = SA.AssessmentTitle
	AND AD.AcademicSubject = SA.AcademicSubject
	AND AD.AssessedGradeLevel = SA.AssessedGradeLevel
JOIN cmp.GoodCauseExemptionDim() GC
	ON GC.GoodCauseExemption = SA.GoodCauseExemption
GROUP BY DD.DemographicId,
		SA.SchoolId,
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey

 