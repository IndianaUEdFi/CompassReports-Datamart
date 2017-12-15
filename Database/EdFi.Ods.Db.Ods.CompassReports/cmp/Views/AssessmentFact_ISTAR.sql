CREATE VIEW [cmp].[AssessmentFact_ISTAR]
	AS 
	/* STUDENT ASSESSMENT PERFORMANCE FOR ISTAR */

WITH StudentEnrollment AS
(
SELECT *
FROM cmp.StudentEnrollment()
WHERE GradeLevel IN ('Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 10')
)

,PERFORMANCELEVELS AS
(
SELECT PerformanceLevel, PerformanceKey
FROM cmp.PerformanceDim()
WHERE PerformanceLevel IN ('Pass', 'Did Not Pass', 'Pass+')
)

,ASSESSMENTDIM AS
(
SELECT AssessmentKey, AssessmentTitle, AssessedGradeLevel, AcademicSubject
FROM cmp.AssessmentDim()
WHERE AssessmentTitle = 'ISTAR'  
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
WHERE [AssessmentTitle] = 'ISTAR'
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
			 WHEN GLT.Description ='Third grade' AND AST.Description = 'English Language Arts' AND [Result] BETWEEN 351 AND 381 THEN 'Pass' --3RD GRADE ELA PASS
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'English Language Arts' AND [Result] BETWEEN 355 AND 384 THEN 'Pass' --4TH GRADE ELA PASS
			 WHEN GLT.Description ='Fifth grade'AND AST.Description = 'English Language Arts' AND [Result] BETWEEN 354 AND 390 THEN 'Pass' --5TH GRADE ELA PASS
			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'English Language Arts' AND [Result] BETWEEN 348 AND 387 THEN 'Pass' --6TH GRADE ELA PASS
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'English Language Arts' AND [Result] BETWEEN 343 AND 377 THEN 'Pass' --7TH GRADE ELA PASS
			 WHEN GLT.Description ='Eighth grade' AND AST.Description = 'English Language Arts' AND [Result] BETWEEN 351 AND 379 THEN 'Pass' --8TH GRADE ELA PASS
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'English Language Arts' AND [Result] BETWEEN 344 AND 385 THEN 'Pass' --10TH GRADE ELA PASS

			 WHEN GLT.Description ='Third grade' AND AST.Description = 'Mathematics' AND [Result] BETWEEN 353 AND 378 THEN 'Pass' --3RD GRADE MA PASS
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'Mathematics' AND [Result] BETWEEN 365 AND 385 THEN 'Pass' --4TH GRADE MA PASS
			 WHEN GLT.Description ='Fifth grade' AND AST.Description = 'Mathematics' AND [Result] BETWEEN 354 AND 380 THEN 'Pass' --5TH GRADE MA PASS
			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'Mathematics' AND [Result] BETWEEN 348 AND 378 THEN 'Pass' --6TH GRADE MA PASS
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'Mathematics' AND [Result] BETWEEN 347 AND 379 THEN 'Pass' --7TH GRADE MA PASS
			 WHEN GLT.Description ='Eighth grade' AND AST.Description = 'Mathematics' AND [Result] BETWEEN 350 AND 381 THEN 'Pass' --8TH GRADE MA PASS
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'Mathematics' AND [Result] BETWEEN 352 AND 389 THEN 'Pass' --10TH GRADE MA PASS

			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'Science' AND [Result] BETWEEN 355 AND 392 THEN 'Pass' --6TH GRADE SC PASS						
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'Science' AND [Result] BETWEEN 354 AND 387 THEN 'Pass' --4TH GRADE SC PASS
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'Science' AND [Result] BETWEEN 342 AND 382 THEN 'Pass' --10TH GRADE SC PASS

			 WHEN GLT.Description ='Fifth grade' AND AST.Description = 'Social Studies' AND [Result] BETWEEN 340 AND 384 THEN 'Pass' --5TH GRADE SS PASS
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'Social Studies' AND [Result] BETWEEN 353 AND 385 THEN 'Pass' --7TH GRADE SS PASS

			 WHEN GLT.Description ='Third grade' AND AST.Description = 'English Language Arts' AND [Result] >= 382 THEN 'Pass+' --3RD GRADE ELA PASS+
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 385 THEN 'Pass+' --4TH GRADE ELA PASS+
			 WHEN GLT.Description ='Fifth grade'AND AST.Description = 'English Language Arts' AND [Result] >= 391 THEN 'Pass+' --5TH GRADE ELA PASS+
			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 388 THEN 'Pass+' --6TH GRADE ELA PASS+
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'English Language Arts' AND [Result] >= 378 THEN 'Pass+' --7TH GRADE ELA PASS+
			 WHEN GLT.Description ='Eighth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 380 THEN 'Pass+' --8TH GRADE ELA PASS+
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'English Language Arts' AND [Result] >= 386 THEN 'Pass+' --10TH GRADE ELA PASS+

			 WHEN GLT.Description ='Third grade' AND AST.Description = 'Mathematics' AND [Result] >= 379 THEN 'Pass+' --3RD GRADE MA PASS+
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'Mathematics' AND [Result] >= 386 THEN 'Pass+' --4TH GRADE MA PASS+
			 WHEN GLT.Description ='Fifth grade' AND AST.Description = 'Mathematics' AND [Result] >= 381 THEN 'Pass+' --5TH GRADE MA PASS+
			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'Mathematics' AND [Result] >= 379 THEN 'Pass+' --6TH GRADE MA PASS+
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'Mathematics' AND [Result] >= 380 THEN 'Pass+' --7TH GRADE MA PASS+
			 WHEN GLT.Description ='Eighth grade' AND AST.Description = 'Mathematics' AND [Result] >= 382 THEN 'Pass+' --8TH GRADE MA PASS+
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'Mathematics' AND [Result] >= 390 THEN 'Pass+' --10TH GRADE MA PASS+

			 WHEN GLT.Description ='Sixth grade' AND AST.Description = 'Science' AND [Result] >= 393 THEN 'Pass+' --6TH GRADE SC PASS+						
			 WHEN GLT.Description ='Fourth grade' AND AST.Description = 'Science' AND [Result] >= 388 THEN 'Pass+' --4TH GRADE SC PASS+
			 WHEN GLT.Description ='Tenth grade' AND AST.Description = 'Science' AND [Result] >= 383 THEN 'Pass+' --10TH GRADE SC PASS+

			 WHEN GLT.Description ='Fifth grade' AND AST.Description = 'Social Studies' AND [Result] >= 385 THEN 'Pass+' --5TH GRADE SS PASS+
			 WHEN GLT.Description ='Seventh grade' AND AST.Description = 'Social Studies' AND [Result] >= 386 THEN 'Pass+' --7TH GRADE SS PASS+

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
WHERE SAR.[AssessmentTitle] = 'ISTAR'
GROUP BY SAR.[StudentUSI]
      ,SAR.[AssessmentTitle]
      ,AST.Description
      ,GLT.Description
	  ,LatestAdministrationDate
	  ,SAR.Result
)

SELECT  DD.DemographicId,
		SE.SchoolId,
		SE.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey,
		COUNT(DISTINCT SA.[StudentUSI]) AS StudentCount
FROM STUDENTASSESSMENT SA
JOIN StudentEnrollment SE
	ON SE.StudentUSI = SA.StudentUSI
	AND SE.SchoolYear = SA.SchoolYear
	AND SE.GradeLevel = SA.AssessedGradeLevel
JOIN cmp.DemographicDim() DD
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
JOIN cmp.GoodCauseExemptionDim() GC
	ON GC.GoodCauseExemption = SA.GoodCauseExemption
GROUP BY DD.DemographicId,
		SE.SchoolId,
		SE.SchoolYear,
		AD.AssessmentKey,
		PL.PerformanceKey,
		GC.GoodCauseExemptionKey

      
 