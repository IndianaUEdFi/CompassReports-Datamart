CREATE PROCEDURE [cmp].[spLoadSchoolYearDimension] (
	@OdsDatabaseReference nvarchar(512)
	) AS
DECLARE @sqlCmd nvarchar(max)
SET @sqlCmd = 'INSERT INTO [cmp].[SchoolYearDimension]
([SchoolYearKey], 
 [SchoolYearDescription]
)

SELECT [SchoolYear]
	,[SchoolYearDescription] 
FROM [' + @OdsDatabaseReference + '].[cmp].[SchoolYearDimension]	
WHERE [SchoolYear] NOT IN ( SELECT [SchoolYearKey] FROM [cmp].[SchoolYearDimension])'

EXEC(@sqlCmd)
