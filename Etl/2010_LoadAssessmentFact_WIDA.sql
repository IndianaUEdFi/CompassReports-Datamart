/* STUDENT ASSESSMENT PERFORMANCE FOR SAT AND ACT TAKEN */

WITH StudentEnrollment AS
(
SELECT *
FROM dbo.StudentEnrollment()
)

,PERFORMANCELEVELS AS
(
SELECT PerformanceLevel, ScoreResult, PerformanceKey
FROM dbo.PerformanceDim()
WHERE PerformanceLevel IN ('Entering', 'Emerging', 'Developing', 'Expanding', 'Bridging', 'Reaching')
)

,ASSESSMENTDIM AS
(
SELECT AssessmentKey, AssessmentTitle, AssessedGradeLevel, AcademicSubject
FROM dbo.AssessmentDim()
WHERE AssessmentTitle = 'WIDA' 
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
WHERE [AssessmentTitle] = 'WIDA' 
GROUP BY [StudentUSI]
      ,[AssessmentTitle]
      ,[AcademicSubjectDescriptorId]
      ,[AssessedGradeLevelDescriptorId]
      ,[Version]
)

,STUDENTPERFORMANCE AS
(
SELECT SA.[StudentUSI]
      ,SA.[AssessmentTitle]
      ,AST.Description AS AcademicSubject
      ,CASE WHEN GLT.Description = 'First grade' THEN 'Grade 1'
			WHEN GLT.Description = 'Second grade' THEN 'Grade 2'
			WHEN GLT.Description = 'Third grade' THEN 'Grade 3'
			WHEN GLT.Description = 'Fourth grade' THEN 'Grade 4'
			WHEN GLT.Description = 'Fifth grade' THEN 'Grade 5'
			WHEN GLT.Description = 'Sixth grade' THEN 'Grade 6'
			WHEN GLT.Description = 'Seventh grade' THEN 'Grade 7'
			WHEN GLT.Description = 'Eighth grade' THEN 'Grade 8'
			WHEN GLT.Description = 'Ninth grade' THEN 'Grade 9'
			WHEN GLT.Description = 'Tenth grade' THEN 'Grade 10'
			WHEN GLT.Description = 'Eleventh grade' THEN 'Grade 11'
			WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12'
			WHEN GLT.Description = 'Preschool/Prekindergarten' THEN 'Pre-Kindergarten'
			WHEN GLT.Description = 'Kindergarten' THEN 'Kindergarten'
	   END AS AssessedGradeLevel
	  ,'Not Applicable' AS GoodCauseExemption
	  ,CASE WHEN MONTH(LatestAdministrationDate) BETWEEN 8 AND 12 THEN YEAR(LatestAdministrationDate) + 1  ELSE YEAR(LatestAdministrationDate) END AS SchoolYear
	  ,D.Description AS [PerformanceLevel]
FROM [edfi].[StudentAssessmentPerformanceLevel] SA
JOIN [edfi].[AcademicSubjectDescriptor] ASD
	ON SA.[AcademicSubjectDescriptorId] = ASD.[AcademicSubjectDescriptorId]
JOIN [edfi].[AcademicSubjectType] AST
	ON AST.[AcademicSubjectTypeId] = ASD.[AcademicSubjectTypeId]
	AND AST.Description  = 'English'
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SA.[AssessedGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLT.[GradeLevelTypeId] = GLD.[GradeLevelTypeId]
JOIN [edfi].[Descriptor] D
	ON D.[DescriptorId] = SA.[PerformanceLevelDescriptorId]
JOIN LATESTASSESSMENT LA
	ON LA.[StudentUSI] = SA.[StudentUSI]
	AND LA.[AssessmentTitle] = SA.[AssessmentTitle]
	AND LA.[AcademicSubjectDescriptorId] = SA.[AcademicSubjectDescriptorId]
	AND LA.[AssessedGradeLevelDescriptorId] = SA.[AssessedGradeLevelDescriptorId]
	AND LA.[Version] = SA.[Version]
	AND [AdministrationDate] = LatestAdministrationDate
WHERE SA.[AssessmentTitle] = 'WIDA'
GROUP BY SA.[StudentUSI]
      ,SA.[AssessmentTitle]
      ,AST.Description
      ,GLT.Description
	  ,LatestAdministrationDate
	  ,D.Description

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
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey,
		COUNT(DISTINCT SA.[StudentUSI]) AS StudentCount
FROM STUDENTPERFORMANCE SA
JOIN StudentEnrollment SE
	ON SA.StudentUSI = SE.StudentUSI
	AND SA.SchoolYear = SE.SchoolYear
	AND SA.AssessedGradeLevel = SE.GradeLevel 
JOIN dbo.DemographicDim() DD
	ON DD.GradeLevel = SE.GradeLevel
	AND	DD.Ethnicity = SE.Ethnicity
	AND	DD.FreeReducedLunchStatus = SE.FreeReducedLunchStatus
	AND	DD.SpecialEducationStatus = SE.SpecialEducationStatus
	AND	DD.EnglishLanguageLearnerStatus = SE.EnglishLanguageLearnerStatus
	AND (SE.ExpectedGraduationYear = DD.ExpectedGraduationYear OR SE.ExpectedGraduationYear IS NULL)
JOIN PERFORMANCELEVELS PL
	ON PL.PerformanceLevel = SA.PerformanceLevel
JOIN ASSESSMENTDIM AD
	ON AD.AssessmentTitle = SA.AssessmentTitle
	AND AD.AcademicSubject = SA.AcademicSubject
	AND AD.AssessedGradeLevel = SA.AssessedGradeLevel
JOIN dbo.GoodCauseExemptionDim() GC
	ON GC.GoodCauseExemption = SA.GoodCauseExemption
GROUP BY DD.DemographicId,
		SE.SchoolId,
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey
OPTION (maxrecursion 0)
      
 