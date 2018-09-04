CREATE PROCEDURE [cmp].[spLoadAttendanceFact] AS
INSERT INTO [$(CompassDataMart)].[cmp].[AttendanceFact]
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
FROM [cmp].[AttendanceFact]