CREATE PROCEDURE [cmp].[spLoadAttendanceFact] (
	@OdsDatabaseReference nvarchar(512)
	) AS
DECLARE @sqlCmd nvarchar(max)
SET @sqlCmd = 'INSERT INTO [cmp].[AttendanceFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[TotalAbsences]
           ,[TotalInstructionalDays])
SELECT [DemographicId]
    ,[SchoolId]
    ,[SchoolYear]
    ,[TotalAbsences]
    ,[TotalInstructionalDays]
FROM [' + @OdsDatabaseReference + '].[cmp].[AttendanceFact]'

EXEC(@sqlCmd)
