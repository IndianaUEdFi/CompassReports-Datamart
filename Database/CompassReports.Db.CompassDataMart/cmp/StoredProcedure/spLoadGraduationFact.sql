CREATE PROCEDURE [cmp].[spLoadGraduationFact] (
	@OdsDatabaseReference nvarchar(512)
	) AS
DECLARE @sqlCmd nvarchar(max)
SET @sqlCmd = 'INSERT INTO [cmp].[GraduationFact]
           ([DemographicKey]
           ,[GraduationStatusKey]
		   ,[SchoolKey]
           ,[SchoolYearKey]
           ,[GraduationStudentCount])

SELECT DemographicId,
	  GraduationStatusKey,
	  SchoolId,
	  SchoolYear,
	  GraduationStudentCount
FROM [' + @OdsDatabaseReference + '].[cmp].[GraduationFact]'

EXEC(@sqlCmd)