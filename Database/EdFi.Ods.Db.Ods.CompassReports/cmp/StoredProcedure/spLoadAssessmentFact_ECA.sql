CREATE PROCEDURE [cmp].[spLoadAssessmentFact_ECA] AS
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
FROM [cmp].[AssessmentFact_ECA]
OPTION (maxrecursion 0)
      
 