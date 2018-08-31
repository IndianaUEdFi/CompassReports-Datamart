CREATE PROCEDURE [cmp].[spLoadAssessmentFact_ECA] (
	@OdsDatabaseReference nvarchar(512)
	) AS
DECLARE @sqlCmd nvarchar(max)
SET @sqlCmd = 'INSERT INTO [cmp].[AssessmentFact]
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
FROM [' + @OdsDatabaseReference + '].[cmp].[AssessmentFact_ECA]
OPTION (maxrecursion 0)'

EXEC(@sqlCmd)

      
 