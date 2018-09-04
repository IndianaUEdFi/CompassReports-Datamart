CREATE PROCEDURE [cmp].[spClearSchoolDataForOds] AS
DELETE 
FROM [$(CompassDataMart)].[cmp].[GraduationFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [cmp].[SchoolDimension])

DELETE 
FROM [$(CompassDataMart)].[cmp].[AssessmentFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [cmp].[SchoolDimension])

DELETE 
FROM [$(CompassDataMart)].[cmp].[AttendanceFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [cmp].[SchoolDimension])

DELETE 
FROM [$(CompassDataMart)].[cmp].[EnrollmentFact]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [cmp].[SchoolDimension])

DELETE 
FROM [$(CompassDataMart)].[cmp].[SchoolDimension]
WHERE [SchoolKey] IN (SELECT [SchoolId] FROM [cmp].[SchoolDimension])