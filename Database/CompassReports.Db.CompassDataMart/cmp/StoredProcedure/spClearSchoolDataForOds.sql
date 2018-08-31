CREATE PROCEDURE [cmp].[spClearSchoolDataForOds] (
	@OdsDatabaseReference nvarchar(512)
	) AS
DECLARE @sqlCmd nvarchar(max)
SET @sqlCmd = '
DELETE 
FROM [cmp].[GraduationFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [' + @OdsDatabaseReference + '].[cmp].[SchoolDimension])

DELETE 
FROM [cmp].[AssessmentFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [' + @OdsDatabaseReference + '].[cmp].[SchoolDimension])

DELETE 
FROM [cmp].[AttendanceFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [' + @OdsDatabaseReference + '].[cmp].[SchoolDimension])

DELETE 
FROM [cmp].[EnrollmentFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [' + @OdsDatabaseReference + '].[cmp].[SchoolDimension])

DELETE 
FROM [cmp].[SchoolDimension]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [' + @OdsDatabaseReference + '].[cmp].[SchoolDimension])'

EXEC(@sqlCmd)