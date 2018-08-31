CREATE PROCEDURE [cmp].[spLoadAssessmentFact_ISTAR] AS
INSERT INTO [$(CompassDataMart)].[cmp].[AssessmentFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[AssessmentKey]
           ,[PerformanceKey]
           ,[GoodCauseExemptionKey]
           ,[AssessmentStudentCount]
		   )
SELECT [DemographicId]
    ,[SchoolId]
    ,[SchoolYear]
    ,[AssessmentKey]
    ,[PerformanceKey]
    ,[GoodCauseExemptionKey]
    ,[StudentCount]
FROM [cmp].[AssessmentFact_ISTAR]
OPTION (maxrecursion 0)
      
 