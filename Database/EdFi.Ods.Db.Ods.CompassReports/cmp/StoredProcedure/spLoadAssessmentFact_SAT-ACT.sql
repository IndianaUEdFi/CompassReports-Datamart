CREATE PROCEDURE [cmp].[spLoadAssessmentFact_SAT-ACT] AS
INSERT INTO [$(CompassDataMart)].[cmp].[AssessmentFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[AssessmentKey]
           ,[PerformanceKey]
           ,[GoodCauseExemptionKey]
           ,[AssessmentStudentCount]
		   )

SELECT  DemographicId,
		SchoolId,
		SchoolYear,
		AssessmentKey,
		PerformanceKey,
		GoodCauseExemptionKey,
		StudentCount
FROM [cmp].[AssessmentFact_SAT-ACT]
OPTION (maxrecursion 0)
 