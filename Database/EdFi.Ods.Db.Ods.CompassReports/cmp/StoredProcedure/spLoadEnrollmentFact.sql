CREATE PROCEDURE [cmp].[spLoadEnrollmentFact] AS 
INSERT INTO [$(CompassDataMart)].[cmp].[EnrollmentFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[EnrollmentStudentCount]
		   )

SELECT  [DemographicId]
	,[SchoolId]
	,[SchoolYear]
	,[EnrollmentCount]
FROM [cmp].[EnrollmentFact]	

