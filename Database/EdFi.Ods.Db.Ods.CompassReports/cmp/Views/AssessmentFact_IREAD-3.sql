CREATE VIEW [cmp].[AssessmentFact_IREAD-3]
	AS 
/* STUDENT ASSESSMENT PERFORMANCE FOR IREAD-3 */

WITH StudentEnrollment AS
(
SELECT *
FROM cmp.StudentEnrollment()
WHERE GradeLevel = 'Grade 3'
)

,PERFORMANCELEVELS AS
(
SELECT PerformanceLevel, PerformanceKey
FROM cmp.PerformanceDim()
WHERE PerformanceLevel IN ('Pass', 'Did Not Pass')
)

,ASSESSMENTDIM AS
(
SELECT AssessmentKey, AssessmentTitle, AssessedGradeLevel, AcademicSubject
FROM cmp.AssessmentDim()
WHERE AssessmentTitle = 'IREAD-3'  
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
WHERE [AssessmentTitle] = 'IREAD-3'
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
      ,AST.Description AS AcademicSubject
      ,CASE WHEN GLT.Description = 'Third grade' THEN 'Grade 3' END AS AssessedGradeLevel
	  ,'No Good Cause Exemption Granted' AS GoodCauseExemption /* NEED TO UPDATE AFTER EXTENSIONIS ADDED FOR GOODCAUSEEXEMPTION */
	  ,CASE WHEN MONTH(LatestAdministrationDate) BETWEEN 8 AND 12 THEN YEAR(LatestAdministrationDate) + 1  ELSE YEAR(LatestAdministrationDate) END AS SchoolYear
	  ,CASE WHEN [Result] >= 446 THEN 'Pass' ELSE 'Did Not Pass' END AS PerformanceLevel
FROM [edfi].[StudentAssessmentScoreResult] SAR
JOIN [edfi].[AssessmentReportingMethodType] ART
	ON ART.[AssessmentReportingMethodTypeId] = SAR.[AssessmentReportingMethodTypeId]
	AND ART.Description = 'Scale score'
JOIN [edfi].[AcademicSubjectDescriptor] ASD
	ON SAR.[AcademicSubjectDescriptorId] = ASD.[AcademicSubjectDescriptorId]
JOIN [edfi].[AcademicSubjectType] AST
	ON AST.[AcademicSubjectTypeId] = ASD.[AcademicSubjectTypeId]
	AND AST.Description = 'Reading'
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SAR.[AssessedGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLT.[GradeLevelTypeId] = GLD.[GradeLevelTypeId]
	AND GLT.Description = 'Third grade'
JOIN LATESTASSESSMENT LA
	ON LA.[StudentUSI] = SAR.[StudentUSI]
	AND LA.[AssessmentTitle] = SAR.[AssessmentTitle]
	AND LA.[AcademicSubjectDescriptorId] = SAR.[AcademicSubjectDescriptorId]
	AND LA.[AssessedGradeLevelDescriptorId] = SAR.[AssessedGradeLevelDescriptorId]
	AND LA.[Version] = SAR.[Version]
	AND [AdministrationDate] = LatestAdministrationDate
WHERE SAR.[AssessmentTitle] = 'IREAD-3'
GROUP BY SAR.[StudentUSI]
      ,SAR.[AssessmentTitle]
      ,AST.Description
      ,GLT.Description
	  ,LatestAdministrationDate
	  ,CASE WHEN [Result] >= 446 THEN 'Pass' ELSE 'Did Not Pass' END
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
GROUP BY SE.SchoolYear,
		SE.SchoolId,
		DD.DemographicId,
		PL.PerformanceKey,
		AD.AssessmentKey,
		GC.GoodCauseExemptionKey

      
 
