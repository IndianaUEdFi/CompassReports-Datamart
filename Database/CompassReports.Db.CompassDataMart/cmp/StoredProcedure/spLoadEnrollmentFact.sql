CREATE PROCEDURE [cmp].[spLoadEnrollmentFact] (
	@OdsDatabaseReference nvarchar(512)
	) AS
DECLARE @sqlCmd nvarchar(max)
SET @sqlCmd = '
INSERT INTO [cmp].[EnrollmentFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[EnrollmentStudentCount]
		   )

SELECT  [DemographicId]
	,[SchoolId]
	,[SchoolYear]
	,[EnrollmentCount]
FROM [' + @OdsDatabaseReference + '].[cmp].[EnrollmentFact]	'

EXEC(@sqlCmd)

