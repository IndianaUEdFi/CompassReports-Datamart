/* STUDENT ENROLLMENT COUNT */
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
FROM [$(OdsDatabaseServer)].[$(OdsDatabaseName)].[cmp].[EnrollmentFact]	

