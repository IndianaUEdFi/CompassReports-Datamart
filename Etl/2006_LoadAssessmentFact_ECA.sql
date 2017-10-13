/* STUDENT ASSESSMENT PERFORMANCE FOR ECA */

WITH StudentEnrollment AS
(
SELECT *
FROM dbo.StudentEnrollment()
WHERE GradeLevel IN ('Grade 10', 'Grade 11', 'Grade 12')
)

,PERFORMANCELEVELS AS
(
SELECT PerformanceLevel, PerformanceKey
FROM dbo.PerformanceDim()
WHERE PerformanceLevel IN ('Pass', 'Did Not Pass')
)

,ASSESSMENTDIM AS
(
SELECT AssessmentKey, AssessmentTitle, AssessedGradeLevel, AcademicSubject
FROM dbo.AssessmentDim()
WHERE AssessmentTitle = 'ECA'  
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
WHERE [AssessmentTitle] = 'ECA'
GROUP BY [StudentUSI]
      ,[AssessmentTitle]
      ,[AcademicSubjectDescriptorId]
      ,[AssessedGradeLevelDescriptorId]
      ,[Version]
)

,STUDENTASSESSMENT AS
(
SELECT SAR.[StudentUSI]
      ,SAR.[AssessmentTitle]
      ,CASE WHEN AST.Description = 'Mathematics' THEN 'Algebra I Only'
			WHEN AST.Description = 'English' THEN 'English 10 Only'
	   END AS AcademicSubject
      ,CASE WHEN GLT.Description = 'Tenth grade' THEN 'Grade 10'
			WHEN GLT.Description = 'Eleventh grade' THEN 'Grade 11'
			WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12'
	   END AS AssessedGradeLevel
	  ,'Not Applicable' AS GoodCauseExemption
	  ,CASE WHEN MONTH(LatestAdministrationDate) BETWEEN 8 AND 12 THEN YEAR(LatestAdministrationDate) + 1  ELSE YEAR(LatestAdministrationDate) END AS SchoolYear
	  ,[Result]
	  ,CASE 
			 WHEN AST.Description = 'English' AND [Result] >= 360 THEN 'Pass' -- ENGLISH PASS
			 WHEN AST.Description = 'Mathematics' AND [Result] >= 564 THEN 'Pass' -- MATH PASS
			 ELSE 'Did Not Pass'
		END AS [PerformanceLevel]
FROM [edfi].[StudentAssessmentScoreResult] SAR
JOIN [edfi].[AssessmentReportingMethodType] ART
	ON ART.[AssessmentReportingMethodTypeId] = SAR.[AssessmentReportingMethodTypeId]
	AND ART.Description = 'Scale score'
JOIN [edfi].[AcademicSubjectDescriptor] ASD
	ON SAR.[AcademicSubjectDescriptorId] = ASD.[AcademicSubjectDescriptorId]
JOIN [edfi].[AcademicSubjectType] AST
	ON AST.[AcademicSubjectTypeId] = ASD.[AcademicSubjectTypeId]
	AND AST.Description  IN ('English', 'Mathematics')
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SAR.[AssessedGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLT.[GradeLevelTypeId] = GLD.[GradeLevelTypeId]
	AND GLT.Description IN ('Tenth grade', 'Eleventh grade', 'Twelfth grade')
JOIN LATESTASSESSMENT LA
	ON LA.[StudentUSI] = SAR.[StudentUSI]
	AND LA.[AssessmentTitle] = SAR.[AssessmentTitle]
	AND LA.[AcademicSubjectDescriptorId] = SAR.[AcademicSubjectDescriptorId]
	AND LA.[AssessedGradeLevelDescriptorId] = SAR.[AssessedGradeLevelDescriptorId]
	AND LA.[Version] = SAR.[Version]
	AND [AdministrationDate] = LatestAdministrationDate
WHERE SAR.[AssessmentTitle] = 'ECA'
GROUP BY SAR.[StudentUSI]
      ,SAR.[AssessmentTitle]
      ,AST.Description
      ,GLT.Description
	  ,LatestAdministrationDate
	  ,SAR.Result
)

,STUDENTELAMA AS
(
SELECT * 
FROM
(
SELECT StudentUSI
      ,AssessmentTitle
      ,AcademicSubject
      ,AssessedGradeLevel
	  ,GoodCauseExemption
	  ,SchoolYear
	  ,CASE WHEN PerformanceLevel = 'Pass' THEN 1 ELSE 0 END AS PerformanceLevel
FROM STUDENTASSESSMENT
WHERE AcademicSubject IN ('Algebra I Only', 'English 10 Only')
) AS ELAMA
PIVOT
(
SUM (PerformanceLevel) FOR AcademicSubject IN ([Algebra I Only], [English 10 Only])
) AS PV
)

,PERFORMANCE AS
(
SELECT  StudentUSI
      ,AssessmentTitle
	  ,AssessedGradeLevel
	  ,GoodCauseExemption
	  ,SchoolYear
	  ,'Both English 10 and Algebra I' AS AcademicSubject
	  , CASE WHEN [Algebra I Only] = 1 AND [English 10 Only] = 1 THEN 'Pass' ELSE 'Did Not Pass' END AS PerformanceLevel
FROM STUDENTELAMA
GROUP BY StudentUSI
      ,AssessmentTitle
	  ,AssessedGradeLevel
	  ,GoodCauseExemption
	  ,SchoolYear
	  , CASE WHEN [Algebra I Only] = 1 AND [English 10 Only] = 1 THEN 'Pass' ELSE 'Did Not Pass' END

UNION

SELECT  StudentUSI
      ,AssessmentTitle
	  ,AssessedGradeLevel
	  ,GoodCauseExemption
	  ,SchoolYear
	  ,AcademicSubject
	  ,PerformanceLevel
FROM STUDENTASSESSMENT
)

INSERT INTO [CompassDataMart].[cmp].[AssessmentFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[AssessmentKey]
           ,[PerformanceKey]
           ,[GoodCauseExemptionKey]
           ,[AssessmentStudentCount]
		   )

SELECT  DD.DemographicId,
		SE.SchoolId,
		SE.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey,
		COUNT(DISTINCT PA.[StudentUSI]) AS StudentCount
FROM PERFORMANCE PA
JOIN StudentEnrollment SE
	ON SE.StudentUSI = PA.StudentUSI
	AND SE.SchoolYear = PA.SchoolYear
	AND SE.GradeLevel = PA.AssessedGradeLevel
JOIN dbo.DemographicDim() DD
	ON DD.GradeLevel = SE.GradeLevel
	AND	DD.Ethnicity = SE.Ethnicity
	AND	DD.FreeReducedLunchStatus = SE.FreeReducedLunchStatus
	AND	DD.SpecialEducationStatus = SE.SpecialEducationStatus
	AND	DD.EnglishLanguageLearnerStatus = SE.EnglishLanguageLearnerStatus
	AND DD.ExpectedGraduationYear = SE.ExpectedGraduationYear
JOIN PERFORMANCELEVELS PL
	ON PL.PerformanceLevel = PA.PerformanceLevel
JOIN ASSESSMENTDIM AD
	ON AD.AssessmentTitle = PA.AssessmentTitle
	AND AD.AcademicSubject = PA.AcademicSubject
	AND AD.AssessedGradeLevel = PA.AssessedGradeLevel
JOIN dbo.GoodCauseExemptionDim() GC
	ON GC.GoodCauseExemption = PA.GoodCauseExemption
GROUP BY DD.DemographicId,
		SE.SchoolId,
		SE.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey
OPTION (maxrecursion 0)

      
 