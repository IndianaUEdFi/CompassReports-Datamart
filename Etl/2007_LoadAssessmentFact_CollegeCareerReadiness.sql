/* STUDENT ASSESSMENT PERFORMANCE FOR AP EXAMS */

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
WHERE PerformanceLevel IN ('Pass', 'Did Not Pass', 'Took an AP Exam', 'Did Not Take an AP Exam')
)

,ASSESSMENTDIM AS
(
SELECT AssessmentKey, AssessmentTitle, AssessedGradeLevel, AcademicSubject
FROM dbo.AssessmentDim()
WHERE AssessmentTitle = 'AP'  
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
WHERE [AssessmentTitle] LIKE 'AP -%'
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
      ,AST.Description AS AcademicSubject
      ,CASE WHEN GLT.Description = 'Tenth grade' THEN 'Grade 10' 
			WHEN GLT.Description = 'Eleventh grade' THEN 'Grade 11'
			WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12'
	   END AS AssessedGradeLevel
	  ,'Not Applicable' AS GoodCauseExemption
	  ,CASE WHEN MONTH(LatestAdministrationDate) BETWEEN 8 AND 12 THEN YEAR(LatestAdministrationDate) + 1  ELSE YEAR(LatestAdministrationDate) END AS SchoolYear
	  ,CASE WHEN SA.Result >2 THEN 'Pass' ELSE 'Did Not Pass' END AS Result
FROM [edfi].[StudentAssessmentScoreResult] SA
JOIN [edfi].[AcademicSubjectDescriptor] ASD
	ON SA.[AcademicSubjectDescriptorId] = ASD.[AcademicSubjectDescriptorId]
JOIN [edfi].[AcademicSubjectType] AST
	ON AST.[AcademicSubjectTypeId] = ASD.[AcademicSubjectTypeId]
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SA.[AssessedGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLT.[GradeLevelTypeId] = GLD.[GradeLevelTypeId]
	AND GLT.Description IN ('Tenth grade', 'Eleventh grade', 'Twelfth grade')
JOIN [edfi].[AssessmentReportingMethodType] ART
	ON ART.[AssessmentReportingMethodTypeId] = SA.[AssessmentReportingMethodTypeId]
	AND ART.Description = 'Raw score'
JOIN LATESTASSESSMENT LA
	ON LA.[StudentUSI] = SA.[StudentUSI]
	AND LA.[AssessmentTitle] = SA.[AssessmentTitle]
	AND LA.[AcademicSubjectDescriptorId] = SA.[AcademicSubjectDescriptorId]
	AND LA.[AssessedGradeLevelDescriptorId] = SA.[AssessedGradeLevelDescriptorId]
	AND LA.[Version] = SA.[Version]
	AND [AdministrationDate] = LatestAdministrationDate
WHERE SA.[AssessmentTitle] LIKE 'AP -%'
GROUP BY SA.[StudentUSI]
      ,SA.[AssessmentTitle]
      ,AST.Description
      ,GLT.Description
	  ,LatestAdministrationDate
	  ,SA.Result
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
	  ,'Did Not Take an AP Exam' AS PerformanceLevel
FROM StudentEnrollment SE
JOIN ASSESSMENTDIM AD
	ON AD.AssessedGradeLevel = SE.GradeLevel
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

,APEXAM AS
(
SELECT StudentUSI,
		COUNT(AssessmentTitle) AS APTaking,
		SUM(CASE WHEN Result = 'Pass' THEN 1 ELSE 0 END) AS APPassing
FROM STUDENTASSESSMENT
GROUP BY StudentUSI
)

,COLLEGEREADY AS
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
	  ,CASE WHEN APTaking >= 1 THEN 'Took an AP Exam'
			ELSE SE.PerformanceLevel
		END AS PerformanceLevel
FROM ALLSTUDENTS SE
LEFT JOIN APEXAM AP
	ON SE.StudentUSI = AP.StudentUSI

UNION

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
	  ,CASE WHEN APPassing > 0 THEN 'Pass'
			ELSE 'Did not Pass' 
		END AS PerformanceLevel
FROM ALLSTUDENTS SE
JOIN APEXAM AP
	ON SE.StudentUSI = AP.StudentUSI
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
		SA.SchoolId,
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey,
		COUNT(DISTINCT SA.[StudentUSI]) AS StudentCount
FROM COLLEGEREADY SA
JOIN  dbo.DemographicDim() DD
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
JOIN dbo.GoodCauseExemptionDim() GC
	ON GC.GoodCauseExemption = SA.GoodCauseExemption
GROUP BY DD.DemographicId,
		SA.SchoolId,
		SA.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey
OPTION (maxrecursion 0)