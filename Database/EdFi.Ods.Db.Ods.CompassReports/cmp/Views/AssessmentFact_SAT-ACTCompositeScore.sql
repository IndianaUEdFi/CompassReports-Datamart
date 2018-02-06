CREATE VIEW [cmp].[AssessmentFact_SAT-ACTCompositeScore] AS
/* STUDENT ASSESSMENT PERFORMANCE FOR SAT AND ACT TAKEN */

WITH StudentEnrollment AS
(
SELECT *
FROM cmp.StudentEnrollment()
WHERE GradeLevel IN ('Grade 12')
)

,PERFORMANCELEVELS AS
(
SELECT PerformanceLevel, ScoreResult, PerformanceKey
FROM cmp.PerformanceDim()
WHERE PerformanceLevel = 'Not Applicable'
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

,STUDENTSCORE AS
(
SELECT SA.[StudentUSI]
      ,SA.[AssessmentTitle]
      ,CASE WHEN AST.Description = 'Composite' THEN 'Composite Score'
			ELSE AST.Description
	   END AS AcademicSubject
      ,CASE WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12' END AS AssessedGradeLevel
	  ,'Not Applicable' AS GoodCauseExemption
	  ,CASE WHEN MONTH(LatestAdministrationDate) BETWEEN 8 AND 12 THEN YEAR(LatestAdministrationDate) + 1  ELSE YEAR(LatestAdministrationDate) END AS SchoolYear
	  ,CASE WHEN ARM.Description = 'Scale score' AND SA.AssessmentTitle = 'ACT' AND AST.Description = 'Composite' THEN Result
			WHEN ARM.Description = 'College Board examination scores' AND SA.AssessmentTitle = 'SAT' AND AST.Description = 'Composite' THEN Result
		END AS Score 
	  , 'Not Applicable' AS [PerformanceLevel]
FROM [edfi].[StudentAssessmentScoreResult] SA
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
JOIN [edfi].[AssessmentReportingMethodType] ARM
	ON ARM.[AssessmentReportingMethodTypeId] = SA.[AssessmentReportingMethodTypeId]
	AND ARM.Description IN ('Scale score', 'College Board examination scores')
JOIN LATESTASSESSMENT LA
	ON LA.[StudentUSI] = SA.[StudentUSI]
	AND LA.[AssessmentTitle] = SA.[AssessmentTitle]
	AND LA.[AcademicSubjectDescriptorId] = SA.[AcademicSubjectDescriptorId]
	AND LA.[AssessedGradeLevelDescriptorId] = SA.[AssessedGradeLevelDescriptorId]
	AND LA.[Version] = SA.[Version]
	AND [AdministrationDate] = LatestAdministrationDate
WHERE SA.[AssessmentTitle] IN ('SAT', 'ACT')
AND AST.Description = 'Composite' 
GROUP BY SA.[StudentUSI]
      ,SA.[AssessmentTitle]
      ,AST.Description
      ,GLT.Description
	  ,LatestAdministrationDate
	  ,ARM.Description
	  ,SA.Result
)

SELECT  DD.DemographicId,
		SE.SchoolId,
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey,
		COUNT(DISTINCT SA.[StudentUSI]) AS StudentCount
FROM STUDENTSCORE SA
JOIN StudentEnrollment SE
	ON SA.StudentUSI = SE.StudentUSI
	AND SA.SchoolYear = SE.SchoolYear
	AND SA.AssessedGradeLevel = SE.GradeLevel 
JOIN cmp.DemographicDim() DD
	ON DD.GradeLevel = SE.GradeLevel
	AND	DD.Ethnicity = SE.Ethnicity
	AND	DD.FreeReducedLunchStatus = SE.FreeReducedLunchStatus
	AND	DD.SpecialEducationStatus = SE.SpecialEducationStatus
	AND	DD.EnglishLanguageLearnerStatus = SE.EnglishLanguageLearnerStatus
	AND DD.ExpectedGraduationYear = SE.ExpectedGraduationYear
JOIN PERFORMANCELEVELS PL
	ON PL.PerformanceLevel = SA.PerformanceLevel
	AND PL.ScoreResult = SA.Score
JOIN ASSESSMENTDIM AD
	ON AD.AssessmentTitle = SA.AssessmentTitle
	AND AD.AcademicSubject = SA.AcademicSubject
	AND AD.AssessedGradeLevel = SA.AssessedGradeLevel
JOIN cmp.GoodCauseExemptionDim() GC
	ON GC.GoodCauseExemption = SA.GoodCauseExemption
GROUP BY DD.DemographicId,
		SE.SchoolId,
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey
      
 