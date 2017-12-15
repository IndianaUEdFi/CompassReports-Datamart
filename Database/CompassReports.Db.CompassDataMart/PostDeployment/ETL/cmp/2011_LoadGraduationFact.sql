INSERT INTO [CompassDataMart].[cmp].[GraduationFact]
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
FROM [$(OdsDatabaseServer)].[$(OdsDatabaseName)].[cmp].[GraduationFact]