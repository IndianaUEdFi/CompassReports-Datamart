CREATE PROCEDURE [cmp].[spLoadAssessmentFact_IREAD-3] AS
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
FROM [cmp].[AssessmentFact_IREAD-3]
OPTION (maxrecursion 0)