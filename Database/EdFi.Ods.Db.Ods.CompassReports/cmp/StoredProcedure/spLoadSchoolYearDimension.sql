CREATE PROCEDURE [cmp].[spLoadSchoolYearDimension] AS
INSERT INTO [$(CompassDataMart)].[cmp].[SchoolYearDimension]
([SchoolYearKey], 
 [SchoolYearDescription]
)

SELECT [SchoolYear]
	,[SchoolYearDescription] 
FROM [cmp].[SchoolYearDimension]	
WHERE [SchoolYear] NOT IN ( SELECT [SchoolYearKey] FROM [$(CompassDataMart)].[cmp].[SchoolYearDimension])