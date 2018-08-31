CREATE PROCEDURE [cmp].[spLoadGraduationFact] AS
INSERT INTO [$(CompassDataMart)].[cmp].[GraduationFact]
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
FROM [cmp].[GraduationFact]