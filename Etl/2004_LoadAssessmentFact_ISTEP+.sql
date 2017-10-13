/* STUDENT ASSESSMENT PERFORMANCE FOR ISTEP+ */

WITH StudentEnrollment AS
(
SELECT *
FROM dbo.StudentEnrollment()
WHERE GradeLevel IN ('Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 10')
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
WHERE AssessmentTitle = 'ISTEP+'  
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
WHERE [AssessmentTitle] = 'ISTEP+'
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
      ,CASE WHEN AST.Description = 'Mathematics' THEN 'Math Only'
			WHEN AST.Description = 'English Language Arts' THEN 'English/Language Arts Only'
			WHEN AST.Description = 'Science' THEN 'Science Only'
			WHEN AST.Description = 'Social Studies' THEN 'Social Studies Only'
	   END AS AcademicSubject
      ,CASE	WHEN GLT.Description = 'Third grade' THEN 'Grade 3'
			WHEN GLT.Description = 'Fourth grade' THEN 'Grade 4'
			WHEN GLT.Description = 'Fifth grade' THEN 'Grade 5'
			WHEN GLT.Description = 'Sixth grade' THEN 'Grade 6'
			WHEN GLT.Description = 'Seventh grade' THEN 'Grade 7'
			WHEN GLT.Description = 'Eighth grade' THEN 'Grade 8'
			WHEN GLT.Description = 'Tenth grade' THEN 'Grade 10'
	   END AS AssessedGradeLevel
	  ,'Not Applicable' AS GoodCauseExemption
	  ,CASE WHEN MONTH(LatestAdministrationDate) BETWEEN 8 AND 12 THEN YEAR(LatestAdministrationDate) + 1  ELSE YEAR(LatestAdministrationDate) END AS SchoolYear
	  ,[Result]
	  ,CASE 
			 WHEN GLT.Description ='Third grade' AND AST.Description = 'English Language Arts' AND [Result] >= 428 THEN 'Pass' --3RD GRADE ELA PASS
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 456 THEN 'Pass' --4TH GRADE ELA PASS
			 WHEN GLT.Description ='Fifth grade'AND AST.Description = 'English Language Arts' AND [Result] >= 486 THEN 'Pass' --5TH GRADE ELA PASS
			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 502 THEN 'Pass' --6TH GRADE ELA PASS
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'English Language Arts' AND [Result] >= 516 THEN 'Pass' --7TH GRADE ELA PASS
			 WHEN GLT.Description ='Eighth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 537 THEN 'Pass' --8TH GRADE ELA PASS
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 244 THEN 'Pass' --10TH GRADE ELA PASS

			 WHEN GLT.Description ='Third grade' AND AST.Description = 'Mathematics' AND [Result] >= 425 THEN 'Pass' --3RD GRADE MA PASS
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'Mathematics' AND [Result] >= 458 THEN 'Pass' --4TH GRADE MA PASS
			 WHEN GLT.Description ='Fifth grade' AND AST.Description = 'Mathematics' AND [Result] >= 480 THEN 'Pass' --5TH GRADE MA PASS
			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'Mathematics' AND [Result] >= 510 THEN 'Pass' --6TH GRADE MA PASS
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'Mathematics' AND [Result] >= 533 THEN 'Pass' --7TH GRADE MA PASS
			 WHEN GLT.Description ='Eighth grade' AND AST.Description = 'Mathematics' AND [Result] >= 554 THEN 'Pass' --8TH GRADE MA PASS
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'Mathematics' AND [Result] >= 271 THEN 'Pass' --10TH GRADE MA PASS

			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'Science' AND [Result] >= 467 THEN 'Pass' --6TH GRADE SC PASS						
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'Science' AND [Result] >= 410 THEN 'Pass' --4TH GRADE SC PASS
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'Science' AND [Result] >= 248 THEN 'Pass' --10TH GRADE SC PASS

			 WHEN GLT.Description ='Fifth grade' AND AST.Description = 'Social Studies' AND [Result] >= 483 THEN 'Pass' --5TH GRADE SS PASS
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'Social Studies' AND [Result] >= 486 THEN 'Pass' --7TH GRADE SS PASS
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
	AND AST.Description  IN ('English Language Arts', 'Mathematics', 'Social Studies', 'Science')
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SAR.[AssessedGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLT.[GradeLevelTypeId] = GLD.[GradeLevelTypeId]
	AND GLT.Description IN ('Third grade', 'Fourth grade', 'Fifth grade', 'Sixth grade', 'Seventh grade', 'Eighth grade', 'Tenth grade')
JOIN LATESTASSESSMENT LA
	ON LA.[StudentUSI] = SAR.[StudentUSI]
	AND LA.[AssessmentTitle] = SAR.[AssessmentTitle]
	AND LA.[AcademicSubjectDescriptorId] = SAR.[AcademicSubjectDescriptorId]
	AND LA.[AssessedGradeLevelDescriptorId] = SAR.[AssessedGradeLevelDescriptorId]
	AND LA.[Version] = SAR.[Version]
	AND [AdministrationDate] = LatestAdministrationDate
WHERE SAR.[AssessmentTitle] = 'ISTEP+'
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
WHERE AcademicSubject IN ('Math Only', 'English/Language Arts Only')
) AS ELAMA
PIVOT
(
SUM (PerformanceLevel) FOR AcademicSubject IN ([Math Only], [English/Language Arts Only])
) AS PV
)

,PERFORMANCE AS
(
SELECT  StudentUSI
      ,AssessmentTitle
	  ,AssessedGradeLevel
	  ,GoodCauseExemption
	  ,SchoolYear
	  ,'Both English/Language Arts and Math' AS AcademicSubject
	  , CASE WHEN [Math Only] = 1 AND [English/Language Arts Only] = 1 THEN 'Pass' ELSE 'Did Not Pass' END AS PerformanceLevel
FROM STUDENTELAMA
GROUP BY StudentUSI
      ,AssessmentTitle
	  ,AssessedGradeLevel
	  ,GoodCauseExemption
	  ,SchoolYear
	  , CASE WHEN [Math Only] = 1 AND [English/Language Arts Only] = 1 THEN 'Pass' ELSE 'Did Not Pass' END

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
	AND (SE.ExpectedGraduationYear = DD.ExpectedGraduationYear OR SE.ExpectedGraduationYear IS NULL)
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

      
 